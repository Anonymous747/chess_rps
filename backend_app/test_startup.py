"""Test script to check backend startup and database connectivity."""
import asyncio
import sys
import os

# Set environment variables
os.environ.setdefault("DB_HOST", "localhost")
os.environ.setdefault("DB_PORT", "5432")
os.environ.setdefault("DB_NAME", "chess_rps")
os.environ.setdefault("DB_USER", "postgres")
os.environ.setdefault("DB_PASS", "chess_rps_password")
os.environ.setdefault("SECRET_AUTH", "test-secret")

async def test_database_connection():
    """Test database connection."""
    from src.database import engine
    from src.config import DB_HOST, DB_PORT, DB_NAME
    
    print(f"Testing connection to {DB_HOST}:{DB_PORT}/{DB_NAME}...")
    try:
        async with engine.begin() as conn:
            result = await conn.execute("SELECT 1")
            await result.fetchone()
        print("[OK] Database connection successful!")
        return True
    except Exception as e:
        print(f"[ERROR] Database connection failed: {e}")
        return False

async def test_startup_event():
    """Test startup event (table creation)."""
    from src.database import engine, Base
    
    print("\nTesting startup event (table creation)...")
    try:
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        print("[OK] Table creation successful!")
        return True
    except Exception as e:
        print(f"[ERROR] Table creation failed: {e}")
        return False

async def main():
    """Run all tests."""
    print("=" * 50)
    print("Backend Startup and Database Check")
    print("=" * 50)
    
    # Test imports
    print("\n[1/3] Testing imports...")
    try:
        from main import app
        print("[OK] Backend imports successful!")
    except Exception as e:
        print(f"[ERROR] Import failed: {e}")
        return 1
    
    # Test database connection
    print("\n[2/3] Testing database connection...")
    db_ok = await test_database_connection()
    
    # Test startup event
    print("\n[3/3] Testing startup event...")
    startup_ok = await test_startup_event()
    
    print("\n" + "=" * 50)
    if db_ok and startup_ok:
        print("[SUCCESS] All checks passed! Backend is ready.")
        return 0
    else:
        print("[FAILED] Some checks failed. Please review the errors above.")
        return 1

if __name__ == "__main__":
    exit_code = asyncio.run(main())
    sys.exit(exit_code)

