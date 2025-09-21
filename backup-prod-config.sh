#!/bin/bash

echo "=== SAUVEGARDE CONFIGURATION PRODUCTION ==="
echo ""

# 1. Créer le dossier de sauvegarde
mkdir -p backups/prod-config-$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="backups/prod-config-$(date +%Y%m%d-%H%M%S)"

echo "📁 Dossier de sauvegarde: $BACKUP_DIR"
echo ""

# 2. Sauvegarder les fichiers de configuration
echo "1. 📋 SAUVEGARDE FICHIERS CONFIG :"
echo "=================================="

# Docker Compose
cp docker-compose.prod.yml "$BACKUP_DIR/"
echo "✅ docker-compose.prod.yml"

# Variables d'environnement
cp env.prod "$BACKUP_DIR/"
echo "✅ env.prod"

# Configuration Nginx
cp -r nginx/ "$BACKUP_DIR/nginx-prod/"
echo "✅ nginx/"

# 3. Sauvegarder la base de données
echo ""
echo "2. 🗄️ SAUVEGARDE BASE DE DONNÉES :"
echo "=================================="

# Dump de la base de données
docker exec u-silenziu-postgres pg_dump -U usilenzio_user -d usilenzio > "$BACKUP_DIR/database-backup.sql"
echo "✅ database-backup.sql"

# 4. Sauvegarder les fichiers de l'application
echo ""
echo "3. 📦 SAUVEGARDE APPLICATION :"
echo "=============================="

# Copier les fichiers essentiels
cp -r app/ "$BACKUP_DIR/app/"
cp -r lib/ "$BACKUP_DIR/lib/"
cp -r components/ "$BACKUP_DIR/components/"
cp -r public/ "$BACKUP_DIR/public/"
cp package.json "$BACKUP_DIR/"
cp next.config.js "$BACKUP_DIR/"
cp tailwind.config.js "$BACKUP_DIR/"
cp tsconfig.json "$BACKUP_DIR/"

echo "✅ Fichiers application"

# 5. Créer un script de restauration
echo ""
echo "4. 📝 CRÉATION SCRIPT RESTAURATION :"
echo "===================================="

cat > "$BACKUP_DIR/restore-to-dev.sh" << 'EOF'
#!/bin/bash

echo "=== RESTAURATION VERS DÉVELOPPEMENT ==="
echo ""

# 1. Arrêter le dev local
echo "1. 🛑 ARRÊT DÉVELOPPEMENT LOCAL :"
echo "================================="
docker compose -f docker-compose.dev.yml down

# 2. Restaurer la base de données
echo ""
echo "2. 🗄️ RESTAURATION BASE DE DONNÉES :"
echo "===================================="
docker compose -f docker-compose.dev.yml up -d postgres
sleep 5

# Restaurer le dump
docker exec -i u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio < database-backup.sql
echo "✅ Base de données restaurée"

# 3. Redémarrer l'application
echo ""
echo "3. 🚀 REDÉMARRAGE APPLICATION :"
echo "==============================="
docker compose -f docker-compose.dev.yml up -d

echo ""
echo "✅ RESTAURATION TERMINÉE !"
echo "Le développement local utilise maintenant la configuration de production."
EOF

chmod +x "$BACKUP_DIR/restore-to-dev.sh"
echo "✅ restore-to-dev.sh"

echo ""
echo "✅ SAUVEGARDE TERMINÉE !"
echo "📁 Dossier: $BACKUP_DIR"
echo ""
echo "Pour restaurer vers le dev local:"
echo "cd $BACKUP_DIR && ./restore-to-dev.sh"
