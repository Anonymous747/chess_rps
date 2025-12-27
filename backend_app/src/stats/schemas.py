from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel


class GameResultRequest(BaseModel):
    result: str  # "win", "loss", "draw"
    opponent_rating: Optional[int] = None  # For future ELO calculation
    game_mode: Optional[str] = None  # "classical" or "rps"
    end_type: Optional[str] = None  # "checkmate", "stalemate", "timeout", etc.


class PerformanceHistoryItem(BaseModel):
    id: int
    rating: int
    result: str
    created_at: datetime

    class Config:
        from_attributes = True


class UserStatsResponse(BaseModel):
    id: int
    user_id: int
    rating: int
    rating_change: int
    total_games: int
    wins: int
    losses: int
    draws: int
    win_rate: float
    current_streak: int
    best_streak: int
    worst_streak: int
    level: int
    experience: int
    level_name: Optional[str] = None  # Calculated field
    level_progress: Optional[dict] = None  # Calculated field
    created_at: datetime
    updated_at: Optional[datetime]
    performance_history: Optional[List[PerformanceHistoryItem]] = None

    class Config:
        from_attributes = True


class StatsUpdateResponse(BaseModel):
    success: bool
    message: str
    new_rating: int
    rating_change: int
    xp_gained: int
    level_up: bool = False
    new_level: Optional[int] = None
    new_stats: UserStatsResponse


class LeaderboardEntry(BaseModel):
    rank: int
    user_id: int
    username: str  # profile_name from User
    rating: int
    level: int
    level_name: Optional[str] = None
    total_games: int
    wins: int
    losses: int
    win_rate: float

    class Config:
        from_attributes = True

