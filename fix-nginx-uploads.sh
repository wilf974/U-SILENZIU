#!/bin/bash

echo "🔧 Correction de la configuration Nginx pour servir /uploads/..."

DOMAIN="rageroom.usilenziu.com"

# Créer une configuration Nginx complète et corrigée
cat > nginx/conf.d/default.conf << EOF
# Configuration pour $DOMAIN
server {
    listen 80;
    server_name $DOMAIN;

    # Redirection HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name $DOMAIN;

    ssl_certificate /etc/nginx/ssl/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/live/$DOMAIN/privkey.pem;

    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    # Activer HTTP/2
    http2 on;

    # Headers de sécurité
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    root /app/public; # Servir les fichiers statiques directement

    # Route pour servir les uploads (NOUVEAU)
    location /uploads/ {
        alias /app/public/uploads/;
        expires 30d;
        add_header Cache-Control "public, immutable";
        add_header Access-Control-Allow-Origin "*";
    }

    # Route pour servir les images statiques
    location /images/ {
        alias /app/public/images/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # Route principale pour l'application Next.js
    location / {
        proxy_pass http://u-silenziu:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 60s;
    }
}
EOF

echo "📋 Configuration Nginx corrigée créée."

# Vérifier la syntaxe nginx avant de redémarrer
echo "🔍 Vérification de la syntaxe Nginx..."
docker compose -f docker-compose.prod.yml exec nginx nginx -t 2>/dev/null || {
    echo "❌ Erreur de syntaxe Nginx détectée. Tentative de correction..."
    
    # Configuration de base si la première échoue
    cat > nginx/conf.d/default.conf << EOF
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_certificate /etc/nginx/ssl/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/live/$DOMAIN/privkey.pem;

    location /uploads/ {
        alias /app/public/uploads/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    location / {
        proxy_pass http://u-silenziu:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
}

echo "🔄 Redémarrage du container Nginx..."
docker compose -f docker-compose.prod.yml restart nginx

echo "⏱️  Attente de 5 secondes pour le démarrage..."
sleep 5

echo "🔍 Vérification du statut des conteneurs..."
docker compose -f docker-compose.prod.yml ps

echo "📋 Logs Nginx récents..."
docker compose -f docker-compose.prod.yml logs nginx --tail=10

echo "🧪 Test de connexion..."
curl -I https://$DOMAIN/ --connect-timeout 10 || echo "❌ Connexion échouée"

echo "✅ Script terminé. Teste maintenant l'accès aux images upload."


