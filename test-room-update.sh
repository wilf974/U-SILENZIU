#!/bin/bash
# Script de test pour la mise à jour des salles
# U Silenziu - Septembre 2025

echo "🧪 TEST DE MISE À JOUR DES SALLES"
echo "================================"
echo ""

# 1. Vérifier l'état actuel des salles
echo "1. État actuel des salles :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT name, objects_to_destroy, included, is_active 
FROM rooms 
ORDER BY created_at;
"

echo ""

# 2. Tester la mise à jour via l'API
echo "2. Test de mise à jour via l'API..."

# Récupérer l'ID de la première salle
ROOM_ID=$(docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -t -c "SELECT id FROM rooms LIMIT 1;")
ROOM_ID=$(echo $ROOM_ID | xargs) # Supprimer les espaces blancs

echo "ID de la salle à tester: $ROOM_ID"

# Test de mise à jour avec objets_to_destroy vide
echo "Test avec objets_to_destroy vide..."
curl -X PUT "https://rageroom.usilenziu.com/api/admin/rooms/$ROOM_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Salle Test",
    "description": "Test de mise à jour",
    "duration": 20,
    "price": 25,
    "maxPeople": 4,
    "objectsToDestroy": [],
    "included": ["Équipements de protection"],
    "isActive": true
  }' | head -c 200

echo ""

# 3. Vérifier l'état après mise à jour
echo "3. État après mise à jour :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT name, objects_to_destroy, included, is_active 
FROM rooms 
WHERE id = '$ROOM_ID';
"

echo ""

echo "✅ TEST TERMINÉ !"
