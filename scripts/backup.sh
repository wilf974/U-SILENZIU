#!/bin/bash

# Script de sauvegarde automatique de la base de données
# U Silenziu - Janvier 2025

set -e

# Configuration
BACKUP_DIR="/backups"
DB_NAME="usilenzio"
DB_USER="usilenzio_user"
DB_HOST="postgres"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/backup_${DB_NAME}_${DATE}.sql"
RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-30}

echo "🗄️ Début de la sauvegarde de la base de données..."

# Créer le répertoire de sauvegarde s'il n'existe pas
mkdir -p "$BACKUP_DIR"

# Effectuer la sauvegarde
echo "📦 Création de la sauvegarde: $BACKUP_FILE"
pg_dump -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" > "$BACKUP_FILE"

# Compresser la sauvegarde
echo "🗜️ Compression de la sauvegarde..."
gzip "$BACKUP_FILE"
BACKUP_FILE="${BACKUP_FILE}.gz"

# Vérifier la taille de la sauvegarde
BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo "✅ Sauvegarde créée avec succès: $BACKUP_FILE (Taille: $BACKUP_SIZE)"

# Nettoyer les anciennes sauvegardes
echo "🧹 Nettoyage des anciennes sauvegardes (plus de $RETENTION_DAYS jours)..."
find "$BACKUP_DIR" -name "backup_${DB_NAME}_*.sql.gz" -type f -mtime +$RETENTION_DAYS -delete

# Lister les sauvegardes restantes
echo "📋 Sauvegardes disponibles:"
ls -lh "$BACKUP_DIR"/backup_${DB_NAME}_*.sql.gz 2>/dev/null || echo "Aucune sauvegarde trouvée"

echo "🎉 Sauvegarde terminée avec succès !"
