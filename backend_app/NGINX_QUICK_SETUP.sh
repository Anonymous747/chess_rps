#!/bin/bash

# Quick setup script for nginx with HTTPS on Ubuntu/Debian
# Run this script with sudo: sudo bash NGINX_QUICK_SETUP.sh

set -e

DOMAIN="gamerbot.pro"
BACKEND_PORT="8000"
NGINX_CONFIG="/etc/nginx/sites-available/${DOMAIN}"

echo "🚀 Setting up nginx with HTTPS for ${DOMAIN}..."

# Step 1: Install nginx if not already installed
if ! command -v nginx &> /dev/null; then
    echo "📦 Installing nginx..."
    apt update
    apt install nginx -y
    systemctl enable nginx
else
    echo "✅ nginx is already installed"
fi

# Step 2: Install certbot if not already installed
if ! command -v certbot &> /dev/null; then
    echo "📦 Installing certbot..."
    apt install certbot python3-certbot-nginx -y
else
    echo "✅ certbot is already installed"
fi

# Step 3: Create nginx configuration
echo "📝 Creating nginx configuration..."
cat > "${NGINX_CONFIG}" << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name DOMAIN_PLACEHOLDER;

    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        return 301 https://$server_name$request_uri;
    }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name DOMAIN_PLACEHOLDER;

    ssl_certificate /etc/letsencrypt/live/DOMAIN_PLACEHOLDER/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/DOMAIN_PLACEHOLDER/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    server_tokens off;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Host $host;

    location /api/v1/game/ws {
        proxy_pass http://localhost:BACKEND_PORT_PLACEHOLDER;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
        proxy_connect_timeout 75s;
    }

    location /api/ {
        proxy_pass http://localhost:BACKEND_PORT_PLACEHOLDER;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
        proxy_send_timeout 300s;
    }

    location /ok {
        proxy_pass http://localhost:BACKEND_PORT_PLACEHOLDER;
        access_log off;
    }
}
EOF

# Replace placeholders
sed -i "s/DOMAIN_PLACEHOLDER/${DOMAIN}/g" "${NGINX_CONFIG}"
sed -i "s/BACKEND_PORT_PLACEHOLDER/${BACKEND_PORT}/g" "${NGINX_CONFIG}"

# Step 4: Create temporary HTTP-only config for certbot
echo "📝 Creating temporary HTTP config for certbot..."
cat > "/etc/nginx/sites-available/${DOMAIN}.temp" << EOF
server {
    listen 80;
    server_name ${DOMAIN};

    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location /api/ {
        proxy_pass http://localhost:${BACKEND_PORT};
    }
}
EOF

# Step 5: Enable site
echo "🔗 Enabling nginx site..."
rm -f /etc/nginx/sites-enabled/default
ln -sf "${NGINX_CONFIG}.temp" /etc/nginx/sites-enabled/${DOMAIN}

# Step 6: Test and reload nginx
echo "🧪 Testing nginx configuration..."
nginx -t

echo "🔄 Reloading nginx..."
systemctl reload nginx

# Step 7: Obtain SSL certificate
echo "🔒 Obtaining SSL certificate with certbot..."
echo "You will be prompted for:"
echo "  - Email address"
echo "  - Agreement to terms"
echo "  - Whether to redirect HTTP to HTTPS (recommended: Yes)"
echo ""
read -p "Press Enter to continue with certbot..."

certbot --nginx -d ${DOMAIN}

# Step 8: Remove temporary config and use final config
echo "📝 Applying final nginx configuration..."
rm -f /etc/nginx/sites-enabled/${DOMAIN}
ln -sf "${NGINX_CONFIG}" /etc/nginx/sites-enabled/${DOMAIN}

# Step 9: Test and reload nginx
echo "🧪 Testing final nginx configuration..."
nginx -t

echo "🔄 Reloading nginx with final configuration..."
systemctl reload nginx

# Step 10: Test certificate renewal
echo "🔄 Testing certificate auto-renewal..."
certbot renew --dry-run

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Update Flutter app endpoint.dart to use https://${DOMAIN}"
echo "2. Test your API: curl https://${DOMAIN}/ok"
echo "3. Check nginx logs: sudo tail -f /var/log/nginx/error.log"
echo ""
echo "🔒 SSL certificate will auto-renew every 90 days"
echo "📝 Configuration file: ${NGINX_CONFIG}"





