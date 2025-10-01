# 🐧 K2 - GITEX Beverage Menu - Ubuntu Quick Reference

## 📥 New Ubuntu PC Setup (One-Time)

```bash
# 1. Clone repository
git clone <your-repo-url>
cd robinfinal

# 2. Run setup script
chmod +x setup.sh
./setup.sh

# 3. Copy Cloudflare credentials from Windows PC
# From Windows: C:\Users\[username]\.cloudflared\
# To Ubuntu:    ~/.cloudflared/

# 4. Start application
./run.sh
```

## 🏃‍♂️ Daily Operations

### Start Application:
```bash
./run.sh              # Linux startup script
```

### Stop Application:
- Press `Ctrl+C` in the terminal

### Update Code:
```bash
git pull origin main
./run.sh
```

## 🌐 URLs

| Service | URL |
|---------|-----|
| **Customer Menu** | https://robinfinal.hydromods.org |
| **Supplier Dashboard** | https://robinfinal.hydromods.org/supplier |
| **Local Access** | http://localhost:5000 |

## 📁 Important Files

| File | Purpose |
|------|---------|
| `run.sh` | Start both Flask + Tunnel (Linux) |
| `setup.sh` | One-time setup script (Linux) |
| `config.yml` | Cloudflare tunnel config |
| `app.py` | Main Flask application |
| `requirements.txt` | Python dependencies |
| `venv/` | Python virtual environment |
| `instance/cafe_orders.db` | SQLite database |

## 🔧 System Commands

### Python Virtual Environment:
```bash
# Activate
source venv/bin/activate

# Deactivate
deactivate

# Recreate if needed
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### File Permissions:
```bash
# Make scripts executable
chmod +x setup.sh
chmod +x run.sh
chmod +x cloudflared
```

## 🔧 Troubleshooting

| Problem | Solution |
|---------|----------|
| **Dependencies missing** | `./setup.sh` or `pip install -r requirements.txt` |
| **Cloudflared not found** | `curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared && chmod +x cloudflared` |
| **Permission denied** | `chmod +x setup.sh run.sh cloudflared` |
| **Port 5000 in use** | `sudo lsof -i :5000` then `sudo kill -9 [PID]` |
| **Virtual env issues** | `rm -rf venv && python3 -m venv venv` |
| **Database errors** | `rm instance/cafe_orders.db` |

## 📊 Process Management

### Check Running Processes:
```bash
# Check Flask
ps aux | grep python.*app.py

# Check Cloudflare tunnel
ps aux | grep cloudflared

# Check ports
sudo lsof -i :5000
```

### Kill Processes:
```bash
# Kill Flask
pkill -f "python.*app.py"

# Kill Cloudflare tunnel
pkill -f "cloudflared.*tunnel"

# Kill specific PID
kill -9 [PID]
```

## 🔒 File Transfer from Windows

### Copy Cloudflare Credentials:
```bash
# On Windows PC, copy these files:
# C:\Users\[username]\.cloudflared\7612c8a3-6f6d-4141-9e4c-9c67ff7c6f54.json
# C:\Users\[username]\.cloudflared\cert.pem

# Transfer to Ubuntu (using scp, USB, or cloud storage)
# Place them at:
# ~/.cloudflared/7612c8a3-6f6d-4141-9e4c-9c67ff7c6f54.json
# ~/.cloudflared/cert.pem

# Set correct permissions
chmod 600 ~/.cloudflared/*.json
chmod 600 ~/.cloudflared/*.pem
```

## 🚀 Production Setup (Optional)

### Create systemd service:
```bash
# Create service file
sudo nano /etc/systemd/system/k2-beverage.service
```

Service content:
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

Enable service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable k2-beverage
sudo systemctl start k2-beverage
sudo systemctl status k2-beverage
```

## 🆘 Emergency Commands

```bash
# Kill all related processes
pkill -f "python.*app.py"
pkill -f "cloudflared"

# Reset database
rm instance/cafe_orders.db

# Re-authenticate tunnel
./cloudflared tunnel login

# Check tunnel status
./cloudflared tunnel info robinfinal-app

# Check system resources
htop
df -h
free -h
```

## 🌍 Network Configuration

### Firewall (if needed):
```bash
# Allow local access from other machines
sudo ufw allow 5000

# Check firewall status
sudo ufw status
```

### Check connectivity:
```bash
# Test local Flask
curl http://localhost:5000

# Test external access
curl https://robinfinal.hydromods.org
```

---
**📞 Support**: Check DEPLOYMENT_UBUNTU.md for detailed instructions
