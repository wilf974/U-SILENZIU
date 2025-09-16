# Guide de Déploiement VPS Hostinger - U Silenziu

## 📋 Prérequis

### 1. VPS Hostinger
- **Plan recommandé** : VPS 2 ou VPS 4
- **OS** : Ubuntu 22.04 LTS
- **RAM** : Minimum 2GB (4GB recommandé)
- **Stockage** : Minimum 20GB SSD
- **Bande passante** : Illimitée

### 2. Domaine
- Domaine configuré chez Hostinger
- DNS pointant vers l'IP du VPS

## 🚀 Installation du Serveur

### 1. Connexion au VPS
```bash
ssh root@VOTRE_IP_VPS
```

### 2. Mise à jour du système
```bash
apt update && apt upgrade -y
```

### 3. Installation des dépendances
```bash
# Installation de Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Installation de Docker Compose
apt install docker-compose-plugin -y

# Installation de Git
apt install git -y

# Installation de Nginx (optionnel, pour reverse proxy)
apt install nginx -y

# Installation de Certbot pour SSL
apt install certbot python3-certbot-nginx -y
```

### 4. Configuration du firewall
```bash
# Installation d'UFW
apt install ufw -y

# Configuration des règles
ufw allow ssh
ufw allow 80
ufw allow 443
ufw allow 3000
ufw enable
```

## 📁 Déploiement de l'Application

### 1. Création du répertoire de travail
```bash
mkdir -p /var/www/usilenzio
cd /var/www/usilenzio
```

### 2. Clonage du projet
```bash
git clone https://github.com/VOTRE_USERNAME/usilenzio.git .
```

### 3. Configuration des variables d'environnement
```bash
# Copier le fichier d'exemple
cp env.example .env

# Éditer le fichier .env
nano .env
```

**Contenu du fichier `.env` :**
```env
# Configuration de base
NODE_ENV=production
NEXT_PUBLIC_SITE_URL=https://votre-domaine.com
NEXT_PUBLIC_SITE_NAME=U Silenziu

# Base de données PostgreSQL
DATABASE_URL=postgresql://usilenzio_user:usilenzio_password_2024@postgres:5432/usilenzio

# Configuration SMTP (à remplir avec vos données)
SMTP_HOST=smtp-mail.outlook.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=contact@votre-domaine.com
SMTP_PASS=votre_mot_de_passe_smtp
SMTP_FROM=contact@votre-domaine.com

# Clé de chiffrement pour les mots de passe SMTP
ENCRYPTION_KEY=votre_cle_de_chiffrement_32_caracteres

# Configuration des notifications
NOTIFICATION_EMAIL=contact@votre-domaine.com
NOTIFICATION_PHONE=+33123456789

# Configuration des uploads
UPLOAD_DIR=./public/uploads
MAX_FILE_SIZE=5242880

# Configuration du cron
CRON_ENABLED=true
CRON_INTERVAL=*/15 * * * * # Toutes les 15 minutes

# Configuration de sécurité
JWT_SECRET=votre_jwt_secret_tres_long_et_complexe
SESSION_SECRET=votre_session_secret_tres_long_et_complexe

# Configuration des logs
LOG_LEVEL=info
LOG_FILE=./logs/app.log

# Configuration du cache
CACHE_TTL=3600
CACHE_MAX_SIZE=100

# Configuration des performances
NEXT_PUBLIC_IMAGE_OPTIMIZATION=true
NEXT_PUBLIC_COMPRESSION=true
```

### 4. Configuration de Nginx (Reverse Proxy)

Créer le fichier de configuration Nginx :
```bash
nano /etc/nginx/sites-available/usilenzio
```

