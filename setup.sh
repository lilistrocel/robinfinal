#!/bin/bash

# K2 - GITEX Beverage Menu - Ubuntu Setup Script
# Run this script after cloning the repository to set up the environment

echo "🚀 Setting up K2 - GITEX Beverage Menu on Ubuntu..."
echo "📍 Working Directory: $(pwd)"

# Check if we're in the right directory
if [ ! -f "app.py" ]; then
    echo "❌ [ERROR] app.py not found. Please run this script from the project root directory."
    exit 1
fi

echo "✅ [OK] Project directory confirmed"

# Update system packages
echo "📦 Updating system packages..."
sudo apt update

# Install required system packages
echo "📦 Installing system dependencies..."
sudo apt install -y python3 python3-pip python3-venv curl

# Check Python installation
if ! command -v python3 &> /dev/null; then
    echo "❌ [ERROR] Python3 is not installed"
    exit 1
fi

echo "✅ [OK] Python3 is available: $(python3 --version)"

# Create virtual environment
if [ ! -d "venv" ]; then
    echo "🐍 Creating Python virtual environment..."
    python3 -m venv venv
    echo "✅ [OK] Virtual environment created"
else
    echo "✅ [OK] Virtual environment already exists"
fi

# Activate virtual environment and install dependencies
echo "📦 Installing Python dependencies..."
source venv/bin/activate
pip install -r requirements.txt

if [ $? -eq 0 ]; then
    echo "✅ [OK] Python dependencies installed"
else
    echo "❌ [ERROR] Failed to install Python dependencies"
    exit 1
fi

# Download cloudflared if not present
if [ ! -f "cloudflared" ]; then
    echo "☁️ Downloading cloudflared..."
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
    chmod +x cloudflared
    echo "✅ [OK] cloudflared downloaded and made executable"
else
    echo "✅ [OK] cloudflared found"
    chmod +x cloudflared  # Ensure it's executable
fi

# Create .cloudflared directory
mkdir -p ~/.cloudflared

# Check for Cloudflare credentials
CREDENTIALS_PATH="$HOME/.cloudflared/7612c8a3-6f6d-4141-9e4c-9c67ff7c6f54.json"
CERT_PATH="$HOME/.cloudflared/cert.pem"

if [ ! -f "$CREDENTIALS_PATH" ] || [ ! -f "$CERT_PATH" ]; then
    echo "⚠️ [WARNING] Cloudflare credentials not found"
    echo "You need to either:"
    echo "1. Copy credentials from your Windows PC:"
    echo "   - From: C:\\Users\\[username]\\.cloudflared\\7612c8a3-6f6d-4141-9e4c-9c67ff7c6f54.json"
    echo "   - To: ~/.cloudflared/7612c8a3-6f6d-4141-9e4c-9c67ff7c6f54.json"
    echo "   - From: C:\\Users\\[username]\\.cloudflared\\cert.pem"
    echo "   - To: ~/.cloudflared/cert.pem"
    echo "2. Or authenticate again:"
    echo "   - Run: ./cloudflared tunnel login"
    echo ""
else
    echo "✅ [OK] Cloudflare credentials found"
fi

# Update config.yml for Linux paths
if [ ! -f "config.yml" ]; then
    echo "⚙️ Creating config.yml..."
    cat > config.yml << EOF
tunnel: 7612c8a3-6f6d-4141-9e4c-9c67ff7c6f54
credentials-file: $CREDENTIALS_PATH

ingress:
  - hostname: robinfinal.hydromods.org
    service: http://localhost:5000
  - service: http_status:404
EOF
    echo "✅ [OK] config.yml created"
else
    echo "✅ [OK] config.yml found"
    # Update the credentials path in existing config.yml for Linux
    sed -i "s|C:\\\\Users\\\\.*\\\\.cloudflared\\\\|$HOME/.cloudflared/|g" config.yml
    sed -i 's|\\\\|/|g' config.yml
    echo "✅ [OK] config.yml updated for Linux paths"
fi

# Create instance directory for database
if [ ! -d "instance" ]; then
    mkdir -p instance
    echo "✅ [OK] Instance directory created"
else
    echo "✅ [OK] Instance directory exists"
fi

# Make run script executable
if [ -f "run.sh" ]; then
    chmod +x run.sh
    echo "✅ [OK] run.sh made executable"
fi

echo ""
echo "==========================================================="
echo "🎉 Setup Complete!"
echo "==========================================================="
echo ""

# Summary
echo "📋 Next Steps:"
echo "1. If Cloudflare credentials are missing, copy them from your Windows PC:"
echo "   - Copy to: ~/.cloudflared/7612c8a3-6f6d-4141-9e4c-9c67ff7c6f54.json"
echo "   - Copy to: ~/.cloudflared/cert.pem"
echo "   OR run: ./cloudflared tunnel login"
echo ""
echo "2. Start the application:"
echo "   - Run: ./run.sh"
echo "   - Or manually: source venv/bin/activate && python3 app.py"
echo ""
echo "3. Access your app at:"
echo "   - Customer Menu: https://robinfinal.hydromods.org"
echo "   - Supplier Dashboard: https://robinfinal.hydromods.org/supplier"
echo "   - Local: http://localhost:5000"
echo ""

echo "📚 For detailed instructions, see: DEPLOYMENT_UBUNTU.md"
echo ""

# Deactivate virtual environment
deactivate 2>/dev/null || true

echo "✅ Setup script completed successfully!"
