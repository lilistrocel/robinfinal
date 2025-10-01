# 🐧 K2 - GITEX Beverage Menu - Ubuntu Deployment Guide

## 📋 Prerequisites

### System Requirements:
- Ubuntu 18.04+ (or other Debian-based Linux)
- Internet connection for Cloudflare tunnel
- sudo privileges

## 🛠️ Step-by-Step Deployment

### 1. Update System and Install Dependencies
```bash
# Update package list
sudo apt update

# Install Python and pip
sudo apt install python3 python3-pip python3-venv git curl -y

# Verify installation
python3 --version
pip3 --version
```

### 2. Clone the Repository
```bash
git clone <your-repository-url>
cd robinfinal
```

### 3. Set Up Python Virtual Environment
```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install Python dependencies
pip install -r requirements.txt
```

### 4. Download Cloudflare Tunnel
```bash
# Download cloudflared for Linux
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared

# Make it executable
chmod +x cloudflared
```

### 5. Configure Cloudflare Tunnel

#### Option A: Use Existing Tunnel (Recommended)
If you have the tunnel credentials from the original Windows PC:

1. **Create cloudflared directory**:
   ```bash
   mkdir -p ~/.cloudflared
   ```

2. **Copy credentials from Windows PC**:
   ```bash
   # Copy these files from Windows PC:
   # C:\Users\[username]\.cloudflared\7612c8a3-6f6d-4141-9e4c-9c67ff7c6f54.json
   # C:\Users\[username]\.cloudflared\cert.pem
   # 
   # To Ubuntu:
   # ~/.cloudflared/7612c8a3-6f6d-4141-9e4c-9c67ff7c6f54.json
   # ~/.cloudflared/cert.pem
   ```

3. **Update config.yml** (adjust path for Linux):
   ```yaml
   tunnel: 7612c8a3-6f6d-4141-9e4c-9c67ff7c6f54
   credentials-file: /home/[your-username]/.cloudflared/7612c8a3-6f6d-4141-9e4c-9c67ff7c6f54.json
   
   ingress:
     - hostname: robinfinal.hydromods.org
       service: http://localhost:5000
     - service: http_status:404
   ```

#### Option B: Create New Tunnel (If credentials lost)
```bash
# Authenticate with Cloudflare
./cloudflared tunnel login

# Create new tunnel
./cloudflared tunnel create robinfinal-app-ubuntu

# Create DNS route
./cloudflared tunnel route dns robinfinal-app-ubuntu robinfinal.hydromods.org

# Update config.yml with new tunnel ID
```

### 6. Database Setup
The SQLite database will be automatically created:
```bash
# Create instance directory
mkdir -p instance
# Database will be created at: instance/cafe_orders.db
```

### 7. Run the Application

#### Quick Start:
```bash
# Make run script executable
chmod +x run.sh

# Run the application
./run.sh
```

#### Manual Start:
```bash
# Terminal 1: Activate venv and start Flask
source venv/bin/activate
python3 app.py

# Terminal 2: Start Tunnel (in new terminal)
./cloudflared tunnel --config config.yml run robinfinal-app
```

## 🔧 Configuration Files

### Update config.yml for Linux:
```yaml
tunnel: 7612c8a3-6f6d-4141-9e4c-9c67ff7c6f54
credentials-file: /home/[your-username]/.cloudflared/7612c8a3-6f6d-4141-9e4c-9c67ff7c6f54.json

ingress:
  - hostname: robinfinal.hydromods.org
    service: http://localhost:5000
  - service: http_status:404
```

### Required Files in Repository:
- `app.py` - Main Flask application
- `models.py` - Database models
- `requirements.txt` - Python dependencies
- `config.yml` - Cloudflare tunnel configuration
- `templates/` - HTML templates
- `static/` - Static assets
- `run.sh` - Linux startup script
- `setup.sh` - Linux setup script

## 🌐 Access URLs

After successful deployment:
- **Customer Menu**: https://robinfinal.hydromods.org
- **Supplier Dashboard**: https://robinfinal.hydromods.org/supplier  
- **Local Access**: http://localhost:5000

## 🔍 Troubleshooting

### Common Issues:

1. **Python not found**:
   ```bash
   sudo apt install python3 python3-pip python3-venv
   ```

2. **Permission denied for cloudflared**:
   ```bash
   chmod +x cloudflared
   ```

3. **Virtual environment issues**:
   ```bash
   # Recreate virtual environment
   rm -rf venv
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

4. **Port 5000 in use**:
   ```bash
   # Find and kill process using port 5000
   sudo lsof -i :5000
   sudo kill -9 [PID]
   ```

5. **Cloudflared tunnel authentication failed**:
   ```bash
   # Re-authenticate
   ./cloudflared tunnel login
   ```

6. **Database permission errors**:
   ```bash
   # Fix permissions
   chmod 755 instance/
   chmod 644 instance/cafe_orders.db  # if exists
   ```

## 🔒 Security Notes

- Keep Cloudflare credentials secure
- Don't commit credentials to Git
- Consider using systemd service for production
- Set up firewall rules if needed:
  ```bash
  sudo ufw allow 5000  # Only if accessing locally from other machines
  ```

## 🚀 Production Setup (Optional)

### Create systemd service:
```bash
# Create service file
sudo nano /etc/systemd/system/k2-beverage.service
```

Service file content:
```ini
[Unit]
Description=K2 GITEX Beverage Menu
After=network.target

[Service]
Type=simple
User=[your-username]
WorkingDirectory=/home/[your-username]/robinfinal
Environment=PATH=/home/[your-username]/robinfinal/venv/bin
ExecStart=/home/[your-username]/robinfinal/venv/bin/python app.py
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable and start service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable k2-beverage
sudo systemctl start k2-beverage
```

## 📊 Monitoring

Check application status:
```bash
# Check Flask process
ps aux | grep python

# Check Cloudflare tunnel
ps aux | grep cloudflared

# Check logs
journalctl -u k2-beverage -f  # if using systemd
```

---

**Note**: Replace `[your-username]` with your actual Ubuntu username and `<your-repository-url>` with your Git repository URL.
