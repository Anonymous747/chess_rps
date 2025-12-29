# Setting up Nginx with HTTPS for Backend Server

This guide will help you set up nginx as a reverse proxy with SSL/TLS certificates to enable HTTPS for your backend API.

## Prerequisites

- Server running Ubuntu/Debian (or similar Linux distribution)
- Domain name `gamerbot.pro` pointing to your server's IP address
- Backend running on port 8000 (inside Docker)
- Root or sudo access to the server

## Step 1: Install Nginx

```bash
# Update package list
sudo apt update

# Install nginx
sudo apt install nginx -y

# Check nginx status
sudo systemctl status nginx

# Enable nginx to start on boot
sudo systemctl enable nginx
```

## Step 2: Install Certbot (Let's Encrypt)

```bash
# Install certbot and nginx plugin
sudo apt install certbot python3-certbot-nginx -y
```

## Step 3: Configure Nginx (HTTP Only - Before SSL)

**IMPORTANT**: You need to set up HTTP-only configuration first, then certbot will add SSL automatically.

Create an nginx configuration file for your domain:

```bash
# Copy the HTTP-only template (recommended)
sudo cp /path/to/backend_app/nginx/gamerbot.pro.http-only /etc/nginx/sites-available/gamerbot.pro

# OR create manually with HTTP-only config:
sudo nano /etc/nginx/sites-available/gamerbot.pro
```

Add the following configuration (HTTP only, certbot will add SSL):

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name gamerbot.pro;

    # Let's Encrypt challenge location
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    # Proxy settings
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    # WebSocket endpoint
    location /api/v1/game/ws {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
        proxy_connect_timeout 75s;
    }

    # API endpoints
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
        proxy_send_timeout 300s;
    }

    # Health check endpoint
    location /ok {
        proxy_pass http://localhost:8000;
        access_log off;
    }
}
```

Enable the site:

```bash
# Create symbolic link
sudo ln -s /etc/nginx/sites-available/gamerbot.pro /etc/nginx/sites-enabled/

# Remove default site (optional)
sudo rm /etc/nginx/sites-enabled/default

# Test nginx configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

## Step 4: Obtain SSL Certificate with Certbot

```bash
# Run certbot to obtain SSL certificate
sudo certbot --nginx -d gamerbot.pro

# Follow the prompts:
# - Enter your email address
# - Agree to terms of service
# - Choose whether to redirect HTTP to HTTPS (recommended: Yes)
```

Certbot will automatically:
- Obtain SSL certificates from Let's Encrypt
- Update your nginx configuration to use HTTPS
- Set up automatic renewal

## Step 5: Verify Nginx Configuration (After SSL)

After certbot runs, your configuration should look like this:

```bash
sudo cat /etc/nginx/sites-available/gamerbot.pro
```

You should see something like:

```nginx
server {
    listen 80;
    server_name gamerbot.pro;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name gamerbot.pro;

    ssl_certificate /etc/letsencrypt/live/gamerbot.pro/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/gamerbot.pro/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    # WebSocket upgrade headers
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";

    # Proxy headers
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    # API endpoints
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # WebSocket endpoint
    location /api/v1/game/ws {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
    }
}
```

## Step 6: Test and Reload Nginx

```bash
# Test nginx configuration
sudo nginx -t

# If test passes, reload nginx
sudo systemctl reload nginx
```

## Step 7: Configure Firewall (if enabled)

If you have a firewall (ufw), allow HTTP and HTTPS:

```bash
# Allow HTTP (port 80)
sudo ufw allow 'Nginx HTTP'

# Allow HTTPS (port 443)
sudo ufw allow 'Nginx HTTPS'

# Check firewall status
sudo ufw status
```

## Step 8: Verify SSL Certificate Auto-Renewal

Let's Encrypt certificates expire every 90 days. Certbot sets up automatic renewal:

```bash
# Test renewal process
sudo certbot renew --dry-run

# Check renewal timer status
sudo systemctl status certbot.timer
```

## Step 9: Update Docker Compose (Remove Port 8000 Exposure)

Since nginx is now handling external traffic, you can optionally remove the port mapping from docker-compose:

Edit `backend_app/docker/docker-compose.prod.yml`:

```yaml
  backend:
    # ... other config ...
    ports:
      - "8000:8000"  # Remove this line or change to "127.0.0.1:8000:8000" to only allow localhost access
```

Or keep it as is - nginx will still work correctly.

## Step 10: Update Flutter App Endpoint

Update `flutter_app/lib/common/endpoint.dart`:

```dart
class Endpoint {
  static const _backendEndpoint = 'gamerbot.pro'; // Remove :8000 port

  static const opponentSocket = 'wss://$_backendEndpoint/api/v1/game/ws'; // wss:// for secure WebSocket
  static const apiBase = 'https://$_backendEndpoint'; // https:// instead of http://
  static const createRoom = '$apiBase/api/v1/game/rooms';
  static const getRoom = '$apiBase/api/v1/game/rooms';
  static const checkAvailableRoom = '$apiBase/api/v1/game/rooms/available';
  static const matchmakeRoom = '$apiBase/api/v1/game/rooms/matchmake';
}
```

## Step 11: Test the Setup

```bash
# Test HTTP redirect
curl -I http://gamerbot.pro/api/v1/auth/validate-token

# Should return: 301 Moved Permanently to https://

# Test HTTPS endpoint
curl -I https://gamerbot.pro/api/v1/auth/validate-token

# Should return: 200 OK (or appropriate status code)
```

## Troubleshooting

### Check nginx error logs
```bash
sudo tail -f /var/log/nginx/error.log
```

### Check nginx access logs
```bash
sudo tail -f /var/log/nginx/access.log
```

### Restart nginx
```bash
sudo systemctl restart nginx
```

### Check if port 80 and 443 are listening
```bash
sudo netstat -tlnp | grep -E ':(80|443)'
```

### Test backend is accessible from nginx
```bash
curl http://localhost:8000/ok
```

## Security Recommendations

1. **Hide nginx version**: Add to nginx config:
   ```nginx
   server_tokens off;
   ```

2. **Add security headers**: Consider adding headers like:
   ```nginx
   add_header X-Frame-Options "SAMEORIGIN" always;
   add_header X-Content-Type-Options "nosniff" always;
   add_header X-XSS-Protection "1; mode=block" always;
   ```

3. **Rate limiting**: Consider adding rate limiting to prevent abuse:
   ```nginx
   limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
   
   location /api/ {
       limit_req zone=api_limit burst=20;
       proxy_pass http://localhost:8000;
   }
   ```

## Summary

After completing these steps:
- ✅ Nginx listens on port 80 (HTTP) and redirects to HTTPS
- ✅ Nginx listens on port 443 (HTTPS) with SSL certificates
- ✅ All requests are proxied to your backend on port 8000
- ✅ WebSocket connections work securely (wss://)
- ✅ Certificates auto-renew every 90 days
- ✅ Your Flutter app uses HTTPS endpoints

Your API will now be accessible at: `https://gamerbot.pro/api/v1/...`

