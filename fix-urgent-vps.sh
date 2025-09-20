#!/bin/bash

echo "=== CORRECTION URGENTE DES PROBLÈMES CRITIQUES ==="
echo ""

# 1. Corriger la fonction LPAD dans PostgreSQL
echo "1. Correction de la fonction LPAD :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
-- Créer une fonction LPAD personnalisée si elle n'existe pas
CREATE OR REPLACE FUNCTION lpad_string(input_text text, length integer, fill_char text DEFAULT '0')
RETURNS text AS \$\$
BEGIN
  RETURN LPAD(input_text, length, fill_char);
END;
\$\$ LANGUAGE plpgsql;
"

# 2. Mettre à jour les réservations existantes avec des numéros
echo ""
echo "2. Génération des numéros de réservation :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
UPDATE reservations 
SET reservation_number = CONCAT(
  TO_CHAR(created_at, 'YYMMDD'),
  lpad_string(ROW_NUMBER() OVER (ORDER BY created_at)::text, 3, '0')
)
WHERE reservation_number IS NULL OR reservation_number = '';
"

# 3. Vérifier les réservations mises à jour
echo ""
echo "3. Vérification des réservations mises à jour :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, reservation_number, customer_name, customer_email, room_name, date, time_slot, amount, status 
FROM reservations 
ORDER BY created_at DESC;
"

# 4. Corriger la configuration de la page d'accueil
echo ""
echo "4. Correction de la configuration de la page d'accueil :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
UPDATE homepage_config 
SET site_description = 'Votre zone de défoulement à Buros. Libérez votre stress et vos tensions dans un environnement sécurisé et fun.'
WHERE site_description IS NULL OR site_description = '';
"

# 5. Redémarrer l'application
echo ""
echo "5. Redémarrage de l'application :"
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml restart u-silenziu

echo ""
echo "6. Attendre que l'application redémarre..."
sleep 15

# 7. Vérifier l'état des conteneurs
echo ""
echo "7. Vérification de l'état des conteneurs :"
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml ps

# 8. Tester l'API admin des réservations
echo ""
echo "8. Test de l'API admin des réservations :"
echo "----------------------------------------"
curl -s "https://rageroom.usilenziu.com/api/admin/reservations" | head -c 500

echo ""
echo "9. Tester l'API de disponibilité :"
echo "----------------------------------------"
curl -s "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-20&endDate=2025-09-21&roomName=Salle%202" | head -c 500

echo ""
echo "10. Vérifier les logs de l'application :"
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=10

echo ""
echo "=== CORRECTION URGENTE TERMINÉE ==="
echo "Les problèmes critiques devraient maintenant être résolus !"
