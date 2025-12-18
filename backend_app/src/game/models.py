from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, Boolean, ForeignKey, Enum as SQLEnum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum

from src.database import Base


class Messages(Base):
    __tablename__ = "messages"

    id = Column(Integer, primary_key=True)
    message = Column(String)


class GameRoomStatus(enum.Enum):
    WAITING = "waiting"
    IN_PROGRESS = "in_progress"
    FINISHED = "finished"


class RpsChoice(enum.Enum):
    ROCK = "rock"
    PAPER = "paper"
    SCISSORS = "scissors"


class GameRoom(Base):
    __tablename__ = "game_rooms"

    id = Column(Integer, primary_key=True, index=True)
    room_code = Column(String, unique=True, index=True, nullable=False)
    status = Column(SQLEnum(GameRoomStatus), default=GameRoomStatus.WAITING)
    game_mode = Column(String, nullable=False)  # "classical" or "rps"
    # Timer fields (in seconds)
    light_player_time = Column(Integer, default=600)  # 10 minutes = 600 seconds
    dark_player_time = Column(Integer, default=600)  # 10 minutes = 600 seconds
    current_turn_started_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    players = relationship("GamePlayer", back_populates="room", cascade="all, delete-orphan")
    moves = relationship("GameMove", back_populates="room", cascade="all, delete-orphan")
    rps_rounds = relationship("RpsRound", back_populates="room", cascade="all, delete-orphan")


class GamePlayer(Base):
    __tablename__ = "game_players"

    id = Column(Integer, primary_key=True, index=True)
    room_id = Column(Integer, ForeignKey("game_rooms.id", ondelete="CASCADE"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=True)
    player_side = Column(String, nullable=False)  # "light" or "dark"
    is_connected = Column(Boolean, default=True)
    joined_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    room = relationship("GameRoom", back_populates="players")


class GameMove(Base):
    __tablename__ = "game_moves"

    id = Column(Integer, primary_key=True, index=True)
    room_id = Column(Integer, ForeignKey("game_rooms.id", ondelete="CASCADE"), nullable=False)
    player_id = Column(Integer, ForeignKey("game_players.id", ondelete="CASCADE"), nullable=False)
    move_notation = Column(String, nullable=False)  # e.g., "e2e4"
    move_number = Column(Integer, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    room = relationship("GameRoom", back_populates="moves")
    player = relationship("GamePlayer", backref="moves")


class RpsRound(Base):
    __tablename__ = "rps_rounds"

    id = Column(Integer, primary_key=True, index=True)
    room_id = Column(Integer, ForeignKey("game_rooms.id", ondelete="CASCADE"), nullable=False)
    round_number = Column(Integer, nullable=False)
    player1_id = Column(Integer, ForeignKey("game_players.id", ondelete="CASCADE"), nullable=False)
    player2_id = Column(Integer, ForeignKey("game_players.id", ondelete="CASCADE"), nullable=False)
    player1_choice = Column(SQLEnum(RpsChoice), nullable=True)
    player2_choice = Column(SQLEnum(RpsChoice), nullable=True)
    winner_id = Column(Integer, ForeignKey("game_players.id", ondelete="CASCADE"), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    completed_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    room = relationship("GameRoom", back_populates="rps_rounds")
    player1 = relationship("GamePlayer", foreign_keys=[player1_id], backref="rps_rounds_as_player1")
    player2 = relationship("GamePlayer", foreign_keys=[player2_id], backref="rps_rounds_as_player2")
    winner = relationship("GamePlayer", foreign_keys=[winner_id], backref="rps_wins")
