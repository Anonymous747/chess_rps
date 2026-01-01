import json
import uuid
from datetime import datetime, timezone
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select, insert, func, and_, or_
from sqlalchemy.ext.asyncio import AsyncSession
from starlette.websockets import WebSocket, WebSocketDisconnect

from src.database import get_async_session, async_session_maker
from src.game.models import Messages, GameRoom, GamePlayer, GameMove, RpsRound, RpsChoice as RpsChoiceModel, GameRoomStatus
from src.game.schemas import (
    MessagesModel, 
    GameRoomCreate, 
    GameRoomResponse,
    GameMoveCreate,
    GameMoveResponse,
    RpsChoiceRequest,
    RpsChoiceEnum,
    RpsRoundResponse,
    WebSocketMessage,
    Connection
)
from src.game.room_manager import room_manager

router = APIRouter(
    prefix="/game",
    tags=["Game"]
)


@router.get("/last_messages")
async def get_last_messages(
        session: AsyncSession = Depends(get_async_session),
) -> List[MessagesModel]:
    query = select(Messages).order_by(Messages.id.desc()).limit(5)
    messages = await session.execute(query)
    return messages.scalars().all()


@router.post("/rooms", response_model=GameRoomResponse, status_code=status.HTTP_201_CREATED)
async def create_room(
    room_data: GameRoomCreate,
    session: AsyncSession = Depends(get_async_session)
):
    """Create a new game room"""
    room = await room_manager.create_room(session, room_data.game_mode)
    return room


