#!/bin/bash

echo "=== DIAGNOSTIC FINAL API ADMIN ==="
echo ""

# 1. Test avec réponse complète et logs d'erreur
echo "1. 🧪 TEST POST AVEC LOGS ERREUR :"
echo "==================================="

# Lancer les logs d'erreur en arrière-plan
docker compose -f docker-compose.prod.yml logs -f u-silenziu | grep -E "error|Error|ERROR|reservation|Reservation" &
LOGS_PID=$!

sleep 2

# Faire la requête avec réponse complète
echo "Envoi de la requête POST..."
curl -v -X POST "https://rageroom.usilenziu.com/api/admin/reservations" \
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
  }' 2>&1

sleep 5

# Arrêter les logs
kill $LOGS_PID 2>/dev/null

echo ""
echo ""

# 2. Vérifier les logs de compilation
echo "2. 🔍 LOGS COMPILATION :"
echo "========================"
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=50 | grep -E "error|Error|ERROR|compilation|build" || echo "Aucun log de compilation"

echo ""
echo ""

# 3. Test de l'API publique pour comparaison
echo "3. 🧪 TEST API PUBLIQUE (COMPARAISON) :"
echo "======================================="
curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "Public",
    "email": "test.public@example.com",
    "phone": "0123456789",
    "date": "2025-09-25",
    "timeSlot": "15:00",
    "duration": 20,
    "numberOfPeople": 2,
    "roomName": "Salle 1",
    "specialRequests": "Test public"
  }' | jq '.success' 2>/dev/null || echo "Erreur API publique"

echo ""
echo "=== DIAGNOSTIC TERMINÉ ==="
