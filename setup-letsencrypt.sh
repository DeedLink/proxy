#!/bin/bash

# Setup Let's Encrypt SSL certificate for nginx
# Requires a domain name pointing to your EC2 IP

set -e

echo "=== Let's Encrypt SSL Setup ==="
echo ""

# Check if domain is provided
if [ -z "$DOMAIN" ]; then
    echo "Enter your domain name (e.g., rpc.yourdomain.com):"
    read DOMAIN
fi

if [ -z "$DOMAIN" ]; then
    echo "Error: Domain name is required"
    exit 1
fi

echo "Using domain: $DOMAIN"
echo ""

# Install certbot
echo "Installing certbot..."
sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx

# Get certificate
echo "Obtaining SSL certificate..."
sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN

# Update nginx.conf to use Let's Encrypt certificates
echo "Updating nginx configuration..."
sudo sed -i "s|ssl_certificate /etc/nginx/ssl/cert.pem;|ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;|g" /etc/nginx/nginx.conf
sudo sed -i "s|ssl_certificate_key /etc/nginx/ssl/key.pem;|ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;|g" /etc/nginx/nginx.conf

# Test and reload
sudo nginx -t
sudo systemctl reload nginx

echo ""
echo "✓ SSL certificate installed!"
echo "Your services are now accessible with trusted certificates:"
echo "  - Anvil RPC: https://$DOMAIN:7001"
echo "  - IPFS API:  https://$DOMAIN:7002"
echo ""
echo "Note: Update your MetaMask RPC URL to use the domain instead of IP"

