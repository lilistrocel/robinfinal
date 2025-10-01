# 🚀 K2 - GITEX Beverage Menu - Deployment Guide

## 📋 Prerequisites

### System Requirements:
- Windows 10/11
- Git installed
- Internet connection for Cloudflare tunnel

## 🛠️ Step-by-Step Deployment

### 1. Clone the Repository
```bash
git clone <your-repository-url>
cd robinfinal
```

### 2. Install Python Dependencies
```bash
# Install Python packages
pip install -r requirements.txt
```

### 3. Download Cloudflare Tunnel
```bash
# Download cloudflared.exe (if not in repository)
# Visit: https://github.com/cloudflare/cloudflared/releases/latest
# Download: cloudflared-windows-amd64.exe
# Rename to: cloudflared.exe
# Place in project root directory
```

### 4. Configure Cloudflare Tunnel

#### Option A: Use Existing Tunnel (Recommended)
If you have the tunnel credentials from the original PC:

1. **Copy credentials file**:
   ```
   Copy from original PC: C:\Users\[username]\.cloudflared\7612c8a3-6f6d-4141-9e4c-9c67ff7c6f54.json
   To new PC: C:\Users\[username]\.cloudflared\7612c8a3-6f6d-4141-9e4c-9c67ff7c6f54.json
   ```

2. **Copy certificate**:
   ```
   Copy from original PC: C:\Users\[username]\.cloudflared\cert.pem
   To new PC: C:\Users\[username]\.cloudflared\cert.pem
   ```

3. **Verify config.yml** (should already be in repository):
   ```yaml
   tunnel: 7612c8a3-6f6d-4141-9e4c-9c67ff7c6f54
   credentials-file: C:\Users\[username]\.cloudflared\7612c8a3-6f6d-4141-9e4c-9c67ff7c6f54.json
   
   ingress:
     - hostname: robinfinal.hydromods.org
       service: http://localhost:5000
     - service: http_status:404
   ```

#### Option B: Create New Tunnel (If credentials lost)
```bash
# Authenticate with Cloudflare
.\cloudflared.exe tunnel login

# Create new tunnel
.\cloudflared.exe tunnel create robinfinal-app-new

# Create DNS route
.\cloudflared.exe tunnel route dns robinfinal-app-new robinfinal.hydromods.org

# Update config.yml with new tunnel ID
```

### 5. Database Setup
The SQLite database will be automatically created when you first run the app:
```
Location: instance/cafe_orders.db
```

### 6. Run the Application

#### Quick Start:
```bash
# Double-click to run
run.bat
```

#### Or PowerShell:
```bash
.\run.ps1
```

#### Manual Start:
```bash
# Terminal 1: Start Flask
python app.py

# Terminal 2: Start Tunnel
.\cloudflared.exe tunnel --config config.yml run robinfinal-app
```

## 🔧 Configuration Files

### Required Files in Repository:
- `app.py` - Main Flask application
- `models.py` - Database models
- `requirements.txt` - Python dependencies
- `config.yml` - Cloudflare tunnel configuration
- `templates/` - HTML templates
- `static/` - Static assets
- `run.ps1` - Startup script
- `run.bat` - Batch startup script

### Files to Transfer Manually:
- `cloudflared.exe` - Cloudflare tunnel executable
- Cloudflare credentials (if using existing tunnel)

## 🌐 Access URLs

After successful deployment:
- **Customer Menu**: https://robinfinal.hydromods.org
- **Supplier Dashboard**: https://robinfinal.hydromods.org/supplier  
- **Local Access**: http://localhost:5000

## 🔍 Troubleshooting

### Common Issues:

1. **Python packages missing**:
   ```bash
   pip install -r requirements.txt
   ```

2. **Cloudflared not found**:
   - Ensure `cloudflared.exe` is in project directory
   - Download from GitHub releases if missing

3. **Tunnel authentication failed**:
   - Copy credentials from original PC
   - Or run `.\cloudflared.exe tunnel login` to re-authenticate

4. **Database errors**:
   - Delete `instance/cafe_orders.db` to reset
   - Database will be recreated automatically

5. **Port 5000 in use**:
   ```bash
   # Find and kill process using port 5000
   netstat -ano | findstr :5000
   taskkill /PID [process_id] /F
   ```

## 📝 Environment Variables (Optional)

Create `.env` file for custom configuration:
```env
FLASK_ENV=production
FLASK_DEBUG=False
DATABASE_PATH=instance/cafe_orders.db
```

## 🔒 Security Notes

- Keep Cloudflare credentials secure
- Don't commit credentials to Git
- Use environment variables for sensitive data
- Consider using production WSGI server for production deployment

## 📊 Monitoring

The startup script provides real-time monitoring:
- Flask application status
- Cloudflare tunnel status
- Automatic restart capabilities

## 🆘 Support

If you encounter issues:
1. Check the troubleshooting section
2. Verify all files are present
3. Ensure internet connectivity for tunnel
4. Check Windows firewall settings

---

**Note**: Replace `<your-repository-url>` with your actual Git repository URL and update usernames/paths as needed for your specific setup.
