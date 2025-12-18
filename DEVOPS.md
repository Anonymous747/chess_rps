# DevOps Documentation

## Overview

The DevOps infrastructure supports containerized deployment using Docker and Docker Compose. The setup includes PostgreSQL database, FastAPI backend, and configuration for both development and production environments. Docker is the primary deployment method for all services.

## Docker Setup

### Docker Compose

Located in `backend_app/docker/docker-compose.yml`:

#### Services

**PostgreSQL Database:**
- Image: Custom build from `Dockerfile.postgres`
- Container: `chess_rps_postgres`
- Port: `5432:5432`
- Environment Variables:
  - `POSTGRES_DB`: chess_rps
  - `POSTGRES_USER`: postgres
  - `POSTGRES_PASSWORD`: chess_rps_password
  - `POSTGRES_INITDB_ARGS`: Encoding and locale settings
- Volumes:
  - `postgres_data`: Persistent data storage
  - `./init-scripts`: Initialization scripts
- Network: `chess_rps_network`
- Health Check: PostgreSQL readiness check

#### Network
- `chess_rps_network`: Bridge network for service communication

#### Volumes
- `postgres_data`: Local volume for PostgreSQL data persistence

### Running Docker Compose

```bash
cd backend_app
docker-compose -f docker/docker-compose.yml up -d
```

### Docker Commands

**Start services:**
```bash
docker-compose -f docker/docker-compose.yml up -d
```

**Stop services:**
```bash
docker-compose -f docker/docker-compose.yml down
```

**View logs:**
```bash
docker-compose -f docker/docker-compose.yml logs -f
```

**Remove volumes (clean data):**
```bash
docker-compose -f docker/docker-compose.yml down -v
```

## Docker Images

### Building Custom Images

If you need to build custom Docker images for the backend or other services:

**PostgreSQL Image:**
```bash
cd backend_app
docker build -f docker/Dockerfile.postgres -t chess_rps_postgres:latest .
```

**FastAPI Backend Image (if needed):**
```bash
cd backend_app
docker build -t chess_rps_backend:latest .
```

### Using Docker Images

All services use Docker images:
- PostgreSQL: Custom image from `Dockerfile.postgres` or official `postgres:latest`
- Images are pulled automatically when using `docker-compose up`

## Environment Configuration

### Local Development

Create `backend_app/env.local`:
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=chess_rps
DB_USER=postgres
DB_PASS=chess_rps_password
SECRET_AUTH=your-secret-key-here
```

### Docker Environment

Environment variables can be set in:
- `docker/docker-compose.yml` (for Docker Compose)
- `docker/env.example` (template file)
- `env.local` (local development, not committed to version control)

## Database Initialization

### Init Scripts

Located in `backend_app/docker/init-scripts/`:
- `01-init-db.sql`: Initial database setup script
- Executed automatically when PostgreSQL container starts for the first time

### Migration Scripts

**Windows:**
```bash
backend_app\migrate.bat
```

**Linux/Mac:**
```bash
backend_app/migrate.sh
```

**Python:**
```bash
cd backend_app
python migrate.py
```

## Health Checks

### Docker Health Check
PostgreSQL container includes health check:
- Command: `pg_isready -U postgres -d chess_rps`
- Interval: 10 seconds
- Timeout: 5 seconds
- Retries: 5

### Checking Container Health
```bash
# Check container status
docker ps

# Check health status
docker inspect chess_rps_postgres | grep Health -A 10

# Test database connection
docker exec chess_rps_postgres pg_isready -U postgres -d chess_rps
```

## Monitoring and Logging

### Docker Logs
```bash
# View all logs
docker-compose -f docker/docker-compose.yml logs

# Follow logs
docker-compose -f docker/docker-compose.yml logs -f postgres

# View last 100 lines
docker-compose -f docker/docker-compose.yml logs --tail=100
```

### Container Inspection
```bash
# Inspect container details
docker inspect chess_rps_postgres

# View container resource usage
docker stats chess_rps_postgres

# Execute commands in container
docker exec -it chess_rps_postgres psql -U postgres -d chess_rps
```

## Backup and Restore

### PostgreSQL Backup

**Docker:**
```bash
# Create backup
docker exec chess_rps_postgres pg_dump -U postgres chess_rps > backup.sql

