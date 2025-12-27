# Server Setup Commands (Copy-Paste Ready)

Copy and paste these commands on your server to set up the deployment.

## Quick Setup (Copy All at Once)

Run this on your server to create everything needed:

```bash
cd /opt/chess-rps

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: chess_rps_postgres
    environment:
      POSTGRES_DB: ${DB_NAME:-chess_rps}
      POSTGRES_USER: ${DB_USER:-postgres}
      POSTGRES_PASSWORD: ${DB_PASS:-chess_rps_password}
      POSTGRES_INITDB_ARGS: "--encoding=UTF-8 --lc-collate=C --lc-ctype=C"
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - chess_rps_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-postgres} -d ${DB_NAME:-chess_rps}"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  backend:
    image: YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest
    container_name: chess_rps_backend
    environment:
      DB_HOST: postgres
      DB_PORT: 5432
      DB_NAME: ${DB_NAME:-chess_rps}
      DB_USER: ${DB_USER:-postgres}
      DB_PASS: ${DB_PASS:-chess_rps_password}
      SECRET_AUTH: ${SECRET_AUTH:-your-secret-key-change-in-production}
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

# Create .env file with secure passwords
cat > .env << EOF
DB_NAME=chess_rps
DB_USER=postgres
DB_PASS=$(openssl rand -base64 32 | tr -d '\n')
SECRET_AUTH=$(openssl rand -hex 32)
EOF

echo "Files created! Now edit docker-compose.yml and replace YOUR_DOCKERHUB_USERNAME with your actual Docker Hub username"
```

## Step-by-Step Setup

### Step 1: Create docker-compose.yml

```bash
cd /opt/chess-rps
nano docker-compose.yml
```

Paste this content (replace `YOUR_DOCKERHUB_USERNAME` with your Docker Hub username):

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: chess_rps_postgres
    environment:
      POSTGRES_DB: ${DB_NAME:-chess_rps}
      POSTGRES_USER: ${DB_USER:-postgres}
      POSTGRES_PASSWORD: ${DB_PASS:-chess_rps_password}
      POSTGRES_INITDB_ARGS: "--encoding=UTF-8 --lc-collate=C --lc-ctype=C"
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - chess_rps_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-postgres} -d ${DB_NAME:-chess_rps}"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  backend:
    image: YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest
    container_name: chess_rps_backend
    environment:
      DB_HOST: postgres
      DB_PORT: 5432
      DB_NAME: ${DB_NAME:-chess_rps}
      DB_USER: ${DB_USER:-postgres}
      DB_PASS: ${DB_PASS:-chess_rps_password}
      SECRET_AUTH: ${SECRET_AUTH:-your-secret-key-change-in-production}
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
```

Save (Ctrl+X, Y, Enter)

### Step 2: Replace YOUR_DOCKERHUB_USERNAME

```bash
# Replace YOUR_DOCKERHUB_USERNAME with your actual username
sed -i 's/YOUR_DOCKERHUB_USERNAME/your_actual_username/g' docker-compose.yml

# Or edit manually
nano docker-compose.yml
```

### Step 3: Create .env file

```bash
# Generate secure passwords and create .env
cat > .env << EOF
DB_NAME=chess_rps
DB_USER=postgres
DB_PASS=$(openssl rand -base64 32 | tr -d '\n')
SECRET_AUTH=$(openssl rand -hex 32)
EOF

# View the generated file (optional)
cat .env
```

### Step 4: Deploy

```bash
# Pull images
docker-compose pull

# Start services
docker-compose up -d

# Run migrations
docker exec -it chess_rps_backend python /app/migrate.py

# Check status
docker-compose ps
```

## Verify Files

```bash
# Check if files exist
ls -la /opt/chess-rps/

# Verify docker-compose.yml syntax
docker-compose config

# Check environment variables
cat .env
```

