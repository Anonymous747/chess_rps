from typing import AsyncGenerator
import logging

from sqlalchemy import MetaData
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import NullPool

from src.config import DB_HOST, DB_NAME, DB_PASS, DB_PORT, DB_USER

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Build database URL with error handling
try:
    DATABASE_URL = f"postgresql+asyncpg://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    logger.info(f"Connecting to database: {DB_HOST}:{DB_PORT}/{DB_NAME}")
except Exception as e:
    logger.error(f"Failed to build database URL: {e}")
    raise

Base = declarative_base()
metadata = MetaData()

# Create engine with connection pooling and error handling
engine = create_async_engine(
    DATABASE_URL, 
    poolclass=NullPool,
    echo=False,  # Set to True for SQL query logging
    pool_pre_ping=True,  # Verify connections before use
    pool_recycle=3600,   # Recycle connections every hour
)

async_session_maker = sessionmaker(
    engine, 
    class_=AsyncSession, 
    expire_on_commit=False
)


async def get_async_session() -> AsyncGenerator[AsyncSession, None]:
    """Get database session with error handling."""
    try:
        async with async_session_maker() as session:
            yield session
    except Exception as e:
        logger.error(f"Database session error: {e}")
        raise
