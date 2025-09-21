#!/bin/bash

echo "=== TEST CRÉATION RÉSERVATION ADMIN AVEC DEBUG ==="
echo ""

# 1. Test de création avec logs en temps réel
echo "1. 🧪 TEST AVEC LOGS DEBUG :"
echo "============================="

# Lancer les logs en arrière-plan
docker compose -f docker-compose.prod.yml logs -f u-silenziu | grep "🔧" &
LOGS_PID=$!

sleep 2

# Faire la requête
echo "Envoi de la requête..."
curl -s -X POST "https://rageroom.usilenziu.com/api/admin/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Test",
    "last_name": "Debug",
    "email": "test.debug@example.com",
    "phone": "0123456789",
    "date": "2025-09-25",
    "time": "15:00",
    "duration": 20,
    "number_of_people": 2,
    "room_name": "Salle 1",
    "status": "confirmed",
    "notes": "Test debug"
  }' | jq '.' 2>/dev/null || echo "Erreur jq"

sleep 3

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
echo "=== TEST TERMINÉ ==="
