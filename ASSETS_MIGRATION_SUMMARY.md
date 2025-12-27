# Assets Migration Summary

## What Was Changed

All assets (chess pieces, avatars, splash screens) have been migrated from the Flutter app to the backend server. The Flutter app now loads all images as network images from the backend API.

## Backend Changes

### New Files Created:
1. **`backend_app/src/assets/router.py`** - Assets API router with endpoints for:
   - Chess pieces: `/api/v1/assets/figures/{piece_set}/{color}/{piece}`
   - Avatars: `/api/v1/assets/avatars/{avatar_name}`
   - Splash screens: `/api/v1/assets/splash/{filename}`
   - Health check: `/api/v1/assets/health`

2. **`backend_app/src/assets/__init__.py`** - Assets module initialization

### Modified Files:
- **`backend_app/main.py`** - Added assets router to the FastAPI app

### Required Directory Structure:
```
backend_app/
└── assets/
    └── images/
        ├── figures/
        │   ├── ancient/
        │   ├── california/
        │   ├── cardinal/
        │   ├── celtic/
        │   ├── condal/
        │   ├── metal/
        │   ├── modern/
        │   ├── stone/
        │   ├── tournament/
        │   ├── vintage/
        │   └── wood/
        ├── avatars/
        └── splash/
```

## Flutter Changes

### New Files Created:
1. **`flutter_app/lib/common/asset_url.dart`** - Utility class for building asset URLs from backend

### Modified Files:
1. **`flutter_app/lib/common/assets.dart`** - Kept for backward compatibility (deprecated)
2. **`flutter_app/lib/presentation/utils/avatar_utils.dart`** - Now returns URLs instead of asset paths
3. **`flutter_app/lib/presentation/utils/piece_pack_utils.dart`** - Now returns URLs instead of asset paths
4. **`flutter_app/lib/presentation/widget/cell_widget.dart`** - Uses NetworkImage instead of AssetImage
5. **`flutter_app/lib/presentation/widget/captured_pieces_widget.dart`** - Uses NetworkImage
6. **`flutter_app/lib/presentation/widget/move_history_widget.dart`** - Uses NetworkImage
7. **`flutter_app/lib/presentation/widget/user_avatar_widget.dart`** - Uses NetworkImage
8. **`flutter_app/lib/presentation/screen/chess_screen.dart`** - Uses NetworkImage for precaching
9. **`flutter_app/lib/presentation/screen/collection_screen.dart`** - Uses NetworkImage
10. **`flutter_app/lib/presentation/screen/profile_screen.dart`** - Uses NetworkImage
11. **`flutter_app/lib/presentation/widget/collection/piece_pack_overlay.dart`** - Uses NetworkImage

### Key Changes:
- All `AssetImage` replaced with `NetworkImage`
- All `Image.asset` replaced with `Image.network`
- Asset path utilities now build URLs using `AssetUrl` class
- Backward compatibility maintained with deprecated methods that now return URLs

## Next Steps

1. **Copy assets to backend**:
   ```bash
   # Copy from Flutter app to backend
   cp -r flutter_app/assets/images backend_app/assets/
   ```

2. **Test backend endpoints**:
   ```bash
   curl http://YOUR_SERVER:8000/api/v1/assets/figures/cardinal/white/king
   curl http://YOUR_SERVER:8000/api/v1/assets/avatars/avatar_1.png
   ```

3. **Update Flutter endpoint configuration**:
   - Ensure `flutter_app/lib/common/endpoint.dart` has correct backend URL

4. **Test Flutter app**:
   - Run app and verify images load correctly
   - Check network tab for image requests

5. **Optional - Remove assets from Flutter app** (after confirming everything works):
   - Remove assets from `pubspec.yaml`
   - Delete `flutter_app/assets/images` directory

## Benefits

✅ Smaller app size (no bundled assets)
✅ Dynamic asset updates without app updates
✅ Centralized asset management
✅ Consistent assets across all clients
✅ Easy to add new assets (just upload to backend)

## Migration Guide

See `backend_app/MIGRATE_ASSETS.md` for detailed migration instructions.

