"""
Seed script to add 20 profile avatars to the collection_items table.
Run this script to populate the database with avatar collection items.
"""
import asyncio
import sys
from pathlib import Path

# Add parent directory to path to import from src
sys.path.insert(0, str(Path(__file__).parent))

from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker
from sqlalchemy import select

from src.database import Base
from src.config import DB_HOST, DB_NAME, DB_PASS, DB_PORT, DB_USER
from src.collection.models import CollectionItem, CollectionCategory, CollectionRarity

# Avatar names and metadata
AVATARS = [
    {"name": "Happy King", "rarity": CollectionRarity.COMMON, "unlock_level": 0, "icon_name": "avatar_1"},
    {"name": "Cool Dude", "rarity": CollectionRarity.COMMON, "unlock_level": 0, "icon_name": "avatar_2"},
    {"name": "Surprised Player", "rarity": CollectionRarity.COMMON, "unlock_level": 0, "icon_name": "avatar_3"},
    {"name": "Laughing Master", "rarity": CollectionRarity.COMMON, "unlock_level": 0, "icon_name": "avatar_4"},
    {"name": "Cool Strategist", "rarity": CollectionRarity.COMMON, "unlock_level": 0, "icon_name": "avatar_5"},
    {"name": "Happy Cat", "rarity": CollectionRarity.UNCOMMON, "unlock_level": 1, "icon_name": "avatar_6"},
    {"name": "Excited Dog", "rarity": CollectionRarity.UNCOMMON, "unlock_level": 2, "icon_name": "avatar_7"},
    {"name": "Friendly Bear", "rarity": CollectionRarity.UNCOMMON, "unlock_level": 3, "icon_name": "avatar_8"},
    {"name": "Cute Rabbit", "rarity": CollectionRarity.RARE, "unlock_level": 4, "icon_name": "avatar_9"},
    {"name": "Sleepy Panda", "rarity": CollectionRarity.RARE, "unlock_level": 5, "icon_name": "avatar_10"},
    {"name": "Party Person", "rarity": CollectionRarity.RARE, "unlock_level": 6, "icon_name": "avatar_11"},
    {"name": "Wise Owl", "rarity": CollectionRarity.EPIC, "unlock_level": 7, "icon_name": "avatar_12"},
    {"name": "Mischievous Monkey", "rarity": CollectionRarity.EPIC, "unlock_level": 8, "icon_name": "avatar_13"},
    {"name": "Chess Nerd", "rarity": CollectionRarity.EPIC, "unlock_level": 9, "icon_name": "avatar_14"},
    {"name": "Cunning Fox", "rarity": CollectionRarity.LEGENDARY, "unlock_level": 10, "icon_name": "avatar_15"},
    {"name": "Epic Champion", "rarity": CollectionRarity.LEGENDARY, "unlock_level": 11, "icon_name": "avatar_16"},
    {"name": "Friendly Dragon", "rarity": CollectionRarity.LEGENDARY, "unlock_level": 12, "icon_name": "avatar_17"},
    {"name": "Mystical Wizard", "rarity": CollectionRarity.LEGENDARY, "unlock_level": 13, "icon_name": "avatar_18"},
    {"name": "Magical Unicorn", "rarity": CollectionRarity.LEGENDARY, "unlock_level": 14, "icon_name": "avatar_19"},
    {"name": "Legendary Master", "rarity": CollectionRarity.LEGENDARY, "unlock_level": 15, "icon_name": "avatar_20"},
]

async def seed_avatars():
    """Seed the database with avatar collection items."""
    # Create database engine
    database_url = f"postgresql+asyncpg://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    engine = create_async_engine(database_url, echo=False)
    
    # Create session
    async_session_maker = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    
    async with async_session_maker() as session:
        try:
            print("Starting avatar seeding...")
            
            # Check if avatars already exist
            query = select(CollectionItem).where(CollectionItem.category == CollectionCategory.AVATARS)
            result = await session.execute(query)
            existing_avatars = result.scalars().all()
            
            if existing_avatars:
                print(f"Found {len(existing_avatars)} existing avatars. Skipping seed.")
                return
            
            # Create avatar items
            created_count = 0
            for idx, avatar_data in enumerate(AVATARS, start=1):
                avatar = CollectionItem(
                    name=avatar_data["name"],
                    description=f"Profile avatar: {avatar_data['name']}",
                    category=CollectionCategory.AVATARS,
                    rarity=avatar_data["rarity"],
                    icon_name=avatar_data["icon_name"],
                    is_premium=avatar_data["rarity"] in [CollectionRarity.EPIC, CollectionRarity.LEGENDARY],
                    unlock_level=avatar_data["unlock_level"],
                    unlock_price=None,  # Avatars are unlocked by level, not purchased
                    item_metadata={
                        "avatar_index": idx,
                        "image_path": f"assets/images/avatars/avatar_{idx}.png"
                    }
                )
                session.add(avatar)
                created_count += 1
                print(f"Created avatar: {avatar_data['name']} (Level {avatar_data['unlock_level']}, Rarity: {avatar_data['rarity'].value})")
            
            await session.commit()
            print(f"\nSuccessfully seeded {created_count} avatars!")
            
        except Exception as e:
            await session.rollback()
            print(f"Error seeding avatars: {e}")
            raise
        finally:
            await engine.dispose()

if __name__ == "__main__":
    asyncio.run(seed_avatars())
