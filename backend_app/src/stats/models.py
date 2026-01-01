from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Float
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from src.database import Base


class UserStats(Base):
    __tablename__ = "user_stats"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False, index=True)
    
    # Rating system (ELO-like)
    rating = Column(Integer, default=0, nullable=False)
    rating_change = Column(Integer, default=0)  # Last rating change
    
    # Game statistics
    total_games = Column(Integer, default=0, nullable=False)
    wins = Column(Integer, default=0, nullable=False)
    losses = Column(Integer, default=0, nullable=False)
    draws = Column(Integer, default=0, nullable=False)
    
    # Win rate (calculated, but stored for quick access)
    win_rate = Column(Float, default=0.0, nullable=False)
    
    # Performance metrics
    current_streak = Column(Integer, default=0, nullable=False)  # Can be negative for losing streak
    best_streak = Column(Integer, default=0, nullable=False)
    worst_streak = Column(Integer, default=0, nullable=False)
    
    # Level system
    level = Column(Integer, default=0, nullable=False)  # Current level (starts at 0)
    experience = Column(Integer, default=0, nullable=False)  # Total experience points
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationship to user
    user = relationship("User", back_populates="stats")
    # Relationship to performance history
    performance_history = relationship("PerformanceHistory", back_populates="user_stats", cascade="all, delete-orphan", order_by="PerformanceHistory.created_at.desc()")


class PerformanceHistory(Base):
    __tablename__ = "performance_history"

    id = Column(Integer, primary_key=True, index=True)
    user_stats_id = Column(Integer, ForeignKey("user_stats.id", ondelete="CASCADE"), nullable=False, index=True)
    
    # Rating at this point
    rating = Column(Integer, nullable=False)
    
    # Game result
    result = Column(String, nullable=False)  # "win", "loss", "draw"
    
    # Timestamp
    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)
    
    # Relationship
    user_stats = relationship("UserStats", back_populates="performance_history")

