from datetime import datetime, timezone
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, or_, case
from sqlalchemy.orm import selectinload, joinedload

from src.database import get_async_session
from src.auth.models import User
from src.auth.dependencies import get_current_active_user
from src.tournament.models import (
    Tournament, TournamentParticipant, TournamentMatch, TournamentRound, TournamentRating,
    TournamentStatus, TournamentFormat, MatchStatus
)
from src.tournament.schemas import (
    TournamentCreate, TournamentUpdate, TournamentResponse, TournamentListResponse,
    TournamentParticipantResponse, TournamentMatchResponse, TournamentRoundResponse,
    TournamentRatingResponse, TournamentLeaderboardEntry
)

router = APIRouter(
    prefix="/tournaments",
    tags=["Tournaments"]
)

# ELO rating constants for tournament ratings
TOURNAMENT_K_FACTOR = 32
INITIAL_TOURNAMENT_RATING = 1200


def calculate_tournament_elo(player_rating: int, opponent_rating: int, result: str) -> tuple[int, int]:
    """
    Calculate new tournament ELO rating based on match result.
    Returns (new_rating, rating_change)
    
    result: "win" (1.0), "draw" (0.5), "loss" (0.0)
    """
    expected_score = 1 / (1 + 10 ** ((opponent_rating - player_rating) / 400))
    
    if result == "win":
        actual_score = 1.0
    elif result == "draw":
        actual_score = 0.5
    else:  # loss
        actual_score = 0.0
    
    rating_change = int(TOURNAMENT_K_FACTOR * (actual_score - expected_score))
    new_rating = player_rating + rating_change
    
    return new_rating, rating_change


@router.post("", response_model=TournamentResponse, status_code=status.HTTP_201_CREATED)
async def create_tournament(
    tournament_data: TournamentCreate,
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """Create a new tournament"""
    # Validate game mode
    if tournament_data.game_mode not in ["classical", "rps"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="game_mode must be 'classical' or 'rps'"
        )
    
    # Validate registration times
    if tournament_data.registration_end <= tournament_data.registration_start:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="registration_end must be after registration_start"
        )
    
    # Validate participant limits
    if tournament_data.min_participants < 2:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="min_participants must be at least 2"
        )
    
    if tournament_data.max_participants < tournament_data.min_participants:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="max_participants must be >= min_participants"
        )
    
    # Create tournament
    tournament = Tournament(
        name=tournament_data.name,
        description=tournament_data.description,
        game_mode=tournament_data.game_mode,
        format=tournament_data.format,
        status=TournamentStatus.REGISTRATION,
        max_participants=tournament_data.max_participants,
        min_participants=tournament_data.min_participants,
        creator_id=current_user.id,
        registration_start=tournament_data.registration_start,
        registration_end=tournament_data.registration_end,
        tournament_start=tournament_data.tournament_start
    )
    
    session.add(tournament)
    await session.commit()
    await session.refresh(tournament)
    
    # Auto-join creator as participant
    participant = TournamentParticipant(
        tournament_id=tournament.id,
        user_id=current_user.id,
        tournament_rating=INITIAL_TOURNAMENT_RATING
    )
    session.add(participant)
    await session.commit()
    
    # Return tournament with participant count
    query = select(func.count(TournamentParticipant.id)).where(
        TournamentParticipant.tournament_id == tournament.id
    )
    result = await session.execute(query)
    participant_count = result.scalar() or 0
    
    tournament_dict = {
        **{c.name: getattr(tournament, c.name) for c in tournament.__table__.columns},
        "participant_count": participant_count
    }
    
    return TournamentResponse(**tournament_dict)


