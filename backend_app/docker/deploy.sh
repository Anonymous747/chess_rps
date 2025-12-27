#!/bin/bash

# Deployment script for Chess RPS Backend
# Usage: ./deploy.sh

set -e  # Exit on error

echo "🚀 Starting Chess RPS Backend Deployment..."

# Check if .env.prod exists
if [ ! -f .env.prod ]; then
    echo "❌ Error: .env.prod file not found!"
    echo "📝 Please create .env.prod file with your configuration."
    echo "   You can copy docker/env.example and modify it:"
    echo "   cp ../docker/env.example .env.prod"
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running!"
    exit 1
fi

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose -f docker-compose.prod.yml down 2>/dev/null || true

# Build and start containers
echo "🔨 Building and starting containers..."
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d --build

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 5

# Check if containers are running
if docker ps | grep -q chess_rps_backend && docker ps | grep -q chess_rps_postgres; then
    echo "✅ Containers are running!"
    
    # Run migrations
    echo "📦 Running database migrations..."
    docker exec -it chess_rps_backend python /app/migrate.py || echo "⚠️  Migration failed or already up to date"
    
    echo ""
    echo "🎉 Deployment complete!"
    echo ""
    echo "📊 Container status:"
    docker-compose -f docker-compose.prod.yml ps
    echo ""
    echo "📝 View logs with:"
    echo "   docker-compose -f docker-compose.prod.yml logs -f"
    echo ""
    echo "🌐 API available at: http://localhost:8000"
    echo "📚 API docs at: http://localhost:8000/docs"
else
    echo "❌ Error: Containers failed to start!"
    echo "📝 Check logs with: docker-compose -f docker-compose.prod.yml logs"
    exit 1
fi