@router.post("/rooms/matchmake", response_model=GameRoomResponse)
async def matchmake(
    room_data: GameRoomCreate,
    session: AsyncSession = Depends(get_async_session)
):
    """Find a waiting room or create a new one for matchmaking.
    Uses SELECT FOR UPDATE SKIP LOCKED to atomically claim slots and prevent race conditions."""
    import logging
    logger = logging.getLogger(__name__)
    
    try:
        # STEP 1: First, check for existing waiting rooms with available slots
        # Use SELECT FOR UPDATE SKIP LOCKED to atomically lock and claim a waiting room
        # This prevents race conditions where multiple users try to join the same room simultaneously
        # Order by created_at ASC to match oldest waiting room first (FIFO)
        logger.info(f"🔍 [MATCHMAKE] Starting matchmaking for game_mode: {room_data.game_mode}")
        
        max_retries = 2
        created_room = None  # Store room created on first attempt in case we need to return it
        created_room_id = None  # Track the room ID we created to avoid matching to it
        
        for attempt in range(max_retries):
            logger.info(f"🔍 [MATCHMAKE] Attempt {attempt + 1}/{max_retries}: Checking for available WAITING rooms...")
            
            # CRITICAL: Query ONLY for WAITING rooms (exclude IN_PROGRESS and other statuses)
            # We lock rooms first, then check player count to ensure atomicity
            # Note: We can't use GROUP BY with FOR UPDATE, so we check counts separately
            # Exclude the room we just created (if any) from the query to avoid matching to our own room
            query_conditions = [
                GameRoom.status == GameRoomStatus.WAITING,
                GameRoom.game_mode == room_data.game_mode
            ]
            if created_room_id is not None:
                # Exclude the room we just created - we want to match to OTHER users' rooms
                query_conditions.append(GameRoom.id != created_room_id)
                logger.info(f"🔍 [MATCHMAKE] Excluding our own room (id: {created_room_id}) from search")
            
            query = select(GameRoom).where(
                and_(*query_conditions)
            ).order_by(GameRoom.created_at.asc()).with_for_update(skip_locked=True)
            
            result = await session.execute(query)
            waiting_rooms = result.scalars().all()
            
            logger.info(f"✅ [MATCHMAKE] Query returned {len(waiting_rooms)} waiting room(s) (status=WAITING, game_mode={room_data.game_mode})")
            
            # Try each locked room to see if it has space
            # Since room is locked, we can safely check and update player count
            available_room_found = False
            for waiting_room in waiting_rooms:
                # Skip our own room (double-check, though it should be filtered in query)
                if created_room_id is not None and waiting_room.id == created_room_id:
                    logger.info(f"🔍 [MATCHMAKE] Skipping our own room {waiting_room.room_code}")
                    continue
                
                # Refresh room to ensure we have latest status
                await session.refresh(waiting_room)
                
                # Double-check room status (should already be WAITING from query, but be safe)
                if waiting_room.status != GameRoomStatus.WAITING:
                    logger.warning(f"⚠️ [MATCHMAKE] Room {waiting_room.room_code} status changed to {waiting_room.status}, skipping")
                    continue
                
                # Count players in this room (room is locked, so safe to check atomically)
                players_count_query = select(func.count(GamePlayer.id)).where(
                    GamePlayer.room_id == waiting_room.id
                )
                count_result = await session.execute(players_count_query)
                players_count = count_result.scalar() or 0
                
                logger.info(f"🔍 [MATCHMAKE] Checking room {waiting_room.room_code}: {players_count} player(s), status: {waiting_room.status.value}")
                
                # CRITICAL: Only proceed if room has less than 2 players
                if players_count >= 2:
                    logger.warning(f"❌ [MATCHMAKE] Room {waiting_room.room_code} is FULL ({players_count} players), skipping")
                    continue
                
                available_room_found = True
                logger.info(f"✅ [MATCHMAKE] Found AVAILABLE room {waiting_room.room_code} with {players_count} player(s), attempting to join...")
                
                # Found a waiting room with space - create a placeholder player to reserve the slot
                # This prevents other matchmake calls from claiming the same slot
                # The player will be properly updated when WebSocket connects
                player_side = "light" if players_count == 0 else "dark"
                placeholder_player = GamePlayer(
                    room_id=waiting_room.id,
                    user_id=None,  # Will be set when WebSocket connects (if authenticated)
                    player_side=player_side,
                    is_connected=False,  # Will be set to True when WebSocket connects
                )
                session.add(placeholder_player)
                await session.flush()
                
                # Update room status if second player joins
                if players_count == 1:
                    waiting_room.status = GameRoomStatus.IN_PROGRESS
                    logger.info(f"✅ [MATCHMAKE] Room {waiting_room.room_code} is now FULL (2 players), updating status to IN_PROGRESS")
                
                await session.commit()
                await session.refresh(waiting_room)
                
                logger.info(f"🎉 [MATCHMAKE] SUCCESS: Matched user to existing room {waiting_room.room_code} (now has {players_count + 1} players, status: {waiting_room.status.value})")
                return GameRoomResponse(
                    id=waiting_room.id,
                    room_code=waiting_room.room_code,
                    status=waiting_room.status.value,
                    game_mode=waiting_room.game_mode,
                    light_player_time=waiting_room.light_player_time,
                    dark_player_time=waiting_room.dark_player_time,
                    current_turn_started_at=waiting_room.current_turn_started_at,
                    created_at=waiting_room.created_at,
                )
            
            # STEP 2: No available waiting room found - create a new one (only on first attempt)
            if not available_room_found:
                logger.info(f"❌ [MATCHMAKE] No available waiting room found on attempt {attempt + 1}")
            
            if attempt == 0 and not available_room_found:
                logger.info(f"🆕 [MATCHMAKE] Creating NEW room (no available rooms found)...")
                room_code = str(uuid.uuid4())[:8].upper()
                
                room = GameRoom(
                    room_code=room_code,
                    status=GameRoomStatus.WAITING,
                    game_mode=room_data.game_mode
                )
                session.add(room)
                await session.flush()  # Flush to get room.id
                
                # Create first player slot for this user (reserved but not connected yet)
                first_player = GamePlayer(
                    room_id=room.id,
                    user_id=None,  # Will be set when WebSocket connects (if authenticated)
                    player_side="light",
                    is_connected=False,  # Will be set to True when WebSocket connects
                )
                session.add(first_player)
                await session.commit()
                await session.refresh(room)
                
                created_room = room  # Store for potential return
                created_room_id = room.id  # Track the room ID we created to exclude it from retry searches
                logger.info(f"✅ [MATCHMAKE] Created new waiting room {room.room_code} (id: {room.id}, game_mode: {room.game_mode}, status: WAITING)")
                
                # If we have retries left, wait a bit and try again to catch concurrent rooms
                if attempt < max_retries - 1:
                    # Small delay to allow concurrent commits to be visible
                    import asyncio
                    logger.info(f"⏳ [MATCHMAKE] Waiting 100ms before retry to catch concurrent room creations...")
                    await asyncio.sleep(0.1)  # 100ms delay
                    continue  # Retry the query
        
        # After all retries, return the room we created (if any)
        if created_room:
            logger.info(f"📤 [MATCHMAKE] Returning created room {created_room.room_code} after {max_retries} attempts (no match found)")
            return GameRoomResponse(
                id=created_room.id,
                room_code=created_room.room_code,
                status=created_room.status.value,
                game_mode=created_room.game_mode,
                light_player_time=created_room.light_player_time,
                dark_player_time=created_room.dark_player_time,
                current_turn_started_at=created_room.current_turn_started_at,
                created_at=created_room.created_at,
            )
        
        # Should not reach here, but just in case
        raise HTTPException(status_code=500, detail="Matchmaking failed after retries")
        
    except Exception as e:
        await session.rollback()
        logger.error(f"Error in matchmake endpoint: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Matchmaking error: {str(e)}")


