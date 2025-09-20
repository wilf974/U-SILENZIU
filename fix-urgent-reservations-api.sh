#!/bin/bash

echo "=== CORRECTION URGENTE API RÉSERVATIONS ==="
echo ""

# 1. Récupérer les dernières modifications
echo "1. Récupération des modifications..."
git pull origin main

# 2. Diagnostic de la structure de la base
echo ""
echo "2. DIAGNOSTIC STRUCTURE BASE DE DONNÉES :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\d reservations;"

# 3. Vérifier les données existantes
echo ""
echo "3. Données existantes dans les réservations :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, reservation_number, customer_name, customer_email, customer_phone, room_name, date, time_slot, duration, participants, amount, status 
FROM reservations 
ORDER BY created_at DESC 
LIMIT 5;
"

# 4. Tester la requête qui pose problème
echo ""
echo "4. Test de la requête SELECT * FROM reservations :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT * FROM reservations LIMIT 1;
"

# 5. Créer la fonction LPAD si elle n'existe pas
echo ""
echo "5. Création de la fonction LPAD..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
CREATE OR REPLACE FUNCTION lpad_string(input_text text, length integer, fill_char text DEFAULT '0')
RETURNS text AS \$\$
BEGIN
  RETURN LPAD(input_text, length, fill_char);
END;
\$\$ LANGUAGE plpgsql;
"

# 6. Mettre à jour toutes les réservations avec des numéros
echo ""
echo "6. Génération des numéros de réservation..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
UPDATE reservations 
SET reservation_number = CONCAT(
  TO_CHAR(created_at, 'YYMMDD'),
  lpad_string(ROW_NUMBER() OVER (ORDER BY created_at)::text, 3, '0')
)
WHERE reservation_number IS NULL OR reservation_number = '';
"

# 7. Vérifier la mise à jour
echo ""
echo "7. Vérification des numéros générés :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, reservation_number, customer_name, customer_email, room_name, date, time_slot, amount, status 
FROM reservations 
ORDER BY created_at DESC;
"

# 8. Redémarrer l'application
echo ""
echo "8. Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

# 9. Attendre le redémarrage
echo ""
echo "9. Attente du redémarrage..."
sleep 20

# 10. Vérifier l'état des conteneurs
echo ""
echo "10. État des conteneurs :"
docker compose -f docker-compose.prod.yml ps

# 11. Tester l'API admin des réservations
echo ""
echo "11. Test de l'API admin des réservations :"
curl -s "https://rageroom.usilenziu.com/api/admin/reservations" | head -c 2000

echo ""
echo "12. Test de l'API publique des réservations :"
curl -s "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-20&endDate=2025-09-21" | head -c 1000

# 13. Vérifier les logs d'erreur
echo ""
echo "13. Logs de l'application (erreurs) :"
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=30 | grep -i "error\|erreur"

# 14. Test de création d'une nouvelle réservation
echo ""
echo "14. Test de création d'une nouvelle réservation :"
curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "Urgent",
    "email": "test.urgent@example.com",
    "phone": "0123456789",
    "roomName": "Salle 1",
    "date": "2025-09-24",
    "timeSlot": "14:00 - 14:20",
    "duration": 20,
    "numberOfPeople": 1
  }' | head -c 1000

# 15. Vérification finale
echo ""
echo "15. Vérification finale des données :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT COUNT(*) as total_reservations, 
       COUNT(reservation_number) as reservations_with_number
FROM reservations;
"

echo ""
echo "=== CORRECTION URGENTE TERMINÉE ==="
echo "Vérifiez maintenant l'interface admin des réservations !"