**Contenu :**
```nginx
server {
    listen 80;
    server_name votre-domaine.com www.votre-domaine.com;

    # Redirection vers HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name votre-domaine.com www.votre-domaine.com;

    # Certificat SSL (sera généré par Certbot)
    ssl_certificate /etc/letsencrypt/live/votre-domaine.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/votre-domaine.com/privkey.pem;

    # Configuration SSL sécurisée
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Headers de sécurité
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # Gestion des uploads
    client_max_body_size 10M;

    # Proxy vers l'application Next.js
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 86400;
    }

    # Cache statique pour les assets
    location /_next/static/ {
        proxy_pass http://localhost:3000;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Cache pour les images
    location /images/ {
        proxy_pass http://localhost:3000;
        expires 1y;
        add_header Cache-Control "public";
    }

    # Cache pour les uploads
    location /uploads/ {
        proxy_pass http://localhost:3000;
        expires 1y;
        add_header Cache-Control "public";
    }

    # Gestion des erreurs
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
}
```

Activer le site :
```bash
ln -s /etc/nginx/sites-available/usilenzio /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
```

### 5. Génération du certificat SSL
```bash
certbot --nginx -d votre-domaine.com -d www.votre-domaine.com
```

### 6. Démarrage de l'application avec Docker
```bash
# Construire et démarrer les conteneurs
docker-compose up -d --build

# Vérifier les logs
docker-compose logs -f
```

## 🔧 Configuration Post-Déploiement

### 1. Création des répertoires nécessaires
```bash
# Créer les répertoires de données
mkdir -p /var/www/usilenzio/data
mkdir -p /var/www/usilenzio/logs
mkdir -p /var/www/usilenzio/public/uploads

# Définir les permissions
chown -R 1000:1000 /var/www/usilenzio/data
chown -R 1000:1000 /var/www/usilenzio/logs
chown -R 1000:1000 /var/www/usilenzio/public/uploads
```

### 2. Configuration des sauvegardes automatiques
```bash
# Créer le script de sauvegarde
nano /var/www/usilenzio/backup.sh
```

**Contenu du script :**
```bash
#!/bin/bash

# Configuration
BACKUP_DIR="/var/backups/usilenzio"
DATE=$(date +%Y%m%d_%H%M%S)
PROJECT_DIR="/var/www/usilenzio"

# Créer le répertoire de sauvegarde
mkdir -p $BACKUP_DIR

# Sauvegarder la base de données PostgreSQL
docker-compose -f $PROJECT_DIR/docker-compose.yml exec -T postgres pg_dump -U usilenzio_user -d usilenzio > $BACKUP_DIR/postgres_backup_$DATE.sql

# Sauvegarder les uploads
tar -czf $BACKUP_DIR/uploads_$DATE.tar.gz -C $PROJECT_DIR/public uploads/

# Sauvegarder la configuration
tar -czf $BACKUP_DIR/config_$DATE.tar.gz -C $PROJECT_DIR .env docker-compose.yml

# Nettoyer les anciennes sauvegardes (garder 7 jours)
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Sauvegarde terminée : $DATE"
```

Rendre le script exécutable :
```bash
chmod +x /var/www/usilenzio/backup.sh
```

Ajouter au cron :
```bash
crontab -e
```

Ajouter cette ligne :
```
0 2 * * * /var/www/usilenzio/backup.sh >> /var/log/backup.log 2>&1
```

### 3. Configuration du monitoring
```bash
# Installation de htop pour le monitoring
apt install htop -y

# Installation de logwatch pour les logs
apt install logwatch -y
```

### 4. Configuration des logs
```bash
# Créer la configuration logrotate
nano /etc/logrotate.d/usilenzio
```

**Contenu :**
```
/var/www/usilenzio/logs/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 root root
    postrotate
        docker-compose -f /var/www/usilenzio/docker-compose.yml restart app
    endscript
}
```

## 🔍 Tests de Validation

### 1. Test de l'application
```bash
# Vérifier que l'application répond
curl -I https://votre-domaine.com

# Vérifier les logs
docker-compose logs app

# Tester l'API
curl https://votre-domaine.com/api/rooms
```

