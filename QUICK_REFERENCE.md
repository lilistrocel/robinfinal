# 🚀 K2 - GITEX Beverage Menu - Quick Reference

## 📥 New PC Setup (One-Time)

```bash
# 1. Clone repository
git clone <your-repo-url>
cd robinfinal

# 2. Run setup script
.\setup.ps1

# 3. Copy Cloudflare credentials (if available)
# From old PC: C:\Users\[username]\.cloudflared\
# To new PC:   C:\Users\[username]\.cloudflared\

# 4. Start application
.\run.ps1
```

## 🏃‍♂️ Daily Operations

### Start Application:
```bash
.\run.ps1          # PowerShell script
# OR
run.bat            # Double-click batch file
```

### Stop Application:
- Press `Ctrl+C` in the terminal
- Or close the PowerShell window

### Update Code:
```bash
git pull origin main
.\run.ps1
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
| `run.ps1` | Start both Flask + Tunnel |
| `setup.ps1` | One-time setup script |
| `config.yml` | Cloudflare tunnel config |
| `app.py` | Main Flask application |
| `requirements.txt` | Python dependencies |
| `instance/cafe_orders.db` | SQLite database |

## 🔧 Troubleshooting

| Problem | Solution |
|---------|----------|
| **Dependencies missing** | `pip install -r requirements.txt` |
| **Cloudflared not found** | Download from GitHub releases |
| **Tunnel auth failed** | Copy credentials OR `.\cloudflared.exe tunnel login` |
| **Port 5000 in use** | `taskkill /f /im python.exe` |
| **Database errors** | Delete `instance/cafe_orders.db` |

## 📊 Menu Structure

1. **Refreshers**
   - Lemon and Mint Juice
   - Orange Juice
   - Sparkling Water
   - Still Water

2. **Tea** (with sugar/milk options)
   - Assam, Earl Gray, English Breakfast
   - Green Sencha, Jasmin Blossom
   - Masala Chai, Moroccan Nights
   - Rosehip & Hibiscus

3. **Coffee** (with sugar option)
   - Americano, Latte, Cappuccino, Espresso

## 🆘 Emergency Commands

```bash
# Kill all processes
taskkill /f /im python.exe
taskkill /f /im cloudflared.exe

# Reset database
del instance\cafe_orders.db

# Re-authenticate tunnel
.\cloudflared.exe tunnel login

# Check tunnel status
.\cloudflared.exe tunnel info robinfinal-app
```

---
**📞 Support**: Check DEPLOYMENT.md for detailed instructions
