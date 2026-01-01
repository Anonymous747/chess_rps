from datetime import datetime, timedelta
from typing import List, Optional, Tuple
import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_

logger = logging.getLogger(__name__)

from src.database import get_async_session
from src.auth.models import User
from src.auth.dependencies import get_current_active_user
from src.stats.models import UserStats, PerformanceHistory
from src.stats.schemas import (
    GameResultRequest,
    UserStatsResponse,
    StatsUpdateResponse,
    PerformanceHistoryItem,
    LeaderboardEntry
)
from src.stats.level_system import (
    calculate_xp_reward,
    calculate_level_from_xp,
    get_level_name,
    get_level_progress
)

router = APIRouter(
    prefix="/stats",
    tags=["Statistics"]
)

# ELO rating constants
K_FACTOR = 32  # Standard K-factor for ELO rating system
INITIAL_RATING = 0  # New users start at 0 rating
PROVISIONAL_RATING_THRESHOLD = 1000  # Below this rating, use provisional multipliers

# Provisional rating multipliers (for players < 1000 rating)
PROVISIONAL_WIN_MULTIPLIER = 2.0  # Wins give 2x points
PROVISIONAL_LOSS_MULTIPLIER = 0.4  # Losses take only 40% of normal points
PROVISIONAL_DRAW_MULTIPLIER = 1.0  # Draws use normal multiplier


def calculate_elo_rating(player_rating: int, opponent_rating: int, result: str) -> Tuple[int, int]:
    """
    Calculate new ELO rating based on game result.
    Uses provisional multipliers for players below 1000 rating.
    Returns (new_rating, rating_change)
    
    result: "win" (1.0), "draw" (0.5), "loss" (0.0)
    """
    # Expected score
    expected_score = 1 / (1 + 10 ** ((opponent_rating - player_rating) / 400))
    
    # Actual score
    if result == "win":
        actual_score = 1.0
    elif result == "draw":
        actual_score = 0.5
    else:  # loss
        actual_score = 0.0
    
    # Calculate base rating change
    rating_change = K_FACTOR * (actual_score - expected_score)
    
    # Apply provisional multipliers for players below 1000 rating
    # This makes wins more rewarding and losses less punishing for new players
    if player_rating < PROVISIONAL_RATING_THRESHOLD:
        if result == "win":
            rating_change *= PROVISIONAL_WIN_MULTIPLIER
        elif result == "loss":
            rating_change *= PROVISIONAL_LOSS_MULTIPLIER
        # Draws use normal multiplier (already 1.0, so no change needed)
    
    # Ensure rating never goes below 0
    rating_change = int(rating_change)
    new_rating = max(0, player_rating + rating_change)
    
    # Adjust rating_change if we capped at 0
    if new_rating == 0 and player_rating + rating_change < 0:
        rating_change = -player_rating
    
    return new_rating, int(rating_change)


