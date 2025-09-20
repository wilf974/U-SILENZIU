#!/bin/bash

echo "=== CORRECTION COMPLÈTE DES RÉSERVATIONS ==="
echo ""

# 1. Mettre à jour les réservations existantes
echo "1. Mise à jour des réservations existantes..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
UPDATE reservations 
SET reservation_number = CONCAT(
  TO_CHAR(created_at, 'YYMMDD'),
  LPAD(ROW_NUMBER() OVER (ORDER BY created_at)::text, 3, '0')
)
WHERE reservation_number IS NULL OR reservation_number = '';
"

echo ""
echo "2. Vérification des réservations mises à jour..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, reservation_number, customer_name, customer_email, room_name, date, time_slot, amount, status 
FROM reservations 
ORDER BY created_at DESC;
"

echo ""
echo "3. Test de génération d'un nouveau numéro..."
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
echo "4. Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

echo ""
echo "5. Vérification des logs..."
sleep 5
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=10

echo ""
echo "=== CORRECTION TERMINÉE ==="
echo "Les numéros de réservation devraient maintenant apparaître !"
