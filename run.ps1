# K2 - GITEX Beverage Menu Startup Script
# This script starts both the Flask app and Cloudflare tunnel

Write-Host "Starting K2 - GITEX Beverage Menu..." -ForegroundColor Green
Write-Host "Working Directory: $PWD" -ForegroundColor Yellow

# Check if required files exist
if (-not (Test-Path "app.py")) {
    Write-Host "[ERROR] app.py not found in current directory" -ForegroundColor Red
    Write-Host "Please run this script from the project root directory" -ForegroundColor Red
    pause
    exit 1
}

if (-not (Test-Path "cloudflared.exe")) {
    Write-Host "[ERROR] cloudflared.exe not found in current directory" -ForegroundColor Red
    Write-Host "Please ensure cloudflared.exe is in the project directory" -ForegroundColor Red
    pause
    exit 1
}

if (-not (Test-Path "config.yml")) {
    Write-Host "[ERROR] config.yml not found in current directory" -ForegroundColor Red
    Write-Host "Please ensure Cloudflare tunnel is configured" -ForegroundColor Red
    pause
    exit 1
}

Write-Host "[OK] All required files found" -ForegroundColor Green

# Kill any existing processes
Write-Host "Cleaning up existing processes..." -ForegroundColor Yellow
try {
    Get-Process -Name "python" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like "*app.py*" } | Stop-Process -Force -ErrorAction SilentlyContinue
    Get-Process -Name "cloudflared" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Write-Host "[OK] Cleanup completed" -ForegroundColor Green
} catch {
    Write-Host "[INFO] No existing processes to clean up" -ForegroundColor Yellow
}

# Start Flask app in background
Write-Host "Starting Flask application..." -ForegroundColor Cyan
$flaskJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    python app.py
}

# Wait a moment for Flask to start
Start-Sleep -Seconds 3

# Check if Flask started successfully
$flaskProcess = Get-Process -Name "python" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "python" }
if ($flaskProcess) {
    Write-Host "[OK] Flask app started successfully" -ForegroundColor Green
    Write-Host "Local access: http://localhost:5000" -ForegroundColor White
} else {
    Write-Host "[ERROR] Failed to start Flask app" -ForegroundColor Red
    Receive-Job $flaskJob
    Remove-Job $flaskJob
    pause
    exit 1
}

# Start Cloudflare tunnel in background
Write-Host "Starting Cloudflare tunnel..." -ForegroundColor Cyan
$tunnelJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    .\cloudflared.exe tunnel --config config.yml run robinfinal-app
}

# Wait a moment for tunnel to establish
Start-Sleep -Seconds 5

# Check if tunnel started successfully
$tunnelProcess = Get-Process -Name "cloudflared" -ErrorAction SilentlyContinue
if ($tunnelProcess) {
    Write-Host "[OK] Cloudflare tunnel started successfully" -ForegroundColor Green
    Write-Host "External access: https://robinfinal.hydromods.org" -ForegroundColor White
} else {
    Write-Host "[ERROR] Failed to start Cloudflare tunnel" -ForegroundColor Red
    Receive-Job $tunnelJob
    Remove-Job $tunnelJob
    Stop-Job $flaskJob
    Remove-Job $flaskJob
    pause
    exit 1
}

Write-Host ""
Write-Host "SUCCESS: K2 - GITEX Beverage Menu is now running!" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
Write-Host "Customer Menu:      https://robinfinal.hydromods.org" -ForegroundColor White
Write-Host "Supplier Dashboard: https://robinfinal.hydromods.org/supplier" -ForegroundColor White
Write-Host "Local Access:       http://localhost:5000" -ForegroundColor White
Write-Host "=========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "TIP: Both services are running in the background" -ForegroundColor Yellow
Write-Host "To stop: Press Ctrl+C or close this window" -ForegroundColor Yellow
Write-Host ""

# Monitor both services
Write-Host "Monitoring services... (Press Ctrl+C to stop)" -ForegroundColor Cyan
try {
    while ($true) {
        # Check Flask
        $flaskRunning = Get-Process -Name "python" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "python" }
        
        # Check Cloudflare tunnel
        $tunnelRunning = Get-Process -Name "cloudflared" -ErrorAction SilentlyContinue
        
        $timestamp = Get-Date -Format "HH:mm:ss"
        
        if ($flaskRunning -and $tunnelRunning) {
            Write-Host "[$timestamp] Flask: Running | Tunnel: Running" -ForegroundColor Green
        } elseif ($flaskRunning -and -not $tunnelRunning) {
            Write-Host "[$timestamp] Flask: Running | Tunnel: Stopped" -ForegroundColor Yellow
        } elseif (-not $flaskRunning -and $tunnelRunning) {
            Write-Host "[$timestamp] Flask: Stopped | Tunnel: Running" -ForegroundColor Yellow
        } else {
            Write-Host "[$timestamp] Flask: Stopped | Tunnel: Stopped" -ForegroundColor Red
            break
        }
        
        Start-Sleep -Seconds 10
    }
} catch {
    Write-Host ""
    Write-Host "Stopping services..." -ForegroundColor Yellow
}

# Cleanup on exit
Write-Host "Cleaning up..." -ForegroundColor Yellow
Stop-Job $flaskJob -ErrorAction SilentlyContinue
Remove-Job $flaskJob -ErrorAction SilentlyContinue
Stop-Job $tunnelJob -ErrorAction SilentlyContinue
Remove-Job $tunnelJob -ErrorAction SilentlyContinue

Get-Process -Name "python" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "python" } | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "cloudflared" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "[OK] Services stopped. Goodbye!" -ForegroundColor Green
pause