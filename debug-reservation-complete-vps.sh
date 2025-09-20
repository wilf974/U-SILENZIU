#!/bin/bash

echo "=== DIAGNOSTIC COMPLET DES RÉSERVATIONS VPS ==="
echo ""

# 1. Vérifier l'état des conteneurs
echo "1. État des conteneurs Docker :"
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml ps

echo ""
echo "2. Vérifier la structure de la table reservations :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\d reservations;"

echo ""
echo "3. Vérifier les données de réservation existantes :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, reservation_number, customer_name, customer_email, room_name, date, time_slot, amount, status, created_at 
FROM reservations 
ORDER BY created_at DESC;
"

echo ""
echo "4. Tester la génération d'un numéro de réservation (nouvelle méthode) :"
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
echo "5. Vérifier les logs de l'application (dernières 50 lignes) :"
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=50

echo ""
echo "6. Tester l'API de réservation :"
echo "----------------------------------------"
curl -X POST https://rageroom.usilenziu.com/api/reservations \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "User",
    "email": "test@example.com",
    "phone": "0123456789",
    "roomName": "Salle 1",
    "date": "2025-09-21",
    "timeSlot": "14:00 - 15:00",
    "duration": 60,
    "numberOfPeople": 2,
    "specialRequests": "Test de diagnostic"
  }' -v

echo ""
echo "7. Vérifier la réponse de l'API admin :"
echo "----------------------------------------"
curl -v https://rageroom.usilenziu.com/api/admin/reservations

echo ""
echo "8. Vérifier la configuration SMTP :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, host, port, username, from_email, from_name, secure, tls_reject_unauthorized, tls_min_version 
FROM smtp_config 
WHERE is_active = true;
"

echo ""
echo "9. Vérifier les erreurs dans les logs PostgreSQL :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT * FROM pg_stat_activity WHERE state = 'active';
"

echo ""
echo "10. Test de connexion à la base de données :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  current_database() as database,
  current_user as user,
  version() as postgres_version,
  now() as current_time;
"

echo ""
echo "=== DIAGNOSTIC TERMINÉ ==="
echo "Vérifiez les erreurs ci-dessus pour identifier le problème."
