# K2 - GITEX Beverage Menu - Setup Script
# Run this script after cloning the repository to set up the environment

Write-Host "Setting up K2 - GITEX Beverage Menu..." -ForegroundColor Green
Write-Host "Working Directory: $PWD" -ForegroundColor Yellow

# Check if we're in the right directory
if (-not (Test-Path "app.py")) {
    Write-Host "[ERROR] app.py not found. Please run this script from the project root directory." -ForegroundColor Red
    pause
    exit 1
}

Write-Host "[OK] Project directory confirmed" -ForegroundColor Green

# Install Python dependencies
Write-Host "Installing Python dependencies..." -ForegroundColor Cyan
try {
    pip install -r requirements.txt
    Write-Host "[OK] Python dependencies installed" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to install Python dependencies" -ForegroundColor Red
    Write-Host "Please ensure Python and pip are installed and accessible" -ForegroundColor Yellow
    pause
    exit 1
}

# Check for cloudflared.exe
if (-not (Test-Path "cloudflared.exe")) {
    Write-Host "[INFO] cloudflared.exe not found. Downloading..." -ForegroundColor Yellow
    try {
        $url = "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe"
        Invoke-WebRequest -Uri $url -OutFile "cloudflared.exe"
        Write-Host "[OK] cloudflared.exe downloaded" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Failed to download cloudflared.exe" -ForegroundColor Red
        Write-Host "Please download manually from: https://github.com/cloudflare/cloudflared/releases/latest" -ForegroundColor Yellow
        Write-Host "Save as: cloudflared.exe in the project directory" -ForegroundColor Yellow
    }
} else {
    Write-Host "[OK] cloudflared.exe found" -ForegroundColor Green
}

# Check for Cloudflare credentials
$credentialsPath = "$env:USERPROFILE\.cloudflared\7612c8a3-6f6d-4141-9e4c-9c67ff7c6f54.json"
$certPath = "$env:USERPROFILE\.cloudflared\cert.pem"

if (-not (Test-Path $credentialsPath) -or -not (Test-Path $certPath)) {
    Write-Host "[WARNING] Cloudflare credentials not found" -ForegroundColor Yellow
    Write-Host "You need to either:" -ForegroundColor Yellow
    Write-Host "1. Copy credentials from your original PC:" -ForegroundColor White
    Write-Host "   - Copy: C:\Users\[username]\.cloudflared\7612c8a3-6f6d-4141-9e4c-9c67ff7c6f54.json" -ForegroundColor White
    Write-Host "   - Copy: C:\Users\[username]\.cloudflared\cert.pem" -ForegroundColor White
    Write-Host "2. Or authenticate again:" -ForegroundColor White
    Write-Host "   - Run: .\cloudflared.exe tunnel login" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "[OK] Cloudflare credentials found" -ForegroundColor Green
}

# Check config.yml
if (-not (Test-Path "config.yml")) {
    Write-Host "[WARNING] config.yml not found" -ForegroundColor Yellow
    Write-Host "Creating default config.yml..." -ForegroundColor Yellow
    
    $configContent = @"
tunnel: 7612c8a3-6f6d-4141-9e4c-9c67ff7c6f54
credentials-file: $credentialsPath

ingress:
  - hostname: robinfinal.hydromods.org
    service: http://localhost:5000
  - service: http_status:404
"@
    
    $configContent | Out-File -FilePath "config.yml" -Encoding UTF8
    Write-Host "[OK] config.yml created" -ForegroundColor Green
} else {
    Write-Host "[OK] config.yml found" -ForegroundColor Green
}

# Create instance directory for database
if (-not (Test-Path "instance")) {
    New-Item -ItemType Directory -Path "instance" | Out-Null
    Write-Host "[OK] Instance directory created" -ForegroundColor Green
} else {
    Write-Host "[OK] Instance directory exists" -ForegroundColor Green
}

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
Write-Host ""

# Summary
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. If Cloudflare credentials are missing, copy them from your original PC" -ForegroundColor White
Write-Host "   OR run: .\cloudflared.exe tunnel login" -ForegroundColor White
Write-Host ""
Write-Host "2. Start the application:" -ForegroundColor White
Write-Host "   - Double-click: run.bat" -ForegroundColor White
Write-Host "   - Or run: .\run.ps1" -ForegroundColor White
Write-Host ""
Write-Host "3. Access your app at:" -ForegroundColor White
Write-Host "   - Customer Menu: https://robinfinal.hydromods.org" -ForegroundColor White
Write-Host "   - Supplier Dashboard: https://robinfinal.hydromods.org/supplier" -ForegroundColor White
Write-Host "   - Local: http://localhost:5000" -ForegroundColor White
Write-Host ""

Write-Host "For detailed instructions, see: DEPLOYMENT.md" -ForegroundColor Yellow
Write-Host ""
pause
