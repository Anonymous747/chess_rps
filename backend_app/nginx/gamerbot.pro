# Nginx configuration for gamerbot.pro
# IMPORTANT: This is an HTTP-only configuration for use BEFORE running certbot
# After running certbot, it will automatically update this file with SSL configuration
#
# Setup steps:
# 1. Copy this file to /etc/nginx/sites-available/gamerbot.pro
# 2. Create symlink: sudo ln -s /etc/nginx/sites-available/gamerbot.pro /etc/nginx/sites-enabled/
# 3. Test: sudo nginx -t && sudo systemctl reload nginx
# 4. Get SSL: sudo certbot --nginx -d gamerbot.pro (certbot will add SSL config automatically)

# HTTP server (certbot will add HTTPS server block automatically)
server {
    listen 80;
    listen [::]:80;
    server_name gamerbot.pro;

    # Let's Encrypt challenge location (required for certbot)
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    # Security headers
    server_tokens off;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Proxy settings
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Forwarded-Port $server_port;

    # WebSocket endpoint - needs special handling
    location /api/v1/game/ws {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket timeouts
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

# Note: After running certbot, it will:
# 1. Add a new server block listening on port 443 with SSL
# 2. Add SSL certificate paths
# 3. Change this server block to redirect HTTP to HTTPS
# 4. Add SSL-related directives
