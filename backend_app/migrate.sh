#!/bin/bash
# Helper script for running Alembic migrations on Linux/Mac
# Usage: ./migrate.sh upgrade head
#        ./migrate.sh downgrade -1
#        ./migrate.sh revision --autogenerate -m "message"

cd "$(dirname "$0")"

if [ -z "$1" ]; then
    echo "Usage: ./migrate.sh <command> [args...]"
    echo ""
    echo "Common commands:"
    echo "  upgrade head          - Apply all pending migrations"
    echo "  downgrade -1          - Rollback last migration"
    echo "  revision --autogenerate -m 'message' - Create new migration"
    echo "  current               - Show current migration version"
    echo "  history               - Show migration history"
    exit 1
fi

python -m alembic "$@"









