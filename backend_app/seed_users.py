"""
Script to seed the database with 5 test users for the friends overlay.
Run this script to add users that can be searched and added as friends.
"""
import asyncio
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker
from passlib.context import CryptContext

from src.database import Base
from src.auth.models import User
from src.stats.models import UserStats
from src.config import DB_HOST, DB_NAME, DB_PASS, DB_PORT, DB_USER

# Build database URL
DATABASE_URL = f"postgresql+asyncpg://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# Password hashing context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password: str) -> str:
    """Hash a password."""
    return pwd_context.hash(password)

# Test users to create
TEST_USERS = [
    {"phone_number": "+1234567890", "password": "password123", "rating": 1350},
    {"phone_number": "+1234567891", "password": "password123", "rating": 1280},
    {"phone_number": "+1234567892", "password": "password123", "rating": 1420},
    {"phone_number": "+1234567893", "password": "password123", "rating": 1150},
    {"phone_number": "+1234567894", "password": "password123", "rating": 1500},
]

async def seed_users():
    """Create test users in the database."""
    # Create async engine
    engine = create_async_engine(DATABASE_URL, echo=False)
    
    # Create session factory
    async_session = sessionmaker(
        engine, class_=AsyncSession, expire_on_commit=False
    )
    
    async with async_session() as session:
        try:
            created_count = 0
            for user_data in TEST_USERS:
                # Check if user already exists
                from sqlalchemy import select
                query = select(User).where(User.phone_number == user_data["phone_number"])
                result = await session.execute(query)
                existing_user = result.scalar_one_or_none()
                
                if existing_user:
                    print(f"User {user_data['phone_number']} already exists, skipping...")
                    continue
                
                # Create new user
                hashed_password = get_password_hash(user_data["password"])
                new_user = User(
                    phone_number=user_data["phone_number"],
                    hashed_password=hashed_password,
                    is_active=True
                )
                session.add(new_user)
                await session.flush()  # Flush to get the user ID
                
                # Create stats for the user with the specified rating
                user_stats = UserStats(
                    user_id=new_user.id,
                    rating=user_data["rating"],
                    rating_change=0,
                    total_games=10,  # Give them some games
                    wins=5,
                    losses=3,
                    draws=2,
                    win_rate=50.0,
                    current_streak=2,
                    best_streak=5,
                    worst_streak=-2
                )
                session.add(user_stats)
                
                created_count += 1
                print(f"Created user: {user_data['phone_number']} with rating {user_data['rating']}")
            
            await session.commit()
            print(f"\n✅ Successfully created {created_count} users!")
            print("\nUsers created:")
            for user_data in TEST_USERS:
                print(f"  - {user_data['phone_number']} (Rating: {user_data['rating']}, Password: {user_data['password']})")
            
        except Exception as e:
            await session.rollback()
            print(f"❌ Error creating users: {e}")
            raise
        finally:
            await engine.dispose()

if __name__ == "__main__":
    print("🌱 Seeding database with test users...")
    asyncio.run(seed_users())
