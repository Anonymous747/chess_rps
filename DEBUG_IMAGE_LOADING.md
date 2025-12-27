# Debug: Image Loading in Flutter App

## Added Logging

I've added comprehensive logging to help debug why images aren't loading:

### 1. AssetUrl Class Logging
- Logs when baseUrl is accessed
- Logs every URL that's built (chess pieces, avatars, splash)
- Tag: `AssetUrl`

### 2. AvatarUtils Logging
- Logs when avatar URLs are generated
- Logs default avatar fallback
- Tag: `AvatarUtils`

### 3. PiecePackUtils Logging
- Logs when piece pack URLs are generated
- Logs when all piece URLs are generated
- Tag: `PiecePackUtils`

### 4. Image Widget Logging
- Logs when Image.network starts loading (loadingBuilder)
- Logs when Image.network fails (errorBuilder)
- Tags: `CollectionScreen`, `UserAvatarWidget`, `CellWidget`

## How to Check Logs

### In Development (Debug Mode)

1. Run the app in debug mode:
   ```bash
   flutter run
   ```

2. Check console output for logs with tags:
   - `[AssetUrl]` - URL generation
   - `[AvatarUtils]` - Avatar URL generation
   - `[PiecePackUtils]` - Piece pack URL generation
   - `[CollectionScreen]` - Collection screen image loading
   - `[UserAvatarWidget]` - Avatar widget image loading
   - `[CellWidget]` - Chess cell image loading

### What to Look For

#### Expected Log Sequence for Loading an Avatar:

```
[AssetUrl] [DEBUG]: AssetUrl.baseUrl: http://gamerbot.pro:8000/api/v1/assets
[AvatarUtils] [DEBUG]: AvatarUtils.getAvatarImageUrl: iconName="avatar_1", url="http://gamerbot.pro:8000/api/v1/assets/avatars/avatar_1.png"
[CollectionScreen] [DEBUG]: _buildFeaturedSet: Loading avatar for item "Happy King", url="http://gamerbot.pro:8000/api/v1/assets/avatars/avatar_1.png"
[CollectionScreen] [DEBUG]: Loading avatar image: http://gamerbot.pro:8000/api/v1/assets/avatars/avatar_1.png (12345/12345)
```

#### If Images Aren't Loading, Check:

1. **No URL logs?**
   - AssetUrl methods aren't being called
   - Check if Image.network widgets are being rendered

2. **URL logs but no loading logs?**
   - Image.network isn't actually trying to load
   - Check if widget is visible/rendered

3. **Loading logs but errors?**
   - Check error logs for network issues
   - Verify backend is accessible from device
   - Check URL format is correct

4. **Wrong URLs?**
   - Check endpoint configuration in `endpoint.dart`
   - Verify AssetUrl.baseUrl is correct

## Common Issues

### Issue 1: No Logs at All

**Possible causes:**
- Widgets not being built
- Logging disabled
- Running in release mode (only errors/warnings logged)

**Fix:**
- Ensure running in debug mode
- Check if widgets are visible on screen

### Issue 2: URLs Generated But Not Loading

**Possible causes:**
- Network permission not granted
- Backend not accessible from device
- CORS issues (if web)
- Wrong endpoint URL

**Fix:**
- Check network logs for connection errors
- Test URL in browser from device
- Verify endpoint configuration

### Issue 3: 404 Errors in Logs

**Possible causes:**
- Wrong URL format
- Backend asset endpoint not working
- Assets not in backend

**Fix:**
- Check backend logs
- Test endpoint with curl
- Verify asset paths match backend structure

### Issue 4: Connection Errors

**Possible causes:**
- Device can't reach server
- Firewall blocking
- Wrong IP/domain

**Fix:**
- Test server accessibility from device
- Check firewall rules
- Verify endpoint URL is correct

## Fixed Issues

1. ✅ Changed `Image.asset` to `Image.network` in `_buildPiecePackCard`
2. ✅ Added loadingBuilder to show loading state
3. ✅ Added comprehensive error logging
4. ✅ Added URL generation logging
5. ✅ Fixed null assertion warning

## Next Steps

1. Run the app and check logs
2. Look for the log tags mentioned above
3. Share log output if images still don't load
4. Check backend logs to see if requests are received