### 2. Test du back-office
- Accéder à `https://votre-domaine.com/admin`
- Vérifier toutes les fonctionnalités
- Tester la création/modification de salles
- Tester la configuration SMTP
- Tester les notifications

### 3. Test des performances
```bash
# Installation d'Apache Bench
apt install apache2-utils -y

# Test de charge
ab -n 1000 -c 10 https://votre-domaine.com/
```

## 🛠️ Maintenance

### 1. Mise à jour de l'application
```bash
cd /var/www/usilenzio

# Arrêter l'application
docker-compose down

# Récupérer les dernières modifications
git pull origin main

# Reconstruire et redémarrer
docker-compose up -d --build

# Vérifier les logs
docker-compose logs -f
```

### 2. Sauvegarde manuelle
```bash
cd /var/www/usilenzio
./backup.sh
```

### 3. Nettoyage des logs
```bash
# Nettoyer les logs Docker
docker system prune -f

# Nettoyer les logs de l'application
find /var/www/usilenzio/logs -name "*.log" -mtime +30 -delete
```

### 4. Monitoring des ressources
```bash
# Vérifier l'utilisation des ressources
htop

# Vérifier l'espace disque
df -h

# Vérifier l'utilisation mémoire
free -h

# Vérifier les processus Docker
docker stats
```

## 🔒 Sécurité

### 1. Mise à jour régulière
```bash
# Mise à jour du système
apt update && apt upgrade -y

# Mise à jour de Docker
docker system prune -f
```

### 2. Surveillance des logs
```bash
# Surveiller les tentatives de connexion
tail -f /var/log/auth.log

# Surveiller les logs Nginx
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

### 3. Configuration du fail2ban
```bash
# Installation
apt install fail2ban -y

# Configuration
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
nano /etc/fail2ban/jail.local
```

## 📞 Support et Dépannage

### 1. Logs utiles
```bash
# Logs de l'application
docker-compose logs app

# Logs Nginx
tail -f /var/log/nginx/error.log

# Logs système
journalctl -u docker.service
```

### 2. Commandes de diagnostic
```bash
# Vérifier l'état des conteneurs
docker-compose ps

# Vérifier l'utilisation des ressources
docker stats

# Vérifier la connectivité
ping google.com
nslookup votre-domaine.com
```

### 3. Redémarrage des services
```bash
# Redémarrer l'application
docker-compose restart

# Redémarrer Nginx
systemctl restart nginx

# Redémarrer Docker
systemctl restart docker
```

## 📊 Monitoring Avancé

### 1. Installation de Prometheus (optionnel)
```bash
# Créer le répertoire
mkdir -p /opt/prometheus
cd /opt/prometheus

# Télécharger Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
tar xvf prometheus-*.tar.gz
cd prometheus-*

# Configuration
nano prometheus.yml
```

### 2. Installation de Grafana (optionnel)
```bash
# Ajouter le repository
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | tee -a /etc/apt/sources.list.d/grafana.list

# Installation
apt update
apt install grafana -y

# Démarrage
systemctl start grafana-server
systemctl enable grafana-server
```

## 🎯 Checklist de Déploiement

- [ ] VPS configuré avec Ubuntu 22.04
- [ ] Docker et Docker Compose installés
- [ ] Nginx configuré comme reverse proxy
- [ ] Certificat SSL généré avec Certbot
- [ ] Variables d'environnement configurées
- [ ] Application déployée et fonctionnelle
- [ ] Sauvegardes automatiques configurées
- [ ] Monitoring de base en place
- [ ] Tests de validation effectués
- [ ] Documentation mise à jour

## 📞 Contact Support

En cas de problème :
1. Vérifier les logs : `docker-compose logs -f`
2. Vérifier l'état des services : `systemctl status nginx docker`
3. Vérifier la connectivité : `curl -I https://votre-domaine.com`
4. Consulter la documentation : `README.md`
5. Contacter le support technique

---

**Note :** Ce guide suppose que vous avez un accès root au VPS. Adaptez les commandes selon vos permissions et votre configuration spécifique.
