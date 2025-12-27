# Docker Container Status Commands

## Check if Containers are Running

### 1. List All Running Containers

```bash
# Show only running containers
docker ps

# Show all containers (including stopped)
docker ps -a
```

### 2. Check Specific Container Status

```bash
# Check if specific container is running
docker ps | grep chess_rps_backend
docker ps | grep chess_rps_postgres

# Check container status by name
docker inspect chess_rps_backend --format='{{.State.Status}}'
docker inspect chess_rps_postgres --format='{{.State.Status}}'
```

### 3. Using Docker Compose

```bash
# Check status of all services defined in docker-compose.yml
docker-compose ps

# Show detailed status
docker-compose ps -a
```

### 4. Check Container Health

```bash
# Check health status
docker inspect chess_rps_backend --format='{{.State.Health.Status}}'
docker inspect chess_rps_postgres --format='{{.State.Health.Status}}'

# Full health check info
docker inspect chess_rps_backend | grep -A 10 Health
```

### 5. View Container Logs

```bash
# View logs for specific container
docker logs chess_rps_backend
docker logs chess_rps_postgres

# Follow logs (real-time)
docker logs -f chess_rps_backend

# Last 100 lines
docker logs --tail 100 chess_rps_backend

# Using docker-compose
docker-compose logs
docker-compose logs backend
docker-compose logs postgres
docker-compose logs -f  # Follow all logs
```

### 6. Check Container Statistics

```bash
# Show resource usage
docker stats chess_rps_backend chess_rps_postgres

# One-time stats (not continuous)
docker stats --no-stream
```

### 7. Test if Services are Responding

```bash
# Test backend health endpoint
curl http://localhost:8000/ok
curl http://localhost:8000/health

# Test if ports are listening
netstat -tlnp | grep 8000
netstat -tlnp | grep 5432

# Or using ss
ss -tlnp | grep 8000
ss -tlnp | grep 5432
```

### 8. Execute Commands in Running Container

```bash
# Open shell in container
docker exec -it chess_rps_backend bash
docker exec -it chess_rps_postgres bash

# Run specific command
docker exec chess_rps_backend python --version
docker exec chess_rps_postgres psql -U postgres -c "SELECT version();"
```

## Quick Status Check Script

Create a quick status check:

```bash
#!/bin/bash
echo "=== Docker Containers Status ==="
echo ""
echo "Running containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "Chess RPS Backend:"
docker ps | grep chess_rps_backend && echo "✅ Backend is running" || echo "❌ Backend is not running"
echo ""
echo "Chess RPS PostgreSQL:"
docker ps | grep chess_rps_postgres && echo "✅ PostgreSQL is running" || echo "❌ PostgreSQL is not running"
echo ""
echo "=== Testing API ==="
curl -s http://localhost:8000/ok && echo "✅ API is responding" || echo "❌ API is not responding"
```

Save as `check-status.sh` and run:
```bash
chmod +x check-status.sh
./check-status.sh
```

## Common Status Outputs

### docker ps output meanings:
- **Up X minutes/seconds** - Container is running
- **Exited (0)** - Container stopped normally
- **Exited (1)** - Container stopped with error
- **Restarting** - Container is restarting
- **Created** - Container created but not started
- **Dead** - Container failed to start

## Troubleshooting

### Container Not Running

```bash
# Check why container stopped
docker ps -a | grep chess_rps_backend
docker logs chess_rps_backend

# Start stopped container
docker start chess_rps_backend

# Or using docker-compose
docker-compose start backend
docker-compose up -d
```

### Container Keeps Restarting

```bash
# Check logs for errors
docker logs --tail 100 chess_rps_backend

# Check restart count
docker inspect chess_rps_backend --format='{{.RestartCount}}'
```

