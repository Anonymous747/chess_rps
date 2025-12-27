from datetime import datetime
from sqlalchemy import Column, Integer, String, Boolean, Float, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from typing import TYPE_CHECKING

from src.database import Base

if TYPE_CHECKING:
    from src.auth.models import User


class UserSettings(Base):
    __tablename__ = "user_settings"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False, index=True)
    
    # Gameplay settings
    board_theme = Column(String, default="glass_dark", nullable=False)
    piece_set = Column(String, default="cardinal", nullable=False)
    effect = Column(String, default=None, nullable=True)  # Visual effect name
    auto_queen = Column(Boolean, default=True, nullable=False)
    confirm_moves = Column(Boolean, default=False, nullable=False)
    
    # Audio settings
    master_volume = Column(Float, default=0.8, nullable=False)  # 0.0 to 1.0
    
    # Notification settings
    push_notifications = Column(Boolean, default=True, nullable=False)
    
    # Privacy settings
    online_status_visible = Column(Boolean, default=True, nullable=False)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationship to user (forward reference, will be set up properly)
    user = relationship("User", back_populates="settings")


