from datetime import datetime
from typing import Optional, Dict, Any
from pydantic import BaseModel, Field
from enum import Enum


class CollectionCategory(str, Enum):
    PIECES = "pieces"
    BOARDS = "boards"
    AVATARS = "avatars"
    EFFECTS = "effects"


class CollectionRarity(str, Enum):
    COMMON = "common"
    UNCOMMON = "uncommon"
    RARE = "rare"
    EPIC = "epic"
    LEGENDARY = "legendary"


class CollectionItemBase(BaseModel):
    name: str
    description: Optional[str] = None
    category: CollectionCategory
    rarity: CollectionRarity
    icon_name: Optional[str] = None
    color_hex: Optional[str] = None
    is_premium: bool = False
    unlock_level: Optional[int] = None
    unlock_price: Optional[int] = None
    season_id: Optional[int] = None
    item_metadata: Optional[Dict[str, Any]] = None


class CollectionItemCreate(CollectionItemBase):
    pass


class CollectionItemResponse(CollectionItemBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class UserCollectionBase(BaseModel):
    is_owned: bool = False
    is_equipped: bool = False
    obtained_at: Optional[datetime] = None
    obtained_via: Optional[str] = None
    obtained_cost: Optional[int] = None


class UserCollectionCreate(UserCollectionBase):
    item_id: int


class UserCollectionUpdate(BaseModel):
    is_owned: Optional[bool] = None
    is_equipped: Optional[bool] = None
    obtained_via: Optional[str] = None


class UserCollectionResponse(UserCollectionBase):
    id: int
    user_id: int
    item_id: int
    item: CollectionItemResponse
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class CollectionStatsResponse(BaseModel):
    total_items: int
    owned_items: int
    equipped_items: int
    items_by_category: Dict[str, int]
    items_by_rarity: Dict[str, int]


class EquipItemRequest(BaseModel):
    item_id: int
    category: CollectionCategory


class EquipAvatarByIconRequest(BaseModel):
    icon_name: str
    category: CollectionCategory = CollectionCategory.AVATARS