# Create timestamped backup
docker exec chess_rps_postgres pg_dump -U postgres chess_rps > backup_$(date +%Y%m%d_%H%M%S).sql

# Backup with compression
docker exec chess_rps_postgres pg_dump -U postgres chess_rps | gzip > backup.sql.gz
```

### PostgreSQL Restore

**Docker:**
```bash
# Restore from backup
docker exec -i chess_rps_postgres psql -U postgres chess_rps < backup.sql

# Restore from compressed backup
gunzip < backup.sql.gz | docker exec -i chess_rps_postgres psql -U postgres chess_rps
```

## Scaling

### Docker Compose
- Single instance deployment by default
- For production scaling, consider:
  - Running multiple Docker Compose instances
  - Using Docker Swarm mode
  - Using container orchestration platforms

### Horizontal Scaling
To scale services horizontally:
1. Use load balancer in front of multiple backend instances
2. Configure database connection pooling
3. Use read replicas for database (requires additional setup)

## Security Best Practices

1. **Secrets Management:**
   - Never commit secrets to version control
   - Use environment variables or Docker secrets
   - Consider external secret management (e.g., HashiCorp Vault) for production
   - Rotate secrets regularly

2. **Network Security:**
   - Use Docker networks to isolate services
   - Limit database access to application containers only
   - Use TLS for database connections in production
   - Configure firewall rules appropriately

3. **Resource Limits:**
   - Set CPU and memory limits for containers
   - Prevent resource exhaustion

4. **Image Security:**
   - Use official, trusted base images
   - Regularly update images for security patches
   - Scan images for vulnerabilities

## Troubleshooting

### Common Issues

**Database Connection Failed:**
- Check if PostgreSQL container is running
- Verify environment variables
- Check network connectivity
- Review logs for errors

**Migration Errors:**
- Ensure database is accessible
- Check Alembic configuration
- Verify database user permissions

**Container Not Starting:**
- Check container status: `docker ps -a`
- View container logs: `docker logs chess_rps_postgres`
- Check Docker daemon: `docker info`
- Verify Docker Compose configuration

## Production Considerations

1. **High Availability:**
   - Deploy PostgreSQL with replication (requires additional Docker setup)
   - Use managed database service (e.g., AWS RDS, Google Cloud SQL, Azure Database)
   - Implement automated backup strategy
   - Set up database failover mechanisms

2. **Performance:**
   - Configure connection pooling
   - Optimize database queries
   - Use read replicas for read-heavy workloads

3. **Monitoring:**
   - Set up monitoring (e.g., Prometheus, Grafana)
   - Configure alerts for critical metrics
   - Monitor database performance

4. **Disaster Recovery:**
   - Regular automated backups
   - Test restore procedures
   - Document recovery procedures

## CI/CD Integration

### GitHub Actions / GitLab CI
Example pipeline steps:
1. Build Docker images
2. Run tests
3. Push images to Docker registry (Docker Hub, GitHub Container Registry, etc.)
4. Deploy using Docker Compose or container orchestration
5. Run database migrations
6. Health checks

### Deployment Scripts
- `start-docker.bat` / `start-docker.sh`: Start Docker services
- `start-fastapi.bat` / `start-fastapi.sh`: Start FastAPI server

### Docker Registry
Push images to registry:
```bash
# Tag image
docker tag chess_rps_backend:latest your-registry/chess_rps_backend:latest

# Push to registry
docker push your-registry/chess_rps_backend:latest
```

## Future Enhancements

Potential improvements:
- Docker Compose profiles for different environments (dev, staging, prod)
- Terraform for infrastructure as code
- CI/CD pipeline configuration with Docker
- Monitoring and alerting setup (Prometheus, Grafana)
- Automated backup and restore scripts
- Multi-environment Docker Compose files
- Database replication and failover with Docker
- Docker Swarm mode for orchestration
- Container health monitoring and auto-restart
- Docker volume backup strategies

## Optional: Kubernetes Deployment

Kubernetes manifests are available in `backend_app/k8s/` for advanced deployments, but Docker Compose is the recommended primary deployment method. Kubernetes can be used for production environments requiring advanced orchestration features.

