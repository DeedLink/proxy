#!/bin/bash

# Setup script for nginx reverse proxy on EC2
# This script generates nginx.conf from template and sets up SSL

set -e

echo "=== Nginx Reverse Proxy Setup ==="
echo ""

# Get EC2 public IP
if [ -z "$EC2_PUBLIC_IP" ]; then
    echo "Enter your EC2 public IP address:"
    read EC2_PUBLIC_IP
fi

if [ -z "$EC2_PUBLIC_IP" ]; then
    echo "Error: EC2 public IP is required"
    exit 1
fi

echo "Using EC2 Public IP: $EC2_PUBLIC_IP"
echo ""

# Generate nginx.conf from template
echo "Generating nginx.conf from template..."
sed "s/{{EC2_PUBLIC_IP}}/$EC2_PUBLIC_IP/g" nginx.conf.template > nginx.conf
echo "✓ nginx.conf generated"
echo ""

# Set up SSL certificates
echo "Setting up SSL certificates..."
sudo mkdir -p /etc/nginx/ssl

# Generate self-signed certificate
echo "Generating self-signed certificate..."
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/key.pem \
    -out /etc/nginx/ssl/cert.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=$EC2_PUBLIC_IP" 2>/dev/null

# Set proper permissions
sudo chmod 600 /etc/nginx/ssl/key.pem
sudo chmod 644 /etc/nginx/ssl/cert.pem
echo "✓ SSL certificates created"
echo ""

# Copy nginx configuration
echo "Copying nginx configuration..."
sudo cp nginx.conf /etc/nginx/nginx.conf
echo "✓ Configuration copied"
echo ""

# Test nginx configuration
echo "Testing nginx configuration..."
if sudo nginx -t; then
    echo "✓ Configuration test passed"
    echo ""
    
    # Restart nginx
    echo "Restarting nginx..."
    sudo systemctl restart nginx
    sudo systemctl enable nginx
    echo "✓ Nginx restarted and enabled"
    echo ""
    
    echo "=== Setup Complete ==="
    echo ""
    echo "Your services are now accessible at:"
    echo "  - Anvil RPC: https://$EC2_PUBLIC_IP:7001 (proxies to localhost:8545)"
    echo "  - IPFS API:  https://$EC2_PUBLIC_IP:7002 (proxies to localhost:5001)"
    echo ""
    echo "Note: Self-signed certificates will show browser warnings."
    echo "For production, use Let's Encrypt: sudo certbot --nginx"
    echo ""
    echo "Important: Make sure ports 7001 and 7002 are open in your EC2 security group!"
else
    echo "✗ Configuration test failed. Please check the errors above."
    exit 1
fi