@router.get("", response_model=List[TournamentListResponse])
async def list_tournaments(
    game_mode: Optional[str] = None,
    status_filter: Optional[str] = None,
    skip: int = 0,
    limit: int = 50,
    session: AsyncSession = Depends(get_async_session)
):
    """List tournaments with optional filters"""
    query = select(Tournament)
    
    if game_mode:
        if game_mode not in ["classical", "rps"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="game_mode must be 'classical' or 'rps'"
            )
        query = query.where(Tournament.game_mode == game_mode)
    
    if status_filter:
        try:
            status_enum = TournamentStatus(status_filter)
            query = query.where(Tournament.status == status_enum)
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid status: {status_filter}"
            )
    
    query = query.order_by(Tournament.created_at.desc()).offset(skip).limit(limit)
    result = await session.execute(query)
    tournaments = result.scalars().all()
    
    # Get participant counts for each tournament
    tournament_list = []
    for tournament in tournaments:
        count_query = select(func.count(TournamentParticipant.id)).where(
            TournamentParticipant.tournament_id == tournament.id
        )
        count_result = await session.execute(count_query)
        participant_count = count_result.scalar() or 0
        
        tournament_dict = {
            **{c.name: getattr(tournament, c.name) for c in tournament.__table__.columns},
            "participant_count": participant_count
        }
        tournament_list.append(TournamentListResponse(**tournament_dict))
    
    return tournament_list


@router.get("/{tournament_id}", response_model=TournamentResponse)
async def get_tournament(
    tournament_id: int,
    session: AsyncSession = Depends(get_async_session)
):
    """Get tournament details"""
    query = select(Tournament).where(Tournament.id == tournament_id)
    result = await session.execute(query)
    tournament = result.scalar_one_or_none()
    
    if not tournament:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Tournament not found"
        )
    
    # Get participant count
    count_query = select(func.count(TournamentParticipant.id)).where(
        TournamentParticipant.tournament_id == tournament.id
    )
    count_result = await session.execute(count_query)
    participant_count = count_result.scalar() or 0
    
    tournament_dict = {
        **{c.name: getattr(tournament, c.name) for c in tournament.__table__.columns},
        "participant_count": participant_count
    }
    
    return TournamentResponse(**tournament_dict)


@router.post("/{tournament_id}/join", response_model=TournamentParticipantResponse)
async def join_tournament(
    tournament_id: int,
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """Join a tournament"""
    # Get tournament
    query = select(Tournament).where(Tournament.id == tournament_id)
    result = await session.execute(query)
    tournament = result.scalar_one_or_none()
    
    if not tournament:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Tournament not found"
        )
    
    # Check if registration is open
    if tournament.status != TournamentStatus.REGISTRATION:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Tournament registration is closed"
        )
    
    # Check registration period
    now = datetime.now(timezone.utc)
    if now < tournament.registration_start or now > tournament.registration_end:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Tournament registration period has not started or has ended"
        )
    
    # Check if already registered
    existing_query = select(TournamentParticipant).where(
        and_(
            TournamentParticipant.tournament_id == tournament_id,
            TournamentParticipant.user_id == current_user.id
        )
    )
    existing_result = await session.execute(existing_query)
    existing_participant = existing_result.scalar_one_or_none()
    
    if existing_participant:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Already registered for this tournament"
        )
    
    # Check if tournament is full
    count_query = select(func.count(TournamentParticipant.id)).where(
        TournamentParticipant.tournament_id == tournament_id
    )
    count_result = await session.execute(count_query)
    participant_count = count_result.scalar() or 0
    
    if participant_count >= tournament.max_participants:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Tournament is full"
        )
    
    # Get or create tournament rating for this game mode
    rating_query = select(TournamentRating).where(
        and_(
            TournamentRating.user_id == current_user.id,
            TournamentRating.game_mode == tournament.game_mode
        )
    )
    rating_result = await session.execute(rating_query)
    tournament_rating = rating_result.scalar_one_or_none()
    
    initial_rating = INITIAL_TOURNAMENT_RATING
    if tournament_rating:
        initial_rating = tournament_rating.rating
    else:
        # Create new tournament rating
        tournament_rating = TournamentRating(
            user_id=current_user.id,
            game_mode=tournament.game_mode,
            rating=INITIAL_TOURNAMENT_RATING
        )
        session.add(tournament_rating)
    
    # Create participant
    participant = TournamentParticipant(
        tournament_id=tournament_id,
        user_id=current_user.id,
        tournament_rating=initial_rating
    )
    
    session.add(participant)
    await session.commit()
    await session.refresh(participant)
    
    participant_dict = {
        **{c.name: getattr(participant, c.name) for c in participant.__table__.columns},
        "username": current_user.profile_name
    }
    
    return TournamentParticipantResponse(**participant_dict)


