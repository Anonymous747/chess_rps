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
    EquipAvatarByIconRequest,
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
    
    # Auto-unlock and equip first avatar if user has no avatars
    if category == CategoryEnum.AVATARS or category is None:
        avatar_collections = [uc for uc in user_collections if uc.item.category == CollectionCategory.AVATARS]
        if not avatar_collections:
            # Find first avatar (unlock_level 0)
            first_avatar_query = select(CollectionItem).where(
                and_(
                    CollectionItem.category == CollectionCategory.AVATARS,
                    CollectionItem.unlock_level == 0
                )
            ).order_by(CollectionItem.id).limit(1)
            first_avatar_result = await session.execute(first_avatar_query)
            first_avatar = first_avatar_result.scalar_one_or_none()
            
            if first_avatar:
                # Create user collection entry for first avatar
                user_collection = UserCollection(
                    user_id=current_user.id,
                    item_id=first_avatar.id,
                    is_owned=True,
                    is_equipped=True,  # Auto-equip first avatar
                    obtained_at=datetime.utcnow(),
                    obtained_via="default",
                )
                session.add(user_collection)
                await session.commit()
                await session.refresh(user_collection)
                await session.refresh(user_collection.item)
                
                # Add to result
                user_collections.append(user_collection)
    
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


# Avatar metadata for auto-creation (matches seed_avatars.py)
AVATAR_METADATA = {
    "avatar_1": {"name": "Happy King", "rarity": CollectionRarity.COMMON, "unlock_level": 0},
    "avatar_2": {"name": "Cool Dude", "rarity": CollectionRarity.COMMON, "unlock_level": 0},
    "avatar_3": {"name": "Surprised Player", "rarity": CollectionRarity.COMMON, "unlock_level": 0},
    "avatar_4": {"name": "Laughing Master", "rarity": CollectionRarity.COMMON, "unlock_level": 0},
    "avatar_5": {"name": "Cool Strategist", "rarity": CollectionRarity.COMMON, "unlock_level": 0},
    "avatar_6": {"name": "Happy Cat", "rarity": CollectionRarity.UNCOMMON, "unlock_level": 1},
    "avatar_7": {"name": "Excited Dog", "rarity": CollectionRarity.UNCOMMON, "unlock_level": 2},
    "avatar_8": {"name": "Friendly Bear", "rarity": CollectionRarity.UNCOMMON, "unlock_level": 3},
    "avatar_9": {"name": "Cute Rabbit", "rarity": CollectionRarity.RARE, "unlock_level": 4},
    "avatar_10": {"name": "Sleepy Panda", "rarity": CollectionRarity.RARE, "unlock_level": 5},
    "avatar_11": {"name": "Party Person", "rarity": CollectionRarity.RARE, "unlock_level": 6},
    "avatar_12": {"name": "Wise Owl", "rarity": CollectionRarity.EPIC, "unlock_level": 7},
    "avatar_13": {"name": "Mischievous Monkey", "rarity": CollectionRarity.EPIC, "unlock_level": 8},
    "avatar_14": {"name": "Chess Nerd", "rarity": CollectionRarity.EPIC, "unlock_level": 9},
    "avatar_15": {"name": "Cunning Fox", "rarity": CollectionRarity.LEGENDARY, "unlock_level": 10},
    "avatar_16": {"name": "Epic Champion", "rarity": CollectionRarity.LEGENDARY, "unlock_level": 11},
    "avatar_17": {"name": "Friendly Dragon", "rarity": CollectionRarity.LEGENDARY, "unlock_level": 12},
    "avatar_18": {"name": "Mystical Wizard", "rarity": CollectionRarity.LEGENDARY, "unlock_level": 13},
    "avatar_19": {"name": "Magical Unicorn", "rarity": CollectionRarity.LEGENDARY, "unlock_level": 14},
    "avatar_20": {"name": "Legendary Master", "rarity": CollectionRarity.LEGENDARY, "unlock_level": 15},
}


