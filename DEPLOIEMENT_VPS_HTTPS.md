# 🚀 Guide de Déploiement HTTPS - U Silenziu sur VPS Debian

## 📋 Prérequis
- VPS Debian 11/12 avec accès root
- Nom de domaine configuré pointant vers l'IP du VPS
- Accès SSH au serveur

## 🔧 1. Préparation du serveur VPS

### Connexion et mise à jour
```bash
# Se connecter au VPS
ssh root@votre-ip-serveur

# Mettre à jour le système
apt update && apt upgrade -y

# Installer les outils essentiels
apt install -y curl wget git unzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release
```

### Installation de Docker et Docker Compose
```bash
# Supprimer les anciennes versions
apt remove -y docker docker-engine docker.io containerd runc

# Installer les prérequis
apt install -y ca-certificates curl gnupg lsb-release

# Ajouter la clé GPG officielle de Docker
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Ajouter le repository Docker
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Mettre à jour les packages
apt update

# Installer Docker
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Démarrer et activer Docker
systemctl start docker
systemctl enable docker

# Vérifier l'installation
docker --version
docker compose version
```

## 🔐 2. Installation et configuration de Nginx

### Installation de Nginx
```bash
# Installer Nginx
apt install -y nginx

# Démarrer et activer Nginx
systemctl start nginx
systemctl enable nginx

# Vérifier le statut
systemctl status nginx
```

### Configuration du firewall
```bash
# Installer UFW
apt install -y ufw

# Configurer les règles de base
ufw default deny incoming
ufw default allow outgoing

# Autoriser SSH, HTTP et HTTPS
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp

# Activer le firewall
ufw --force enable

# Vérifier le statut
ufw status
```

## 🔒 3. Installation et configuration de Certbot (Let's Encrypt)

### Installation de Certbot
```bash
# Installer snapd
apt install -y snapd

# Installer certbot via snap
snap install core; snap refresh core
snap install --classic certbot

# Créer un lien symbolique
ln -sf /snap/bin/certbot /usr/bin/certbot
```

### Configuration initiale
```bash
# Vérifier l'installation
certbot --version

# Tester la configuration
certbot --nginx --dry-run -d votre-domaine.com
```

## 📁 4. Déploiement de l'application

### Création du répertoire de déploiement
```bash
# Créer le répertoire de l'application
mkdir -p /opt/usilenziu
cd /opt/usilenziu

# Cloner le repository (remplacer par votre URL Git)
git clone https://github.com/votre-username/usilenziu.git .

# Ou si vous n'avez pas de repository distant, créer un tar depuis votre machine locale
# Sur votre machine locale :
# tar -czf usilenziu.tar.gz --exclude=node_modules --exclude=.git .
# Puis transférer sur le serveur :
# scp usilenziu.tar.gz root@votre-ip-serveur:/opt/usilenziu/
# Sur le serveur :
# tar -xzf usilenziu.tar.gz
```

### Configuration des variables d'environnement
```bash
# Créer le fichier .env
cat > .env << 'EOF'
# Configuration de base
NODE_ENV=production
NEXT_TELEMETRY_DISABLED=1

# Configuration PostgreSQL
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=usilenzio
POSTGRES_USER=usilenzio_user
POSTGRES_PASSWORD=usilenzio_password_2024
DATABASE_URL=postgresql://usilenzio_user:usilenzio_password_2024@postgres:5432/usilenzio

# Configuration SMTP (à adapter selon votre fournisseur)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=votre-email@gmail.com
SMTP_PASS=votre-mot-de-passe-app
SMTP_FROM=U Silenziu <noreply@votre-domaine.com>

# Configuration de l'application
NEXT_PUBLIC_APP_URL=https://votre-domaine.com
NEXT_PUBLIC_APP_NAME=U Silenziu
EOF
```