@router.get("/rooms/available", response_model=Optional[GameRoomResponse])
async def check_available_room(
    game_mode: str,
    session: AsyncSession = Depends(get_async_session)
):
    """Check if there's an available waiting room for matchmaking (without creating one)"""
    import logging
    logger = logging.getLogger(__name__)
    
    try:
        # Query for waiting rooms with available slots
        query = select(GameRoom).where(
            and_(
                GameRoom.status == GameRoomStatus.WAITING,
                GameRoom.game_mode == game_mode
            )
        ).order_by(GameRoom.created_at.asc())
        
        result = await session.execute(query)
        waiting_rooms = result.scalars().all()
        
        logger.info(f"🔍 [CHECK_AVAILABLE] Query found {len(waiting_rooms)} waiting room(s)")
        
        # Check each room for available slots (same logic as matchmake for consistency)
        for room in waiting_rooms:
            # Refresh room to ensure we have latest status from database
            # This is critical to see rooms that were just created/updated by other requests
            await session.refresh(room)
            
            # Double-check room status (may have changed since query due to race conditions)
            if room.status != GameRoomStatus.WAITING:
                logger.debug(f"🔍 [CHECK_AVAILABLE] Room {room.room_code} is not WAITING (status: {room.status}), skipping")
                continue
            
            # Count players in this room (use same query as matchmake)
            players_count_query = select(func.count(GamePlayer.id)).where(
                GamePlayer.room_id == room.id
            )
            count_result = await session.execute(players_count_query)
            players_count = count_result.scalar() or 0
            
            logger.info(f"🔍 [CHECK_AVAILABLE] Room {room.room_code}: {players_count} player(s), status: {room.status.value}")
            
            # Only return room if it has less than 2 players (same logic as matchmake)
            if players_count < 2:
                logger.info(f"✅ [CHECK_AVAILABLE] Found available room: {room.room_code} with {players_count} player(s)")
                return GameRoomResponse(
                    id=room.id,
                    room_code=room.room_code,
                    status=room.status.value,
                    game_mode=room.game_mode,
                    light_player_time=room.light_player_time,
                    dark_player_time=room.dark_player_time,
                    current_turn_started_at=room.current_turn_started_at,
                    created_at=room.created_at,
                )
            else:
                logger.debug(f"🔍 [CHECK_AVAILABLE] Room {room.room_code} is full ({players_count} players), skipping")
        
        logger.info(f"❌ [CHECK_AVAILABLE] No available rooms found")
        return None
        
    except Exception as e:
        logger.error(f"Error checking available rooms: {e}", exc_info=True)
        return None


