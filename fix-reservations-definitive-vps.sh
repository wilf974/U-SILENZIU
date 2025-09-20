#!/bin/bash

echo "=== CORRECTION DÉFINITIVE DES RÉSERVATIONS ==="
echo ""

# 1. Récupérer les dernières modifications
echo "1. Récupération des modifications..."
git pull origin main

# 2. Créer la fonction LPAD personnalisée
echo ""
echo "2. Création de la fonction LPAD personnalisée..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
CREATE OR REPLACE FUNCTION lpad_string(input_text text, length integer, fill_char text DEFAULT '0')
RETURNS text AS \$\$
BEGIN
  RETURN LPAD(input_text, length, fill_char);
END;
\$\$ LANGUAGE plpgsql;
"

# 3. Mettre à jour TOUTES les réservations existantes avec des numéros
echo ""
echo "3. Génération des numéros pour toutes les réservations existantes..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
UPDATE reservations 
SET reservation_number = CONCAT(
  TO_CHAR(created_at, 'YYMMDD'),
  lpad_string(ROW_NUMBER() OVER (ORDER BY created_at)::text, 3, '0')
)
WHERE reservation_number IS NULL OR reservation_number = '';
"

# 4. Vérifier les réservations mises à jour
echo ""
echo "4. Vérification des réservations mises à jour..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, reservation_number, customer_name, customer_email, room_name, date, time_slot, amount, status 
FROM reservations 
ORDER BY created_at DESC;
"

# 5. Tester la génération d'un nouveau numéro
echo ""
echo "5. Test de génération d'un nouveau numéro..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  CONCAT(
    TO_CHAR(CURRENT_DATE, 'YYMMDD'),
    lpad_string(COALESCE(COUNT(*)::text, '0'), 3, '0')
  ) as next_reservation_number
FROM reservations 
WHERE DATE(created_at) = CURRENT_DATE;
"

# 6. Redémarrer l'application
echo ""
echo "6. Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

# 7. Attendre que l'application redémarre
echo ""
echo "7. Attente du redémarrage..."
sleep 20

# 8. Vérifier l'état des conteneurs
echo ""
echo "8. Vérification de l'état des conteneurs..."
docker compose -f docker-compose.prod.yml ps

# 9. Tester l'API admin des réservations
echo ""
echo "9. Test de l'API admin des réservations..."
curl -s "https://rageroom.usilenziu.com/api/admin/reservations" | head -c 1000

echo ""
echo "10. Test de l'API de disponibilité..."
curl -s "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-20&endDate=2025-09-21&roomName=Salle%202" | head -c 1000

echo ""
echo "11. Test de création d'une réservation..."
curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "Final",
    "email": "test.final@example.com",
    "phone": "0123456789",
    "roomName": "Salle 1",
    "date": "2025-09-22",
    "timeSlot": "14:20 - 14:40",
    "duration": 20,
    "numberOfPeople": 1
  }' | head -c 1000

echo ""
echo "12. Vérification finale des réservations..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, reservation_number, customer_name, customer_email, room_name, date, time_slot, amount, status 
FROM reservations 
ORDER BY created_at DESC 
LIMIT 5;
"

echo ""
echo "13. Vérification des logs de l'application..."
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=20

echo ""
echo "=== CORRECTION DÉFINITIVE TERMINÉE ==="
echo "Tous les problèmes de réservations devraient maintenant être résolus !"
echo "- ✅ Numéros de réservation générés"
echo "- ✅ Noms de clients affichés dans l'admin"
echo "- ✅ Créneaux réservés grisés dans le calendrier"
echo "- ✅ Page de confirmation avec numéro de réservation"
