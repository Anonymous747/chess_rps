#!/usr/bin/env python
"""
Script to fix alembic_version table when migration files are missing.
This will update the alembic_version table to point to the actual existing migration.
"""
import os
import asyncio
from dotenv import load_dotenv
from sqlalchemy import text
from src.database import async_session_maker

# Load environment variables (try env.local first, then .env)
load_dotenv('env.local')
load_dotenv()  # Also try default .env

async def fix_alembic_version():
    """Update alembic_version to point to the actual migration"""
    async with async_session_maker() as session:
        try:
            # Check current version
            result = await session.execute(text('SELECT version_num FROM alembic_version'))
            current_version = result.scalar_one_or_none()
            print(f"Current alembic_version in database: {current_version}")
            
            # Update to the actual migration (d0a2d70fc984)
            new_version = 'd0a2d70fc984'
            if current_version != new_version:
                await session.execute(
                    text('UPDATE alembic_version SET version_num = :new_version'),
                    {'new_version': new_version}
                )
                await session.commit()
                print(f"Updated alembic_version to: {new_version}")
            else:
                print(f"alembic_version is already correct: {new_version}")
                
        except Exception as e:
            print(f"Error: {e}")
            await session.rollback()
            raise

if __name__ == "__main__":
    asyncio.run(fix_alembic_version())

