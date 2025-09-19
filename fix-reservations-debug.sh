#!/bin/bash
# Debug et correction API réservations

echo "=== DIAGNOSTIC API RÉSERVATIONS ==="

# 1. Logs spécifiques aux erreurs réservations
echo "1. Erreurs dans les logs..."
docker logs u-silenziu-app-prod --tail 100 | grep -A5 -B5 "reservation\|Error.*création"

echo -e "\n2. Structure table reservations..."
docker exec u-silenziu-postgres-prod psql -U usilenzio_user -d usilenzio -c "\d reservations"

echo -e "\n3. Test API réservations direct..."
docker exec u-silenziu-postgres-prod psql -U usilenzio_user -d usilenzio -c "
-- Vérifier qu'on peut insérer une réservation test
SELECT 'Test création réservation...' as status;
"

echo -e "\n4. Test insertion manuelle..."
docker exec u-silenziu-postgres-prod psql -U usilenzio_user -d usilenzio -c "
INSERT INTO reservations (
  reservation_number, first_name, last_name, email, phone, 
  room_name, date, time, duration, number_of_people, 
  status, amount, notes
) VALUES (
  'TEST001', 'Test', 'Debug', 'test@debug.com', '0123456789',
  'Salle Défoulement Standard', '2025-12-25', '14:00', 30, 2,
  'pending', 25.00, 'Test manuel'
) RETURNING id, reservation_number;
"

echo -e "\n5. Vérifier structure attendue vs réelle..."
docker exec u-silenziu-postgres-prod psql -U usilenzio_user -d usilenzio -c "
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'reservations' 
ORDER BY ordinal_position;
"

echo -e "\n6. Test API POST direct..."
curl -k -X POST https://rageroom.usilenziu.com/api/reservations \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "Debug", 
    "email": "test@debug.com",
    "phone": "0123456789",
    "date": "2025-12-25",
    "timeSlot": "14:00",
    "duration": 30,
    "numberOfPeople": 2,
    "roomName": "Salle Défoulement Standard"
  }' 2>&1 | head -c 500

echo -e "\n\n=== DIAGNOSTIC TERMINÉ ==="
