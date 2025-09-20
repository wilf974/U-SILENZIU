#!/bin/bash

echo "=== CORRECTION TABLE SMTP_CONFIG ==="
echo ""

# 1. Corriger la structure de la table smtp_config
echo "1. Ajout des colonnes manquantes..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
ALTER TABLE smtp_config 
ADD COLUMN IF NOT EXISTS tls_reject_unauthorized BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS tls_min_version VARCHAR(20) DEFAULT 'TLSv1.2';
"

echo ""
echo "2. Vérification de la structure de la table smtp_config..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\d smtp_config;"

echo ""
echo "3. Vérification des données existantes..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "SELECT * FROM smtp_config;"

echo ""
echo "4. Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

echo ""
echo "5. Vérification des logs..."
sleep 5
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=10

echo ""
echo "=== CORRECTION TERMINÉE ==="
echo "Vous devriez maintenant pouvoir sauvegarder la configuration SMTP."
