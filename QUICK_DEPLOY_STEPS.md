# Quick Deploy Steps - Copy & Paste

## On Your Local Machine (Windows PowerShell)

```powershell
# Step 1: Go to backend directory
cd D:\Programs\chess_rps\backend_app

# Step 2: Build Docker image
docker build -t chess-rps-backend:latest .

# Step 3: Tag for Docker Hub (replace YOUR_USERNAME with your actual Docker Hub username)
docker tag chess-rps-backend:latest YOUR_USERNAME/chess-rps-backend:latest

# Step 4: Login to Docker Hub (if not already logged in)
docker login

# Step 5: Push to Docker Hub
docker push YOUR_USERNAME/chess-rps-backend:latest
```

**Replace `YOUR_USERNAME` with your Docker Hub username!**

## On Your Server (Linux)

```bash
# Step 1: SSH into server
ssh root@YOUR_SERVER_IP

# Step 2: Go to deployment directory
cd /opt/chess-rps

# Step 3: If using docker-compose-simple.yml, update it first:
# Edit docker-compose.yml and replace YOUR_DOCKERHUB_USERNAME with your actual username
nano docker-compose.yml
# Change: image: YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest
# To:     image: YOUR_USERNAME/chess-rps-backend:latest
# Save: Ctrl+X, Y, Enter

# Step 4: Pull latest image
docker-compose pull

# Step 5: Stop old containers
docker-compose down

# Step 6: Start with new image
docker-compose up -d --force-recreate

# Step 7: Verify assets exist
docker exec chess_rps_backend ls -la /app/assets/images/

# Step 8: Test endpoint
curl http://localhost:8000/api/v1/assets/health
curl http://localhost:8000/api/v1/assets/figures/cardinal/white/king
```

## Update docker-compose.prod.yml to Use Image Instead of Build

If you want to use `docker-compose.prod.yml` with Docker Hub image:

```bash
# On server, edit the file
cd /opt/chess-rps/backend_app/docker
nano docker-compose.prod.yml
```

Change the backend section from:
```yaml
backend:
  build:
    context: ..
    dockerfile: Dockerfile
```

To:
```yaml
backend:
  image: YOUR_USERNAME/chess-rps-backend:latest
```

Then use:
```bash
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d --force-recreate
```

## Complete Example (if your Docker Hub username is "johndoe")

### Local:
```powershell
cd D:\Programs\chess_rps\backend_app
docker build -t chess-rps-backend:latest .
docker tag chess-rps-backend:latest johndoe/chess-rps-backend:latest
docker login
docker push johndoe/chess-rps-backend:latest
```

### Server:
```bash
cd /opt/chess-rps
docker-compose pull
docker-compose down
docker-compose up -d --force-recreate
docker exec chess_rps_backend ls /app/assets/images/
curl http://localhost:8000/api/v1/assets/health
```

