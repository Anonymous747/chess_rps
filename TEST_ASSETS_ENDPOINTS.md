# Testing Assets Endpoints

## Why 405 Error?

`curl -I` sends a **HEAD request**, but FastAPI endpoints typically only accept **GET requests**. The 405 error with `allow: GET` means the endpoint exists, it just doesn't accept HEAD.

## Test with GET Request Instead

```bash
# Use GET request (without -I flag)
curl http://gamerbot.pro:8000/api/v1/assets/figures/cardinal/white/king

# Or test and save to file
curl http://gamerbot.pro:8000/api/v1/assets/figures/cardinal/white/king --output /tmp/test-king.png
file /tmp/test-king.png  # Should say: PNG image data

# Check headers with GET request
curl -v http://gamerbot.pro:8000/api/v1/assets/figures/cardinal/white/king 2>&1 | head -20

# Test health endpoint (should return JSON)
curl http://gamerbot.pro:8000/api/v1/assets/health

# Test avatar
curl -I http://gamerbot.pro:8000/api/v1/assets/avatars/avatar_1.png
curl http://gamerbot.pro:8000/api/v1/assets/avatars/avatar_1.png --output /tmp/test-avatar.png
```

## Test in Browser

Open these URLs in your browser (should display images):

```
http://gamerbot.pro:8000/api/v1/assets/figures/cardinal/white/king
http://gamerbot.pro:8000/api/v1/assets/avatars/avatar_1.png
http://gamerbot.pro:8000/api/v1/assets/health
```

If images display in browser, the backend is working correctly!

## Check Response Headers (with GET)

```bash
# Get full response with headers
curl -i http://gamerbot.pro:8000/api/v1/assets/figures/cardinal/white/king 2>&1 | head -15
```

Expected:
- HTTP/1.1 200 OK
- Content-Type: image/png
- Image data

