# Setup Guide: Move Assets to Backend

This guide will help you move all assets from the Flutter app to the backend and configure everything to work.

## Step 1: Copy Assets to Backend

### On Windows (PowerShell):

```powershell
# Navigate to project root
cd D:\Programs\chess_rps

# Create assets directory structure in backend
New-Item -ItemType Directory -Force -Path "backend_app\assets\images"

# Copy all images from Flutter app to backend
Copy-Item -Path "flutter_app\assets\images\*" -Destination "backend_app\assets\images\" -Recurse -Force
```

### On Linux/Mac:

```bash
# Navigate to project root
cd /path/to/chess_rps

# Create assets directory structure in backend
mkdir -p backend_app/assets/images

# Copy all images from Flutter app to backend
cp -r flutter_app/assets/images/* backend_app/assets/images/
```

### Verify Assets Were Copied:

```bash
# Windows
dir backend_app\assets\images

# Linux/Mac
ls -la backend_app/assets/images/

# You should see:
# - figures/
# - avatars/
# - splash/
```

## Step 2: Verify Backend Code

The backend code is already updated. Verify these files exist:

1. ✅ `backend_app/src/assets/router.py` - Assets API router
2. ✅ `backend_app/src/assets/__init__.py` - Module init file
3. ✅ `backend_app/main.py` - Should include assets router

Check that `main.py` includes:
```python
from src.assets.router import router as router_assets
# ...
app.include_router(router_assets, prefix="/api/v1")
```

## Step 3: Test Backend Locally

### Start Backend Server:

```bash
cd backend_app
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Test Assets Endpoints:

Open your browser or use curl:

```bash
# Test health endpoint
curl http://localhost:8000/api/v1/assets/health

# Test chess piece endpoint
curl http://localhost:8000/api/v1/assets/figures/cardinal/white/king

# Test avatar endpoint
curl http://localhost:8000/api/v1/assets/avatars/avatar_1.png
```

**Expected Results:**
- Health endpoint: Should return JSON with status and asset types
- Chess piece: Should return PNG image
- Avatar: Should return PNG image

If you get 404 errors, check:
1. Assets directory exists at `backend_app/assets/images/`
2. File structure matches expected layout
3. Files have correct names (lowercase, correct extensions)

## Step 4: Update Flutter App Endpoint

Check `flutter_app/lib/common/endpoint.dart`:

```dart
class Endpoint {
  static const _backendEndpoint = 'YOUR_BACKEND_URL:8000'; // Update this!
  static const apiBase = 'http://$_backendEndpoint';
  // ...
}
```

**For Local Development (Android Emulator):**
```dart
static const _backendEndpoint = '10.0.2.2:8000';
```

**For Physical Device (Local Network):**
```dart
static const _backendEndpoint = 'YOUR_COMPUTER_IP:8000';
```

**For Production:**
```dart
static const _backendEndpoint = 'gamerbot.pro:8000'; // or your domain
```

## Step 5: Test Flutter App

1. **Get dependencies:**
   ```bash
   cd flutter_app
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

3. **Verify images load:**
   - Open the app
   - Check if chess pieces display correctly
   - Check if avatars display correctly
   - Check browser/network inspector for image requests

4. **Check for errors:**
   - Look for network errors in console
   - Verify images are loading from backend URLs
   - Check that no AssetImage errors appear

## Step 6: Deploy to Server

### Option A: Deploy with Docker

1. **Copy assets to server:**
   ```bash
   # On your server
   mkdir -p /opt/chess-rps/backend_app/assets/images
   
   # Copy assets (use scp, rsync, or git)
   scp -r backend_app/assets/images/* user@server:/opt/chess-rps/backend_app/assets/images/
   ```

2. **Update Dockerfile** (already done):
   The Dockerfile will copy assets during build:
   ```dockerfile
   COPY assets/ /app/assets/
   ```

3. **Rebuild Docker image:**
   ```bash
   cd backend_app
   docker build -t chess-rps-backend:latest .
   ```

