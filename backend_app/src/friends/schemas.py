from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel
from enum import Enum


class FriendshipStatusEnum(str, Enum):
    PENDING = "pending"
    ACCEPTED = "accepted"
    BLOCKED = "blocked"
    DECLINED = "declined"


class FriendRequestCreate(BaseModel):
    addressee_id: int  # The user ID to send friend request to


class FriendRequestResponse(BaseModel):
    id: int
    requester_id: int
    addressee_id: int
    status: str
    created_at: datetime
    updated_at: Optional[datetime]
    accepted_at: Optional[datetime]

    class Config:
        from_attributes = True


class UserBasicInfo(BaseModel):
    id: int
    phone_number: str
    created_at: datetime

    class Config:
        from_attributes = True


class FriendInfo(BaseModel):
    id: int
    user_id: int
    phone_number: str
    rating: Optional[int] = None
    is_online: bool = False
    friendship_id: int
    status: str
    created_at: datetime
    accepted_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class FriendRequestInfo(BaseModel):
    id: int
    requester_id: int
    addressee_id: int
    requester_phone: str
    addressee_phone: str
    status: str
    created_at: datetime

    class Config:
        from_attributes = True


class SearchUserResponse(BaseModel):
    id: int
    phone_number: str
    rating: Optional[int] = None
    is_friend: bool = False
    friendship_status: Optional[str] = None
    friendship_id: Optional[int] = None

    class Config:
        from_attributes = True