@router.get("/rooms/{room_code}", response_model=GameRoomResponse)
async def get_room(
    room_code: str,
    session: AsyncSession = Depends(get_async_session)
):
    """Get room information"""
    query = select(GameRoom).where(GameRoom.room_code == room_code)
    result = await session.execute(query)
    room = result.scalar_one_or_none()
    
    if not room:
        raise HTTPException(status_code=404, detail="Room not found")
    
    return room


@router.websocket("/ws/{room_code}")
async def websocket_endpoint(websocket: WebSocket, room_code: str):
    """WebSocket endpoint for game communication"""
    import logging
    logger = logging.getLogger(__name__)
    
    try:
        logger.info(f"WebSocket connection attempt for room: {room_code}")
        await websocket.accept()
        logger.info(f"WebSocket accepted for room: {room_code}")
        
        # Get database session
        async with async_session_maker() as session:
            # Find the room
            query = select(GameRoom).where(GameRoom.room_code == room_code)
            result = await session.execute(query)
            room = result.scalar_one_or_none()
            
            if not room:
                logger.warning(f"Room not found: {room_code}")
                await websocket.send_text(json.dumps({
                    "type": "error",
                    "message": "Room not found"
                }))
                await websocket.close()
                return
            
            # Find existing placeholder player for this room (created during matchmaking)
            # OR find a disconnected player trying to reconnect
            # Priority: 1) Disconnected placeholder, 2) Any disconnected player in this room
            players_query = select(GamePlayer).where(
                and_(
                    GamePlayer.room_id == room.id,
                    GamePlayer.is_connected == False
                )
            ).order_by(GamePlayer.id.asc()).limit(1)
            players_result = await session.execute(players_query)
            player = players_result.scalar_one_or_none()
            
            if not player:
                # Check if room already has 2 players (counting all players, not just connected ones)
                all_players_query = select(func.count(GamePlayer.id)).where(
                    GamePlayer.room_id == room.id
                )
                count_result = await session.execute(all_players_query)
                player_count = count_result.scalar() or 0
                
                # Check if room has 2 connected players already (room is truly full and active)
                connected_players_query = select(func.count(GamePlayer.id)).where(
                    and_(
                        GamePlayer.room_id == room.id,
                        GamePlayer.is_connected == True
                    )
                )
                connected_count_result = await session.execute(connected_players_query)
                connected_count = connected_count_result.scalar() or 0
                
                # Only reject if there are 2 connected players (room is active and full)
                if connected_count >= 2:
                    logger.warning(f"Room {room_code} is full (has {connected_count} connected players)")
                    await websocket.send_text(json.dumps({
                        "type": "error",
                        "message": "Room is full"
                    }))
                    await websocket.close()
                    return
                
                # If room has 2 total players but less than 2 connected, check if we can reconnect
                # This handles the case where a player disconnected and is reconnecting
                if player_count >= 2 and connected_count < 2:
                    # Find any disconnected player in the room (for reconnection)
                    reconnect_query = select(GamePlayer).where(
                        and_(
                            GamePlayer.room_id == room.id,
                            GamePlayer.is_connected == False
                        )
                    ).order_by(GamePlayer.id.asc()).limit(1)
                    reconnect_result = await session.execute(reconnect_query)
                    player = reconnect_result.scalar_one_or_none()
                    
                    if player:
                        logger.info(f"Player {player.id} reconnecting to room {room_code}")
                        # Update existing player to connected
                        player.is_connected = True
                    else:
                        # This shouldn't happen, but handle it gracefully
                        logger.warning(f"Room {room_code} has {player_count} players but none are disconnected. This is unexpected.")
                        await websocket.send_text(json.dumps({
                            "type": "error",
                            "message": "Room is full"
                        }))
                        await websocket.close()
                        return
                else:
                    # Create new player (room has less than 2 players)
                    player_side = "light" if player_count == 0 else "dark"
                    player = GamePlayer(
                        room_id=room.id,
                        user_id=None,
                        player_side=player_side,
                        is_connected=True,
                    )
                    session.add(player)
                    logger.info(f"Created new player for room {room_code} with side {player_side}")
            else:
                # Update existing placeholder/disconnected player
                logger.info(f"Found existing player {player.id} (disconnected) for room {room_code}, updating to connected")
                player.is_connected = True
            
            # Count connected players BEFORE adding to room_manager to determine if this is the second player
            players_count_query = select(func.count(GamePlayer.id)).where(
                and_(
                    GamePlayer.room_id == room.id,
                    GamePlayer.is_connected == True
                )
            )
            connected_count_result = await session.execute(players_count_query)
            connected_count_before_commit = connected_count_result.scalar() or 0
            
            # Update room status if second player joins
            if connected_count_before_commit >= 2 and room.status == GameRoomStatus.WAITING:
                room.status = GameRoomStatus.IN_PROGRESS
                logger.info(f"Room {room_code} is now full (2 players connected), updating status to IN_PROGRESS")
            
            await session.commit()
            await session.refresh(room)
            await session.refresh(player)
            
            # Add connection to room_manager AFTER commit
            connection = Connection(room.id, websocket, player.id)
            room_manager.connections[websocket] = connection
            
            if room.id not in room_manager.room_connections:
                room_manager.room_connections[room.id] = []
            room_manager.room_connections[room.id].append(connection)
            
            # Check if this is the second player AFTER adding to room_manager
            current_connections_count = len(room_manager.room_connections.get(room.id, []))
            is_second_player = (current_connections_count == 2)
            
            logger.info(f"Player connected to room {room_code}: {connected_count_before_commit} DB players, {current_connections_count} WebSocket connections")
            
            # Send room info with timer and player side to the current player
            await websocket.send_text(json.dumps({
                "type": "room_joined",
                "room_code": room.room_code,
                "game_mode": room.game_mode,
                "status": room.status.value,
                "player_side": player.player_side,  # Send the assigned player side
                "light_player_time": room.light_player_time,
                "dark_player_time": room.dark_player_time,
                "current_turn_started_at": room.current_turn_started_at.isoformat() if room.current_turn_started_at else None
            }))
            
            # If second player just joined, notify ALL players (including the one who just joined)
            # that the game is starting
            if is_second_player:
                logger.info(f"🎮 Second player joined room {room_code}, notifying ALL players that game is starting")
                
                # Get opponent info for each player
                # Query all players in room to get opponent info
                all_players_query = select(GamePlayer).where(GamePlayer.room_id == room.id)
                all_players_result = await session.execute(all_players_query)
                all_players = all_players_result.scalars().all()
                
                # Send to all connections (including the current one)
                for conn in room_manager.room_connections.get(room.id, []):
                    try:
                        # Find opponent for this connection
                        current_player_id = conn.playerId
                        opponent_player = next((p for p in all_players if p.id != current_player_id), None)
                        
                        opponent_info = None
                        if opponent_player and opponent_player.user_id:
                            # Import here to avoid circular dependencies
                            from src.auth.models import User
                            from src.collection.models import UserCollection, CollectionItem
                            
                            # Query opponent user and their equipped avatar
                            opponent_user_query = select(User).where(User.id == opponent_player.user_id)
                            opponent_user_result = await session.execute(opponent_user_query)
                            opponent_user = opponent_user_result.scalar_one_or_none()
                            
                            if opponent_user:
                                # Get equipped avatar
                                avatar_query = (
                                    select(CollectionItem.icon_name)
                                    .join(UserCollection, UserCollection.item_id == CollectionItem.id)
                                    .where(
                                        and_(
                                            UserCollection.user_id == opponent_user.id,
                                            UserCollection.is_equipped == True,
                                            CollectionItem.category == "avatars"
                                        )
                                    )
                                )
                                avatar_result = await session.execute(avatar_query)
                                avatar_icon = avatar_result.scalar_one_or_none()
                                
                                opponent_info = {
                                    "user_id": opponent_user.id,
                                    "username": opponent_user.profile_name,  # Use profile_name instead of username
                                    "avatar_icon": avatar_icon if avatar_icon else "avatar_3"  # Default avatar
                                }
                        
                        player_joined_message = json.dumps({
                            "type": "player_joined",
                            "room_code": room.room_code,
                            "status": room.status.value,
                            "opponent": opponent_info  # Include opponent info if available
                        })
                        await conn.socket.send_text(player_joined_message)
                        logger.info(f"Sent player_joined message to player in room {room_code} with opponent info")
                    except Exception as e:
                        logger.warning(f"Failed to send player_joined to connection: {e}")
            else:
                # First player joined - just log
                logger.info(f"First player joined room {room_code}, waiting for second player")
            
            try:
                while True:
                    data = await websocket.receive_text()
                    message = json.loads(data)
                    message_type = message.get("type")
                    
                    if message_type == "move":
                        await handle_move(session, websocket, room.id, message.get("data", {}))
                    elif message_type == "rps_choice":
                        await handle_rps_choice(session, websocket, room.id, message.get("data", {}))
                    elif message_type == "surrender":
                        await handle_surrender(session, websocket, room.id)
                    elif message_type == "game_over":
                        await handle_game_over(session, websocket, room.id, message.get("data", {}))
                    elif message_type == "heartbeat":
                        # Heartbeat message - user is still waiting, just acknowledge
                        # No response needed, connection staying alive is the acknowledgment
                        logger.debug(f"Heartbeat received from player in room {room_code}")
                    else:
                        await websocket.send_text(json.dumps({
                            "type": "error",
                            "message": f"Unknown message type: {message_type}"
                        }))
                        
            except WebSocketDisconnect:
                logger.info(f"WebSocket disconnected for room: {room_code}")
                connection = room_manager.get_connection(websocket)
                
                # Check if this is a waiting room that should be cleaned up
                if connection and connection.roomId:
                    # Get room to check status BEFORE disconnecting
                    room_query = select(GameRoom).where(GameRoom.id == connection.roomId)
                    room_result = await session.execute(room_query)
                    room_to_check = room_result.scalar_one_or_none()
                    
                    if room_to_check and room_to_check.status == GameRoomStatus.WAITING:
                        # Count remaining connected players (before we disconnect this one)
                        players_query = select(func.count(GamePlayer.id)).where(
                            and_(
                                GamePlayer.room_id == connection.roomId,
                                GamePlayer.is_connected == True
                            )
                        )
                        players_result = await session.execute(players_query)
                        connected_players = players_result.scalar() or 0
                        
                        # If only 1 connected player (the one disconnecting), delete the waiting room
                        if connected_players <= 1:
                            logger.info(f"Cleaning up empty waiting room {room_code} (only {connected_players} connected player(s))")
                            # Delete the room and all associated data (cascade will handle players, moves, etc.)
                            await session.delete(room_to_check)
                            await session.commit()
                            logger.info(f"Deleted waiting room {room_code}")
                            # Don't send player_left message since room is deleted
                            await room_manager.disconnect(websocket, session)
                            return
                
                await room_manager.disconnect(websocket, session)
                if connection and connection.roomId:
                    # Only send player_left if room still exists (not deleted)
                    room_query = select(GameRoom).where(GameRoom.id == connection.roomId)
                    room_result = await session.execute(room_query)
                    room_exists = room_result.scalar_one_or_none() is not None
                    
                    if room_exists:
                        await room_manager.send_to_room(
                            connection.roomId,
                            json.dumps({
                                "type": "player_left",
                                "room_code": room_code
                            })
                        )
            except Exception as e:
                logger.error(f"WebSocket error for room {room_code}: {e}", exc_info=True)
                try:
                    await websocket.send_text(json.dumps({
                        "type": "error",
                        "message": f"Server error: {str(e)}"
                    }))
                    await websocket.close()
                except:
                    pass
    except Exception as e:
        logger.error(f"Error setting up WebSocket connection for room {room_code}: {e}", exc_info=True)
        try:
            await websocket.close()
        except:
            pass


