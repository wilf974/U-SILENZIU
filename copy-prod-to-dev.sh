#!/bin/bash

echo "=== COPIE PRODUCTION → DÉVELOPPEMENT ==="
echo ""

# 1. Arrêter le développement local
echo "1. 🛑 ARRÊT DÉVELOPPEMENT LOCAL :"
echo "================================="
docker compose -f docker-compose.dev.yml down

# 2. Sauvegarder la config dev actuelle
echo ""
echo "2. 💾 SAUVEGARDE CONFIG DEV ACTUELLE :"
echo "======================================"
mkdir -p backups/dev-backup-$(date +%Y%m%d-%H%M%S)
BACKUP_DEV="backups/dev-backup-$(date +%Y%m%d-%H%M%S)"

cp docker-compose.dev.yml "$BACKUP_DEV/"
cp env.dev "$BACKUP_DEV/"
cp -r nginx-dev/ "$BACKUP_DEV/nginx-dev-backup/"

echo "✅ Config dev sauvegardée dans: $BACKUP_DEV"

# 3. Copier la configuration de production
echo ""
echo "3. 📋 COPIE CONFIGURATION PRODUCTION :"
echo "======================================"

# Copier les fichiers de configuration
cp docker-compose.prod.yml docker-compose.dev.yml
echo "✅ docker-compose.dev.yml (copié depuis prod)"

# Adapter pour le dev local
echo ""
echo "4. 🔧 ADAPTATION POUR DÉVELOPPEMENT :"
echo "===================================="

# Modifier les ports pour éviter les conflits
sed -i 's/3000:3000/3001:3000/g' docker-compose.dev.yml
sed -i 's/5432:5432/5433:5432/g' docker-compose.dev.yml
sed -i 's/6379:6379/6380:6379/g' docker-compose.dev.yml
sed -i 's/80:80/8080:80/g' docker-compose.dev.yml
sed -i 's/443:443/8443:443/g' docker-compose.dev.yml

echo "✅ Ports adaptés pour le dev local"

# Modifier les noms de conteneurs
sed -i 's/u-silenziu-/u-silenziu-dev-/g' docker-compose.dev.yml
sed -i 's/nginx-prod/nginx-dev/g' docker-compose.dev.yml
sed -i 's/redis-prod/redis-dev/g' docker-compose.dev.yml

echo "✅ Noms de conteneurs adaptés"

# 5. Copier les variables d'environnement
echo ""
echo "5. 🔐 COPIE VARIABLES ENVIRONNEMENT :"
echo "===================================="

cp env.prod env.dev
echo "✅ env.dev (copié depuis env.prod)"

# Adapter pour le dev local
sed -i 's/DATABASE_URL=postgresql:\/\/usilenzio_user:usilenzio_password@postgres:5432\/usilenzio/DATABASE_URL=postgresql:\/\/usilenzio_user:usilenzio_password@postgres:5432\/usilenzio_dev/g' env.dev
sed -i 's/REDIS_URL=redis:\/\/redis:6379/REDIS_URL=redis:\/\/redis:6380/g' env.dev

echo "✅ Variables d'environnement adaptées"

# 6. Copier la configuration Nginx
echo ""
echo "6. 🌐 COPIE CONFIGURATION NGINX :"
echo "================================="

cp -r nginx/ nginx-dev/
echo "✅ nginx-dev/ (copié depuis nginx/)"

# Adapter les ports dans la config Nginx
find nginx-dev/ -name "*.conf" -exec sed -i 's/proxy_pass http:\/\/u-silenziu:3000/proxy_pass http:\/\/u-silenziu-dev:3000/g' {} \;
find nginx-dev/ -name "*.conf" -exec sed -i 's/server_name rageroom.usilenziu.com/server_name localhost/g' {} \;

echo "✅ Configuration Nginx adaptée"

# 7. Démarrer le développement
echo ""
echo "7. 🚀 DÉMARRAGE DÉVELOPPEMENT :"
echo "==============================="

docker compose -f docker-compose.dev.yml up -d --build

echo ""
echo "✅ COPIE TERMINÉE !"
echo ""
echo "🌐 Développement local disponible sur:"
echo "   - Application: http://localhost:3001"
echo "   - Nginx: http://localhost:8080"
echo "   - Base de données: localhost:5433"
echo ""
echo "📁 Sauvegarde dev précédent: $BACKUP_DEV"
