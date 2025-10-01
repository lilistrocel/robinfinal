# 🚀 How to Run K2 - GITEX Beverage Menu

## Quick Start

### Option 1: Double-click to run (Easiest)
```
Double-click: run.bat
```

### Option 2: PowerShell (Recommended)
```powershell
.\run.ps1
```

### Option 3: Command Line
```powershell
powershell -ExecutionPolicy Bypass -File run.ps1
```

## What the script does:

1. [OK] Checks for required files (app.py, cloudflared.exe, config.yml)
2. [CLEANUP] Cleans up any existing processes
3. [FLASK] Starts Flask application in background
4. [TUNNEL] Starts Cloudflare tunnel in background
5. [MONITOR] Monitors both services every 10 seconds
6. [STOP] Stops everything when you press Ctrl+C

## Access URLs:

- **Customer Menu**: https://robinfinal.hydromods.org
- **Supplier Dashboard**: https://robinfinal.hydromods.org/supplier
- **Local Access**: http://localhost:5000

## Requirements:

- Python with Flask installed
- cloudflared.exe in project directory
- config.yml configured for Cloudflare tunnel

## Troubleshooting:

If you get a PowerShell execution policy error:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Manual Commands:

If you prefer to run manually:

1. Start Flask:
   ```bash
   python app.py
   ```

2. Start Tunnel (in separate terminal):
   ```bash
   .\cloudflared.exe tunnel --config config.yml run robinfinal-app
   ```
