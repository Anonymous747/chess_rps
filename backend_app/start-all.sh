#!/bin/bash

echo "========================================"
echo "  Chess RPS - Backend Startup Script"
echo "========================================"
echo ""

# Change to script directory
cd "$(dirname "$0")"

# Check if Docker is running
echo "[1/5] Checking Docker..."
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker is not running!"
    echo "Please start Docker and try again."
    exit 1
fi
echo "Docker is running."
echo ""

# Start Docker containers
echo "[2/5] Starting Docker containers..."
docker-compose -f docker/docker-compose.yml up -d
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to start Docker containers!"
    exit 1
fi
CONTAINERS_STARTED=1
echo "Docker containers started."
echo ""

# Wait for PostgreSQL to be ready
echo "[3/5] Waiting for PostgreSQL to be ready..."

# First, wait for container to be running
echo "Waiting for container to start..."
attempt=0
while [ $attempt -lt 10 ]; do
    if docker ps --filter "name=chess_rps_postgres" --filter "status=running" --format "{{.Names}}" | grep -q "chess_rps_postgres"; then
        break
    fi
    attempt=$((attempt + 1))
    echo "Waiting for container... (attempt $attempt/10)"
    sleep 2
done

if [ $attempt -eq 10 ]; then
    echo "ERROR: PostgreSQL container is not running!"
    echo "Checking container status..."
    docker ps -a --filter "name=chess_rps_postgres"
    exit 1
fi

# Now wait for PostgreSQL to accept connections
max_attempts=60
attempt=0
while [ $attempt -lt $max_attempts ]; do
    # Check if container is still running
    if ! docker ps --filter "name=chess_rps_postgres" --filter "status=running" --format "{{.Names}}" | grep -q "chess_rps_postgres"; then
        echo "ERROR: PostgreSQL container stopped unexpectedly!"
        echo "Container logs:"
        docker logs chess_rps_postgres --tail 20
        exit 1
    fi
    
    # Try to connect to PostgreSQL (check if service is ready)
    if docker exec chess_rps_postgres pg_isready -U postgres > /dev/null 2>&1; then
        # Then verify database exists and is accessible
        if docker exec chess_rps_postgres psql -U postgres -c "SELECT 1" -d chess_rps > /dev/null 2>&1; then
            echo "PostgreSQL is ready!"
            break
        fi
    fi
    attempt=$((attempt + 1))
    echo "Waiting for database... (attempt $attempt/$max_attempts)"
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo "ERROR: PostgreSQL did not become ready in time!"
    echo ""
    echo "Checking container logs..."
    docker logs chess_rps_postgres --tail 30
    echo ""
    echo "You can try:"
    echo "  1. Check if container is running: docker ps -a"
    echo "  2. Check container logs: docker logs chess_rps_postgres"
    echo "  3. Manually test: docker exec chess_rps_postgres pg_isready -U postgres"
    exit 1
fi
echo ""

# Run database migrations
echo "[4/5] Running database migrations..."
python3 migrate.py upgrade head
if [ $? -ne 0 ]; then
    echo "WARNING: Migration failed, but continuing..."
    echo "You may need to run migrations manually."
fi
echo "Migrations completed."
echo ""

# Set environment variables
echo "[5/5] Starting FastAPI backend..."
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=chess_rps
export DB_USER=postgres
export DB_PASS=chess_rps_password
export SECRET_AUTH=your-secret-key-here-change-in-production

echo ""
echo "========================================"
echo "  Backend is starting..."
echo "========================================"
echo ""
echo "API will be available at: http://localhost:8000"
echo "API Documentation: http://localhost:8000/docs"
echo "Health Check: http://localhost:8000/health"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Function to cleanup on exit
cleanup() {
    if [ -n "$CONTAINERS_STARTED" ]; then
        echo ""
        echo "Stopping Docker containers..."
        docker-compose -f docker/docker-compose.yml down
        echo "Done."
    fi
    exit 0
}

# Trap Ctrl+C and other exit signals
trap cleanup INT TERM EXIT

# Start FastAPI server
python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload

