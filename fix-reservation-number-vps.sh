#!/bin/bash

echo "=== CORRECTION NUMÉRO DE RÉSERVATION ==="
echo ""

# 1. Appliquer la migration SQL
echo "1. Ajout de la colonne reservation_number..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
ALTER TABLE reservations 
ADD COLUMN IF NOT EXISTS reservation_number VARCHAR(20) UNIQUE;

CREATE INDEX IF NOT EXISTS idx_reservations_reservation_number ON reservations(reservation_number);

UPDATE reservations 
SET reservation_number = 'RES' || LPAD(EXTRACT(EPOCH FROM created_at)::text, 10, '0')
WHERE reservation_number IS NULL;
"

echo ""
echo "2. Vérification de la structure de la table..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\d reservations;"

echo ""
echo "3. Vérification des données de réservation..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "SELECT id, reservation_number, customer_name, customer_email, room_name, date, time_slot, amount, status FROM reservations ORDER BY created_at DESC LIMIT 5;"

echo ""
echo "4. Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

echo ""
echo "5. Vérification des logs..."
sleep 5
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=10

echo ""
echo "=== CORRECTION TERMINÉE ==="
echo "Les numéros de réservation devraient maintenant apparaître dans l'interface admin."
