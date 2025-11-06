from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
import logging

from src.game.router import router as router_game
from src.database import get_async_session, engine
from src.database import Base

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Chess RPS API",
    description="A chess game API with Rock Paper Scissors mechanics",
    version="1.0.0"
)


@app.on_event("startup")
async def startup_event():
    """Initialize database tables on startup."""
    try:
        # Create all tables
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        logger.info("Database tables created successfully")
    except Exception as e:
        logger.error(f"Failed to create database tables: {e}")
        raise


@app.get("/")
async def root():
    """Root endpoint with API information."""
    return {
        "message": "Chess RPS API",
        "version": "1.0.0",
        "docs": "/docs",
        "health": "/health"
    }


@app.get("/health")
async def health_check(db: AsyncSession = Depends(get_async_session)):
    """Health check endpoint that verifies database connectivity."""
    try:
        # Test database connection
        result = await db.execute("SELECT 1")
        await result.fetchone()
        return {
            "status": "healthy",
            "database": "connected",
            "message": "All systems operational"
        }
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        raise HTTPException(status_code=503, detail="Database connection failed")


@app.get("/ok")
async def simple_health():
    """Simple health check without database dependency."""
    return {"status": "ok"}

# Include game router
app.include_router(router_game, prefix="/api/v1", tags=["games"])

