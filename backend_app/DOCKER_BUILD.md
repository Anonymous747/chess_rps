# Docker Image Build Instructions

## Building the Backend Docker Image

### Local Build

```bash
cd backend_app
docker build -t chess-rps-backend:latest .
```

### Build with Tag

```bash
docker build -t chess-rps-backend:v1.0.0 .
```

### Build and Push to Docker Hub

```bash
# 1. Build the image
docker build -t chess-rps-backend:latest .

# 2. Tag for Docker Hub (replace YOUR_USERNAME)
docker tag chess-rps-backend:latest YOUR_USERNAME/chess-rps-backend:latest

# 3. Login to Docker Hub
docker login

# 4. Push the image
docker push YOUR_USERNAME/chess-rps-backend:latest
```

### Build for Different Architectures

If you need to build for different platforms (e.g., ARM for Raspberry Pi):

```bash
# Build for multiple platforms
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 -t YOUR_USERNAME/chess-rps-backend:latest --push .
```

## Image Size Optimization

The current Dockerfile uses Python 3.11-slim, which is already optimized. To further reduce size:

1. Use multi-stage builds (if needed)
2. Remove unnecessary system packages after build
3. Use Alpine-based images (may cause compatibility issues with some Python packages)

## Testing the Image Locally

```bash
# Run the image locally (requires database)
docker run -p 8000:8000 \
  -e DB_HOST=host.docker.internal \
  -e DB_PORT=5432 \
  -e DB_NAME=chess_rps \
  -e DB_USER=postgres \
  -e DB_PASS=your_password \
  -e SECRET_AUTH=your_secret \
  chess-rps-backend:latest

# Or test with docker-compose
cd backend_app/docker
docker-compose -f docker-compose.prod.yml up --build
```

## Image Layers

The Dockerfile is optimized to leverage Docker layer caching:
1. System dependencies are installed first
2. Requirements are copied and installed (changes less frequently)
3. Application code is copied last (changes most frequently)

This ensures faster rebuilds when only code changes.

## Troubleshooting Build Issues

### Build Fails with "Package not found"

```bash
# Update pip and retry
pip install --upgrade pip setuptools wheel
```

### Build is Slow

- Use Docker BuildKit: `DOCKER_BUILDKIT=1 docker build ...`
- Check your Docker daemon resources
- Use `.dockerignore` to exclude unnecessary files

### Image Size is Too Large

- Check what's included: `docker history chess-rps-backend:latest`
- Review `.dockerignore` to ensure large files are excluded
- Consider multi-stage builds for production

## Verifying the Build

```bash
# Check image details
docker inspect chess-rps-backend:latest

# Check image size
docker images chess-rps-backend

# Test health endpoint
docker run -d -p 8000:8000 \
  -e DB_HOST=postgres \
  -e DB_PORT=5432 \
  -e DB_NAME=chess_rps \
  -e DB_USER=postgres \
  -e DB_PASS=test \
  -e SECRET_AUTH=test \
  chess-rps-backend:latest

curl http://localhost:8000/ok
```

