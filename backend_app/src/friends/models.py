from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Boolean, Enum as SQLEnum, UniqueConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum

from src.database import Base


class FriendshipStatus(enum.Enum):
    PENDING = "pending"  # Friend request sent, waiting for response
    ACCEPTED = "accepted"  # Friends
    BLOCKED = "blocked"  # One user blocked the other
    DECLINED = "declined"  # Friend request was declined


class Friendship(Base):
    __tablename__ = "friendships"

    id = Column(Integer, primary_key=True, index=True)
    
    # The user who sent the friend request
    requester_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    
    # The user who received the friend request
    addressee_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    
    # Status of the friendship
    status = Column(SQLEnum(FriendshipStatus), default=FriendshipStatus.PENDING, nullable=False, index=True)
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # When the request was accepted (if status is ACCEPTED)
    accepted_at = Column(DateTime(timezone=True), nullable=True)
    
    # Relationships
    requester = relationship("User", foreign_keys=[requester_id], back_populates="friendships_sent")
    addressee = relationship("User", foreign_keys=[addressee_id], back_populates="friendships_received")
    
    # Ensure unique friendship pairs (prevent duplicate requests)
    __table_args__ = (
        UniqueConstraint('requester_id', 'addressee_id', name='unique_friendship_pair'),
        {'extend_existing': True},
    )

