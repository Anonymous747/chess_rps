# Troubleshooting Docker Deployment

## Error: Can't Pull Backend Image

If you see:
```
Pulling backend  ... error
```

### Common Causes and Solutions

### 1. Check if Image Name is Correct

```bash
# Check what's in your docker-compose.yml
cat docker-compose.yml | grep "image:"

# Make sure it's not still "YOUR_DOCKERHUB_USERNAME"
# It should be something like: "yourusername/chess-rps-backend:latest"
```

### 2. Verify Image Exists on Docker Hub

```bash
# Try to pull the image directly to see the error
docker pull YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest

# Replace YOUR_DOCKERHUB_USERNAME with your actual username
```

### 3. Check if Image Was Pushed

You need to push the image from your local machine first:

**On your local machine:**

```bash
cd backend_app

# Build the image
docker build -t chess-rps-backend:latest .

# Tag it with your Docker Hub username
docker tag chess-rps-backend:latest YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest

# Login to Docker Hub
docker login

# Push the image
docker push YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest
```

### 4. Check Docker Hub Image Name Format

The image name must be in the format: `username/repository:tag`

Examples:
- ✅ `johndoe/chess-rps-backend:latest`
- ✅ `mycompany/chess-rps-backend:v1.0.0`
- ❌ `chess-rps-backend:latest` (missing username/)
- ❌ `YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest` (placeholder not replaced)

### 5. Verify Docker Hub Repository

1. Go to https://hub.docker.com
2. Login to your account
3. Check if the repository `chess-rps-backend` exists
4. Make sure it's public (or you're logged in on the server if it's private)

### 6. Update docker-compose.yml on Server

```bash
# Edit docker-compose.yml
nano docker-compose.yml

# Find the line:
#   image: YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest
# Replace YOUR_DOCKERHUB_USERNAME with your actual Docker Hub username
# For example:
#   image: johndoe/chess-rps-backend:latest

# Save and exit (Ctrl+X, Y, Enter)

# Verify the change
cat docker-compose.yml | grep "image:"
```

### 7. Login to Docker Hub on Server (if image is private)

If your image is private, you need to login:

```bash
docker login
# Enter your Docker Hub username and password
```

### 8. Get Full Error Message

```bash
# Get more details about the error
docker-compose pull --verbose

# Or check docker logs
docker-compose pull 2>&1 | tee pull-error.log
cat pull-error.log
```

## Complete Setup Checklist

- [ ] Built Docker image on local machine
- [ ] Tagged image with Docker Hub username
- [ ] Logged into Docker Hub (`docker login`)
- [ ] Pushed image to Docker Hub (`docker push`)
- [ ] Verified image exists on Docker Hub website
- [ ] Created docker-compose.yml on server
- [ ] Replaced `YOUR_DOCKERHUB_USERNAME` with actual username in docker-compose.yml
- [ ] Created .env file on server
- [ ] Ran `docker-compose pull` on server

## Quick Test

Test if you can pull the image directly:

```bash
# Replace with your actual Docker Hub username
docker pull YOUR_DOCKERHUB_USERNAME/chess-rps-backend:latest
```

If this works, then the issue is with docker-compose.yml configuration.
If this fails, then the image doesn't exist or there's an authentication issue.

