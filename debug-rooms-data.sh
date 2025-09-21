#!/bin/bash

echo "=== DIAGNOSTIC DONNÉES SALLES ==="
echo ""

# 1. Vérifier les données des salles en base
echo "1. 🔍 DONNÉES SALLES EN BASE :"
echo "=============================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  id, 
  name, 
  description, 
  included, 
  objects_to_destroy,
  max_people,
  price,
  duration,
  is_active,
  updated_at
FROM rooms 
ORDER BY name;
"

echo ""
echo "2. 🔍 API PUBLIQUE SALLES :"
echo "==========================="
curl -s "https://rageroom.usilenziu.com/api/rooms" | jq '.data[] | {name, description, included, objects_to_destroy}' 2>/dev/null || echo "Erreur jq ou API"

echo ""
echo "3. 🔍 TEST API DIRECTE :"
echo "======================="
curl -s "https://rageroom.usilenziu.com/api/rooms" | head -20

echo ""
echo "=== DIAGNOSTIC TERMINÉ ==="