async def handle_move(session: AsyncSession, websocket: WebSocket, room_id: int, data: dict):
    """Handle chess move"""
    connection = room_manager.get_connection(websocket)
    if not connection or not connection.playerId:
        await websocket.send_text(json.dumps({
            "type": "error",
            "message": "Not connected to room"
        }))
        return
    
    move_notation = data.get("move_notation")
    if not move_notation:
        await websocket.send_text(json.dumps({
            "type": "error",
            "message": "Move notation required"
        }))
        return
    
    # Get room and player info
    room_query = select(GameRoom).where(GameRoom.id == room_id)
    room_result = await session.execute(room_query)
    room = room_result.scalar_one()
    
    player_query = select(GamePlayer).where(GamePlayer.id == connection.playerId)
    player_result = await session.execute(player_query)
    player = player_result.scalar_one()
    
    # Update timer: subtract elapsed time from current player
    # Note: current_turn_started_at is timezone-aware (DateTime(timezone=True) in model)
    if room.current_turn_started_at:
        # Use timezone-aware datetime for comparison (database column is timezone-aware)
        now = datetime.now(timezone.utc)
        elapsed = (now - room.current_turn_started_at).total_seconds()
        if player.player_side == "light":
            room.light_player_time = max(0, int(room.light_player_time - elapsed))
        else:
            room.dark_player_time = max(0, int(room.dark_player_time - elapsed))
    
    # Switch turn timer - use timezone-aware datetime (matching database column type)
    room.current_turn_started_at = datetime.now(timezone.utc)
    
    # Get current move number
    query = select(func.max(GameMove.move_number)).where(GameMove.room_id == room_id)
    result = await session.execute(query)
    max_move = result.scalar_one()
    move_number = (max_move or 0) + 1
    
    # Create move
    move = GameMove(
        room_id=room_id,
        player_id=connection.playerId,
        move_notation=move_notation,
        move_number=move_number
    )
    session.add(move)
    await session.commit()
    await session.refresh(room)
    
    # Broadcast move and timer update to ALL players (including sender)
    # This ensures both players see the move and timer updates
    await room_manager.send_to_room(
        room_id,
        json.dumps({
            "type": "move",
            "data": {
                "move_notation": move_notation,
                "player_id": connection.playerId,
                "move_number": move_number,
                "light_player_time": room.light_player_time,
                "dark_player_time": room.dark_player_time,
                "current_turn_started_at": room.current_turn_started_at.isoformat() if room.current_turn_started_at else None
            }
        }),
        exclude_websocket=None  # Send to all players including sender (sender will ignore their own move in _processOpponentMove)
    )
    
    # Send timer update to all players
    await room_manager.send_to_room(
        room_id,
        json.dumps({
            "type": "timer_update",
            "data": {
                "light_player_time": room.light_player_time,
                "dark_player_time": room.dark_player_time,
                "current_turn_started_at": room.current_turn_started_at.isoformat() if room.current_turn_started_at else None
            }
        })
    )