### Création du docker-compose.yml pour la production
```bash
# Créer le fichier docker-compose.prod.yml
cat > docker-compose.prod.yml << 'EOF'
version: '3.8'

services:
  # Base de données PostgreSQL
  postgres:
    image: postgres:15-alpine
    container_name: usilenziu-postgres
    environment:
      POSTGRES_DB: usilenzio
      POSTGRES_USER: usilenzio_user
      POSTGRES_PASSWORD: usilenzio_password_2024
      POSTGRES_INITDB_ARGS: "--encoding=UTF-8 --lc-collate=C --lc-ctype=C"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U usilenzio_user -d usilenzio"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    networks:
      - usilenziu-network

  # Application Next.js
  app:
    build: 
      context: .
      dockerfile: Dockerfile
    container_name: usilenziu-app
    environment:
      - NODE_ENV=production
      - NEXT_TELEMETRY_DISABLED=1
      - DATABASE_URL=postgresql://usilenzio_user:usilenzio_password_2024@postgres:5432/usilenzio
      - POSTGRES_HOST=postgres
      - POSTGRES_PORT=5432
      - POSTGRES_DB=usilenzio
      - POSTGRES_USER=usilenzio_user
      - POSTGRES_PASSWORD=usilenzio_password_2024
    restart: unless-stopped
    depends_on:
      postgres:
        condition: service_healthy
    volumes:
      - ./public/uploads:/app/public/uploads
      - ./logs:/app/logs
    networks:
      - usilenziu-network

  # Nginx reverse proxy
  nginx:
    image: nginx:alpine
    container_name: usilenziu-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
      - ./public/uploads:/var/www/uploads:ro
    depends_on:
      - app
    restart: unless-stopped
    networks:
      - usilenziu-network

networks:
  usilenziu-network:
    driver: bridge

volumes:
  postgres_data:
    driver: local
EOF
```

### Configuration de Nginx
```bash
# Créer la configuration Nginx
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;
    
    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=login:10m rate=5r/m;
    
    # Upstream pour l'application
    upstream app {
        server app:3000;
    }
    
    # Redirection HTTP vers HTTPS
    server {
        listen 80;
        server_name votre-domaine.com www.votre-domaine.com;
        
        # Let's Encrypt challenge
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }
        
        # Redirection vers HTTPS
        location / {
            return 301 https://$server_name$request_uri;
        }
    }
    
    # Configuration HTTPS
    server {
        listen 443 ssl http2;
        server_name votre-domaine.com www.votre-domaine.com;
        
        # Certificats SSL
        ssl_certificate /etc/nginx/ssl/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/privkey.pem;
        
        # Configuration SSL moderne
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;
        
        # Headers de sécurité
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Frame-Options DENY always;
        add_header X-Content-Type-Options nosniff always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Referrer-Policy "strict-origin-when-cross-origin" always;
        
        # Limitation de débit pour l'API
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            proxy_pass http://app;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
        }
        
        # Limitation de débit pour le login
        location /admin/login {
            limit_req zone=login burst=5 nodelay;
            proxy_pass http://app;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # Fichiers statiques
        location /uploads/ {
            alias /var/www/uploads/;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
        
        # Application principale
        location / {
            proxy_pass http://app;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
        }
    }
}
EOF
```

## 🔐 5. Configuration SSL avec Let's Encrypt

### Obtenir les certificats SSL
```bash
# Arrêter Nginx temporairement
systemctl stop nginx

# Obtenir le certificat SSL
certbot certonly --standalone -d votre-domaine.com -d www.votre-domaine.com

# Créer le répertoire SSL pour Docker
mkdir -p ssl

# Copier les certificats
cp /etc/letsencrypt/live/votre-domaine.com/fullchain.pem ssl/
cp /etc/letsencrypt/live/votre-domaine.com/privkey.pem ssl/

# Ajuster les permissions
chmod 644 ssl/fullchain.pem
chmod 600 ssl/privkey.pem
```

### Configuration du renouvellement automatique
```bash
# Tester le renouvellement
certbot renew --dry-run

# Ajouter une tâche cron pour le renouvellement automatique
echo "0 12 * * * /usr/bin/certbot renew --quiet --post-hook 'docker compose -f /opt/usilenziu/docker-compose.prod.yml restart nginx'" | crontab -
```

## 🚀 6. Déploiement et démarrage

### Construction et démarrage des conteneurs
```bash
# Se placer dans le répertoire de l'application
cd /opt/usilenziu

# Construire et démarrer les services
docker compose -f docker-compose.prod.yml up -d --build

# Vérifier le statut des conteneurs
docker compose -f docker-compose.prod.yml ps

# Vérifier les logs
docker compose -f docker-compose.prod.yml logs -f
```

