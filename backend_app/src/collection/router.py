from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, func
from sqlalchemy.orm import selectinload

from src.database import get_async_session
from src.auth.models import User
from src.auth.dependencies import get_current_active_user
from src.collection.models import CollectionItem, UserCollection, CollectionCategory, CollectionRarity
from src.collection.schemas import (
    CollectionItemResponse,
    UserCollectionResponse,
    UserCollectionCreate,
    UserCollectionUpdate,
    CollectionStatsResponse,
    EquipItemRequest,
    CollectionCategory as CategoryEnum,
)

router = APIRouter(
    prefix="/collection",
    tags=["Collection"]
)


@router.get("/items", response_model=List[CollectionItemResponse])
async def get_collection_items(
    category: Optional[CategoryEnum] = None,
    rarity: Optional[CollectionRarity] = None,
    session: AsyncSession = Depends(get_async_session)
):
    """Get all collection items, optionally filtered by category and/or rarity"""
    query = select(CollectionItem)
    
    if category:
        query = query.where(CollectionItem.category == category.value)
    if rarity:
        query = query.where(CollectionItem.rarity == rarity.value)
    
    query = query.order_by(CollectionItem.rarity, CollectionItem.name)
    result = await session.execute(query)
    items = result.scalars().all()
    
    return items


@router.get("/items/{item_id}", response_model=CollectionItemResponse)
async def get_collection_item(
    item_id: int,
    session: AsyncSession = Depends(get_async_session)
):
    """Get a specific collection item by ID"""
    query = select(CollectionItem).where(CollectionItem.id == item_id)
    result = await session.execute(query)
    item = result.scalar_one_or_none()
    
    if not item:
        raise HTTPException(status_code=404, detail="Collection item not found")
    
    return item