async def handle_rps_choice(session: AsyncSession, websocket: WebSocket, room_id: int, data: dict):
    """Handle RPS choice"""
    connection = room_manager.get_connection(websocket)
    if not connection or not connection.playerId:
        await websocket.send_text(json.dumps({
            "type": "error",
            "message": "Not connected to room"
        }))
        return
    
    choice_str = data.get("choice")
    if not choice_str:
        await websocket.send_text(json.dumps({
            "type": "error",
            "message": "RPS choice required"
        }))
        return
    
    try:
        choice = RpsChoiceEnum(choice_str)
    except ValueError:
        await websocket.send_text(json.dumps({
            "type": "error",
            "message": f"Invalid RPS choice: {choice_str}"
        }))
        return
    
    # Get or create current RPS round
    query = select(RpsRound).where(
        RpsRound.room_id == room_id,
        RpsRound.completed_at.is_(None)
    ).order_by(RpsRound.id.desc())
    result = await session.execute(query)
    rps_round = result.scalar_one_or_none()
    
    # Get players in room
    players_query = select(GamePlayer).where(GamePlayer.room_id == room_id)
    players_result = await session.execute(players_query)
    players = players_result.scalars().all()
    
    if len(players) != 2:
        await websocket.send_text(json.dumps({
            "type": "error",
            "message": "Room must have 2 players"
        }))
        return
    
    player1 = players[0]
    player2 = players[1]
    
    if not rps_round:
        # Create new RPS round
        round_query = select(func.max(RpsRound.round_number)).where(RpsRound.room_id == room_id)
        round_result = await session.execute(round_query)
        max_round = round_result.scalar_one()
        round_number = (max_round or 0) + 1
        
        rps_round = RpsRound(
            room_id=room_id,
            round_number=round_number,
            player1_id=player1.id,
            player2_id=player2.id
        )
        session.add(rps_round)
    
    # Set player's choice
    if connection.playerId == player1.id:
        rps_round.player1_choice = RpsChoiceModel[choice.value.upper()]
    elif connection.playerId == player2.id:
        rps_round.player2_choice = RpsChoiceModel[choice.value.upper()]
    else:
        await websocket.send_text(json.dumps({
            "type": "error",
            "message": "Player not in room"
        }))
        return
    
    await session.commit()
    await session.refresh(rps_round)
    
    # Check if both players have chosen
    if rps_round.player1_choice and rps_round.player2_choice:
        # Determine winner
        winner_id = determine_rps_winner(
            rps_round.player1_choice.value,
            rps_round.player2_choice.value,
            player1.id,
            player2.id
        )
        rps_round.winner_id = winner_id
        rps_round.completed_at = datetime.now(timezone.utc)
        await session.commit()
        
        # Broadcast result
        await room_manager.send_to_room(
            room_id,
            json.dumps({
                "type": "rps_result",
                "data": {
                    "round_number": rps_round.round_number,
                    "player1_choice": rps_round.player1_choice.value,
                    "player2_choice": rps_round.player2_choice.value,
                    "winner_id": winner_id
                }
            })
        )
    else:
        # Notify that choice was received, waiting for opponent
        await websocket.send_text(json.dumps({
            "type": "rps_choice_received",
            "data": {
                "waiting_for_opponent": True
            }
        }))