@router.get("/me", response_model=UserStatsResponse)
async def get_my_stats(
    include_history: bool = False,
    history_days: int = 30,
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """
    Get current user's statistics.
    Optionally include performance history for the last N days.
    """
    # Get or create user stats
    query = select(UserStats).where(UserStats.user_id == current_user.id)
    result = await session.execute(query)
    user_stats = result.scalar_one_or_none()
    
    if not user_stats:
        # Create default stats for new user
        user_stats = UserStats(
            user_id=current_user.id,
            rating=INITIAL_RATING,
            rating_change=0,
            total_games=0,
            wins=0,
            losses=0,
            draws=0,
            win_rate=0.0,
            current_streak=0,
            best_streak=0,
            worst_streak=0,
            level=0,
            experience=0
        )
        session.add(user_stats)
        await session.commit()
        await session.refresh(user_stats)
    
    # Load performance history if requested
    performance_history = None
    if include_history:
        cutoff_date = datetime.utcnow() - timedelta(days=history_days)
        history_query = select(PerformanceHistory).where(
            and_(
                PerformanceHistory.user_stats_id == user_stats.id,
                PerformanceHistory.created_at >= cutoff_date
            )
        ).order_by(PerformanceHistory.created_at.asc())
        history_result = await session.execute(history_query)
        performance_history = history_result.scalars().all()
    
    # Calculate level information
    level_progress = get_level_progress(user_stats.experience)
    
    # Build response
    response_data = {
        "id": user_stats.id,
        "user_id": user_stats.user_id,
        "rating": user_stats.rating,
        "rating_change": user_stats.rating_change,
        "total_games": user_stats.total_games,
        "wins": user_stats.wins,
        "losses": user_stats.losses,
        "draws": user_stats.draws,
        "win_rate": user_stats.win_rate,
        "current_streak": user_stats.current_streak,
        "best_streak": user_stats.best_streak,
        "worst_streak": user_stats.worst_streak,
        "level": user_stats.level,
        "experience": user_stats.experience,
        "level_name": level_progress["level_name"],
        "level_progress": level_progress,
        "created_at": user_stats.created_at,
        "updated_at": user_stats.updated_at,
    }
    
    if include_history and performance_history:
        response_data["performance_history"] = [
            PerformanceHistoryItem(
                id=h.id,
                rating=h.rating,
                result=h.result,
                created_at=h.created_at
            ) for h in performance_history
        ]
    
    return UserStatsResponse(**response_data)


@router.post("/game-result", response_model=StatsUpdateResponse)
async def record_game_result(
    game_result: GameResultRequest,
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """
    Record a game result and update user statistics.
    This should be called when a game ends (checkmate, stalemate, timeout, etc.)
    """
    try:
        # Get or create user stats
        query = select(UserStats).where(UserStats.user_id == current_user.id)
        result = await session.execute(query)
        user_stats = result.scalar_one_or_none()
        
        if not user_stats:
            # Create default stats for new user
            user_stats = UserStats(
                user_id=current_user.id,
                rating=INITIAL_RATING,
                rating_change=0,
                total_games=0,
                wins=0,
                losses=0,
                draws=0,
                win_rate=0.0,
                current_streak=0,
                best_streak=0,
                worst_streak=0,
                level=0,
                experience=0
            )
            session.add(user_stats)
            await session.flush()  # Flush to get the ID
        
        # Calculate new rating - only for online games (not AI games)
        # AI games should only give XP, not affect rating
        opponent_mode = game_result.opponent_mode or "socket"  # Default to socket for backward compatibility
        is_online_game = opponent_mode == "socket"
        
        # Get opponent rating for XP calculation (use own rating if not provided)
        opponent_rating = game_result.opponent_rating or user_stats.rating
        
        new_rating = user_stats.rating
        rating_change = 0
        
        if is_online_game:
            # Only update rating for online games
            new_rating, rating_change = calculate_elo_rating(
                user_stats.rating,
                opponent_rating,
                game_result.result
            )
            # Update statistics
            user_stats.rating = new_rating
            user_stats.rating_change = rating_change
        else:
            # AI games: keep rating unchanged, rating_change stays 0
            logger.info(f'AI game detected - skipping rating update (only XP will be awarded)')
        
        user_stats.total_games += 1
        
        if game_result.result == "win":
            user_stats.wins += 1
            # Update streak
            if user_stats.current_streak >= 0:
                user_stats.current_streak += 1
            else:
                user_stats.current_streak = 1
            if user_stats.current_streak > user_stats.best_streak:
                user_stats.best_streak = user_stats.current_streak
        elif game_result.result == "loss":
            user_stats.losses += 1
            # Update streak
            if user_stats.current_streak <= 0:
                user_stats.current_streak -= 1
            else:
                user_stats.current_streak = -1
            if user_stats.current_streak < user_stats.worst_streak:
                user_stats.worst_streak = user_stats.current_streak
        else:  # draw
            user_stats.draws += 1
            # Reset streak on draw
            user_stats.current_streak = 0
        
        # Calculate win rate
        if user_stats.total_games > 0:
            user_stats.win_rate = (user_stats.wins / user_stats.total_games) * 100.0
        else:
            user_stats.win_rate = 0.0
        
        # Calculate and award XP
        old_level = user_stats.level
        old_xp = user_stats.experience
        xp_gained = calculate_xp_reward(
            game_result.result,
            user_stats.rating,
            opponent_rating
        )
        user_stats.experience += xp_gained
        
        # Calculate new level from total XP
        new_level, _, _ = calculate_level_from_xp(user_stats.experience)
        user_stats.level = new_level
        level_up = new_level > old_level
        
        # Create performance history entry
        history_entry = PerformanceHistory(
            user_stats_id=user_stats.id,
            rating=new_rating,
            result=game_result.result
        )
        session.add(history_entry)
        
        await session.commit()
        await session.refresh(user_stats)
        
        # Get level progress for response
        level_progress = get_level_progress(user_stats.experience)
        
        # Build response
        return StatsUpdateResponse(
            success=True,
            message="Game result recorded successfully" + (" - Level Up!" if level_up else ""),
            new_rating=new_rating,
            rating_change=rating_change,
            xp_gained=xp_gained,
            level_up=level_up,
            new_level=new_level if level_up else None,
            new_stats=UserStatsResponse(
                id=user_stats.id,
                user_id=user_stats.user_id,
                rating=user_stats.rating,
                rating_change=user_stats.rating_change,
                total_games=user_stats.total_games,
                wins=user_stats.wins,
                losses=user_stats.losses,
                draws=user_stats.draws,
                win_rate=user_stats.win_rate,
                current_streak=user_stats.current_streak,
                best_streak=user_stats.best_streak,
                worst_streak=user_stats.worst_streak,
                level=user_stats.level,
                experience=user_stats.experience,
                level_name=level_progress["level_name"],
                level_progress=level_progress,
                created_at=user_stats.created_at,
                updated_at=user_stats.updated_at,
            )
        )
    except Exception as e:
        logger.error(f"Error recording game result: {e}", exc_info=True)
        await session.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to record game result: {str(e)}"
        )


@router.get("/leaderboard", response_model=List[LeaderboardEntry])
async def get_leaderboard(
    limit: int = 10,
    session: AsyncSession = Depends(get_async_session)
):
    """
    Get top users by rating (leaderboard).
    Returns list of users sorted by rating in descending order.
    """
    # Query top users by rating, joining with User to get profile_name
    query = (
        select(
            UserStats,
            User.profile_name
        )
        .join(User, UserStats.user_id == User.id)
        .order_by(UserStats.rating.desc())
        .limit(limit)
    )
    result = await session.execute(query)
    rows = result.all()
    
    leaderboard = []
    for rank, (user_stats, profile_name) in enumerate(rows, start=1):
        # Get level name
        level_progress = get_level_progress(user_stats.experience)
        level_name = level_progress.get("level_name", "Novice")
        
        leaderboard.append(LeaderboardEntry(
            rank=rank,
            user_id=user_stats.user_id,
            username=profile_name,  # Using profile_name as username
            rating=user_stats.rating,
            level=user_stats.level,
            level_name=level_name,
            total_games=user_stats.total_games,
            wins=user_stats.wins,
            losses=user_stats.losses,
            win_rate=user_stats.win_rate
        ))
    
    return leaderboard

