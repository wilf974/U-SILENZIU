#!/bin/bash

echo "=== TEST API ADMIN RÉSERVATIONS DIRECT ==="
echo ""

# 1. Test GET d'abord
echo "1. 🧪 TEST GET API ADMIN :"
echo "=========================="
curl -s "https://rageroom.usilenziu.com/api/admin/reservations" | jq '.success' 2>/dev/null || echo "Erreur GET"

echo ""
echo ""

# 2. Test POST avec réponse complète
echo "2. 🧪 TEST POST API ADMIN :"
echo "==========================="
curl -s -X POST "https://rageroom.usilenziu.com/api/admin/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Test",
    "last_name": "Direct",
    "email": "test.direct@example.com",
    "phone": "0123456789",
    "date": "2025-09-25",
    "time": "15:00",
    "duration": 20,
    "number_of_people": 2,
    "room_name": "Salle 1",
    "status": "confirmed",
    "notes": "Test direct"
  }'

echo ""
echo ""

# 3. Test avec logs en temps réel
echo "3. 🔍 LOGS EN TEMPS RÉEL :"
echo "=========================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=5 | grep -E "reservation|Reservation|error|Error|ERROR" || echo "Aucun log récent"

echo ""
echo "=== TEST TERMINÉ ==="
