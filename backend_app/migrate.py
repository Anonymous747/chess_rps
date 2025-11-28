#!/usr/bin/env python
"""
Helper script to run Alembic migrations.
Usage:
    python migrate.py upgrade head    # Apply all migrations
    python migrate.py downgrade -1    # Rollback last migration
    python migrate.py revision --autogenerate -m "message"  # Create new migration
"""
import sys
from alembic.config import Config
from alembic import command

if __name__ == "__main__":
    alembic_cfg = Config("alembic.ini")
    
    if len(sys.argv) < 2:
        print("Usage: python migrate.py <alembic_command> [args...]")
        print("\nCommon commands:")
        print("  upgrade head          - Apply all pending migrations")
        print("  downgrade -1          - Rollback last migration")
        print("  revision --autogenerate -m 'message' - Create new migration")
        print("  current               - Show current migration version")
        print("  history               - Show migration history")
        sys.exit(1)
    
    cmd = sys.argv[1]
    args = sys.argv[2:]
    
    if cmd == "upgrade":
        revision = args[0] if args else "head"
        command.upgrade(alembic_cfg, revision)
    elif cmd == "downgrade":
        revision = args[0] if args else "-1"
        command.downgrade(alembic_cfg, revision)
    elif cmd == "revision":
        autogenerate = "--autogenerate" in args
        message_arg = [a for a in args if a.startswith("-m")]
        message = message_arg[0].split("'")[1] if message_arg and "'" in message_arg[0] else None
        
        command.revision(alembic_cfg, message=message, autogenerate=autogenerate)
    elif cmd == "current":
        command.current(alembic_cfg)
    elif cmd == "history":
        command.history(alembic_cfg)
    else:
        print(f"Unknown command: {cmd}")
        sys.exit(1)




