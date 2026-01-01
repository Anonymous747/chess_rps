from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, Boolean, ForeignKey, Enum as SQLEnum, Text, UniqueConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum

from src.database import Base


class TournamentStatus(enum.Enum):
    REGISTRATION = "registration"  # Accepting participants
    STARTED = "started"  # Tournament in progress
    FINISHED = "finished"  # Tournament completed
    CANCELLED = "cancelled"  # Tournament cancelled


class TournamentFormat(enum.Enum):
    SINGLE_ELIMINATION = "single_elimination"  # Knockout bracket
    DOUBLE_ELIMINATION = "double_elimination"  # Double elimination bracket
    SWISS = "swiss"  # Swiss system
    ROUND_ROBIN = "round_robin"  # Everyone plays everyone


class MatchStatus(enum.Enum):
    PENDING = "pending"  # Not started
    IN_PROGRESS = "in_progress"  # Game in progress
    FINISHED = "finished"  # Game completed
    BYE = "bye"  # Player gets a bye (advances automatically)


class Tournament(Base):
    __tablename__ = "tournaments"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False, index=True)
    description = Column(Text, nullable=True)
    
    # Tournament configuration
    game_mode = Column(String, nullable=False)  # "classical" or "rps"
    format = Column(SQLEnum(TournamentFormat), default=TournamentFormat.SINGLE_ELIMINATION, nullable=False)
    status = Column(SQLEnum(TournamentStatus), default=TournamentStatus.REGISTRATION, nullable=False, index=True)
    
    # Participant limits
    max_participants = Column(Integer, nullable=False)
    min_participants = Column(Integer, default=2, nullable=False)
    
    # Creator/organizer
    creator_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    
    # Timestamps
    registration_start = Column(DateTime(timezone=True), nullable=False)
    registration_end = Column(DateTime(timezone=True), nullable=False)
    tournament_start = Column(DateTime(timezone=True), nullable=True)  # Set when tournament starts
    tournament_end = Column(DateTime(timezone=True), nullable=True)  # Set when tournament ends
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    participants = relationship("TournamentParticipant", back_populates="tournament", cascade="all, delete-orphan")
    matches = relationship("TournamentMatch", back_populates="tournament", cascade="all, delete-orphan")
    rounds = relationship("TournamentRound", back_populates="tournament", cascade="all, delete-orphan")


class TournamentParticipant(Base):
    __tablename__ = "tournament_participants"

    id = Column(Integer, primary_key=True, index=True)
    tournament_id = Column(Integer, ForeignKey("tournaments.id", ondelete="CASCADE"), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    
    # Tournament-specific rating (separate from regular rating)
    tournament_rating = Column(Integer, default=1200, nullable=False)  # Initial rating for this tournament
    
    # Placement in tournament
    final_place = Column(Integer, nullable=True)  # Final ranking (1 = winner, 2 = runner-up, etc.)
    
    # Statistics for this tournament
    wins = Column(Integer, default=0, nullable=False)
    losses = Column(Integer, default=0, nullable=False)
    draws = Column(Integer, default=0, nullable=False)
    
    # Timestamps
    registered_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    tournament = relationship("Tournament", back_populates="participants")
    matches_as_player1 = relationship("TournamentMatch", foreign_keys="TournamentMatch.player1_id", back_populates="player1")
    matches_as_player2 = relationship("TournamentMatch", foreign_keys="TournamentMatch.player2_id", back_populates="player2")
    
    # Unique constraint: one user per tournament
    __table_args__ = (
        UniqueConstraint('tournament_id', 'user_id', name='uq_tournament_participant'),
    )


class TournamentRound(Base):
    __tablename__ = "tournament_rounds"

    id = Column(Integer, primary_key=True, index=True)
    tournament_id = Column(Integer, ForeignKey("tournaments.id", ondelete="CASCADE"), nullable=False, index=True)
    round_number = Column(Integer, nullable=False)  # 1, 2, 3, etc.
    round_name = Column(String, nullable=True)  # "Round 1", "Quarterfinals", "Semifinals", "Finals", etc.
    is_final = Column(Boolean, default=False, nullable=False)  # True for final round
    
    # Timestamps
    scheduled_start = Column(DateTime(timezone=True), nullable=True)
    actual_start = Column(DateTime(timezone=True), nullable=True)
    completed_at = Column(DateTime(timezone=True), nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    tournament = relationship("Tournament", back_populates="rounds")
    matches = relationship("TournamentMatch", back_populates="round")


class TournamentMatch(Base):
    __tablename__ = "tournament_matches"

    id = Column(Integer, primary_key=True, index=True)
    tournament_id = Column(Integer, ForeignKey("tournaments.id", ondelete="CASCADE"), nullable=False, index=True)
    round_id = Column(Integer, ForeignKey("tournament_rounds.id", ondelete="SET NULL"), nullable=True, index=True)
    
    # Players
    player1_id = Column(Integer, ForeignKey("tournament_participants.id", ondelete="CASCADE"), nullable=True)  # Null for bye
    player2_id = Column(Integer, ForeignKey("tournament_participants.id", ondelete="CASCADE"), nullable=True)  # Null for bye
    
    # Match status and result
    status = Column(SQLEnum(MatchStatus), default=MatchStatus.PENDING, nullable=False, index=True)
    winner_id = Column(Integer, ForeignKey("tournament_participants.id", ondelete="SET NULL"), nullable=True)
    
    # Game room reference (if match is in progress)
    game_room_id = Column(Integer, ForeignKey("game_rooms.id", ondelete="SET NULL"), nullable=True)
    
    # Match number in bracket (for bracket visualization)
    bracket_position = Column(Integer, nullable=True)  # Position in bracket tree
    
    # Timestamps
    scheduled_start = Column(DateTime(timezone=True), nullable=True)
    started_at = Column(DateTime(timezone=True), nullable=True)
    completed_at = Column(DateTime(timezone=True), nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    tournament = relationship("Tournament", back_populates="matches")
    round = relationship("TournamentRound", back_populates="matches")
    player1 = relationship("TournamentParticipant", foreign_keys=[player1_id], back_populates="matches_as_player1")
    player2 = relationship("TournamentParticipant", foreign_keys=[player2_id], back_populates="matches_as_player2")
    winner = relationship("TournamentParticipant", foreign_keys=[winner_id])


# Tournament rating table - separate ratings per game mode
class TournamentRating(Base):
    __tablename__ = "tournament_ratings"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    game_mode = Column(String, nullable=False, index=True)  # "classical" or "rps"
    
    # Tournament-specific rating (ELO-like)
    rating = Column(Integer, default=1200, nullable=False)
    rating_change = Column(Integer, default=0)  # Last rating change
    
    # Tournament statistics
    tournaments_played = Column(Integer, default=0, nullable=False)
    tournaments_won = Column(Integer, default=0, nullable=False)
    best_placement = Column(Integer, nullable=True)  # Best final placement (1 = first, 2 = second, etc.)
    
    # Match statistics
    total_matches = Column(Integer, default=0, nullable=False)
    match_wins = Column(Integer, default=0, nullable=False)
    match_losses = Column(Integer, default=0, nullable=False)
    match_draws = Column(Integer, default=0, nullable=False)
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Unique constraint: one rating per user per game mode
    __table_args__ = (
        UniqueConstraint('user_id', 'game_mode', name='uq_tournament_rating'),
    )

