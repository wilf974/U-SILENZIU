#!/bin/bash

# Script de déploiement U Silenziu
# Usage: ./deploy.sh [domaine] [email]

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
DOMAIN=${1:-"votre-domaine.com"}
EMAIL=${2:-"admin@votre-domaine.com"}
APP_DIR="/opt/usilenziu"

echo -e "${BLUE}🚀 Déploiement de U Silenziu sur $DOMAIN${NC}"

# Fonction pour afficher les messages
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERREUR: $1${NC}"
    exit 1
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] ATTENTION: $1${NC}"
}

# Vérifier si on est root
if [ "$EUID" -ne 0 ]; then
    error "Ce script doit être exécuté en tant que root"
fi

# Mise à jour du système
log "Mise à jour du système..."
apt update && apt upgrade -y

# Installation des prérequis
log "Installation des prérequis..."
apt install -y curl wget git unzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release snapd

# Installation de Docker
log "Installation de Docker..."
if ! command -v docker &> /dev/null; then
    # Supprimer les anciennes versions
    apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # Ajouter la clé GPG officielle de Docker
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Ajouter le repository Docker
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Installer Docker
    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Démarrer Docker
    systemctl start docker
    systemctl enable docker
else
    log "Docker est déjà installé"
fi

# Installation de Nginx
log "Installation de Nginx..."
if ! command -v nginx &> /dev/null; then
    apt install -y nginx
    systemctl start nginx
    systemctl enable nginx
else
    log "Nginx est déjà installé"
fi

# Installation de Certbot
log "Installation de Certbot..."
if ! command -v certbot &> /dev/null; then
    snap install core; snap refresh core
    snap install --classic certbot
    ln -sf /snap/bin/certbot /usr/bin/certbot
else
    log "Certbot est déjà installé"
fi

# Configuration du firewall
log "Configuration du firewall..."
if command -v ufw &> /dev/null; then
    ufw --force enable
    ufw allow ssh
    ufw allow 80/tcp
    ufw allow 443/tcp
else
    apt install -y ufw
    ufw --force enable
    ufw allow ssh
    ufw allow 80/tcp
    ufw allow 443/tcp
fi

# Création du répertoire de l'application
log "Création du répertoire de l'application..."
mkdir -p $APP_DIR
cd $APP_DIR

# Si le code n'est pas déjà présent, le cloner
if [ ! -f "package.json" ]; then
    log "Clonage du code source..."
    # Ici vous devriez remplacer par votre repository Git
    # git clone https://github.com/votre-username/usilenziu.git .
    warn "Veuillez copier le code source dans $APP_DIR"
    warn "Ou configurez le repository Git dans ce script"
fi

# Configuration des variables d'environnement
log "Configuration des variables d'environnement..."
cat > .env << EOF
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

# Configuration de l'application
NEXT_PUBLIC_APP_URL=https://$DOMAIN
NEXT_PUBLIC_APP_NAME=U Silenziu
EOF

# Mise à jour de la configuration Nginx avec le domaine
log "Configuration de Nginx..."
sed -i "s/votre-domaine.com/$DOMAIN/g" nginx.conf

# Arrêt de Nginx pour obtenir les certificats
log "Arrêt de Nginx pour obtenir les certificats SSL..."
systemctl stop nginx

# Obtenir les certificats SSL
log "Obtention des certificats SSL pour $DOMAIN..."
certbot certonly --standalone -d $DOMAIN -d www.$DOMAIN --email $EMAIL --agree-tos --non-interactive

# Création du répertoire SSL
mkdir -p ssl

# Copie des certificats
log "Copie des certificats SSL..."
cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem ssl/
cp /etc/letsencrypt/live/$DOMAIN/privkey.pem ssl/

# Ajustement des permissions
chmod 644 ssl/fullchain.pem
chmod 600 ssl/privkey.pem

# Construction et démarrage des conteneurs
log "Construction et démarrage des conteneurs..."
docker compose -f docker-compose.prod.yml up -d --build

# Attendre que la base de données soit prête
log "Attente de la base de données..."
sleep 30

# Configuration de l'utilisateur admin
log "Configuration de l'utilisateur administrateur..."
docker exec usilenziu-postgres psql -U usilenzio_user -d usilenzio -c "
INSERT INTO admin_users (username, password_hash, role) 
VALUES ('administrateur', '@dm1n1str@t3uR!)', 'super-admin')
ON CONFLICT (username) DO UPDATE SET 
    password_hash = EXCLUDED.password_hash,
    role = EXCLUDED.role,
    updated_at = CURRENT_TIMESTAMP;
" || warn "Impossible de créer l'utilisateur admin (peut-être déjà existant)"

# Configuration du renouvellement automatique des certificats
log "Configuration du renouvellement automatique des certificats..."
echo "0 12 * * * /usr/bin/certbot renew --quiet --post-hook 'docker compose -f $APP_DIR/docker-compose.prod.yml restart nginx'" | crontab -

# Création des scripts de maintenance
log "Création des scripts de maintenance..."

# Script de sauvegarde
cat > backup.sh << 'EOF'
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

chmod +x backup.sh

# Script de redémarrage
cat > restart.sh << 'EOF'
#!/bin/bash
cd /opt/usilenziu
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up -d --build
echo "Application redémarrée: $(date)"
EOF

chmod +x restart.sh

# Configuration de la sauvegarde automatique
echo "0 2 * * * $APP_DIR/backup.sh" | crontab -

# Vérification finale
log "Vérification du déploiement..."
sleep 10

# Test de l'application
if curl -f -s https://$DOMAIN > /dev/null; then
    log "✅ Application accessible en HTTPS"
else
    warn "⚠️  L'application n'est pas encore accessible, vérifiez les logs"
fi

# Affichage des informations de connexion
echo ""
echo -e "${GREEN}🎉 Déploiement terminé !${NC}"
echo -e "${BLUE}📋 Informations de connexion :${NC}"
echo -e "   URL: https://$DOMAIN"
echo -e "   Admin: https://$DOMAIN/admin/login"
echo -e "   Utilisateur: administrateur"
echo -e "   Mot de passe: @dm1n1str@t3uR!)"
echo ""
echo -e "${BLUE}🔧 Commandes utiles :${NC}"
echo -e "   Voir les logs: docker compose -f docker-compose.prod.yml logs -f"
echo -e "   Redémarrer: ./restart.sh"
echo -e "   Sauvegarder: ./backup.sh"
echo -e "   Statut: docker compose -f docker-compose.prod.yml ps"
echo ""

log "Déploiement terminé avec succès !"
