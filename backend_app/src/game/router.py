import json
from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select, insert, func
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
    WebSocketMessage
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
            # Join room
            room = await room_manager.join_room(session, room_code, websocket)
            
            if not room:
                logger.warning(f"Room not found or full: {room_code}")
                await websocket.send_text(json.dumps({
                    "type": "error",
                    "message": "Room not found or full"
                }))
                await websocket.close()
                return
            
            # Send room info with timer
            await websocket.send_text(json.dumps({
                "type": "room_joined",
                "room_code": room.room_code,
                "game_mode": room.game_mode,
                "status": room.status.value,
                "light_player_time": room.light_player_time,
                "dark_player_time": room.dark_player_time,
                "current_turn_started_at": room.current_turn_started_at.isoformat() if room.current_turn_started_at else None
            }))
            
            # Notify other players
            await room_manager.send_to_room(
                room.id,
                json.dumps({
                    "type": "player_joined",
                    "room_code": room.room_code
                }),
                exclude_websocket=websocket
            )
            
            try:
                while True:
                    data = await websocket.receive_text()
                    message = json.loads(data)
                    message_type = message.get("type")
                    
                    if message_type == "move":
                        await handle_move(session, websocket, room.id, message.get("data", {}))
                    elif message_type == "rps_choice":
                        await handle_rps_choice(session, websocket, room.id, message.get("data", {}))
                    else:
                        await websocket.send_text(json.dumps({
                            "type": "error",
                            "message": f"Unknown message type: {message_type}"
                        }))
                        
            except WebSocketDisconnect:
                logger.info(f"WebSocket disconnected for room: {room_code}")
                await room_manager.disconnect(websocket, session)
                connection = room_manager.get_connection(websocket)
                if connection and connection.roomId:
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
    if room.current_turn_started_at:
        elapsed = (datetime.utcnow() - room.current_turn_started_at).total_seconds()
        if player.player_side == "light":
            room.light_player_time = max(0, int(room.light_player_time - elapsed))
        else:
            room.dark_player_time = max(0, int(room.dark_player_time - elapsed))
    
    # Switch turn timer
    room.current_turn_started_at = datetime.utcnow()
    
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
    
    # Broadcast move and timer update
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
        exclude_websocket=websocket
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
        rps_round.completed_at = datetime.utcnow()
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
