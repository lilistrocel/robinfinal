#!/bin/bash

# K2 - GITEX Beverage Menu Startup Script for Ubuntu
# This script starts both the Flask app and Cloudflare tunnel

echo "🚀 Starting K2 - GITEX Beverage Menu..."
echo "📍 Working Directory: $(pwd)"

# Check if required files exist
if [ ! -f "app.py" ]; then
    echo "❌ [ERROR] app.py not found in current directory"
    echo "Please run this script from the project root directory"
    exit 1
fi

if [ ! -f "cloudflared" ]; then
    echo "❌ [ERROR] cloudflared not found in current directory"
    echo "Please ensure cloudflared is in the project directory"
    echo "Run: curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared && chmod +x cloudflared"
    exit 1
fi

if [ ! -f "config.yml" ]; then
    echo "❌ [ERROR] config.yml not found in current directory"
    echo "Please ensure Cloudflare tunnel is configured"
    exit 1
fi

if [ ! -d "venv" ]; then
    echo "❌ [ERROR] Virtual environment not found"
    echo "Please run: ./setup.sh first"
    exit 1
fi

echo "✅ [OK] All required files found"

# Function to cleanup processes on exit
cleanup() {
    echo ""
    echo "🛑 Stopping services..."
    
    # Kill Flask process
    if [ ! -z "$FLASK_PID" ]; then
        kill $FLASK_PID 2>/dev/null
        echo "✅ [OK] Flask stopped"
    fi
    
    # Kill Cloudflare tunnel process
    if [ ! -z "$TUNNEL_PID" ]; then
        kill $TUNNEL_PID 2>/dev/null
        echo "✅ [OK] Cloudflare tunnel stopped"
    fi
    
    # Kill any remaining processes
    pkill -f "python.*app.py" 2>/dev/null
    pkill -f "cloudflared.*tunnel" 2>/dev/null
    
    echo "✅ [OK] Services stopped. Goodbye!"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Kill any existing processes
echo "🧹 Cleaning up existing processes..."
pkill -f "python.*app.py" 2>/dev/null
pkill -f "cloudflared.*tunnel" 2>/dev/null
sleep 2
echo "✅ [OK] Cleanup completed"

# Activate virtual environment
echo "🐍 Activating virtual environment..."
source venv/bin/activate

if [ $? -ne 0 ]; then
    echo "❌ [ERROR] Failed to activate virtual environment"
    echo "Please run: ./setup.sh first"
    exit 1
fi

echo "✅ [OK] Virtual environment activated"

# Start Flask app in background
echo "🐍 Starting Flask application..."
python3 app.py &
FLASK_PID=$!

# Wait a moment for Flask to start
sleep 3

# Check if Flask started successfully
if ps -p $FLASK_PID > /dev/null; then
    echo "✅ [OK] Flask app started successfully (PID: $FLASK_PID)"
    echo "🌐 Local access: http://localhost:5000"
else
    echo "❌ [ERROR] Failed to start Flask app"
    exit 1
fi

# Start Cloudflare tunnel in background
echo "☁️ Starting Cloudflare tunnel..."
./cloudflared tunnel --config config.yml run robinfinal-app &
TUNNEL_PID=$!

# Wait a moment for tunnel to establish
sleep 5

# Check if tunnel started successfully
if ps -p $TUNNEL_PID > /dev/null; then
    echo "✅ [OK] Cloudflare tunnel started successfully (PID: $TUNNEL_PID)"
    echo "🌍 External access: https://robinfinal.hydromods.org"
else
    echo "❌ [ERROR] Failed to start Cloudflare tunnel"
    kill $FLASK_PID 2>/dev/null
    exit 1
fi

echo ""
echo "🎉 SUCCESS: K2 - GITEX Beverage Menu is now running!"
echo "========================================================="
echo "📱 Customer Menu:      https://robinfinal.hydromods.org"
echo "🏪 Supplier Dashboard: https://robinfinal.hydromods.org/supplier"
echo "🏠 Local Access:       http://localhost:5000"
echo "========================================================="
echo ""
echo "💡 TIP: Both services are running in the background"
echo "🛑 To stop: Press Ctrl+C"
echo ""

# Monitor both services
echo "📊 Monitoring services... (Press Ctrl+C to stop)"
while true; do
    # Check Flask
    if ps -p $FLASK_PID > /dev/null 2>&1; then
        FLASK_STATUS="✅ Running"
    else
        FLASK_STATUS="❌ Stopped"
    fi
    
    # Check Cloudflare tunnel
    if ps -p $TUNNEL_PID > /dev/null 2>&1; then
        TUNNEL_STATUS="✅ Running"
    else
        TUNNEL_STATUS="❌ Stopped"
    fi
    
    TIMESTAMP=$(date '+%H:%M:%S')
    echo "[$TIMESTAMP] Flask: $FLASK_STATUS | Tunnel: $TUNNEL_STATUS"
    
    # If both services are stopped, exit
    if ! ps -p $FLASK_PID > /dev/null 2>&1 && ! ps -p $TUNNEL_PID > /dev/null 2>&1; then
        echo "❌ [ERROR] Both services have stopped"
        break
    fi
    
    sleep 10
done

# Cleanup will be called by trap