### Configuration de la base de données
```bash
# Attendre que la base de données soit prête
sleep 30

# Exécuter les scripts d'initialisation
docker exec usilenziu-postgres psql -U usilenzio_user -d usilenzio -c "
INSERT INTO admin_users (username, password_hash, role) 
VALUES ('administrateur', '@dm1n1str@t3uR!)', 'super-admin')
ON CONFLICT (username) DO UPDATE SET 
    password_hash = EXCLUDED.password_hash,
    role = EXCLUDED.role,
    updated_at = CURRENT_TIMESTAMP;
"
```

## 🔧 7. Configuration du monitoring et maintenance

### Script de sauvegarde
```bash
# Créer un script de sauvegarde
cat > /opt/usilenziu/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/opt/usilenziu/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Sauvegarde de la base de données
docker exec usilenziu-postgres pg_dump -U usilenzio_user usilenzio > $BACKUP_DIR/db_backup_$DATE.sql

# Sauvegarde des uploads
tar -czf $BACKUP_DIR/uploads_$DATE.tar.gz public/uploads/

# Nettoyer les anciennes sauvegardes (garder 7 jours)
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Sauvegarde terminée: $DATE"
EOF

chmod +x /opt/usilenziu/backup.sh

# Ajouter à la crontab (sauvegarde quotidienne à 2h)
echo "0 2 * * * /opt/usilenziu/backup.sh" | crontab -
```

### Script de redémarrage
```bash
# Créer un script de redémarrage
cat > /opt/usilenziu/restart.sh << 'EOF'
#!/bin/bash
cd /opt/usilenziu
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up -d --build
echo "Application redémarrée: $(date)"
EOF

chmod +x /opt/usilenziu/restart.sh
```

## 📊 8. Vérification et tests

### Tests de fonctionnement
```bash
# Vérifier que l'application répond
curl -I https://votre-domaine.com

# Vérifier la redirection HTTP vers HTTPS
curl -I http://votre-domaine.com

# Tester l'API
curl -X GET https://votre-domaine.com/api/rooms

# Vérifier les certificats SSL
openssl s_client -connect votre-domaine.com:443 -servername votre-domaine.com
```

### Monitoring des logs
```bash
# Logs de l'application
docker compose -f docker-compose.prod.yml logs -f app

# Logs de Nginx
docker compose -f docker-compose.prod.yml logs -f nginx

# Logs de la base de données
docker compose -f docker-compose.prod.yml logs -f postgres
```

## 🔄 9. Mise à jour de l'application

### Processus de mise à jour
```bash
# Se placer dans le répertoire de l'application
cd /opt/usilenziu

# Faire une sauvegarde
./backup.sh

# Récupérer les dernières modifications
git pull origin main

# Redémarrer l'application
./restart.sh
```

## 🛡️ 10. Sécurité supplémentaire

### Configuration du fail2ban
```bash
# Installer fail2ban
apt install -y fail2ban

# Configuration pour Nginx
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log

[nginx-limit-req]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log
maxretry = 10
EOF

# Démarrer fail2ban
systemctl start fail2ban
systemctl enable fail2ban
```

## 📝 11. Commandes utiles

### Gestion des conteneurs
```bash
# Voir le statut
docker compose -f docker-compose.prod.yml ps

# Redémarrer un service
docker compose -f docker-compose.prod.yml restart app

# Voir les logs
docker compose -f docker-compose.prod.yml logs -f

# Arrêter tous les services
docker compose -f docker-compose.prod.yml down

# Redémarrer tous les services
docker compose -f docker-compose.prod.yml up -d
```

### Maintenance
```bash
# Nettoyer les images Docker inutilisées
docker system prune -a

# Vérifier l'espace disque
df -h

# Vérifier l'utilisation mémoire
free -h

# Vérifier les processus
htop
```

## ✅ Vérification finale

Votre application U Silenziu devrait maintenant être accessible en HTTPS à l'adresse :
- **URL principale** : `https://votre-domaine.com`
- **Admin** : `https://votre-domaine.com/admin/login`
- **Identifiants admin** : `administrateur` / `@dm1n1str@t3uR!)`

### Points de vérification :
- ✅ Certificat SSL valide
- ✅ Redirection HTTP vers HTTPS
- ✅ Application accessible
- ✅ Base de données fonctionnelle
- ✅ Authentification admin opérationnelle
- ✅ Sauvegardes automatiques configurées
- ✅ Renouvellement automatique des certificats

Votre application est maintenant déployée de manière sécurisée en production ! 🎉
