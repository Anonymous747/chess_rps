# DigitalOcean Deployment Guide

## Connecting to Your DigitalOcean Droplet

### 1. Using SSH with Password Authentication

**Initial Connection (if password authentication is enabled):**
```bash
ssh root@YOUR_DROPLET_IP
# or
ssh root@YOUR_DROPLET_IP -p 22
```

Replace `YOUR_DROPLET_IP` with your droplet's public IP address (found in DigitalOcean control panel).

### 2. Using SSH with Key-Based Authentication (Recommended)

**Step 1: Generate SSH Key Pair (if you don't have one)**

On Windows (PowerShell):
```powershell
# Generate SSH key
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Default location: C:\Users\YourUsername\.ssh\id_rsa
```

**Step 2: Add Public Key to DigitalOcean**

1. Copy your public key:
   ```powershell
   cat C:\Users\YourUsername\.ssh\id_rsa.pub
   ```

2. In DigitalOcean Dashboard:
   - Go to **Settings** → **Security** → **SSH Keys**
   - Click **Add SSH Key**
   - Paste your public key and give it a name
   - Click **Add SSH Key**

**Step 3: Add SSH Key When Creating Droplet**

- When creating a new droplet, select your SSH key in the **Authentication** section
- Or add it to existing droplet via DigitalOcean console

**Step 4: Connect Using SSH Key**

```bash
ssh root@YOUR_DROPLET_IP
# or specify key explicitly
ssh -i C:\Users\YourUsername\.ssh\id_rsa root@YOUR_DROPLET_IP
```

### 3. Using DigitalOcean Web Console

1. Go to DigitalOcean Dashboard
2. Click on your droplet
3. Click **Access** → **Launch Droplet Console**
4. This opens a browser-based terminal

### 4. Using PowerShell (Windows)

```powershell
# Basic connection
ssh root@YOUR_DROPLET_IP

# With specific key
ssh -i C:\Users\YourUsername\.ssh\id_rsa root@YOUR_DROPLET_IP

# With verbose output (for troubleshooting)
ssh -v root@YOUR_DROPLET_IP
```

## Initial Droplet Setup

After connecting, set up your server:

### 1. Update System

```bash
# Ubuntu/Debian
apt update && apt upgrade -y

# CentOS/RHEL
yum update -y
```

### 2. Create Non-Root User (Recommended)

```bash
# Create new user
adduser your_username

# Add to sudo group
usermod -aG sudo your_username

# Copy SSH keys to new user
rsync --archive --chown=your_username:your_username ~/.ssh /home/your_username

# Switch to new user
su - your_username
```

### 3. Install Essential Tools

```bash
# Install Docker (for containerized deployment)
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Add user to docker group (if using non-root user)
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Git
sudo apt install git -y  # Ubuntu/Debian
# or
sudo yum install git -y  # CentOS/RHEL

# Install Python (if needed for direct deployment)
sudo apt install python3 python3-pip python3-venv -y
```

### 4. Configure Firewall

```bash
# UFW (Ubuntu)
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw allow 8000/tcp # FastAPI (temporary, use reverse proxy in production)
sudo ufw enable

# Or firewalld (CentOS/RHEL)
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=8000/tcp
sudo firewall-cmd --reload
```

## Deploying Your Application

### Option 1: Docker Deployment (Recommended)

**Step 1: Clone Your Repository**

```bash
cd /opt  # or wherever you want to store the app
git clone YOUR_REPO_URL chess_rps
cd chess_rps/backend_app
```

**Step 2: Set Up Environment Variables**

```bash
# Create environment file
nano docker/env.prod
```

Add your production environment variables:
```env
POSTGRES_DB=chess_rps
POSTGRES_USER=postgres
POSTGRES_PASSWORD=YOUR_SECURE_PASSWORD
DB_HOST=postgres  # Docker service name
DB_PORT=5432
DB_NAME=chess_rps
DB_USER=postgres
DB_PASS=YOUR_SECURE_PASSWORD
SECRET_AUTH=YOUR_JWT_SECRET_KEY
```

**Step 3: Deploy with Docker Compose**

```bash
# Start services
docker-compose -f docker/docker-compose.yml --env-file docker/env.prod up -d

# View logs
docker-compose -f docker/docker-compose.yml logs -f

# Check status
docker-compose -f docker/docker-compose.yml ps
```

**Step 4: Run Database Migrations**

```bash
# Inside backend_app directory
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Update env.local with production DB credentials
python migrate.py
```

### Option 2: Direct Python Deployment

**Step 1: Install Dependencies**

```bash
cd /opt/chess_rps/backend_app
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

**Step 2: Set Up PostgreSQL**

```bash
# Install PostgreSQL
sudo apt install postgresql postgresql-contrib -y

# Create database and user
sudo -u postgres psql
```

In PostgreSQL prompt:
```sql
CREATE DATABASE chess_rps;
CREATE USER postgres WITH PASSWORD 'YOUR_PASSWORD';
ALTER ROLE postgres SET client_encoding TO 'utf8';
ALTER ROLE postgres SET default_transaction_isolation TO 'read committed';
ALTER ROLE postgres SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE chess_rps TO postgres;
\q
```

**Step 3: Configure Environment**

```bash
# Create env.local
nano env.local
```

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=chess_rps
DB_USER=postgres
DB_PASS=YOUR_PASSWORD
SECRET_AUTH=YOUR_JWT_SECRET_KEY
```

**Step 4: Run Migrations**

```bash
python migrate.py
```

**Step 5: Run FastAPI Server**

```bash
# Development (not recommended for production)
uvicorn main:app --host 0.0.0.0 --port 8000

# Production with Gunicorn (recommended)
pip install gunicorn
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

### Option 3: Using Systemd Service (for Direct Deployment)

Create a systemd service file for production:

```bash
sudo nano /etc/systemd/system/chess-rps-backend.service
```

```ini
[Unit]
Description=Chess RPS Backend API
After=network.target postgresql.service

[Service]
Type=notify
User=your_username
WorkingDirectory=/opt/chess_rps/backend_app
Environment="PATH=/opt/chess_rps/backend_app/venv/bin"
ExecStart=/opt/chess_rps/backend_app/venv/bin/gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable and start service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable chess-rps-backend
sudo systemctl start chess-rps-backend
sudo systemctl status chess-rps-backend
```

## Setting Up Reverse Proxy (Nginx)

For production, use Nginx as a reverse proxy:

**Step 1: Install Nginx**

```bash
sudo apt install nginx -y
```

**Step 2: Configure Nginx**

```bash
sudo nano /etc/nginx/sites-available/chess-rps
```

```nginx
server {
    listen 80;
    server_name YOUR_DOMAIN_OR_IP;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

**Step 3: Enable Site**

```bash
sudo ln -s /etc/nginx/sites-available/chess-rps /etc/nginx/sites-enabled/
sudo nginx -t  # Test configuration
sudo systemctl restart nginx
```

## SSL/HTTPS Setup (Let's Encrypt)

**Step 1: Install Certbot**

```bash
sudo apt install certbot python3-certbot-nginx -y
```

**Step 2: Obtain Certificate**

```bash
sudo certbot --nginx -d yourdomain.com
```

Follow the prompts to complete setup.

## Troubleshooting Connection Issues

### Can't Connect via SSH

1. **Check Droplet Status**: Ensure droplet is running in DigitalOcean dashboard
2. **Check Firewall Rules**: 
   - DigitalOcean Firewall: Ensure SSH (port 22) is allowed
   - Server Firewall: Ensure SSH is allowed
3. **Check IP Address**: Verify you're using the correct public IP
4. **Check SSH Key**: Ensure your public key is added to the droplet
5. **Verbose SSH**: Use `ssh -v root@YOUR_IP` to see detailed connection info

### Connection Refused

- Check if SSH service is running: `sudo systemctl status ssh`
- Verify port 22 is open: `sudo netstat -tlnp | grep 22`
- Check DigitalOcean firewall rules

### Permission Denied

- Verify SSH key is correct
- Check file permissions: `chmod 600 ~/.ssh/id_rsa`
- Verify public key is in `~/.ssh/authorized_keys` on server

## Security Best Practices

1. **Disable Root Login**: After setting up sudo user, disable root SSH
2. **Use SSH Keys Only**: Disable password authentication
3. **Change SSH Port**: Use non-standard port (optional)
4. **Keep System Updated**: Regularly run `apt update && apt upgrade`
5. **Use Firewall**: Configure UFW or firewalld
6. **Regular Backups**: Set up automated backups in DigitalOcean
7. **Monitor Logs**: Check `/var/log/auth.log` for failed login attempts

## Quick Reference Commands

```bash
# Connect to droplet
ssh root@YOUR_DROPLET_IP

# Check system status
sudo systemctl status nginx
sudo systemctl status docker
sudo systemctl status chess-rps-backend  # if using systemd

# View logs
docker-compose logs -f
sudo journalctl -u chess-rps-backend -f

# Check disk space
df -h

# Check memory
free -h

# Check running processes
htop  # or top
```

## Next Steps

1. Set up domain name and point DNS to droplet IP
2. Configure SSL certificate
3. Set up monitoring (e.g., DigitalOcean Monitoring)
4. Configure automated backups
5. Set up CI/CD for automated deployments

