import uuid
from datetime import datetime
from typing import Dict, Optional, List
from starlette.websockets import WebSocket
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from src.game.models import GameRoom, GamePlayer, GameRoomStatus
from src.game.schemas import Connection


class RoomManager:
    def __init__(self):
        self.rooms: Dict[str, GameRoom] = {}
        self.connections: Dict[WebSocket, Connection] = {}
        self.room_connections: Dict[int, List[Connection]] = {}

    async def create_room(
        self, 
        session: AsyncSession, 
        game_mode: str,
        user_id: Optional[int] = None
    ) -> GameRoom:
        """Create a new game room"""
        room_code = str(uuid.uuid4())[:8].upper()
        
        room = GameRoom(
            room_code=room_code,
            status=GameRoomStatus.WAITING,
            game_mode=game_mode
        )
        session.add(room)
        await session.commit()
        await session.refresh(room)
        
        self.rooms[room_code] = room
        self.room_connections[room.id] = []
        
        return room

    async def join_room(
        self,
        session: AsyncSession,
        room_code: str,
        websocket: WebSocket,
        user_id: Optional[int] = None
    ) -> Optional[GameRoom]:
        """Join an existing game room"""
        query = select(GameRoom).where(GameRoom.room_code == room_code)
        result = await session.execute(query)
        room = result.scalar_one_or_none()
        
        if not room:
            return None
        
        # Check if room is full (max 2 players)
        existing_players = await session.execute(
            select(GamePlayer).where(GamePlayer.room_id == room.id)
        )
        players = existing_players.scalars().all()
        
        if len(players) >= 2:
            return None
        
        # Determine player side
        player_side = "light" if len(players) == 0 else "dark"
        
        # Create player
        player = GamePlayer(
            room_id=room.id,
            user_id=user_id,
            player_side=player_side,
            is_connected=True
        )
        session.add(player)
        
        # Update room status if second player joins
        if len(players) == 1:
            room.status = GameRoomStatus.IN_PROGRESS
        
        await session.commit()
        await session.refresh(player)
        await session.refresh(room)
        
        # Add connection
        connection = Connection(room.id, websocket, player.id)
        self.connections[websocket] = connection
        
        if room.id not in self.room_connections:
            self.room_connections[room.id] = []
        self.room_connections[room.id].append(connection)
        
        return room

    def get_connection(self, websocket: WebSocket) -> Optional[Connection]:
        """Get connection for a websocket"""
        return self.connections.get(websocket)

    def get_room_connections(self, room_id: int) -> List[Connection]:
        """Get all connections for a room"""
        return self.room_connections.get(room_id, [])

    async def disconnect(self, websocket: WebSocket, session: AsyncSession):
        """Handle disconnection"""
        connection = self.connections.get(websocket)
        if connection and connection.roomId:
            # Update player status
            if connection.playerId:
                query = select(GamePlayer).where(GamePlayer.id == connection.playerId)
                result = await session.execute(query)
                player = result.scalar_one_or_none()
                if player:
                    player.is_connected = False
                    await session.commit()
            
            # Remove from room connections
            if connection.roomId in self.room_connections:
                self.room_connections[connection.roomId] = [
                    c for c in self.room_connections[connection.roomId]
                    if c.socket != websocket
                ]
        
        self.connections.pop(websocket, None)

    async def send_to_room(
        self,
        room_id: int,
        message: str,
        exclude_websocket: Optional[WebSocket] = None
    ):
        """Send message to all connections in a room"""
        connections = self.get_room_connections(room_id)
        for connection in connections:
            if connection.socket != exclude_websocket:
                try:
                    await connection.socket.send_text(message)
                except Exception:
                    pass  # Connection might be closed


room_manager = RoomManager()

