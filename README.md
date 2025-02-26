# Cafe Order System

A simple web-based cafe order management system built with Flask. It features a customer-facing menu page for placing orders and a supplier dashboard for managing orders.

## Local Development Setup

1. Create a virtual environment:
```bash
python -m venv venv
```

2. Activate the virtual environment:
- Windows:
```bash
venv\Scripts\activate
```
- Linux/Mac:
```bash
source venv/bin/activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Run the development server:
```bash
python app.py
```

The application will be available at http://localhost:5000

## AWS EC2 Deployment

1. Launch an Amazon Linux 2023 EC2 instance
2. Configure security group to allow inbound traffic on port 80 (HTTP)
3. Connect to your instance using SSH
4. Copy all files to the instance:
```bash
scp -i your-key.pem -r cafe-order-system ec2-user@your-instance-ip:~
```

5. SSH into your instance:
```bash
ssh -i your-key.pem ec2-user@your-instance-ip
```

6. Navigate to the project directory and run the deployment script:
```bash
cd cafe-order-system
chmod +x deploy.sh
./deploy.sh
```

The application will be available at http://your-instance-ip

## Features

- Customer Menu Page (/)
  - Browse menu items by category
  - Add/remove items from cart
  - Place orders
  - Real-time total calculation

- Supplier Dashboard (/supplier)
  - View all orders
  - Mark orders as completed
  - Auto-refresh when new orders arrive
  - Order status tracking

## Project Structure

```
cafe-order-system/
├── app.py              # Main Flask application
├── requirements.txt    # Python dependencies
├── deploy.sh          # AWS EC2 deployment script
├── static/            # Static files (if any)
└── templates/         # HTML templates
    ├── index.html     # Customer menu page
    └── supplier.html  # Supplier dashboard
```

## Notes

- This is a basic implementation using in-memory storage
- For production use, consider adding:
  - Database integration
  - User authentication
  - HTTPS support
  - Error handling
  - Logging
  - Backup system 