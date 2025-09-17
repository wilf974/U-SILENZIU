#!/bin/bash

# Script pour nettoyer les fichiers problématiques avant le build
echo "🧹 Nettoyage des fichiers problématiques..."

# Supprimer les fichiers de backup qui causent des erreurs
find . -name "*backup-additionalinfo*" -type f -delete
find . -name "*backup*" -type d -exec rm -rf {} + 2>/dev/null || true

# Supprimer les fichiers temporaires
find . -name "*.tmp" -type f -delete
find . -name "*.log" -type f -delete

# Supprimer les dossiers node_modules et .next s'ils existent
rm -rf node_modules
rm -rf .next

echo "✅ Nettoyage terminé"
echo "🔨 Reconstruction des conteneurs..."

# Reconstruire
docker compose down
docker system prune -f
docker compose up -d --build
