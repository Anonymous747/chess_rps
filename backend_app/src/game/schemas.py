from datetime import datetime
from typing import Optional
from pydantic import BaseModel
from starlette.websockets import WebSocket
import enum


class MessagesModel(BaseModel):
    id: int
    message: str

    class Config:
        from_attributes = True


class Connection:
    def __init__(self, room_id: int | None, socket: WebSocket, player_id: int | None = None):
        self.roomId = room_id
        self.socket = socket
        self.playerId = player_id


class RpsChoiceEnum(str, enum.Enum):
    ROCK = "rock"
    PAPER = "paper"
    SCISSORS = "scissors"


class GameRoomCreate(BaseModel):
    game_mode: str  # "classical" or "rps"


class GameRoomResponse(BaseModel):
    id: int
    room_code: str
    status: str
    game_mode: str
    light_player_time: int
    dark_player_time: int
    current_turn_started_at: Optional[datetime]
    created_at: datetime

    class Config:
        from_attributes = True


class GamePlayerResponse(BaseModel):
    id: int
    room_id: int
    user_id: Optional[int]
    player_side: str
    is_connected: bool
    joined_at: datetime

    class Config:
        from_attributes = True


class GameMoveCreate(BaseModel):
    move_notation: str


class GameMoveResponse(BaseModel):
    id: int
    room_id: int
    player_id: int
    move_notation: str
    move_number: int
    created_at: datetime

    class Config:
        from_attributes = True


class RpsChoiceRequest(BaseModel):
    choice: RpsChoiceEnum


class RpsRoundResponse(BaseModel):
    id: int
    room_id: int
    round_number: int
    player1_id: int
    player2_id: int
    player1_choice: Optional[str]
    player2_choice: Optional[str]
    winner_id: Optional[int]
    created_at: datetime
    completed_at: Optional[datetime]

    class Config:
        from_attributes = True


class WebSocketMessage(BaseModel):
    type: str  # "move", "rps_choice", "join_room", "create_room", etc.
    data: dict

