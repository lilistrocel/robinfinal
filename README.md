# K2 - GITEX Beverage Menu

A modern web-based beverage ordering system built with Flask and featuring real-time order management through Cloudflare tunnels.

## 🚀 Quick Start

### New PC Setup:
```bash
git clone <your-repository-url>
cd robinfinal
.\setup.ps1
.\run.ps1
```

### Daily Use:
```bash
.\run.ps1  # Starts both Flask app and Cloudflare tunnel
```

## 📱 Features

- **Customer Interface**: Interactive beverage menu with options
- **Supplier Dashboard**: Real-time order management
- **Multi-language**: English and Arabic support
- **Cloud Access**: Available worldwide via Cloudflare tunnel
- **Real-time Updates**: Live order status monitoring

## 🌐 Access URLs

- **Customer Menu**: https://robinfinal.hydromods.org
- **Supplier Dashboard**: https://robinfinal.hydromods.org/supplier
- **Local Access**: http://localhost:5000

## 📋 Menu Categories

1. **Refreshers**: Juices and water options
2. **Tea**: 8 varieties with customizable sugar/milk
3. **Coffee**: 4 varieties with sugar options

## 📚 Documentation

- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Complete setup guide
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Commands cheat sheet
- **[RUNNING.md](RUNNING.md)** - How to run the application

## 🛠️ Tech Stack

- **Backend**: Python Flask
- **Database**: SQLite
- **Frontend**: HTML, CSS, JavaScript (Bootstrap)
- **Deployment**: Cloudflare Tunnels
- **OS**: Windows

## 📁 Project Structure

```
robinfinal/
├── app.py              # Main Flask application
├── models.py           # Database models
├── requirements.txt    # Python dependencies
├── config.yml         # Cloudflare tunnel config
├── run.ps1            # Startup script
├── setup.ps1          # Setup script
├── templates/         # HTML templates
├── static/           # CSS, JS, images
└── instance/         # SQLite database
```

## 🔧 Requirements

- Python 3.7+
- Windows 10/11
- Internet connection for Cloudflare tunnel

## 📝 License

This project is for K2 - GITEX event use.