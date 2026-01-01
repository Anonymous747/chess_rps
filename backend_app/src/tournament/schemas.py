from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel
from enum import Enum


class TournamentStatusEnum(str, Enum):
    REGISTRATION = "registration"
    STARTED = "started"
    FINISHED = "finished"
    CANCELLED = "cancelled"


class TournamentFormatEnum(str, Enum):
    SINGLE_ELIMINATION = "single_elimination"
    DOUBLE_ELIMINATION = "double_elimination"
    SWISS = "swiss"
    ROUND_ROBIN = "round_robin"


class MatchStatusEnum(str, Enum):
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    FINISHED = "finished"
    BYE = "bye"


# Tournament creation/update schemas
class TournamentCreate(BaseModel):
    name: str
    description: Optional[str] = None
    game_mode: str  # "classical" or "rps"
    format: TournamentFormatEnum
    max_participants: int
    min_participants: int = 2
    registration_start: datetime
    registration_end: datetime
    tournament_start: Optional[datetime] = None


class TournamentUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    status: Optional[TournamentStatusEnum] = None


# Response schemas
class TournamentParticipantResponse(BaseModel):
    id: int
    tournament_id: int
    user_id: int
    username: Optional[str] = None  # From user relationship
    tournament_rating: int
    final_place: Optional[int]
    wins: int
    losses: int
    draws: int
    registered_at: datetime

    class Config:
        from_attributes = True


class TournamentMatchResponse(BaseModel):
    id: int
    tournament_id: int
    round_id: Optional[int]
    player1_id: Optional[int]
    player2_id: Optional[int]
    player1_name: Optional[str] = None
    player2_name: Optional[str] = None
    status: MatchStatusEnum
    winner_id: Optional[int]
    game_room_id: Optional[int]
    bracket_position: Optional[int]
    scheduled_start: Optional[datetime]
    started_at: Optional[datetime]
    completed_at: Optional[datetime]
    created_at: datetime

    class Config:
        from_attributes = True


class TournamentRoundResponse(BaseModel):
    id: int
    tournament_id: int
    round_number: int
    round_name: Optional[str]
    is_final: bool
    scheduled_start: Optional[datetime]
    actual_start: Optional[datetime]
    completed_at: Optional[datetime]
    created_at: datetime
    matches: Optional[List[TournamentMatchResponse]] = None

    class Config:
        from_attributes = True


class TournamentResponse(BaseModel):
    id: int
    name: str
    description: Optional[str]
    game_mode: str
    format: TournamentFormatEnum
    status: TournamentStatusEnum
    max_participants: int
    min_participants: int
    creator_id: Optional[int]
    registration_start: datetime
    registration_end: datetime
    tournament_start: Optional[datetime]
    tournament_end: Optional[datetime]
    created_at: datetime
    updated_at: Optional[datetime]
    participant_count: Optional[int] = None
    participants: Optional[List[TournamentParticipantResponse]] = None
    matches: Optional[List[TournamentMatchResponse]] = None
    rounds: Optional[List[TournamentRoundResponse]] = None

    class Config:
        from_attributes = True


class TournamentListResponse(BaseModel):
    id: int
    name: str
    description: Optional[str]
    game_mode: str
    format: TournamentFormatEnum
    status: TournamentStatusEnum
    max_participants: int
    participant_count: Optional[int] = None
    creator_id: Optional[int]
    registration_start: datetime
    registration_end: datetime
    tournament_start: Optional[datetime]
    created_at: datetime

    class Config:
        from_attributes = True


# Tournament rating schemas
class TournamentRatingResponse(BaseModel):
    id: int
    user_id: int
    username: Optional[str] = None
    game_mode: str
    rating: int
    rating_change: int
    tournaments_played: int
    tournaments_won: int
    best_placement: Optional[int]
    total_matches: int
    match_wins: int
    match_losses: int
    match_draws: int
    created_at: datetime
    updated_at: Optional[datetime]

    class Config:
        from_attributes = True


class TournamentLeaderboardEntry(BaseModel):
    rank: int
    user_id: int
    username: str
    rating: int
    tournaments_played: int
    tournaments_won: int
    best_placement: Optional[int]
    total_matches: int
    match_wins: int
    match_losses: int
    match_draws: int
    win_rate: float

    class Config:
        from_attributes = True

