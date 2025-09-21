#!/bin/bash

echo "=== TEST CRÉATION RÉSERVATION ADMIN ==="
echo ""

# 1. Test de création de réservation via API admin
echo "1. 🧪 TEST CRÉATION RÉSERVATION :"
echo "=================================="
curl -X POST "https://rageroom.usilenziu.com/api/admin/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Test",
    "last_name": "Admin",
    "email": "test.admin@example.com",
    "phone": "0123456789",
    "date": "2025-09-25",
    "time": "15:00",
    "duration": 20,
    "number_of_people": 2,
    "room_name": "Salle 1",
    "status": "confirmed",
    "notes": "Test depuis admin"
  }' | jq '.' 2>/dev/null || echo "Erreur jq"

echo ""
echo "2. 🔍 VÉRIFICATION EN BASE :"
echo "============================"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  reservation_number,
  customer_name,
  customer_email,
  room_name,
  date,
  time_slot,
  participants,
  status,
  amount,
  created_at
FROM reservations 
ORDER BY created_at DESC 
LIMIT 3;
"

echo ""
echo "3. 🔍 LOGS ERREUR :"
echo "==================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=10 | grep -E "error|Error|ERROR" || echo "Aucune erreur récente"

echo ""
echo "=== TEST TERMINÉ ==="
