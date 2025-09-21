#!/bin/bash

echo "=== RESTAURATION CONFIG DÉVELOPPEMENT ORIGINALE ==="
echo ""

# 1. Arrêter le dev actuel
echo "1. 🛑 ARRÊT DÉVELOPPEMENT ACTUEL :"
echo "=================================="
docker compose -f docker-compose.dev.yml down

# 2. Lister les sauvegardes disponibles
echo ""
echo "2. 📋 SAUVEGARDES DISPONIBLES :"
echo "=============================="
ls -la backups/ | grep "dev-backup-"

echo ""
read -p "Entrez le nom de la sauvegarde à restaurer (ex: dev-backup-20250121-143022): " BACKUP_NAME

if [ ! -d "backups/$BACKUP_NAME" ]; then
    echo "❌ Sauvegarde non trouvée: backups/$BACKUP_NAME"
    exit 1
fi

# 3. Restaurer la configuration
echo ""
echo "3. 🔄 RESTAURATION CONFIGURATION :"
echo "=================================="

cp "backups/$BACKUP_NAME/docker-compose.dev.yml" .
cp "backups/$BACKUP_NAME/env.dev" .

# Restaurer Nginx si disponible
if [ -d "backups/$BACKUP_NAME/nginx-dev-backup" ]; then
    rm -rf nginx-dev/
    cp -r "backups/$BACKUP_NAME/nginx-dev-backup" nginx-dev/
    echo "✅ Configuration Nginx restaurée"
fi

echo "✅ Configuration restaurée depuis: $BACKUP_NAME"

# 4. Redémarrer le développement
echo ""
echo "4. 🚀 REDÉMARRAGE DÉVELOPPEMENT :"
echo "================================="
docker compose -f docker-compose.dev.yml up -d

echo ""
echo "✅ RESTAURATION TERMINÉE !"
echo "Le développement local utilise maintenant sa configuration originale."