4. **Push and deploy:**
   ```bash
   docker tag chess-rps-backend:latest YOUR_USERNAME/chess-rps-backend:latest
   docker push YOUR_USERNAME/chess-rps-backend:latest
   
   # On server
   docker-compose pull
   docker-compose up -d
   ```

### Option B: Deploy Without Docker

1. **Copy assets to server:**
   ```bash
   # On server
   mkdir -p /opt/chess-rps/backend_app/assets/images
   ```

2. **Copy files** (use scp, rsync, or git):
   ```bash
   scp -r backend_app/assets/images/* user@server:/opt/chess-rps/backend_app/assets/images/
   ```

3. **Verify directory structure:**
   ```bash
   # On server
   ls -la /opt/chess-rps/backend_app/assets/images/
   ```

4. **Restart backend:**
   ```bash
   # Restart your backend service (systemd, supervisor, etc.)
   sudo systemctl restart chess-rps-backend
   ```

## Step 7: Verify Deployment

### Test Server Endpoints:

```bash
# Replace with your server IP/domain
curl http://YOUR_SERVER:8000/api/v1/assets/health
curl http://YOUR_SERVER:8000/api/v1/assets/figures/cardinal/white/king
curl http://YOUR_SERVER:8000/api/v1/assets/avatars/avatar_1.png
```

### Update Flutter App Endpoint:

Update `flutter_app/lib/common/endpoint.dart` with your production server URL:

```dart
static const _backendEndpoint = 'YOUR_SERVER_DOMAIN_OR_IP:8000';
```

### Test Flutter App:

1. Rebuild Flutter app:
   ```bash
   cd flutter_app
   flutter clean
   flutter pub get
   flutter build apk  # or ios, web, etc.
   ```

2. Test on device/emulator
3. Verify all images load correctly

## Step 8: (Optional) Remove Assets from Flutter App

**ONLY after confirming everything works!**

1. **Remove from pubspec.yaml:**
   ```yaml
   flutter:
     assets:
       # Remove all asset entries
       # - assets/images/figures/
       # - assets/images/avatars/
       # - assets/images/splash/
   ```

2. **Delete assets directory:**
   ```bash
   # Windows
   Remove-Item -Recurse -Force flutter_app\assets\images

   # Linux/Mac
   rm -rf flutter_app/assets/images
   ```

3. **Rebuild app:**
   ```bash
   cd flutter_app
   flutter clean
   flutter pub get
   flutter build apk
   ```

**Note:** Keep a backup of assets before deleting!

## Troubleshooting

### Images Not Loading

**Problem:** 404 errors when requesting assets

**Solutions:**
1. Check assets directory exists: `backend_app/assets/images/`
2. Verify file structure matches expected layout
3. Check file permissions (should be readable)
4. Verify backend server is running
5. Check backend logs for errors

**On Linux/Mac:**
```bash
# Fix permissions
chmod -R 644 backend_app/assets/images/
```

### CORS Errors

**Problem:** CORS errors in browser console

**Solution:** Backend already has CORS middleware configured. If issues persist, check `backend_app/main.py`:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, use specific origins
    ...
)
```

### Images Loading Slowly

**Solutions:**
1. Use CDN (CloudFlare, AWS CloudFront, etc.)
2. Enable image caching headers in backend
3. Compress images before serving
4. Use image optimization tools

### Docker Build Fails

**Problem:** Assets not found during Docker build

**Solution:** Ensure assets are copied before building:
```dockerfile
# Copy assets first
COPY assets/ /app/assets/

# Then copy code
COPY . .
```

## Quick Checklist

- [ ] Copy assets from Flutter app to `backend_app/assets/images/`
- [ ] Verify directory structure is correct
- [ ] Test backend endpoints locally
- [ ] Update Flutter app endpoint configuration
- [ ] Test Flutter app locally
- [ ] Deploy assets to production server
- [ ] Update Flutter app with production endpoint
- [ ] Test production deployment
- [ ] (Optional) Remove assets from Flutter app

## Need Help?

- Check `backend_app/MIGRATE_ASSETS.md` for detailed migration info
- Check `ASSETS_MIGRATION_SUMMARY.md` for overview of changes
- Review backend logs for errors
- Check Flutter console for network errors

