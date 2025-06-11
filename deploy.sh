#!/bin/bash

# Update system packages
sudo yum update -y

# Install Python and pip
sudo yum install -y python3 python3-pip

# Install virtualenv
sudo pip3 install virtualenv

# Create and activate virtual environment
python3 -m virtualenv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Install and configure Nginx
sudo yum install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Create Nginx configuration
sudo tee /etc/nginx/conf.d/cafe.conf << EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# Remove default Nginx configuration
sudo rm -f /etc/nginx/conf.d/default.conf

# Remove default site Nginx configuration
sudo rm -f /etc/nginx/sites-enabled/default
sudo rm -f /etc/nginx/sites-available/default

# Restart Nginx
sudo systemctl restart nginx

# Install and configure Supervisor
sudo yum install -y supervisor
sudo systemctl start supervisord
sudo systemctl enable supervisord

# Create Supervisor configuration for the application
sudo tee /etc/supervisor.d/cafe.ini << EOF
[program:cafe]
directory=/home/ubuntu/robinfinal
command=/home/ubuntu/robinfinal/venv/bin/gunicorn -w 4 -b 127.0.0.1:5000 app:app
user=ubuntu
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
stderr_logfile=/var/log/cafe/cafe.err.log
stdout_logfile=/var/log/cafe/cafe.out.log
EOF

# Create log directory
sudo mkdir -p /var/log/cafe
sudo chown -R ec2-user:ec2-user /var/log/cafe

# Restart Supervisor
sudo systemctl restart supervisord

echo "Deployment complete! The application should be running on port 80." 