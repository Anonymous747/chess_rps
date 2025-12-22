from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, func

from src.database import get_async_session
from src.auth.models import User
from src.auth.dependencies import get_current_active_user
from src.stats.models import UserStats
from src.friends.models import Friendship, FriendshipStatus
from src.friends.schemas import (
    FriendRequestCreate,
    FriendRequestResponse,
    FriendInfo,
    FriendRequestInfo,
    SearchUserResponse,
)

router = APIRouter(
    prefix="/friends",
    tags=["Friends"]
)


@router.get("/", response_model=List[FriendInfo])
async def get_my_friends(
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """
    Get all accepted friends of the current user.
    """
    # Get all friendships where user is either requester or addressee and status is ACCEPTED
    query = select(Friendship).where(
        and_(
            or_(
                Friendship.requester_id == current_user.id,
                Friendship.addressee_id == current_user.id
            ),
            Friendship.status == FriendshipStatus.ACCEPTED
        )
    )
    result = await session.execute(query)
    friendships = result.scalars().all()
    
    friends_list = []
    for friendship in friendships:
        # Determine which user is the friend (the other user)
        friend_user_id = friendship.addressee_id if friendship.requester_id == current_user.id else friendship.requester_id
        
        # Get friend user
        user_query = select(User).where(User.id == friend_user_id)
        user_result = await session.execute(user_query)
        friend_user = user_result.scalar_one_or_none()
        
        if not friend_user:
            continue
        
        # Get friend's stats for rating
        stats_query = select(UserStats).where(UserStats.user_id == friend_user_id)
        stats_result = await session.execute(stats_query)
        friend_stats = stats_result.scalar_one_or_none()
        
        friends_list.append(FriendInfo(
            id=friend_user.id,
            user_id=friend_user.id,
            phone_number=friend_user.phone_number,
            rating=friend_stats.rating if friend_stats else None,
            is_online=False,  # TODO: Implement online status tracking
            friendship_id=friendship.id,
            status=friendship.status.value,
            created_at=friendship.created_at,
            accepted_at=friendship.accepted_at,
        ))
    
    return friends_list


@router.get("/requests", response_model=List[FriendRequestInfo])
async def get_friend_requests(
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """
    Get pending friend requests (both sent and received).
    """
    # Get pending requests where user is the addressee (received requests)
    query = select(Friendship).where(
        and_(
            Friendship.addressee_id == current_user.id,
            Friendship.status == FriendshipStatus.PENDING
        )
    )
    result = await session.execute(query)
    received_requests = result.scalars().all()
    
    requests_list = []
    for friendship in received_requests:
        # Get requester user
        requester_query = select(User).where(User.id == friendship.requester_id)
        requester_result = await session.execute(requester_query)
        requester = requester_result.scalar_one_or_none()
        
        if requester:
            requests_list.append(FriendRequestInfo(
                id=friendship.id,
                requester_id=friendship.requester_id,
                addressee_id=friendship.addressee_id,
                requester_phone=requester.phone_number,
                addressee_phone=current_user.phone_number,
                status=friendship.status.value,
                created_at=friendship.created_at,
            ))
    
    return requests_list


@router.post("/requests", response_model=FriendRequestResponse, status_code=status.HTTP_201_CREATED)
async def send_friend_request(
    request_data: FriendRequestCreate,
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """
    Send a friend request to another user.
    """
    # Cannot send request to yourself
    if request_data.addressee_id == current_user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot send friend request to yourself"
        )
    
    # Check if addressee exists
    addressee_query = select(User).where(User.id == request_data.addressee_id)
    addressee_result = await session.execute(addressee_query)
    addressee = addressee_result.scalar_one_or_none()
    
    if not addressee:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    # Check if friendship already exists
    existing_query = select(Friendship).where(
        or_(
            and_(
                Friendship.requester_id == current_user.id,
                Friendship.addressee_id == request_data.addressee_id
            ),
            and_(
                Friendship.requester_id == request_data.addressee_id,
                Friendship.addressee_id == current_user.id
            )
        )
    )
    existing_result = await session.execute(existing_query)
    existing = existing_result.scalar_one_or_none()
    
    if existing:
        if existing.status == FriendshipStatus.ACCEPTED:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Already friends with this user"
            )
        elif existing.status == FriendshipStatus.PENDING:
            if existing.requester_id == current_user.id:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Friend request already sent"
                )
            else:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="This user has already sent you a friend request"
                )
        elif existing.status == FriendshipStatus.BLOCKED:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Cannot send friend request to blocked user"
            )
    
    # Create new friendship request
    friendship = Friendship(
        requester_id=current_user.id,
        addressee_id=request_data.addressee_id,
        status=FriendshipStatus.PENDING
    )
    session.add(friendship)
    await session.commit()
    await session.refresh(friendship)
    
    return FriendRequestResponse(
        id=friendship.id,
        requester_id=friendship.requester_id,
        addressee_id=friendship.addressee_id,
        status=friendship.status.value,
        created_at=friendship.created_at,
        updated_at=friendship.updated_at,
        accepted_at=friendship.accepted_at,
    )