@router.get("/my-items", response_model=List[UserCollectionResponse])
async def get_my_collection(
    category: Optional[CategoryEnum] = None,
    owned_only: bool = False,
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """Get current user's collection items"""
    query = select(UserCollection).where(UserCollection.user_id == current_user.id)
    query = query.options(selectinload(UserCollection.item))
    
    if owned_only:
        query = query.where(UserCollection.is_owned == True)
    
    result = await session.execute(query)
    user_collections = result.scalars().all()
    
    # Filter by category if specified
    if category:
        user_collections = [
            uc for uc in user_collections 
            if uc.item.category == category.value
        ]
    
    return user_collections


@router.get("/stats", response_model=CollectionStatsResponse)
async def get_collection_stats(
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """Get collection statistics for current user"""
    # Get all items
    items_query = select(func.count(CollectionItem.id))
    items_result = await session.execute(items_query)
    total_items = items_result.scalar() or 0
    
    # Get owned items
    owned_query = select(func.count(UserCollection.id)).where(
        and_(
            UserCollection.user_id == current_user.id,
            UserCollection.is_owned == True
        )
    )
    owned_result = await session.execute(owned_query)
    owned_items = owned_result.scalar() or 0
    
    # Get equipped items
    equipped_query = select(func.count(UserCollection.id)).where(
        and_(
            UserCollection.user_id == current_user.id,
            UserCollection.is_equipped == True
        )
    )
    equipped_result = await session.execute(equipped_query)
    equipped_items = equipped_result.scalar() or 0
    
    # Get items by category
    category_query = select(
        CollectionItem.category,
        func.count(UserCollection.id)
    ).join(
        UserCollection, CollectionItem.id == UserCollection.item_id
    ).where(
        and_(
            UserCollection.user_id == current_user.id,
            UserCollection.is_owned == True
        )
    ).group_by(CollectionItem.category)
    
    category_result = await session.execute(category_query)
    items_by_category = {str(cat.value): int(count) for cat, count in category_result.all()}
    
    # Initialize all categories to 0 if not present
    for category in CollectionCategory:
        if category.value not in items_by_category:
            items_by_category[category.value] = 0
    
    # Get items by rarity
    rarity_query = select(
        CollectionItem.rarity,
        func.count(UserCollection.id)
    ).join(
        UserCollection, CollectionItem.id == UserCollection.item_id
    ).where(
        and_(
            UserCollection.user_id == current_user.id,
            UserCollection.is_owned == True
        )
    ).group_by(CollectionItem.rarity)
    
    rarity_result = await session.execute(rarity_query)
    items_by_rarity = {str(rarity.value): int(count) for rarity, count in rarity_result.all()}
    
    # Initialize all rarities to 0 if not present
    for rarity in CollectionRarity:
        if rarity.value not in items_by_rarity:
            items_by_rarity[rarity.value] = 0
    
    return CollectionStatsResponse(
        total_items=total_items,
        owned_items=owned_items,
        equipped_items=equipped_items,
        items_by_category=items_by_category,
        items_by_rarity=items_by_rarity,
    )


@router.post("/my-items", response_model=UserCollectionResponse, status_code=status.HTTP_201_CREATED)
async def create_user_collection(
    collection_data: UserCollectionCreate,
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """Create or update a user collection entry"""
    # Check if item exists
    item_query = select(CollectionItem).where(CollectionItem.id == collection_data.item_id)
    item_result = await session.execute(item_query)
    item = item_result.scalar_one_or_none()
    
    if not item:
        raise HTTPException(status_code=404, detail="Collection item not found")
    
    # Check if user collection already exists
    existing_query = select(UserCollection).where(
        and_(
            UserCollection.user_id == current_user.id,
            UserCollection.item_id == collection_data.item_id
        )
    )
    existing_result = await session.execute(existing_query)
    existing = existing_result.scalar_one_or_none()
    
    if existing:
        # Update existing
        for key, value in collection_data.model_dump(exclude_unset=True).items():
            setattr(existing, key, value)
        await session.commit()
        await session.refresh(existing)
        await session.refresh(existing.item)
        return existing
    else:
        # Create new
        user_collection = UserCollection(
            user_id=current_user.id,
            item_id=collection_data.item_id,
            **collection_data.model_dump()
        )
        session.add(user_collection)
        await session.commit()
        await session.refresh(user_collection)
        await session.refresh(user_collection.item)
        return user_collection


@router.put("/my-items/{item_id}", response_model=UserCollectionResponse)
async def update_user_collection(
    item_id: int,
    collection_update: UserCollectionUpdate,
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """Update a user collection entry"""
    query = select(UserCollection).where(
        and_(
            UserCollection.user_id == current_user.id,
            UserCollection.item_id == item_id
        )
    )
    result = await session.execute(query)
    user_collection = result.scalar_one_or_none()
    
    if not user_collection:
        raise HTTPException(status_code=404, detail="User collection entry not found")
    
    update_data = collection_update.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(user_collection, key, value)
    
    await session.commit()
    await session.refresh(user_collection)
    await session.refresh(user_collection.item)
    
    return user_collection


@router.post("/equip", response_model=List[UserCollectionResponse])
async def equip_item(
    equip_request: EquipItemRequest,
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """Equip an item. This will unequip other items in the same category."""
    # Verify item exists and is owned by user
    user_collection_query = select(UserCollection).where(
        and_(
            UserCollection.user_id == current_user.id,
            UserCollection.item_id == equip_request.item_id
        )
    ).options(selectinload(UserCollection.item))
    
    result = await session.execute(user_collection_query)
    user_collection = result.scalar_one_or_none()
    
    if not user_collection:
        raise HTTPException(status_code=404, detail="Collection item not found in your collection")
    
    if not user_collection.is_owned:
        raise HTTPException(status_code=400, detail="Item is not owned")
    
    # Verify item category matches
    if user_collection.item.category != equip_request.category.value:
        raise HTTPException(status_code=400, detail="Item category mismatch")
    
    # Unequip all other items in the same category
    unequip_query = select(UserCollection).join(CollectionItem).where(
        and_(
            UserCollection.user_id == current_user.id,
            CollectionItem.category == equip_request.category.value,
            UserCollection.is_equipped == True,
            UserCollection.item_id != equip_request.item_id
        )
    )
    unequip_result = await session.execute(unequip_query)
    items_to_unequip = unequip_result.scalars().all()
    
    for item in items_to_unequip:
        item.is_equipped = False
    
    # Equip the requested item
    user_collection.is_equipped = True
    
    await session.commit()
    
    # Return all equipped items
    equipped_query = select(UserCollection).where(
        and_(
            UserCollection.user_id == current_user.id,
            UserCollection.is_equipped == True
        )
    ).options(selectinload(UserCollection.item))
    
    equipped_result = await session.execute(equipped_query)
    equipped_items = equipped_result.scalars().all()
    
    return equipped_items


@router.post("/unlock/{item_id}", response_model=UserCollectionResponse)
async def unlock_item(
    item_id: int,
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """Unlock/purchase a collection item for the user"""
    # Get the item
    item_query = select(CollectionItem).where(CollectionItem.id == item_id)
    item_result = await session.execute(item_query)
    item = item_result.scalar_one_or_none()
    
    if not item:
        raise HTTPException(status_code=404, detail="Collection item not found")
    
    # Check if already owned
    existing_query = select(UserCollection).where(
        and_(
            UserCollection.user_id == current_user.id,
            UserCollection.item_id == item_id
        )
    )
    existing_result = await session.execute(existing_query)
    existing = existing_result.scalar_one_or_none()
    
    if existing and existing.is_owned:
        raise HTTPException(status_code=400, detail="Item is already owned")
    
    # TODO: Check user level, coins, etc. and deduct cost
    # For now, just unlock it
    
    if existing:
        existing.is_owned = True
        existing.obtained_at = datetime.utcnow()
        existing.obtained_via = "purchase"
        existing.obtained_cost = item.unlock_price
        await session.commit()
        await session.refresh(existing)
        await session.refresh(existing.item)
        return existing
    else:
        user_collection = UserCollection(
            user_id=current_user.id,
            item_id=item_id,
            is_owned=True,
            is_equipped=False,
            obtained_at=datetime.utcnow(),
            obtained_via="purchase",
            obtained_cost=item.unlock_price,
        )
        session.add(user_collection)
        await session.commit()
        await session.refresh(user_collection)
        await session.refresh(user_collection.item)
        return user_collection

