#!/bin/bash

echo "=== TEST API ROOM DIRECT ==="
echo ""

ROOM_ID="0b9dfff4-421a-468e-ad29-96ed6445b84f"

# 1. Test GET pour vérifier que l'endpoint fonctionne
echo "1. 🧪 TEST GET ROOM :"
echo "===================="
echo "GET /api/admin/rooms/$ROOM_ID"
curl -s "https://rageroom.usilenziu.com/api/admin/rooms/$ROOM_ID" | head -c 300

# 2. Vérifier tous les endpoints rooms disponibles
echo ""
echo ""
echo "2. 🔍 VÉRIFICATION ENDPOINTS :"
echo "==============================="

# Test d'endpoints possibles
echo "Test PATCH (toggle status) :"
curl -s -X PATCH "https://rageroom.usilenziu.com/api/admin/rooms/$ROOM_ID" \
  -H "Content-Type: application/json" \
  -d '{"action": "toggle"}' | head -c 200

echo ""
echo ""
echo "Test PUT simple avec un seul champ :"
curl -s -X PUT "https://rageroom.usilenziu.com/api/admin/rooms/$ROOM_ID" \
  -H "Content-Type: application/json" \
  -d '{"max_people": 15}' | head -c 300

# 3. Vérifier les logs après ce test
echo ""
echo ""
echo "3. 🔍 LOGS APRÈS TEST PUT :"
echo "==========================="
sleep 2
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=20 | grep -i "put\|🔧\|room\|error"

# 4. Vérifier dans la base
echo ""
echo "4. 🔍 ÉTAT EN BASE :"
echo "==================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT name, max_people, updated_at FROM rooms WHERE id = '$ROOM_ID';
"

# 5. Test avec tous les champs requis
echo ""
echo "5. 🧪 TEST PUT COMPLET :"
echo "========================"
curl -s -X PUT "https://rageroom.usilenziu.com/api/admin/rooms/$ROOM_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test API Direct",
    "description": "Test description",
    "price": 30,
    "duration": 25,
    "max_people": 20,
    "objects_to_destroy": ["test"],
    "included": ["protection"],
    "image_url": "/test.jpg",
    "is_active": true
  }' | head -c 300

echo ""
echo ""
echo "6. 🔍 LOGS FINAUX :"
echo "=================="
sleep 2
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=30 | grep -A5 -B5 "🔧"

echo ""
echo "7. 🔍 ÉTAT FINAL :"
echo "================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT name, max_people, updated_at FROM rooms WHERE id = '$ROOM_ID';
"

echo ""
echo "=== ANALYSE ==="
echo "Si aucun log '🔧' n'apparaît, l'API PUT /api/admin/rooms/[id] n'est pas appelée"
echo "Vérifier si l'interface admin utilise un autre endpoint"
