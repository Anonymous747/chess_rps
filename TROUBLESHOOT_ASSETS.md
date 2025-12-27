# Troubleshooting: Assets Not Loading in App

If images show as placeholders, follow these steps to diagnose and fix the issue.

## Step 1: Verify Assets in Docker Container

SSH into your server and check if assets exist in the container:

```bash
# Check if assets directory exists
docker exec chess_rps_backend ls -la /app/assets/

# Check if images directory exists
docker exec chess_rps_backend ls -la /app/assets/images/

# Check if figures exist
docker exec chess_rps_backend ls -la /app/assets/images/figures/

# Check specific piece set
docker exec chess_rps_backend ls -la /app/assets/images/figures/cardinal/white/
```

**Expected output:** You should see king.png, queen.png, etc.

## Step 2: Test Backend Assets Endpoints

Test if the backend can serve assets:

```bash
# Test health endpoint
curl http://YOUR_SERVER:8000/api/v1/assets/health

# Test chess piece endpoint
curl http://YOUR_SERVER:8000/api/v1/assets/figures/cardinal/white/king

# Test avatar endpoint  
curl http://YOUR_SERVER:8000/api/v1/assets/avatars/avatar_1.png
```

**Expected results:**
- Health endpoint: Returns JSON with status and available types
- Chess piece/avatar: Returns PNG image data

**If you get 404:**
- Assets might not be in the container
- Router might not be registered
- Path might be incorrect

**If you get 500:**
- Check backend logs: `docker logs chess_rps_backend`
- Check file permissions in container

## Step 3: Check Backend Logs

```bash
# View recent logs
docker logs chess_rps_backend --tail 100

# Follow logs in real-time
docker logs chess_rps_backend -f
```

Look for:
- Errors about missing files
- 404 errors for asset requests
- Import errors for assets router

## Step 4: Verify Assets Router is Registered

Check if the assets router is included in main.py:

```bash
# Check main.py in container
docker exec chess_rps_backend cat /app/main.py | grep -A 5 "router_assets"
```

Should see:
```python
from src.assets.router import router as router_assets
...
app.include_router(router_assets, prefix="/api/v1")
```

## Step 5: Check Flutter App Endpoint

Verify the Flutter app is pointing to the correct backend:

In `flutter_app/lib/common/endpoint.dart`:
```dart
static const _backendEndpoint = 'gamerbot.pro:8000'; // Should match your server
static const apiBase = 'http://$_backendEndpoint';
```

## Step 6: Check Network Requests in Flutter

Enable network logging in Flutter to see what URLs are being requested:

1. Run app with verbose logging
2. Check console for network errors
3. Look for 404 or connection errors

Common errors:
- `Failed to load image` - Network error or 404
- `Connection refused` - Wrong endpoint or server down
- `CORS error` - CORS not configured (should already be fixed)

## Step 7: Rebuild Docker Image with Assets

If assets are missing from the container, rebuild the image:

```bash
# On your local machine or CI/CD
cd backend_app

# Verify assets exist locally
ls -la assets/images/

# Build new image
docker build -t chess-rps-backend:latest .

# Tag and push
docker tag chess-rps-backend:latest YOUR_USERNAME/chess-rps-backend:latest
docker push YOUR_USERNAME/chess-rps-backend:latest

# On server, pull and restart
docker-compose pull
docker-compose up -d --force-recreate
```

## Step 8: Verify .dockerignore

Check that `.dockerignore` doesn't exclude assets:

```bash
# Check .dockerignore
cat backend_app/.dockerignore | grep assets
```

If `assets/` is in .dockerignore, remove it!

## Common Issues and Fixes

### Issue 1: Assets Not in Docker Image

**Symptoms:** 404 errors, assets directory missing in container

**Fix:**
1. Ensure assets exist at `backend_app/assets/images/`
2. Check `.dockerignore` doesn't exclude assets
3. Rebuild Docker image
4. Verify with: `docker exec chess_rps_backend ls /app/assets/images/`

### Issue 2: Wrong File Paths

**Symptoms:** 404 errors, but assets exist in container

**Fix:**
Check the assets router path configuration matches actual file structure:
- Router expects: `/app/assets/images/figures/{piece_set}/{color}/{piece}`
- Files should be at: `/app/assets/images/figures/cardinal/white/king.png`

### Issue 3: Permissions Issue

**Symptoms:** 500 errors, file exists but can't be read

**Fix:**
```bash
# Fix permissions in Dockerfile (already done, but verify)
# Or fix in running container
docker exec -u root chess_rps_backend chmod -R 644 /app/assets/images/
docker exec -u root chess_rps_backend chown -R appuser:appuser /app/assets/images/
docker-compose restart backend
```

### Issue 4: Assets Router Not Registered

**Symptoms:** 404 for `/api/v1/assets/*` endpoints

**Fix:**
1. Check `main.py` includes assets router
2. Restart backend: `docker-compose restart backend`
3. Check logs for import errors

### Issue 5: Wrong Flutter Endpoint

**Symptoms:** Connection errors, images not loading

**Fix:**
1. Verify endpoint in `flutter_app/lib/common/endpoint.dart`
2. Should match your server: `gamerbot.pro:8000` or your IP
3. Test endpoint is accessible: `curl http://YOUR_SERVER:8000/api/v1/assets/health`

### Issue 6: CORS Issues

**Symptoms:** Network errors in browser console

**Fix:**
CORS should already be configured in `main.py`. If issues persist:
```python
# In main.py, ensure:
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Or specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## Quick Diagnostic Script

Run this on your server to quickly diagnose:

```bash
#!/bin/bash
echo "=== Docker Container Check ==="
docker exec chess_rps_backend ls -la /app/assets/images/ 2>&1
echo ""
echo "=== Assets Health Check ==="
curl -s http://localhost:8000/api/v1/assets/health | jq .
echo ""
echo "=== Test Chess Piece ==="
curl -I http://localhost:8000/api/v1/assets/figures/cardinal/white/king 2>&1 | head -1
echo ""
echo "=== Test Avatar ==="
curl -I http://localhost:8000/api/v1/assets/avatars/avatar_1.png 2>&1 | head -1
echo ""
echo "=== Backend Logs (last 20 lines) ==="
docker logs chess_rps_backend --tail 20
```

## Next Steps

1. Run the diagnostic script above
2. Check each step in this guide
3. Fix the identified issue
4. Restart services: `docker-compose restart backend`
5. Test endpoints again
6. Test Flutter app again

