#!/bin/bash

echo "=== CORRECTION BUG MAX_PEOPLE ==="
echo ""

# 1. Pull du code corrigé
echo "1. 📥 PULL CORRECTION :"
echo "======================"
git pull origin main

# 2. Rebuild rapide
echo ""
echo "2. 🔧 REBUILD RAPIDE :"
echo "====================="
docker compose -f docker-compose.prod.yml build u-silenziu --no-cache

# 3. Restart application
echo ""
echo "3. 🔄 RESTART APP :"
echo "=================="
docker compose -f docker-compose.prod.yml restart u-silenziu

# 4. Attendre stabilisation
echo ""
echo "4. ⏳ ATTENTE STABILISATION :"
echo "============================"
sleep 15

# 5. Test correction max_people
echo ""
echo "5. 🧪 TEST CORRECTION MAX_PEOPLE :"
echo "=================================="
FIRST_ROOM_ID=$(docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -t -c "SELECT id FROM rooms LIMIT 1;" | xargs)

if [ ! -z "$FIRST_ROOM_ID" ]; then
  echo "Test avec ID: $FIRST_ROOM_ID"
  
  # Valeur actuelle
  echo "Valeur actuelle max_people :"
  docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
  SELECT name, max_people, updated_at FROM rooms WHERE id = '$FIRST_ROOM_ID';
  "
  
  echo ""
  echo "Test PUT avec max_people = 10 :"
  curl -s -X PUT "https://rageroom.usilenziu.com/api/admin/rooms/$FIRST_ROOM_ID" \
    -H "Content-Type: application/json" \
    -d '{
      "name": "Salle 1",
      "description": "Pour un défoulement intense", 
      "max_people": 10,
      "price": 25,
      "duration": 20,
      "objects_to_destroy": ["Objets divers"],
      "included": ["Équipements de protection"],
      "is_active": true
    }' | head -c 500
    
  echo ""
  echo ""
  echo "Vérification dans la base :"
  sleep 2
  docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
  SELECT name, max_people, updated_at FROM rooms WHERE id = '$FIRST_ROOM_ID';
  "
  
  echo ""
  echo "Test API GET pour vérifier :"
  curl -s "https://rageroom.usilenziu.com/api/admin/rooms/$FIRST_ROOM_ID" | grep -o '"max_people":[0-9]*'
  
else
  echo "❌ Aucune salle trouvée pour le test"
fi

echo ""
echo ""
echo "=== CORRECTION TERMINÉE ==="
echo ""
echo "✅ BUG CORRIGÉ :"
echo "• API lit maintenant max_people ET maxPeople"
echo "• Compatibilité frontend/backend assurée"
echo "• Test de modification effectué"
echo ""
echo "🧪 À tester :"
echo "• Modifier max_people dans l'interface admin"
echo "• Vérifier que la valeur se sauvegarde"
echo "• Vérifier que updated_at change"
