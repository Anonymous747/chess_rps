# Complete Guide: Update Docker Image and Deploy to Server

This guide walks you through building a new Docker image with assets and deploying it to your server.

## Prerequisites

- Docker installed on your local machine
- Docker Hub account (or your registry)
- SSH access to your server
- Assets already copied to `backend_app/assets/images/` ✅ (already done)

## Step 1: Verify Assets Exist Locally

Before building, verify assets are in place:

```powershell
# On Windows (from project root)
cd D:\Programs\chess_rps
Test-Path backend_app\assets\images\figures\cardinal\white\king.png
# Should return: True

# Verify directory structure
dir backend_app\assets\images\
# Should show: figures, avatars, splash directories
```

## Step 2: Build Docker Image Locally

```powershell
# Navigate to backend_app directory
cd backend_app

# Build the Docker image
docker build -t chess-rps-backend:latest .

# Wait for build to complete (this may take a few minutes)
```

**What this does:**
- Copies all files including assets into the image
- Installs Python dependencies
- Sets up the application

**Expected output:** 
- Build should complete successfully
- You'll see "Successfully built" and "Successfully tagged" messages

## Step 3: Test Image Locally (Optional but Recommended)

Test the image before pushing:

```powershell
# Run container locally
docker run -d -p 8000:8000 --name test-backend chess-rps-backend:latest

# Wait a few seconds for it to start
Start-Sleep -Seconds 5

# Test assets endpoint
Invoke-WebRequest -Uri http://localhost:8000/api/v1/assets/health

# Test image endpoint (should return image data)
$response = Invoke-WebRequest -Uri http://localhost:8000/api/v1/assets/figures/cardinal/white/king
$response.StatusCode  # Should be 200
$response.Headers["Content-Type"]  # Should be image/png

# Clean up test container
docker stop test-backend
docker rm test-backend
```

## Step 4: Tag Image for Docker Hub

Replace `YOUR_USERNAME` with your Docker Hub username:

```powershell
# Tag the image
docker tag chess-rps-backend:latest YOUR_USERNAME/chess-rps-backend:latest

# Verify tag was created
docker images | Select-String "chess-rps-backend"
```

**Example:**
```powershell
docker tag chess-rps-backend:latest johndoe/chess-rps-backend:latest
```

## Step 5: Login to Docker Hub

```powershell
# Login to Docker Hub
docker login

# Enter your Docker Hub username and password when prompted
```

## Step 6: Push Image to Docker Hub

```powershell
# Push the image (this may take several minutes)
docker push YOUR_USERNAME/chess-rps-backend:latest

# Example:
# docker push johndoe/chess-rps-backend:latest
```

**Expected output:**
- Upload progress bars
- "latest: digest: sha256:..." message when complete
- Image should appear in your Docker Hub repository

## Step 7: Deploy on Server

SSH into your server:

```bash
# SSH into your server
ssh root@YOUR_SERVER_IP
# or
ssh YOUR_USERNAME@YOUR_SERVER_IP
```

## Step 8: Navigate to Deployment Directory

```bash
# Go to deployment directory
cd /opt/chess-rps

# Or if using docker subdirectory
cd /opt/chess-rps/backend_app/docker
```

## Step 9: Update docker-compose.yml (if needed)

If you're using `docker-compose.yml` (not docker-compose.prod.yml), make sure it uses the image:

```bash
# Check which docker-compose file you're using
ls -la docker-compose*.yml

# Edit if needed (use nano or vi)
nano docker-compose.yml
```

Ensure the backend service uses your Docker Hub image:

```yaml
backend:
  image: YOUR_USERNAME/chess-rps-backend:latest
  # Remove or comment out 'build' section if it exists
```

Save and exit (Ctrl+X, Y, Enter in nano).

## Step 10: Pull Latest Image

```bash
# Pull the latest image from Docker Hub
docker-compose pull

# Or if using specific file:
docker-compose -f docker-compose.prod.yml pull
```

**Expected output:**
- "Pulling backend..."
- "latest: Pulling from YOUR_USERNAME/chess-rps-backend"
- Download progress
- "Status: Downloaded newer image..."

## Step 11: Stop Current Containers

```bash
# Stop and remove existing containers
docker-compose down

# Or if using specific file:
docker-compose -f docker-compose.prod.yml down
```

## Step 12: Start with New Image

