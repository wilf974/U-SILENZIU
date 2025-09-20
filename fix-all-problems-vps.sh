#!/bin/bash

echo "=== CORRECTION COMPLÈTE DE TOUS LES PROBLÈMES ==="
echo ""

# 1. Récupérer les dernières modifications
echo "1. Récupération des modifications..."
git pull origin main

# 2. Diagnostic complet de la base de données
echo ""
echo "2. DIAGNOSTIC COMPLET DE LA BASE DE DONNÉES :"
echo "----------------------------------------"

echo "2.1. Structure de la table rooms :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\d rooms;"

echo ""
echo "2.2. Données des salles :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, name, price, max_people, duration, is_active, objects_to_destroy, included
FROM rooms 
ORDER BY name;
"

echo ""
echo "2.3. Structure de la table reservations :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\d reservations;"

echo ""
echo "2.4. Données des réservations :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, reservation_number, customer_name, customer_email, room_name, date, time_slot, duration, participants, amount, status, created_at
FROM reservations 
ORDER BY created_at DESC;
"

# 3. Créer la fonction LPAD personnalisée si elle n'existe pas
echo ""
echo "3. Création/Vérification de la fonction LPAD personnalisée..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
CREATE OR REPLACE FUNCTION lpad_string(input_text text, length integer, fill_char text DEFAULT '0')
RETURNS text AS \$\$
BEGIN
  RETURN LPAD(input_text, length, fill_char);
END;
\$\$ LANGUAGE plpgsql;
"

# 4. Mettre à jour TOUTES les réservations existantes avec des numéros
echo ""
echo "4. Génération des numéros pour toutes les réservations..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
UPDATE reservations 
SET reservation_number = CONCAT(
  TO_CHAR(created_at, 'YYMMDD'),
  lpad_string(ROW_NUMBER() OVER (ORDER BY created_at)::text, 3, '0')
)
WHERE reservation_number IS NULL OR reservation_number = '';
"

# 5. Vérifier les réservations mises à jour
echo ""
echo "5. Vérification des réservations mises à jour..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, reservation_number, customer_name, customer_email, room_name, date, time_slot, duration, participants, amount, status
FROM reservations 
ORDER BY created_at DESC;
"

# 6. Tester la génération d'un nouveau numéro
echo ""
echo "6. Test de génération d'un nouveau numéro..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  CONCAT(
    TO_CHAR(CURRENT_DATE, 'YYMMDD'),
    lpad_string((COALESCE(COUNT(*), 0) + 1)::text, 3, '0')
  ) as next_reservation_number
FROM reservations 
WHERE DATE(created_at) = CURRENT_DATE;
"

# 7. Test de mise à jour d'une salle (Max personnes)
echo ""
echo "7. Test de mise à jour de la Salle 1 (max_people = 8)..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
UPDATE rooms 
SET max_people = 8, updated_at = CURRENT_TIMESTAMP
WHERE name = 'Salle 1';
"

echo ""
echo "8. Vérification de la mise à jour des salles..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, name, price, max_people, duration, is_active, updated_at
FROM rooms 
ORDER BY name;
"

# 9. Redémarrer l'application complètement
echo ""
echo "9. Redémarrage complet de l'application..."
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml build --no-cache u-silenziu
docker compose -f docker-compose.prod.yml up -d

# 10. Attendre que l'application redémarre
echo ""
echo "10. Attente du redémarrage complet..."
sleep 30

# 11. Vérifier l'état des conteneurs
echo ""
echo "11. Vérification de l'état des conteneurs..."
docker compose -f docker-compose.prod.yml ps

# 12. Test des APIs
echo ""
echo "12. Test de l'API admin des réservations..."
curl -s "https://rageroom.usilenziu.com/api/admin/reservations" | head -c 1000

echo ""
echo "13. Test de l'API admin des salles..."
curl -s "https://rageroom.usilenziu.com/api/admin/rooms" | head -c 1000

echo ""
echo "14. Test de mise à jour d'une salle via API..."
ROOM_ID=\$(docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -t -c "SELECT id FROM rooms WHERE name = 'Salle 1' LIMIT 1;" | tr -d ' ')
echo "ID de la Salle 1: \$ROOM_ID"

curl -s -X PUT "https://rageroom.usilenziu.com/api/admin/rooms/\$ROOM_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "maxPeople": 10
  }' | head -c 500

echo ""
echo "15. Test de création d'une réservation..."
curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "Complet",
    "email": "test.complet@example.com",
    "phone": "0123456789",
    "roomName": "Salle 1",
    "date": "2025-09-23",
    "timeSlot": "14:00 - 14:20",
    "duration": 20,
    "numberOfPeople": 1
  }' | head -c 1000

# 16. Vérification finale
echo ""
echo "16. Vérification finale des données..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 'SALLES:' as type, name as info, max_people::text as value FROM rooms
UNION ALL
SELECT 'RESERVATIONS:', customer_name, reservation_number FROM reservations
ORDER BY type, info;
"

echo ""
echo "17. Vérification des logs de l'application..."
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=30

echo ""
echo "=== CORRECTION COMPLÈTE TERMINÉE ==="
echo "Vérifiez maintenant :"
echo "- ✅ Modification des salles (max personnes)"
echo "- ✅ Numéros de réservation côté site"
echo "- ✅ Noms et numéros dans l'admin"
echo "- ✅ Créneaux grisés dans le calendrier"
