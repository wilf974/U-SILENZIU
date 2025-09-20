#!/bin/bash
# Script pour activer la section rooms
# U Silenziu - Septembre 2025

echo "🔧 ACTIVATION SECTION ROOMS"
echo "==========================="
echo ""

# 1. Activer la section rooms
echo "1. Activation de la section 'rooms'..."

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
UPDATE homepage_sections 
SET is_active = true 
WHERE id = 'rooms';
"

echo ""

# 2. Vérifier les sections
echo "2. Vérification des sections..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, section_type, title, order_index, is_active, is_visible
FROM homepage_sections 
ORDER BY order_index;
"

echo ""

# 3. Redémarrer l'application
echo "3. Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

echo "Attente du démarrage (15 secondes)..."
sleep 15

echo ""

# 4. Test de l'API homepage-sections
echo "4. Test de l'API homepage-sections..."
curl -s "https://rageroom.usilenziu.com/api/homepage-sections" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 500

echo ""

echo "✅ SECTION ROOMS ACTIVÉE !"
echo ""
echo "🔗 Vérifiez maintenant : https://rageroom.usilenziu.com"
