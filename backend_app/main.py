from fastapi import FastAPI

from src.game.router import router as router_game

app = FastAPI(title="Chess App")


@app.get("/ok")
async def some():
    return "some"

app.include_router(router_game)

