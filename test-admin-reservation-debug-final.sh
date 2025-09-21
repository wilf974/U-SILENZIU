#!/bin/bash

echo "=== TEST ADMIN RESERVATION DEBUG FINAL ==="
echo ""

# 1. Redémarrer l'application pour activer les nouveaux logs
echo "1. 🔄 REDÉMARRAGE APPLICATION :"
echo "==============================="
docker compose -f docker-compose.prod.yml restart u-silenziu
sleep 5

# 2. Test avec logs détaillés
echo ""
echo "2. 🧪 TEST AVEC LOGS DÉTAILLÉS :"
echo "==============================="

# Lancer les logs en arrière-plan
docker compose -f docker-compose.prod.yml logs -f u-silenziu | grep -E "🔧|error|Error|ERROR" &
LOGS_PID=$!

sleep 2

# Faire la requête
echo "Envoi de la requête POST..."
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
    "notes": "Test debug final"
  }' | jq '.' 2>/dev/null || echo "Erreur jq"

sleep 5

# Arrêter les logs
kill $LOGS_PID 2>/dev/null

echo ""
echo "=== TEST TERMINÉ ==="
