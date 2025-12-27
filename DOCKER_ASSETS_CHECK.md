# Docker Deployment with Assets - Quick Check

## ✅ Current Status

Your setup should work fine with Docker! Here's what's been done:

1. ✅ **Assets copied to backend**: `backend_app/assets/images/` exists with all assets
2. ✅ **Dockerfile updated**: Will copy assets during build
3. ✅ **Backend code ready**: Assets router is configured
4. ✅ **Flutter code updated**: Uses network images

## Docker Build Process

When you build the Docker image:

```bash
cd backend_app
docker build -t chess-rps-backend:latest .
```

The Dockerfile will:
1. Copy everything (including `assets/` directory) with `COPY . .`
2. Assets will be available at `/app/assets/images/` in the container
3. Backend router will serve them at `/api/v1/assets/*`

## Verify It Works

### 1. Build and Test Locally

```bash
# Build the image
cd backend_app
docker build -t chess-rps-backend:latest .

# Test locally with docker-compose
cd docker
docker-compose -f docker-compose.prod.yml up --build
```

### 2. Test Assets Endpoints

Once the container is running:

```bash
# Health check
curl http://localhost:8000/api/v1/assets/health

# Test chess piece
curl http://localhost:8000/api/v1/assets/figures/cardinal/white/king

# Test avatar
curl http://localhost:8000/api/v1/assets/avatars/avatar_1.png
```

### 3. Deploy to Server

If using Docker Hub:

```bash
# Tag and push
docker tag chess-rps-backend:latest YOUR_USERNAME/chess-rps-backend:latest
docker push YOUR_USERNAME/chess-rps-backend:latest

# On server, pull and restart
docker-compose pull
docker-compose up -d
```

## Important Notes

### ✅ Assets ARE Included in Docker Image

Since assets are in `backend_app/assets/`, they'll be copied into the Docker image automatically. **No extra volume mounts needed!**

### ✅ Flutter App Endpoint

Make sure your Flutter app endpoint points to your Docker server:

**In `flutter_app/lib/common/endpoint.dart`:**
```dart
// For production server
static const _backendEndpoint = 'gamerbot.pro:8000';

// Or with protocol if needed
static const apiBase = 'http://gamerbot.pro:8000';
```

### ✅ No Volume Mounts Required

You don't need to add volume mounts for assets in docker-compose because:
- Assets are copied into the image during build
- They're part of the container filesystem
- No need for external volumes

If you want to update assets without rebuilding:
- You CAN add a volume mount (optional):
  ```yaml
  volumes:
    - ./assets:/app/assets
  ```
- But it's usually better to rebuild the image with new assets

## Troubleshooting

### Assets Not Found (404)

**Check:**
1. Assets exist in `backend_app/assets/images/` before building
2. Docker build completed without errors
3. Container has assets: `docker exec chess_rps_backend ls -la /app/assets/images/`

### Images Not Loading in Flutter

**Check:**
1. Backend endpoint URL is correct in Flutter app
2. Backend server is accessible from your device
3. CORS is configured (already done in main.py)
4. Network permissions in Flutter app (for Android/iOS)

### Docker Build Fails

**If COPY fails:**
- Ensure `backend_app/assets/` directory exists
- Check that you're running `docker build` from `backend_app/` directory
- Verify `.dockerignore` doesn't exclude `assets/`

## Quick Test Command

```bash
# From backend_app directory
docker build -t chess-rps-backend:test .
docker run -p 8000:8000 chess-rps-backend:test

# In another terminal
curl http://localhost:8000/api/v1/assets/health
```

If this works, you're good to go! 🚀

