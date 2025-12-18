from pydantic import BaseModel, Field, validator
from typing import Optional


class UserSettingsBase(BaseModel):
    board_theme: Optional[str] = Field(default="glass_dark", description="Board theme name")
    piece_set: Optional[str] = Field(default="cardinal", description="Piece set name")
    auto_queen: Optional[bool] = Field(default=True, description="Automatically promote to Queen")
    confirm_moves: Optional[bool] = Field(default=False, description="Confirm moves before executing")
    master_volume: Optional[float] = Field(default=0.8, ge=0.0, le=1.0, description="Master volume (0.0 to 1.0)")
    push_notifications: Optional[bool] = Field(default=True, description="Enable push notifications")
    online_status_visible: Optional[bool] = Field(default=True, description="Show online status to others")

    @validator('master_volume')
    def validate_volume(cls, v):
        if v is not None and (v < 0.0 or v > 1.0):
            raise ValueError('Master volume must be between 0.0 and 1.0')
        return v


class UserSettingsUpdate(UserSettingsBase):
    """Schema for updating user settings (all fields optional)"""
    pass


class UserSettingsResponse(UserSettingsBase):
    """Schema for user settings response"""
    user_id: int
    
    class Config:
        from_attributes = True

