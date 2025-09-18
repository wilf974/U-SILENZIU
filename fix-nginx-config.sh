#!/bin/bash
# Script pour corriger la configuration Nginx

echo "🔧 Correction de la configuration Nginx..."

# Corriger le fichier de configuration Nginx
cat > nginx/conf.d/default.conf << 'EOF'
# Configuration pour rageroom.usilenziu.com
server {
    listen 80;
    server_name rageroom.usilenziu.com;
    
    # Redirection HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    http2 on;
    server_name rageroom.usilenziu.com;
    
    # Certificats SSL
    ssl_certificate /etc/nginx/ssl/live/rageroom.usilenziu.com/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/live/rageroom.usilenziu.com/privkey.pem;
    
    # Configuration SSL moderne
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Headers de sécurité
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Gestion des fichiers statiques
    location /_next/static/ {
        proxy_pass http://u-silenziu:3000;
        proxy_cache_valid 200 1y;
        add_header Cache-Control "public, immutable";
    }
    
    location /images/ {
        proxy_pass http://u-silenziu:3000;
        proxy_cache_valid 200 30d;
        add_header Cache-Control "public";
    }
    
    # Proxy vers l'application
    location / {
        proxy_pass http://u-silenziu:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF

echo "✅ Configuration Nginx corrigée !"
echo "🚀 Redémarrage des conteneurs..."

# Redémarrer les conteneurs
docker compose -f docker-compose.prod.yml restart nginx

echo "📊 Vérification du statut..."
docker compose -f docker-compose.prod.yml ps
