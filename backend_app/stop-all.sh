#!/bin/bash

echo "Stopping Chess RPS Backend..."

cd "$(dirname "$0")"

echo "Stopping Docker containers..."
docker-compose -f docker/docker-compose.yml down

echo ""
echo "All services stopped."







