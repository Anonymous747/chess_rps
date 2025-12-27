#!/bin/bash
# Minimal server setup script for deploying from Docker Hub
# This script creates the minimal files needed on the server
# Usage: Run this script on your server after connecting via SSH

set -e

echo "🚀 Setting up minimal deployment for Chess RPS Backend"
echo ""

# Get Docker Hub username
read -p "Enter your Docker Hub username: " DOCKERHUB_USERNAME

# Create deployment directory
DEPLOY_DIR="/opt/chess-rps"
mkdir -p "$DEPLOY_DIR"
cd "$DEPLOY_DIR"

echo "📁 Created deployment directory: $DEPLOY_DIR"

# Generate secure passwords
DB_PASSWORD=$(openssl rand -base64 32 | tr -d '\n')
JWT_SECRET=$(openssl rand -hex 32)

echo "🔐 Generated secure passwords"

# Create docker-compose.yml
cat > docker-compose.yml << EOF
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: chess_rps_postgres
    environment:
      POSTGRES_DB: \${DB_NAME:-chess_rps}
      POSTGRES_USER: \${DB_USER:-postgres}
      POSTGRES_PASSWORD: \${DB_PASS:-chess_rps_password}
      POSTGRES_INITDB_ARGS: "--encoding=UTF-8 --lc-collate=C --lc-ctype=C"
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - chess_rps_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U \${DB_USER:-postgres} -d \${DB_NAME:-chess_rps}"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  backend:
    image: ${DOCKERHUB_USERNAME}/chess-rps-backend:latest
    container_name: chess_rps_backend
    environment:
      DB_HOST: postgres
      DB_PORT: 5432
      DB_NAME: \${DB_NAME:-chess_rps}
      DB_USER: \${DB_USER:-postgres}
      DB_PASS: \${DB_PASS:-chess_rps_password}
      SECRET_AUTH: \${SECRET_AUTH:-your-secret-key-change-in-production}
    ports:
      - "8000:8000"
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - chess_rps_network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/ok')"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

volumes:
  postgres_data:
    driver: local

networks:
  chess_rps_network:
    driver: bridge
EOF

echo "✅ Created docker-compose.yml"

# Create .env file
cat > .env << EOF
# Database Configuration
DB_HOST=postgres
DB_PORT=5432
DB_NAME=chess_rps
DB_USER=postgres
DB_PASS=${DB_PASSWORD}

# Application Configuration
SECRET_AUTH=${JWT_SECRET}
EOF

echo "✅ Created .env file with secure passwords"

# Create deploy script
cat > deploy.sh << 'DEPLOY_SCRIPT'
#!/bin/bash
set -e

cd /opt/chess-rps
echo "📥 Pulling latest images..."
docker-compose pull
echo "🚀 Starting services..."
docker-compose up -d
echo "📦 Running database migrations..."
sleep 5
docker exec -it chess_rps_backend python /app/migrate.py || echo "⚠️  Migrations may already be up to date"
echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Container status:"
docker-compose ps
echo ""
echo "🌐 API available at: http://localhost:8000"
echo "📚 API docs at: http://localhost:8000/docs"
DEPLOY_SCRIPT

chmod +x deploy.sh
echo "✅ Created deploy.sh script"

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📝 Files created in $DEPLOY_DIR:"
echo "   - docker-compose.yml"
echo "   - .env (contains your secrets - keep secure!)"
echo "   - deploy.sh"
echo ""
echo "📋 Next steps:"
echo "   1. Make sure your Docker image is pushed to Docker Hub:"
echo "      ${DOCKERHUB_USERNAME}/chess-rps-backend:latest"
echo ""
echo "   2. Run deployment:"
echo "      cd $DEPLOY_DIR"
echo "      ./deploy.sh"
echo ""
echo "   3. Or manually:"
echo "      cd $DEPLOY_DIR"
echo "      docker-compose pull"
echo "      docker-compose up -d"
echo "      docker exec -it chess_rps_backend python /app/migrate.py"
echo ""