@router.post("/equip", response_model=List[UserCollectionResponse])
async def equip_item(
    equip_request: EquipItemRequest,
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """Equip an item. This will unequip other items in the same category."""
    # First, get the item to check its properties
    item_query = select(CollectionItem).where(CollectionItem.id == equip_request.item_id)
    item_result = await session.execute(item_query)
    item = item_result.scalar_one_or_none()
    
    if not item:
        raise HTTPException(status_code=404, detail="Collection item not found")
    
    # Verify item category matches
    if item.category != equip_request.category.value:
        raise HTTPException(status_code=400, detail="Item category mismatch")
    
    # Check if user collection entry exists
    user_collection_query = select(UserCollection).where(
        and_(
            UserCollection.user_id == current_user.id,
            UserCollection.item_id == equip_request.item_id
        )
    ).options(selectinload(UserCollection.item))
    
    result = await session.execute(user_collection_query)
    user_collection = result.scalar_one_or_none()
    
    # If user collection doesn't exist, create it (for unlock_level 0 items or if explicitly allowed)
    if not user_collection:
        if item.unlock_level == 0 or item.unlock_level is None:
            # Auto-create and unlock items with unlock_level 0 or None
            user_collection = UserCollection(
                user_id=current_user.id,
                item_id=equip_request.item_id,
                is_owned=True,
                is_equipped=False,
                obtained_at=datetime.utcnow(),
                obtained_via="default",
            )
            session.add(user_collection)
            await session.flush()  # Flush to get the ID
            await session.refresh(user_collection)
            await session.refresh(user_collection.item)
        else:
            raise HTTPException(status_code=400, detail="Item is not owned and cannot be auto-unlocked")
    else:
        # If not owned, check if it should be auto-unlocked (unlock_level 0)
        if not user_collection.is_owned:
            if item.unlock_level == 0 or item.unlock_level is None:
                # Auto-unlock items with unlock_level 0
                user_collection.is_owned = True
                user_collection.obtained_at = datetime.utcnow()
                user_collection.obtained_via = "default"
            else:
                raise HTTPException(status_code=400, detail="Item is not owned")
    
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


@router.post("/equip-avatar-by-icon", response_model=List[UserCollectionResponse])
async def equip_avatar_by_icon(
    equip_request: EquipAvatarByIconRequest,
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """Equip an avatar by icon_name. Auto-creates the CollectionItem if it doesn't exist."""
    # First, try to find the item by icon_name
    item_query = select(CollectionItem).where(
        and_(
            CollectionItem.category == CollectionCategory.AVATARS,
            CollectionItem.icon_name == equip_request.icon_name
        )
    )
    item_result = await session.execute(item_query)
    item = item_result.scalar_one_or_none()
    
    # If item doesn't exist, create it from metadata
    if not item:
        if equip_request.icon_name not in AVATAR_METADATA:
            raise HTTPException(
                status_code=404, 
                detail=f"Avatar with icon_name '{equip_request.icon_name}' not found and no metadata available"
            )
        
        metadata = AVATAR_METADATA[equip_request.icon_name]
        # Extract avatar index from icon_name (e.g., "avatar_6" -> 6)
        try:
            avatar_index = int(equip_request.icon_name.replace("avatar_", ""))
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid avatar icon_name format")
        
        item = CollectionItem(
            name=metadata["name"],
            description=f"Profile avatar: {metadata['name']}",
            category=CollectionCategory.AVATARS,
            rarity=metadata["rarity"],
            icon_name=equip_request.icon_name,
            is_premium=metadata["rarity"] in [CollectionRarity.EPIC, CollectionRarity.LEGENDARY],
            unlock_level=metadata["unlock_level"],
            unlock_price=None,
            item_metadata={
                "avatar_index": avatar_index,
                "image_path": f"assets/images/avatars/{equip_request.icon_name}.png"
            }
        )
        session.add(item)
        await session.flush()  # Flush to get the ID
        await session.refresh(item)
    
    # Now proceed with equipping (similar to equip_item)
    user_collection_query = select(UserCollection).where(
        and_(
            UserCollection.user_id == current_user.id,
            UserCollection.item_id == item.id
        )
    ).options(selectinload(UserCollection.item))
    
    result = await session.execute(user_collection_query)
    user_collection = result.scalar_one_or_none()
    
    # If user collection doesn't exist, create it
    if not user_collection:
        if item.unlock_level == 0 or item.unlock_level is None:
            user_collection = UserCollection(
                user_id=current_user.id,
                item_id=item.id,
                is_owned=True,
                is_equipped=False,
                obtained_at=datetime.utcnow(),
                obtained_via="default",
            )
            session.add(user_collection)
            await session.flush()
            await session.refresh(user_collection)
            await session.refresh(user_collection.item)
        else:
            # For avatars with unlock_level > 0, check user level
            # For now, allow equipping if user has reached the level
            # TODO: Add user level check here
            user_collection = UserCollection(
                user_id=current_user.id,
                item_id=item.id,
                is_owned=True,
                is_equipped=False,
                obtained_at=datetime.utcnow(),
                obtained_via="default",
            )
            session.add(user_collection)
            await session.flush()
            await session.refresh(user_collection)
            await session.refresh(user_collection.item)
    else:
        # If not owned, auto-unlock if unlock_level is 0
        if not user_collection.is_owned:
            if item.unlock_level == 0 or item.unlock_level is None:
                user_collection.is_owned = True
                user_collection.obtained_at = datetime.utcnow()
                user_collection.obtained_via = "default"
            # For unlock_level > 0, we still allow equipping (user might have reached the level)
            # TODO: Add proper level check
    
    # Unequip all other avatars
    unequip_query = select(UserCollection).join(CollectionItem).where(
        and_(
            UserCollection.user_id == current_user.id,
            CollectionItem.category == CollectionCategory.AVATARS,
            UserCollection.is_equipped == True,
            UserCollection.item_id != item.id
        )
    )
    unequip_result = await session.execute(unequip_query)
    items_to_unequip = unequip_result.scalars().all()
    
    for item_to_unequip in items_to_unequip:
        item_to_unequip.is_equipped = False
    
    # Equip the requested avatar
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
