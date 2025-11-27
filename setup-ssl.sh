#!/bin/bash

# Script to set up SSL certificates for nginx reverse proxy
# Run this on your EC2 instance

echo "Setting up SSL certificates for nginx..."

# Create SSL directory
sudo mkdir -p /etc/nginx/ssl

# Option 1: Generate self-signed certificate (for testing)
echo "Generating self-signed certificate..."
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/key.pem \
    -out /etc/nginx/ssl/cert.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=16.171.111.124"

# Set proper permissions
sudo chmod 600 /etc/nginx/ssl/key.pem
sudo chmod 644 /etc/nginx/ssl/cert.pem

echo "Self-signed certificate created at /etc/nginx/ssl/"
echo ""
echo "For production, use Let's Encrypt (certbot) instead:"
echo "  sudo apt-get install certbot python3-certbot-nginx"
echo "  sudo certbot --nginx -d your-domain.com"

