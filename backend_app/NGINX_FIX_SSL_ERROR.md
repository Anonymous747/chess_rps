# Fix: nginx SSL Certificate Error

If you get the error:
```
no "ssl_certificate" is defined for the "listen ... ssl" directive
```

This means you're trying to use SSL before getting the certificates. Follow these steps to fix it:

## Solution: Use HTTP-Only Config First

### Step 1: Remove the existing symlink

```bash
sudo rm /etc/nginx/sites-enabled/gamerbot.pro
```

### Step 2: Replace config with HTTP-only version

```bash
sudo nano /etc/nginx/sites-available/gamerbot.pro
```

Replace the entire file content with this (HTTP-only, no SSL):

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

### Step 3: Create the symlink

```bash
sudo ln -s /etc/nginx/sites-available/gamerbot.pro /etc/nginx/sites-enabled/
```

### Step 4: Test nginx configuration

```bash
sudo nginx -t
```

Should output: `nginx: configuration file /etc/nginx/nginx.conf test is successful`

### Step 5: Reload nginx

```bash
sudo systemctl reload nginx
```

### Step 6: Get SSL certificates with certbot

```bash
sudo certbot --nginx -d gamerbot.pro
```

Certbot will:
- Obtain SSL certificates
- **Automatically update your nginx config** to add SSL directives
- Add HTTPS redirect

### Step 7: Verify after certbot

After certbot runs, test again:

```bash
sudo nginx -t
sudo systemctl reload nginx

# Test HTTPS endpoint
curl https://gamerbot.pro/ok
```

## Quick Fix Commands (Copy-Paste)

```bash
# Remove symlink
sudo rm /etc/nginx/sites-enabled/gamerbot.pro

# Copy HTTP-only template (if you have it)
# OR manually edit the file as shown above
sudo nano /etc/nginx/sites-available/gamerbot.pro

# Recreate symlink
sudo ln -s /etc/nginx/sites-available/gamerbot.pro /etc/nginx/sites-enabled/

# Test and reload
sudo nginx -t && sudo systemctl reload nginx

# Get SSL certificate (certbot will add SSL config automatically)
sudo certbot --nginx -d gamerbot.pro
```