async def handle_game_over(session: AsyncSession, websocket: WebSocket, room_id: int, data: dict):
    """Handle game over message - broadcast to opponent"""
    import logging
    logger = logging.getLogger(__name__)
    
    connection = room_manager.get_connection(websocket)
    if not connection or not connection.playerId:
        await websocket.send_text(json.dumps({
            "type": "error",
            "message": "Not connected to room"
        }))
        return
    
    logger.info(f"Player {connection.playerId} game over in room {room_id}")
    
    # Broadcast game_over message to opponent (all other players in room)
    await room_manager.send_to_room(
        room_id,
        json.dumps({
            "type": "game_over",
            "data": data
        }),
        exclude_websocket=websocket  # Don't send back to the player who sent it
    )
    
    logger.info(f"Game over message broadcast to opponent in room {room_id}")


async def handle_surrender(session: AsyncSession, websocket: WebSocket, room_id: int):
    """Handle player surrender - broadcast to opponent"""
    import logging
    logger = logging.getLogger(__name__)
    
    connection = room_manager.get_connection(websocket)
    if not connection or not connection.playerId:
        await websocket.send_text(json.dumps({
            "type": "error",
            "message": "Not connected to room"
        }))
        return
    
    logger.info(f"Player {connection.playerId} surrendered in room {room_id}")
    
    # Broadcast surrender message to opponent (all other players in room)
    await room_manager.send_to_room(
        room_id,
        json.dumps({
            "type": "surrender",
            "data": {}
        }),
        exclude_websocket=websocket  # Don't send back to the surrendering player
    )
    
    logger.info(f"Surrender message broadcast to opponent in room {room_id}")


def determine_rps_winner(choice1: str, choice2: str, player1_id: int, player2_id: int) -> Optional[int]:
    """Determine RPS winner"""
    if choice1 == choice2:
        return None  # Tie
    
    wins = {
        "rock": "scissors",
        "paper": "rock",
        "scissors": "paper"
    }
    
    if wins[choice1] == choice2:
        return player1_id
    else:
        return player2_id
