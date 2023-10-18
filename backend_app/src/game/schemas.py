from pydantic import BaseModel
from starlette.websockets import WebSocket


class MessagesModel(BaseModel):
    id: int
    message: str

    class Config:
        orm_mode = True


class Connection:
    def __init__(self, room_id: int | None, socket: WebSocket):
        self.roomId = room_id
        self.socket = socket
