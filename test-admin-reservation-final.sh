#!/bin/bash

echo "=== TEST FINAL API ADMIN RÉSERVATIONS ==="
echo ""

# 1. Test avec logs de debug en temps réel
echo "1. 🧪 TEST AVEC LOGS DEBUG COMPLETS :"
echo "====================================="

# Lancer les logs en arrière-plan
docker compose -f docker-compose.prod.yml logs -f u-silenziu | grep "🔧" &
LOGS_PID=$!

sleep 2

# Faire la requête
echo "Envoi de la requête POST..."
curl -s -X POST "https://rageroom.usilenziu.com/api/admin/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Test",
    "last_name": "Final",
    "email": "test.final@example.com",
    "phone": "0123456789",
    "date": "2025-09-25",
    "time": "15:00",
    "duration": 20,
    "number_of_people": 2,
    "room_name": "Salle 1",
    "status": "confirmed",
    "notes": "Test final debug"
  }' | jq '.' 2>/dev/null || echo "Erreur jq"

sleep 5

# Arrêter les logs
kill $LOGS_PID 2>/dev/null

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
echo "3. 🔍 LOGS ERREUR RÉCENTS :"
echo "==========================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=10 | grep -E "error|Error|ERROR|reservation|Reservation" || echo "Aucun log récent"

echo ""
echo "=== TEST TERMINÉ ==="
