#!/bin/bash

echo "=== DIAGNOSTIC NUMÉRO DE RÉSERVATION ==="
echo ""

# 1. Vérifier la structure de la table reservations
echo "1. Structure de la table reservations :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\d reservations;"

echo ""
echo "2. Vérifier les données de réservation existantes :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "SELECT id, reservation_number, customer_name, customer_email, room_name, date, time_slot, amount, status FROM reservations ORDER BY created_at DESC LIMIT 5;"

echo ""
echo "3. Tester la génération d'un numéro de réservation :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  CONCAT(
    TO_CHAR(CURRENT_DATE, 'YYMMDD'),
    LPAD(COALESCE(COUNT(*), 0) + 1, 3, '0')
  ) as next_reservation_number
FROM reservations 
WHERE DATE(created_at) = CURRENT_DATE;
"

echo ""
echo "4. Vérifier les logs de l'application :"
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=20 | grep -i "reservation\|error\|erreur"

echo ""
echo "5. Tester l'API de réservation :"
echo "----------------------------------------"
curl -X POST https://rageroom.usilenziu.com/api/reservations \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "User",
    "email": "test@example.com",
    "phone": "0123456789",
    "date": "2025-09-27",
    "timeSlot": "16:00",
    "duration": 20,
    "numberOfPeople": 2,
    "roomName": "Salle 2"
  }' -v

echo ""
echo "=== DIAGNOSTIC TERMINÉ ==="
