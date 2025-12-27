# Quick Fix: Assets Not Loading

## Most Likely Issue: Assets Not in Docker Image

If you built the Docker image before copying assets to `backend_app/assets/`, the assets won't be in the image.

## Solution: Rebuild Docker Image

### Step 1: Verify Assets Exist Locally

```powershell
# On your local machine
cd D:\Programs\chess_rps
Test-Path backend_app\assets\images\figures\cardinal\white\king.png
# Should return: True
```

### Step 2: Rebuild Docker Image

```powershell
cd backend_app
docker build -t chess-rps-backend:latest .
```

### Step 3: Test Locally (Optional)

```powershell
# Test the image locally
docker run -d -p 8000:8000 --name test-backend chess-rps-backend:latest

# Test endpoint
curl http://localhost:8000/api/v1/assets/health
curl http://localhost:8000/api/v1/assets/figures/cardinal/white/king

# Clean up
docker stop test-backend
docker rm test-backend
```

### Step 4: Push to Docker Hub

```powershell
docker tag chess-rps-backend:latest YOUR_USERNAME/chess-rps-backend:latest
docker login
docker push YOUR_USERNAME/chess-rps-backend:latest
```

### Step 5: Update on Server

SSH into your server and run:

```bash
cd /opt/chess-rps/backend_app/docker

# Pull new image
docker-compose -f docker-compose.prod.yml pull

# Recreate containers
docker-compose -f docker-compose.prod.yml up -d --force-recreate

# Check if assets exist in container
docker exec chess_rps_backend ls -la /app/assets/images/figures/cardinal/white/

# Test endpoint
curl http://localhost:8000/api/v1/assets/figures/cardinal/white/king
```

## Quick Diagnostic Commands (Run on Server)

```bash
# 1. Check if assets exist in container
docker exec chess_rps_backend ls -la /app/assets/images/ 2>&1

# 2. Test health endpoint
curl http://localhost:8000/api/v1/assets/health

# 3. Test chess piece endpoint (should return image)
curl -I http://localhost:8000/api/v1/assets/figures/cardinal/white/king

# 4. Check backend logs
docker logs chess_rps_backend --tail 50 | grep -i asset

# 5. Check if router is registered
docker exec chess_rps_backend grep -r "router_assets" /app/main.py
```

## Expected Results

✅ **Assets exist:** You should see `figures/`, `avatars/`, `splash/` directories
✅ **Health endpoint:** Returns JSON with status "ok"
✅ **Chess piece endpoint:** Returns HTTP 200 with image data (Content-Type: image/png)
✅ **Router registered:** Should see `router_assets` in main.py

## If Assets Still Don't Work

1. **Check Flutter endpoint:** Verify `flutter_app/lib/common/endpoint.dart` points to your server
2. **Check network:** Test if your Flutter app can reach the server
3. **Check CORS:** Backend should already have CORS configured
4. **Check logs:** Look for specific error messages in backend logs

## Alternative: Verify Current Image Has Assets

If you want to check your current image without rebuilding:

```bash
# On server, check current container
docker exec chess_rps_backend ls -la /app/assets/images/ 2>&1

# If empty or missing, assets weren't included in the build
# You need to rebuild the image with assets
```

