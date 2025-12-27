# Asset Migration Guide

This guide explains how to migrate assets from the Flutter app to the backend server.

## Overview

All assets (chess pieces, avatars, splash screens) are now served from the backend API instead of being bundled with the mobile app. This allows:
- Smaller app size
- Dynamic asset updates without app updates
- Centralized asset management
- Consistent assets across all clients

## Backend Setup

### 1. Create Assets Directory Structure

On your server or in the backend project, create the following directory structure:

```bash
backend_app/
├── assets/
│   └── images/
│       ├── figures/
│       │   ├── ancient/
│       │   │   ├── black/
│       │   │   └── white/
│       │   ├── california/
│       │   ├── cardinal/
│       │   ├── celtic/
│       │   ├── condal/
│       │   ├── metal/
│       │   ├── modern/
│       │   ├── stone/
│       │   ├── tournament/
│       │   ├── vintage/
│       │   └── wood/
│       ├── avatars/
│       └── splash/
```

### 2. Copy Assets from Flutter App

Copy all asset files from `flutter_app/assets/images/` to `backend_app/assets/images/`:

**On Windows (PowerShell):**
```powershell
# From project root
Copy-Item -Path "flutter_app\assets\images\*" -Destination "backend_app\assets\images\" -Recurse -Force
```

**On Linux/Mac:**
```bash
# From project root
cp -r flutter_app/assets/images/* backend_app/assets/images/
```

### 3. Verify Assets Router

The assets router is already set up in `backend_app/src/assets/router.py`. It provides endpoints:

- `GET /api/v1/assets/figures/{piece_set}/{color}/{piece}` - Chess piece images
- `GET /api/v1/assets/avatars/{avatar_name}` - Avatar images
- `GET /api/v1/assets/splash/{filename}` - Splash screen images
- `GET /api/v1/assets/health` - Assets service health check

### 4. Update Dockerfile (if using Docker)

If you're using Docker, ensure assets are copied into the image:

```dockerfile
# Copy assets
COPY assets/ /app/assets/
```

The assets router expects assets to be at `backend_app/assets/` directory.

## Flutter App Changes

The Flutter app has been updated to use network images instead of local assets:

1. **New Utility Class**: `lib/common/asset_url.dart` - Builds asset URLs from backend
2. **Updated Utils**:
   - `AvatarUtils` - Now returns URLs instead of asset paths
   - `PiecePackUtils` - Now returns URLs instead of asset paths
3. **Updated Widgets**: All widgets now use `NetworkImage` instead of `AssetImage`

### Remove Assets from Flutter App (Optional)

After confirming everything works, you can remove assets from the Flutter app to reduce app size:

1. Remove assets from `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       # Remove all asset entries
   ```

2. Delete the assets directory:
   ```bash
   rm -rf flutter_app/assets/images
   ```

**Note**: Keep a backup of assets in case you need to rollback!

## Testing

### Test Backend Assets

```bash
# Test chess piece endpoint
curl http://YOUR_SERVER:8000/api/v1/assets/figures/cardinal/white/king

# Test avatar endpoint
curl http://YOUR_SERVER:8000/api/v1/assets/avatars/avatar_1.png

# Test health endpoint
curl http://YOUR_SERVER:8000/api/v1/assets/health
```

### Test Flutter App

1. Update `flutter_app/lib/common/endpoint.dart` with your backend URL
2. Run the Flutter app
3. Verify images load correctly
4. Check network tab to see image requests

## Environment Variables

No additional environment variables are needed. The assets router uses the base directory structure relative to the backend app.

## Troubleshooting

### Images Not Loading

1. **Check assets directory exists**:
   ```bash
   ls -la backend_app/assets/images/
   ```

2. **Check file permissions**:
   ```bash
   chmod -R 644 backend_app/assets/images/
   ```

3. **Check backend logs** for 404 errors

4. **Verify endpoint URL** in Flutter app matches backend URL

### CORS Issues

If you see CORS errors in the browser console, ensure CORS middleware in `main.py` allows your domain:

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Or specific origins in production
    ...
)
```

### Performance

For better performance, consider:
1. **CDN**: Use a CDN to serve assets
2. **Caching**: Add cache headers to asset responses
3. **Image Optimization**: Compress images before serving
4. **Precaching**: Flutter app precaches images on startup

## Deployment

### Docker Deployment

If using Docker, ensure assets are included in the image:

1. Update `Dockerfile` to copy assets
2. Rebuild Docker image
3. Deploy updated image

### Non-Docker Deployment

1. Copy assets to server
2. Ensure directory structure matches expected layout
3. Restart backend server

## Rollback Plan

If you need to rollback:

1. Keep assets in Flutter app (don't delete immediately)
2. Revert Flutter code changes to use `AssetImage` again
3. Remove assets router from backend (or leave it, it won't hurt)

## Next Steps

1. ✅ Copy assets to backend
2. ✅ Test backend endpoints
3. ✅ Update Flutter app endpoint configuration
4. ✅ Test Flutter app with network images
5. ✅ Monitor performance and errors
6. ⬜ Remove assets from Flutter app (after confirmation)
7. ⬜ Set up CDN (optional, for production)

