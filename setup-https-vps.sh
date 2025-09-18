#!/bin/bash
# Script pour configurer HTTPS avec Let's Encrypt sur le VPS

# Variables à modifier selon ton domaine
DOMAIN="ton-domaine.com"  # Remplace par ton domaine
EMAIL="admin@ton-domaine.com"  # Remplace par ton email

echo "🔒 Configuration HTTPS pour U SILENZIU"
echo "========================================="

# 1. Installer Certbot
echo "📦 Installation de Certbot..."
apt update
apt install -y certbot python3-certbot-nginx

# 2. Créer la configuration Nginx
echo "⚙️  Configuration Nginx..."
mkdir -p nginx/conf.d

cat > nginx/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # Logs
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;

    # Include server configs
    include /etc/nginx/conf.d/*.conf;
}
EOF

cat > nginx/conf.d/default.conf << EOF
# Configuration pour $DOMAIN
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    
    # Redirection HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;
    
    # Certificats SSL
    ssl_certificate /etc/nginx/ssl/live/$DOMAIN/fullchain.pem;
    ssl_private_key /etc/nginx/ssl/live/$DOMAIN/privkey.pem;
    
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
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF

# 3. Obtenir le certificat SSL
echo "🔐 Obtention du certificat SSL..."
certbot certonly --standalone \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    -d $DOMAIN \
    -d www.$DOMAIN

# 4. Copier les certificats pour Docker
echo "📋 Copie des certificats..."
mkdir -p certbot/conf
cp -r /etc/letsencrypt/* certbot/conf/

# 5. Modifier docker-compose.prod.yml pour activer Nginx
echo "🐳 Mise à jour Docker Compose..."
cat > docker-compose.prod.yml << 'EOF'
# Configuration Docker Compose pour PRODUCTION HTTPS
services:
  postgres:
    image: postgres:15-alpine
    container_name: u-silenziu-postgres-prod
    environment:
      POSTGRES_DB: usilenzio
      POSTGRES_USER: usilenzio_user
      POSTGRES_PASSWORD: usilenzio_password_2024
    volumes:
      - postgres_prod_data:/var/lib/postgresql/data
      - ./init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    networks:
      - u-silenziu-prod-network

  u-silenziu:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: u-silenziu-app-prod
    environment:
      - NODE_ENV=production
      - NEXT_TELEMETRY_DISABLED=1
      - DATABASE_URL=postgresql://usilenzio_user:usilenzio_password_2024@postgres:5432/usilenzio
      - SMTP_HOST=smtp.gmail.com
      - SMTP_PORT=587
      - SMTP_SECURE=false
      - SMTP_USER=
      - SMTP_PASS=
      - ADMIN_JWT_SECRET=super_secret_admin_jwt_key_2024_usilenzio_very_long_and_secure
      - UPLOAD_DIR=/app/public/uploads
    volumes:
      - ./public/uploads:/app/public/uploads
      - ./logs:/app/logs
    networks:
      - u-silenziu-prod-network
    depends_on:
      - postgres
      - redis-prod
    # Plus d'exposition directe du port 3000

  nginx:
    image: nginx:alpine
    container_name: u-silenziu-nginx-prod
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./certbot/conf:/etc/nginx/ssl:ro
      - ./public:/app/public:ro
    networks:
      - u-silenziu-prod-network
    depends_on:
      - u-silenziu
    restart: unless-stopped

  redis-prod:
    image: redis:7-alpine
    container_name: u-silenziu-redis-prod
    volumes:
      - redis_prod_data:/data
    networks:
      - u-silenziu-prod-network

networks:
  u-silenziu-prod-network:
    driver: bridge
    name: u-silenziu-prod-network

volumes:
  postgres_prod_data:
    driver: local
    name: u-silenziu-postgres-prod-data
  redis_prod_data:
    driver: local
    name: u-silenziu-redis-prod-data
EOF

# 6. Configurer le renouvellement automatique
echo "🔄 Configuration du renouvellement automatique..."
cat > /etc/cron.d/certbot-renew << 'EOF'
0 12 * * * /usr/bin/certbot renew --quiet --deploy-hook "cd /root/U-SILENZIU && docker compose -f docker-compose.prod.yml restart nginx"
EOF

echo "✅ Configuration HTTPS terminée !"
echo ""
echo "📝 Instructions finales :"
echo "1. Modifie DOMAIN et EMAIL dans ce script"
echo "2. Assure-toi que ton domaine pointe vers cette IP"
echo "3. Exécute : chmod +x setup-https-vps.sh"
echo "4. Exécute : ./setup-https-vps.sh"
echo "5. Redémarre : docker compose -f docker-compose.prod.yml up -d"
echo ""
echo "🌐 Ton site sera accessible en HTTPS sur : https://$DOMAIN"
