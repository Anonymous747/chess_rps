# Debug: Assets Exist But Not Loading in App

Assets are in the container, so the issue is likely:
1. Backend endpoints not accessible
2. Wrong endpoint URL in Flutter app
3. Network/CORS issues
4. Images loading but failing silently

## Step 1: Test Backend Endpoints

Run these on your server:

```bash
# Test health endpoint (should return JSON)
curl http://localhost:8000/api/v1/assets/health

# Test chess piece endpoint (should return image data)
curl -I http://localhost:8000/api/v1/assets/figures/cardinal/white/king

# Test with full response to see if image loads
curl http://localhost:8000/api/v1/assets/figures/cardinal/white/king --output /tmp/test-king.png
file /tmp/test-king.png  # Should say: PNG image data

# Test avatar endpoint
curl -I http://localhost:8000/api/v1/assets/avatars/avatar_1.png
```

**Expected:**
- Health: Returns JSON with status "ok"
- Chess piece/Avatar: Returns HTTP 200 with Content-Type: image/png

**If you get 404:**
- Router might not be registered
- Check backend logs for errors

**If you get 500:**
- Check backend logs for Python errors
- Check file permissions

## Step 2: Test from Outside (Important!)

Test from your computer/phone to see if the server is accessible:

```bash
# From your computer (replace YOUR_SERVER_IP with gamerbot.pro or IP)
curl http://YOUR_SERVER_IP:8000/api/v1/assets/health
curl -I http://YOUR_SERVER_IP:8000/api/v1/assets/figures/cardinal/white/king
```

**If this fails:**
- Server might not be accessible from outside
- Firewall might be blocking port 8000
- Check if port is open: `sudo ufw status` or check DigitalOcean firewall

## Step 3: Check Backend Logs

```bash
# Check for errors
docker logs chess_rps_backend --tail 100 | grep -i error

# Check for asset-related errors
docker logs chess_rps_backend --tail 100 | grep -i asset

# Check all recent logs
docker logs chess_rps_backend --tail 50
```

Look for:
- 404 errors for asset requests
- Import errors for assets router
- Permission errors
- Path errors

## Step 4: Verify Router is Registered

```bash
# Check if assets router is in main.py
docker exec chess_rps_backend grep -A 2 "router_assets" /app/main.py

# Check if router file exists
docker exec chess_rps_backend ls -la /app/src/assets/router.py

# Test if the endpoint is registered
curl http://localhost:8000/docs  # Open in browser, check if /api/v1/assets/ endpoints appear
```

## Step 5: Check Flutter App Configuration

Verify the Flutter app endpoint in `flutter_app/lib/common/endpoint.dart`:

```dart
class Endpoint {
  static const _backendEndpoint = 'gamerbot.pro:8000'; // Should match your server
  
  static const apiBase = 'http://$_backendEndpoint';
  // ...
}
```

**Important:** 
- For Android emulator: Use `10.0.2.2:8000`
- For physical device on same network: Use your server IP: `192.168.x.x:8000` or `gamerbot.pro:8000`
- For production: Use your domain: `gamerbot.pro:8000`

## Step 6: Test Image URL Directly

Build the URL that Flutter app would use and test it:

```bash
# The URL should be:
http://gamerbot.pro:8000/api/v1/assets/figures/cardinal/white/king

# Test it:
curl -I http://gamerbot.pro:8000/api/v1/assets/figures/cardinal/white/king
```

**If this works from server but not from phone:**
- Network/firewall issue
- DNS resolution issue (if using domain)
- Port not accessible from mobile network

## Step 7: Check CORS Configuration

CORS should already be configured, but verify in logs:

```bash
docker exec chess_rps_backend grep -A 5 "CORSMiddleware" /app/main.py
```

Should see:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Or specific origins
    ...
)
```

## Step 8: Test in Browser

Open in browser from your phone or computer:
```
http://gamerbot.pro:8000/api/v1/assets/figures/cardinal/white/king
```

**Expected:** Image should display in browser

**If you see:**
- 404 Not Found → Router not working or wrong path
- 500 Internal Server Error → Check backend logs
- Connection refused → Server not accessible
- CORS error → CORS not configured (shouldn't happen)

## Common Issues

### Issue 1: Port Not Accessible

**Symptoms:** Works from server, but not from outside

**Fix:**
```bash
# Check firewall
sudo ufw status
sudo ufw allow 8000/tcp

# Check DigitalOcean firewall in dashboard
# Ensure port 8000 is open for inbound traffic
```

### Issue 2: Router Not Registered

**Symptoms:** 404 errors, endpoints don't exist

**Fix:**
1. Check main.py includes assets router
2. Restart backend: `docker-compose restart backend`
3. Check logs for import errors

### Issue 3: Wrong Endpoint in Flutter

**Symptoms:** Connection errors, wrong URL

**Fix:**
1. Update `endpoint.dart` with correct server address
2. Rebuild Flutter app
3. Test with curl to verify URL works

### Issue 4: Images Loading But Failing Silently

**Symptoms:** Placeholders show, no errors in console

**Fix:**
1. Check Flutter console for network errors
2. Use Flutter DevTools to inspect network requests
3. Check if images are actually being requested
4. Verify image URLs are correct

## Quick Diagnostic Script

Run this on your server:

```bash
#!/bin/bash
echo "=== 1. Assets Check ==="
docker exec chess_rps_backend ls /app/assets/images/figures/cardinal/white/ | head -5

echo ""
echo "=== 2. Health Endpoint ==="
curl -s http://localhost:8000/api/v1/assets/health | jq . || curl -s http://localhost:8000/api/v1/assets/health

echo ""
echo "=== 3. Chess Piece Endpoint ==="
curl -I http://localhost:8000/api/v1/assets/figures/cardinal/white/king 2>&1 | head -3

echo ""
echo "=== 4. Router Check ==="
docker exec chess_rps_backend grep -c "router_assets" /app/main.py

echo ""
echo "=== 5. Recent Errors ==="
docker logs chess_rps_backend --tail 20 | grep -i "error\|404\|500" || echo "No errors found"

echo ""
echo "=== 6. Test from Outside ==="
echo "Run this from your computer:"
echo "curl -I http://$(hostname -I | awk '{print $1}'):8000/api/v1/assets/figures/cardinal/white/king"
```

## Next Steps Based on Results

1. **If endpoints work from server but not from outside:**
   - Fix firewall/port access
   - Check DigitalOcean firewall settings

2. **If endpoints return 404:**
   - Check router registration
   - Restart backend

3. **If endpoints return 500:**
   - Check backend logs for errors
   - Check file permissions

4. **If endpoints work but Flutter app doesn't load:**
   - Check Flutter endpoint configuration
   - Check Flutter console for errors
   - Test URL in browser from phone

