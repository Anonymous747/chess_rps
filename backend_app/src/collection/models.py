from datetime import datetime
from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, Enum as SQLEnum, DateTime, JSON, UniqueConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum

from src.database import Base


class CollectionCategory(str, enum.Enum):
    PIECES = "pieces"
    BOARDS = "boards"
    AVATARS = "avatars"
    EFFECTS = "effects"


class CollectionRarity(str, enum.Enum):
    COMMON = "common"
    UNCOMMON = "uncommon"
    RARE = "rare"
    EPIC = "epic"
    LEGENDARY = "legendary"


class CollectionItem(Base):
    __tablename__ = "collection_items"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False, index=True)
    description = Column(String, nullable=True)
    category = Column(SQLEnum(CollectionCategory), nullable=False, index=True)
    rarity = Column(SQLEnum(CollectionRarity), nullable=False, index=True)
    icon_name = Column(String, nullable=True)  # Icon identifier for frontend
    color_hex = Column(String, nullable=True)  # Color in hex format
    
    # Metadata
    is_premium = Column(Boolean, default=False, nullable=False)
    unlock_level = Column(Integer, nullable=True)  # Level required to unlock (if applicable)
    unlock_price = Column(Integer, nullable=True)  # Price in coins/gems if purchasable
    season_id = Column(Integer, nullable=True)  # Season/event this item belongs to
    item_metadata = Column(JSON, nullable=True)  # Additional metadata (e.g., animations, effects)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    user_collections = relationship("UserCollection", back_populates="item", cascade="all, delete-orphan")


class UserCollection(Base):
    __tablename__ = "user_collections"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    item_id = Column(Integer, ForeignKey("collection_items.id", ondelete="CASCADE"), nullable=False, index=True)
    
    # Ownership and status
    is_owned = Column(Boolean, default=False, nullable=False)
    is_equipped = Column(Boolean, default=False, nullable=False)
    obtained_at = Column(DateTime(timezone=True), nullable=True)  # When user obtained the item
    
    # Purchase/obtainment info
    obtained_via = Column(String, nullable=True)  # "purchase", "reward", "level_up", etc.
    obtained_cost = Column(Integer, nullable=True)  # Cost at time of purchase
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    user = relationship("User", back_populates="collections")
    item = relationship("CollectionItem", back_populates="user_collections")

    # Unique constraint: one record per user-item combination
    __table_args__ = (
        UniqueConstraint('user_id', 'item_id', name='uq_user_collection'),
    )

