#!/bin/bash

echo "=== DIAGNOSTIC PROBLÈME MAX_PEOPLE ==="
echo ""

# 1. Vérifier la structure de la table rooms
echo "1. 🔍 STRUCTURE TABLE ROOMS :"
echo "============================"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\d rooms;"

# 2. Vérifier les salles existantes
echo ""
echo "2. 🔍 SALLES EXISTANTES :"
echo "========================"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  id,
  name,
  max_people,
  price,
  duration,
  is_active,
  updated_at
FROM rooms 
ORDER BY name;
"

# 3. Vérifier les logs d'erreur lors de la mise à jour
echo ""
echo "3. 🔍 LOGS ERREUR MISE À JOUR SALLE :"
echo "===================================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=50 | grep -A5 -B5 -i "rooms\|max_people\|erreur.*salle\|PUT.*rooms"

# 4. Test API GET d'une salle spécifique
echo ""
echo "4. 🧪 TEST API GET SALLE :"
echo "=========================="
FIRST_ROOM_ID=$(docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -t -c "SELECT id FROM rooms LIMIT 1;" | xargs)
if [ ! -z "$FIRST_ROOM_ID" ]; then
  echo "Test avec ID: $FIRST_ROOM_ID"
  curl -s "https://rageroom.usilenziu.com/api/admin/rooms/$FIRST_ROOM_ID" | head -c 500
else
  echo "❌ Aucune salle trouvée pour le test"
fi

# 5. Test API PUT simulation (modification max_people)
echo ""
echo ""
echo "5. 🧪 TEST API PUT MAX_PEOPLE :"
echo "==============================="
if [ ! -z "$FIRST_ROOM_ID" ]; then
  echo "Test modification max_people pour ID: $FIRST_ROOM_ID"
  
  # D'abord récupérer les données actuelles
  CURRENT_DATA=$(curl -s "https://rageroom.usilenziu.com/api/admin/rooms/$FIRST_ROOM_ID")
  echo "Données actuelles : $CURRENT_DATA" | head -c 200
  
  echo ""
  echo "Test PUT avec max_people modifié :"
  curl -s -X PUT "https://rageroom.usilenziu.com/api/admin/rooms/$FIRST_ROOM_ID" \
    -H "Content-Type: application/json" \
    -d '{
      "name": "Salle 1",
      "description": "Test description",
      "max_people": 8,
      "price": 25,
      "duration": 30,
      "objects_to_destroy": [],
      "included": [],
      "is_active": true
    }' | head -c 500
    
  echo ""
  echo ""
  echo "Vérification après PUT :"
  curl -s "https://rageroom.usilenziu.com/api/admin/rooms/$FIRST_ROOM_ID" | head -c 300
else
  echo "❌ Aucune salle trouvée pour le test PUT"
fi

# 6. Vérifier dans la base après test
echo ""
echo ""
echo "6. 🔍 VÉRIFICATION BASE APRÈS TEST :"
echo "===================================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  id,
  name,
  max_people,
  updated_at
FROM rooms 
WHERE id = '$FIRST_ROOM_ID';
"

echo ""
echo "=== DIAGNOSTIC TERMINÉ ==="
echo ""
echo "🔍 VÉRIFICATIONS :"
echo "• Structure table rooms"
echo "• Données actuelles des salles"
echo "• Logs d'erreur API"
echo "• Test GET/PUT API"
echo "• Vérification base de données"
echo ""
echo "💡 CAUSES POSSIBLES :"
echo "• Problème avec handleInputChange"
echo "• Type de données incorrect (string vs number)"
echo "• Cache navigateur"
echo "• Erreur API updateRoom"
echo "• Rechargement automatique des données"
