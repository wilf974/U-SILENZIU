#!/bin/bash

echo "=== SAUVEGARDE COMPLÈTE VPS U-SILENZIU ==="
echo ""

# Variables
BACKUP_DIR="backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📁 Répertoire de sauvegarde: $BACKUP_DIR"
echo ""

# 1. Sauvegarde de la base de données
echo "1. 💾 SAUVEGARDE BASE DE DONNÉES..."
docker exec u-silenziu-postgres pg_dump -U usilenzio_user -d usilenzio | gzip > "$BACKUP_DIR/database-backup.sql.gz"
echo "✅ Base de données sauvegardée"

# 2. Sauvegarde des volumes Docker
echo ""
echo "2. 📦 SAUVEGARDE VOLUMES DOCKER..."
docker run --rm -v u-silenziu-postgres-data:/data -v $(pwd)/$BACKUP_DIR:/backup alpine tar czf /backup/postgres-volume.tar.gz -C /data .
echo "✅ Volume PostgreSQL sauvegardé"

# 3. Sauvegarde des images Docker
echo ""
echo "3. 🐳 SAUVEGARDE IMAGES DOCKER..."
docker save u-silenziu-u-silenziu:latest | gzip > "$BACKUP_DIR/app-image.tar.gz"
docker save postgres:15-alpine nginx:alpine redis:7-alpine | gzip > "$BACKUP_DIR/base-images.tar.gz"
echo "✅ Images Docker sauvegardées"

# 4. Sauvegarde de la configuration
echo ""
echo "4. ⚙️ SAUVEGARDE CONFIGURATION..."
tar czf "$BACKUP_DIR/config.tar.gz" \
  docker-compose.prod.yml \
  nginx/ \
  ssl/ \
  env.prod \
  2>/dev/null || echo "Certains fichiers de config non trouvés (normal)"

# 5. Sauvegarde du code source
echo ""
echo "5. 📄 SAUVEGARDE CODE SOURCE..."
tar czf "$BACKUP_DIR/source-code.tar.gz" \
  --exclude=node_modules \
  --exclude=.git \
  --exclude=logs \
  --exclude=backups \
  --exclude="*.tar*" \
  app/ \
  components/ \
  lib/ \
  public/ \
  *.js \
  *.json \
  *.ts \
  *.md \
  2>/dev/null || echo "Certains fichiers source non trouvés"

# 6. État des conteneurs
echo ""
echo "6. 📊 ÉTAT DES CONTENEURS..."
docker compose -f docker-compose.prod.yml ps > "$BACKUP_DIR/containers-status.txt"
docker images > "$BACKUP_DIR/images-list.txt"
docker volume ls > "$BACKUP_DIR/volumes-list.txt"

# 7. Informations système
echo ""
echo "7. 💻 INFORMATIONS SYSTÈME..."
{
  echo "=== DATE DE SAUVEGARDE ==="
  date
  echo ""
  echo "=== ESPACE DISQUE ==="
  df -h
  echo ""
  echo "=== MÉMOIRE ==="
  free -h
  echo ""
  echo "=== PROCESSUS DOCKER ==="
  docker stats --no-stream
} > "$BACKUP_DIR/system-info.txt"

# 8. Résumé de la sauvegarde
echo ""
echo "8. 📋 RÉSUMÉ DE LA SAUVEGARDE..."
{
  echo "=== SAUVEGARDE U-SILENZIU VPS ==="
  echo "Date: $(date)"
  echo "Répertoire: $BACKUP_DIR"
  echo ""
  echo "=== FICHIERS CRÉÉS ==="
  ls -lh "$BACKUP_DIR"
  echo ""
  echo "=== TAILLE TOTALE ==="
  du -sh "$BACKUP_DIR"
} | tee "$BACKUP_DIR/backup-summary.txt"

# 9. Création d'une archive finale
echo ""
echo "9. 🗜️ CRÉATION ARCHIVE FINALE..."
tar czf "backup-vps-u-silenziu-$(date +%Y%m%d-%H%M%S).tar.gz" "$BACKUP_DIR/"
echo "✅ Archive finale créée: backup-vps-u-silenziu-$(date +%Y%m%d-%H%M%S).tar.gz"

echo ""
echo "=== SAUVEGARDE TERMINÉE ==="
echo "📁 Répertoire: $BACKUP_DIR"
echo "📦 Archive: backup-vps-u-silenziu-$(date +%Y%m%d-%H%M%S).tar.gz"
echo ""
echo "Pour télécharger la sauvegarde:"
echo "scp root@votre-ip:~/U-SILENZIU/backup-vps-u-silenziu-*.tar.gz ."
echo ""
echo "Pour restaurer:"
echo "1. Extraire l'archive"
echo "2. Restaurer la base: gunzip -c database-backup.sql.gz | docker exec -i postgres psql -U user -d db"
echo "3. Restaurer les images: docker load < app-image.tar.gz"
echo "4. Redémarrer: docker compose up -d"
