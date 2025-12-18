from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from src.database import get_async_session
from src.auth.models import User
from src.auth.settings_models import UserSettings
from src.auth.settings_schemas import UserSettingsResponse, UserSettingsUpdate
from src.auth.dependencies import get_current_active_user

router = APIRouter(
    prefix="/auth/settings",
    tags=["Settings"]
)


async def get_or_create_user_settings(user: User, session: AsyncSession) -> UserSettings:
    """Get user settings or create default settings if they don't exist"""
    query = select(UserSettings).where(UserSettings.user_id == user.id)
    result = await session.execute(query)
    settings = result.scalar_one_or_none()
    
    if not settings:
        # Create default settings
        settings = UserSettings(user_id=user.id)
        session.add(settings)
        await session.commit()
        await session.refresh(settings)
    
    return settings


@router.get("", response_model=UserSettingsResponse, status_code=status.HTTP_200_OK)
async def get_user_settings(
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """
    Get current user's settings.
    Creates default settings if they don't exist.
    """
    settings = await get_or_create_user_settings(current_user, session)
    return settings


@router.put("", response_model=UserSettingsResponse, status_code=status.HTTP_200_OK)
async def update_user_settings(
    settings_update: UserSettingsUpdate,
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """
    Update current user's settings.
    Only provided fields will be updated.
    """
    settings = await get_or_create_user_settings(current_user, session)
    
    # Update only provided fields
    update_data = settings_update.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(settings, field, value)
    
    await session.commit()
    await session.refresh(settings)
    
    return settings