@router.post("/requests/{request_id}/accept", response_model=FriendRequestResponse)
async def accept_friend_request(
    request_id: int,
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """
    Accept a friend request.
    """
    # Get the friendship request
    query = select(Friendship).where(
        and_(
            Friendship.id == request_id,
            Friendship.addressee_id == current_user.id,
            Friendship.status == FriendshipStatus.PENDING
        )
    )
    result = await session.execute(query)
    friendship = result.scalar_one_or_none()
    
    if not friendship:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Friend request not found or already processed"
        )
    
    # Update friendship status
    friendship.status = FriendshipStatus.ACCEPTED
    friendship.accepted_at = datetime.utcnow()
    
    await session.commit()
    await session.refresh(friendship)
    
    return FriendRequestResponse(
        id=friendship.id,
        requester_id=friendship.requester_id,
        addressee_id=friendship.addressee_id,
        status=friendship.status.value,
        created_at=friendship.created_at,
        updated_at=friendship.updated_at,
        accepted_at=friendship.accepted_at,
    )


@router.post("/requests/{request_id}/decline", response_model=FriendRequestResponse)
async def decline_friend_request(
    request_id: int,
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """
    Decline a friend request.
    """
    # Get the friendship request
    query = select(Friendship).where(
        and_(
            Friendship.id == request_id,
            Friendship.addressee_id == current_user.id,
            Friendship.status == FriendshipStatus.PENDING
        )
    )
    result = await session.execute(query)
    friendship = result.scalar_one_or_none()
    
    if not friendship:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Friend request not found or already processed"
        )
    
    # Update friendship status
    friendship.status = FriendshipStatus.DECLINED
    
    await session.commit()
    await session.refresh(friendship)
    
    return FriendRequestResponse(
        id=friendship.id,
        requester_id=friendship.requester_id,
        addressee_id=friendship.addressee_id,
        status=friendship.status.value,
        created_at=friendship.created_at,
        updated_at=friendship.updated_at,
        accepted_at=friendship.accepted_at,
    )


@router.delete("/{friendship_id}", status_code=status.HTTP_204_NO_CONTENT)
async def remove_friend(
    friendship_id: int,
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session)
):
    """
    Remove a friend (delete friendship).
    """
    # Get the friendship
    query = select(Friendship).where(
        and_(
            Friendship.id == friendship_id,
            or_(
                Friendship.requester_id == current_user.id,
                Friendship.addressee_id == current_user.id
            )
        )
    )
    result = await session.execute(query)
    friendship = result.scalar_one_or_none()
    
    if not friendship:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Friendship not found"
        )
    
    # Delete the friendship
    await session.delete(friendship)
    await session.commit()
    
    return None


@router.get("/search", response_model=List[SearchUserResponse])
async def search_users(
    query: str,
    current_user: User = Depends(get_current_active_user),
    session: AsyncSession = Depends(get_async_session),
    limit: int = 20
):
    """
    Search for users by phone number or user ID.
    """
    if not query or len(query) < 3:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Search query must be at least 3 characters"
        )
    
    # Try to parse as user ID first
    try:
        user_id = int(query)
        user_query = select(User).where(User.id == user_id)
    except ValueError:
        # Search by phone number
        user_query = select(User).where(
            User.phone_number.ilike(f"%{query}%")
        ).limit(limit)
    
    result = await session.execute(user_query)
    users = result.scalars().all()
    
    # Exclude current user
    users = [u for u in users if u.id != current_user.id]
    
    search_results = []
    for user in users:
        # Check friendship status
        friendship_query = select(Friendship).where(
            or_(
                and_(
                    Friendship.requester_id == current_user.id,
                    Friendship.addressee_id == user.id
                ),
                and_(
                    Friendship.requester_id == user.id,
                    Friendship.addressee_id == current_user.id
                )
            )
        )
        friendship_result = await session.execute(friendship_query)
        friendship = friendship_result.scalar_one_or_none()
        
        # Get user stats for rating
        stats_query = select(UserStats).where(UserStats.user_id == user.id)
        stats_result = await session.execute(stats_query)
        user_stats = stats_result.scalar_one_or_none()
        
        is_friend = friendship is not None and friendship.status == FriendshipStatus.ACCEPTED
        
        search_results.append(SearchUserResponse(
            id=user.id,
            phone_number=user.phone_number,
            rating=user_stats.rating if user_stats else None,
            is_friend=is_friend,
            friendship_status=friendship.status.value if friendship else None,
            friendship_id=friendship.id if friendship else None,
        ))
    
    return search_results