```bash
# Start containers with new image
docker-compose up -d

# Or if using specific file:
docker-compose -f docker-compose.prod.yml up -d

# Or force recreate to ensure fresh start:
docker-compose up -d --force-recreate
```

## Step 13: Verify Deployment

```bash
# Check container status
docker-compose ps

# Check if containers are running
docker ps | grep chess_rps

# Check assets exist in container
docker exec chess_rps_backend ls -la /app/assets/images/

# Test health endpoint
curl http://localhost:8000/api/v1/assets/health

# Test chess piece endpoint (should return image)
curl -I http://localhost:8000/api/v1/assets/figures/cardinal/white/king

# Test from outside (replace with your domain/IP)
curl -I http://gamerbot.pro:8000/api/v1/assets/figures/cardinal/white/king
```

## Step 14: Check Logs

```bash
# View backend logs
docker logs chess_rps_backend --tail 50

# Follow logs in real-time
docker logs chess_rps_backend -f
```

Look for:
- No errors about missing assets
- Server started successfully
- Router registered correctly

## Step 15: Test from Flutter App

1. Ensure Flutter app endpoint is correct in `flutter_app/lib/common/endpoint.dart`:
   ```dart
   static const _backendEndpoint = 'gamerbot.pro:8000';
   ```

2. Rebuild Flutter app if needed:
   ```powershell
   cd flutter_app
   flutter clean
   flutter pub get
   flutter build apk  # or run
   ```

3. Test on device/emulator

## Complete Command Sequence

### Local Machine (Windows PowerShell):

```powershell
# 1. Navigate to backend
cd D:\Programs\chess_rps\backend_app

# 2. Build image
docker build -t chess-rps-backend:latest .

# 3. Tag for Docker Hub (replace YOUR_USERNAME)
docker tag chess-rps-backend:latest YOUR_USERNAME/chess-rps-backend:latest

# 4. Login
docker login

# 5. Push
docker push YOUR_USERNAME/chess-rps-backend:latest
```

### On Server (Linux):

```bash
# 1. Navigate to deployment directory
cd /opt/chess-rps/backend_app/docker

# 2. Pull latest image
docker-compose -f docker-compose.prod.yml pull

# 3. Stop containers
docker-compose -f docker-compose.prod.yml down

# 4. Start with new image
docker-compose -f docker-compose.prod.yml up -d

# 5. Verify
docker exec chess_rps_backend ls /app/assets/images/
curl http://localhost:8000/api/v1/assets/health
```

## Troubleshooting

### Build Fails

**Error:** "COPY failed: file not found"
- **Fix:** Ensure you're running `docker build` from `backend_app/` directory
- **Fix:** Verify assets exist: `Test-Path backend_app\assets\images\`

### Push Fails

**Error:** "denied: requested access to the resource is denied"
- **Fix:** Make sure you're logged in: `docker login`
- **Fix:** Check image tag matches your Docker Hub username

### Image Not Updating on Server

**Problem:** Old image still running
- **Fix:** Use `--force-recreate` flag: `docker-compose up -d --force-recreate`
- **Fix:** Remove old containers: `docker-compose down` then `docker-compose up -d`

### Assets Not in Container

**Problem:** Assets directory empty in container
- **Fix:** Rebuild image locally (assets must exist before building)
- **Fix:** Check `.dockerignore` doesn't exclude assets
- **Fix:** Verify assets copied correctly: `docker exec chess_rps_backend ls /app/assets/images/`

## Quick Reference

**Build and push:**
```powershell
docker build -t chess-rps-backend:latest .
docker tag chess-rps-backend:latest YOUR_USERNAME/chess-rps-backend:latest
docker push YOUR_USERNAME/chess-rps-backend:latest
```

**Deploy on server:**
```bash
docker-compose pull
docker-compose down
docker-compose up -d --force-recreate
```

**Verify:**
```bash
docker exec chess_rps_backend ls /app/assets/images/
curl http://localhost:8000/api/v1/assets/health
```

## Summary Checklist

- [ ] Assets exist in `backend_app/assets/images/`
- [ ] Docker image built locally
- [ ] Image tested locally (optional)
- [ ] Image tagged for Docker Hub
- [ ] Logged into Docker Hub
- [ ] Image pushed to Docker Hub
- [ ] Pulled image on server
- [ ] Containers restarted on server
- [ ] Assets verified in container
- [ ] Endpoints tested
- [ ] Flutter app tested

