#!/bin/bash

echo "=== CORRECTION FINALE DES RÉSERVATIONS ==="
echo ""

# 1. Vérifier l'état actuel
echo "1. État actuel des réservations :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT COUNT(*) as total_reservations FROM reservations;
"

echo ""
echo "2. Tester la génération de numéro (nouvelle méthode) :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  CONCAT(
    TO_CHAR(CURRENT_DATE, 'YYMMDD'),
    LPAD(COALESCE(COUNT(*)::integer, 0) + 1, 3, '0')
  ) as next_reservation_number
FROM reservations 
WHERE DATE(created_at) = CURRENT_DATE;
"

echo ""
echo "3. Redémarrage de l'application avec le nouveau code :"
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml build --no-cache u-silenziu
docker compose -f docker-compose.prod.yml up -d

echo ""
echo "4. Attendre que l'application démarre..."
sleep 10

echo ""
echo "5. Vérifier l'état des conteneurs :"
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml ps

echo ""
echo "6. Tester l'API de réservation :"
echo "----------------------------------------"
curl -X POST https://rageroom.usilenziu.com/api/reservations \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "Final",
    "email": "test.final@example.com",
    "phone": "0123456789",
    "roomName": "Salle 1",
    "date": "2025-09-21",
    "timeSlot": "15:00 - 16:00",
    "duration": 60,
    "numberOfPeople": 1,
    "specialRequests": "Test final"
  }' -v

echo ""
echo "7. Vérifier les réservations créées :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, reservation_number, customer_name, customer_email, room_name, date, time_slot, amount, status 
FROM reservations 
ORDER BY created_at DESC;
"

echo ""
echo "8. Vérifier les logs de l'application :"
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=20

echo ""
echo "=== CORRECTION TERMINÉE ==="
echo "Les numéros de réservation devraient maintenant fonctionner !"
