from typing import List

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy import select, insert
from sqlalchemy.ext.asyncio import AsyncSession
from starlette.websockets import WebSocket, WebSocketDisconnect

from src.database import get_async_session, async_session_maker
from src.game.models import Messages
from src.game.schemas import MessagesModel, Connection

router = APIRouter(
    prefix="/game",
    tags=["Game"]
)


class ConnectionManager:
    def __init__(self):
        self.active_connections: List[Connection] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(Connection(None, websocket))

    def disconnect(self, websocket: WebSocket):
        connection = next((x for x in self.active_connections if x.socket == websocket), None)
        self.active_connections.remove(connection)

    async def send_personal_message(self, message: str, websocket: WebSocket):
        await websocket.send_text(message)

    async def broadcast(self, message: str, add_to_db: bool):
        if add_to_db:
            await self.add_messages_to_database(message)
        for connection in self.active_connections:
            await connection.socket.send_text(message)

    @staticmethod
    async def add_messages_to_database(message: str):
        async with async_session_maker() as session:
            stmt = insert(Messages).values(
                message=message
            )
            await session.execute(stmt)
            await session.commit()


manager = ConnectionManager()


@router.get("/last_messages")
async def get_last_messages(
        session: AsyncSession = Depends(get_async_session),
) -> List[MessagesModel]:
    query = select(Messages).order_by(Messages.id.desc()).limit(5)
    messages = await session.execute(query)
    return messages.scalars().all()


@router.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: int):
    await manager.connect(websocket)
    try:
        while True:
            data = await websocket.receive_text()
            await manager.broadcast(f"Client #{client_id} says: {data}", add_to_db=True)
    except WebSocketDisconnect:
        manager.disconnect(websocket)
        await manager.broadcast(f"Client #{client_id} left the chat", add_to_db=False)
