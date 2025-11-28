from datetime import datetime
from pydantic import BaseModel, Field, validator
import re


class UserRegister(BaseModel):
    phone_number: str = Field(..., description="User phone number")
    password: str = Field(..., min_length=8, description="User password (minimum 8 characters)")

    @validator('phone_number')
    def validate_phone_number(cls, v):
        # Basic phone number validation (digits only, at least 10 digits)
        cleaned = re.sub(r'[^\d]', '', v)
        if len(cleaned) < 10:
            raise ValueError('Phone number must contain at least 10 digits')
        return cleaned

    @validator('password')
    def validate_password(cls, v):
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters long')
        return v


class UserLogin(BaseModel):
    phone_number: str = Field(..., description="User phone number")
    password: str = Field(..., description="User password")

    @validator('phone_number')
    def validate_phone_number(cls, v):
        cleaned = re.sub(r'[^\d]', '', v)
        if len(cleaned) < 10:
            raise ValueError('Phone number must contain at least 10 digits')
        return cleaned


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: int
    phone_number: str

    class Config:
        orm_mode = True


class UserResponse(BaseModel):
    id: int
    phone_number: str
    is_active: bool
    created_at: datetime

    class Config:
        orm_mode = True