@router.get("/{tournament_id}/participants", response_model=List[TournamentParticipantResponse])
async def get_tournament_participants(
    tournament_id: int,
    session: AsyncSession = Depends(get_async_session)
):
    """Get all participants in a tournament"""
    query = select(TournamentParticipant).where(
        TournamentParticipant.tournament_id == tournament_id
    ).options(joinedload(TournamentParticipant.tournament))
    
    result = await session.execute(query)
    participants = result.scalars().unique().all()
    
    # Load usernames
    participant_list = []
    for participant in participants:
        user_query = select(User).where(User.id == participant.user_id)
        user_result = await session.execute(user_query)
        user = user_result.scalar_one_or_none()
        username = user.profile_name if user else None
        
        participant_dict = {
            **{c.name: getattr(participant, c.name) for c in participant.__table__.columns},
            "username": username
        }
        participant_list.append(TournamentParticipantResponse(**participant_dict))
    
    return participant_list


@router.get("/ratings/{game_mode}", response_model=List[TournamentLeaderboardEntry])
async def get_tournament_leaderboard(
    game_mode: str,
    limit: int = 100,
    session: AsyncSession = Depends(get_async_session)
):
    """Get tournament rating leaderboard for a specific game mode"""
    if game_mode not in ["classical", "rps"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="game_mode must be 'classical' or 'rps'"
        )
    
    query = select(
        TournamentRating,
        User.profile_name
    ).join(
        User, TournamentRating.user_id == User.id
    ).where(
        TournamentRating.game_mode == game_mode
    ).order_by(
        TournamentRating.rating.desc()
    ).limit(limit)
    
    result = await session.execute(query)
    rows = result.all()
    
    leaderboard = []
    for rank, (rating, username) in enumerate(rows, start=1):
        total_matches = rating.match_wins + rating.match_losses + rating.match_draws
        win_rate = (rating.match_wins / total_matches * 100) if total_matches > 0 else 0.0
        
        leaderboard.append(TournamentLeaderboardEntry(
            rank=rank,
            user_id=rating.user_id,
            username=username,
            rating=rating.rating,
            tournaments_played=rating.tournaments_played,
            tournaments_won=rating.tournaments_won,
            best_placement=rating.best_placement,
            total_matches=total_matches,
            match_wins=rating.match_wins,
            match_losses=rating.match_losses,
            match_draws=rating.match_draws,
            win_rate=round(win_rate, 2)
        ))
    
    return leaderboard


@router.get("/ratings/me/{game_mode}", response_model=TournamentRatingResponse)
async def get_my_tournament_rating(
    game_mode: str,
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """Get current user's tournament rating for a specific game mode"""
    if game_mode not in ["classical", "rps"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="game_mode must be 'classical' or 'rps'"
        )
    
    query = select(TournamentRating).where(
        and_(
            TournamentRating.user_id == current_user.id,
            TournamentRating.game_mode == game_mode
        )
    )
    result = await session.execute(query)
    rating = result.scalar_one_or_none()
    
    if not rating:
        # Create default rating
        rating = TournamentRating(
            user_id=current_user.id,
            game_mode=game_mode,
            rating=INITIAL_TOURNAMENT_RATING
        )
        session.add(rating)
        await session.commit()
        await session.refresh(rating)
    
    rating_dict = {
        **{c.name: getattr(rating, c.name) for c in rating.__table__.columns},
        "username": current_user.profile_name
    }
    
    return TournamentRatingResponse(**rating_dict)

