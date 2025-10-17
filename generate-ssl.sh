#!/bin/bash

# Script to generate self-signed SSL certificates for testing
# For production, use Let's Encrypt or your own CA-signed certificates

set -e

SSL_DIR="./ssl"
DAYS=365
COUNTRY="CN"
STATE="Beijing"
CITY="Beijing"
ORG="Nginx-QUIC"
COMMON_NAME="localhost"

echo "Generating self-signed SSL certificate for testing..."

# Create SSL directory if it doesn't exist
mkdir -p "$SSL_DIR"

# Generate private key and certificate
openssl req -x509 -nodes -days $DAYS -newkey rsa:2048 \
    -keyout "$SSL_DIR/key.pem" \
    -out "$SSL_DIR/cert.pem" \
    -subj "/C=$COUNTRY/ST=$STATE/L=$CITY/O=$ORG/CN=$COMMON_NAME" \
    -addext "subjectAltName=DNS:localhost,DNS:*.localhost,IP:127.0.0.1"

# Set proper permissions
chmod 600 "$SSL_DIR/key.pem"
chmod 644 "$SSL_DIR/cert.pem"

echo "✓ SSL certificate generated successfully!"
echo "  Certificate: $SSL_DIR/cert.pem"
echo "  Private Key: $SSL_DIR/key.pem"
echo ""
echo "⚠ WARNING: This is a self-signed certificate for testing only!"
echo "  For production, use Let's Encrypt or a proper CA-signed certificate."

