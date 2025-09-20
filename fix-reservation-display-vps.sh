#!/bin/bash

echo "=== CORRECTION AFFICHAGE NUMÉRO DE RÉSERVATION ==="
echo ""

# 1. Récupérer les dernières modifications
echo "1. Récupération des modifications..."
git pull origin main

echo ""
echo "2. Redémarrage de l'application avec les corrections..."
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml build --no-cache u-silenziu
docker compose -f docker-compose.prod.yml up -d

echo ""
echo "3. Attendre que l'application démarre..."
sleep 15

echo ""
echo "4. Vérifier l'état des conteneurs :"
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml ps

echo ""
echo "5. Tester l'API de réservation :"
echo "----------------------------------------"
curl -X POST https://rageroom.usilenziu.com/api/reservations \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "Display",
    "email": "test.display@example.com",
    "phone": "0123456789",
    "roomName": "Salle 1",
    "date": "2025-09-21",
    "timeSlot": "16:00 - 17:00",
    "duration": 60,
    "numberOfPeople": 1,
    "specialRequests": "Test affichage numéro"
  }' -v

echo ""
echo "6. Vérifier les réservations créées :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, reservation_number, customer_name, customer_email, room_name, date, time_slot, amount, status 
FROM reservations 
ORDER BY created_at DESC 
LIMIT 3;
"

echo ""
echo "7. Vérifier les logs de l'application :"
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=20

echo ""
echo "=== CORRECTION TERMINÉE ==="
echo "Le numéro de réservation devrait maintenant s'afficher correctement !"
echo "Testez en créant une nouvelle réservation sur le site."
