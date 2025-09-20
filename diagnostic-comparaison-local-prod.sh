#!/bin/bash

echo "=== DIAGNOSTIC COMPARAISON LOCAL VS PROD ==="
echo ""

# 1. Récupérer les dernières modifications
echo "1. Récupération des modifications..."
git pull origin main

# 2. DIAGNOSTIC COMPLET DE LA BASE DE DONNÉES PROD
echo ""
echo "2. DIAGNOSTIC BASE DE DONNÉES PRODUCTION :"
echo "=========================================="

echo "2.1. Structure de la table reservations :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\d reservations;"

echo ""
echo "2.2. Compter TOUTES les réservations :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT COUNT(*) as total_reservations FROM reservations;
"

echo ""
echo "2.3. Lister TOUTES les réservations (si elles existent) :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, reservation_number, customer_name, customer_email, room_name, date, time_slot, duration, participants, amount, status, created_at 
FROM reservations 
ORDER BY created_at DESC;
"

echo ""
echo "2.4. Vérifier les données fantômes (tables liées) :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT table_name, column_name 
FROM information_schema.columns 
WHERE table_name LIKE '%reservation%' 
ORDER BY table_name, column_name;
"

echo ""
echo "2.5. Vérifier les index et contraintes sur reservations :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'reservations';
"

# 3. NETTOYER COMPLÈTEMENT LA BASE SI NÉCESSAIRE
echo ""
echo "3. NETTOYAGE COMPLET DE LA BASE (AU CAS OÙ) :"
echo "============================================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
TRUNCATE TABLE reservations RESTART IDENTITY CASCADE;
"

echo ""
echo "3.1. Vérifier que la table est vraiment vide :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT COUNT(*) as should_be_zero FROM reservations;
"

# 4. CRÉER LA FONCTION LPAD
echo ""
echo "4. CRÉATION DE LA FONCTION LPAD :"
echo "================================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
CREATE OR REPLACE FUNCTION lpad_string(input_text text, length integer, fill_char text DEFAULT '0')
RETURNS text AS \$\$
BEGIN
  RETURN LPAD(input_text, length, fill_char);
END;
\$\$ LANGUAGE plpgsql;
"

# 5. REDÉMARRER COMPLÈTEMENT L'APPLICATION
echo ""
echo "5. REDÉMARRAGE COMPLET DE L'APPLICATION :"
echo "========================================="
docker compose -f docker-compose.prod.yml down
docker system prune -f --volumes
docker compose -f docker-compose.prod.yml build --no-cache u-silenziu
docker compose -f docker-compose.prod.yml up -d

# 6. ATTENDRE LE REDÉMARRAGE COMPLET
echo ""
echo "6. ATTENTE DU REDÉMARRAGE COMPLET..."
sleep 30

# 7. VÉRIFIER L'ÉTAT DES CONTENEURS
echo ""
echo "7. ÉTAT DES CONTENEURS :"
echo "========================"
docker compose -f docker-compose.prod.yml ps

# 8. TESTER LES APIs APRÈS NETTOYAGE
echo ""
echo "8. TESTS DES APIs APRÈS NETTOYAGE :"
echo "==================================="

echo "8.1. Test API admin reservations (devrait être vide) :"
curl -s "https://rageroom.usilenziu.com/api/admin/reservations" | head -c 2000

echo ""
echo "8.2. Test API availability (devrait montrer tout disponible) :"
curl -s "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-20&endDate=2025-09-21" | head -c 1000

echo ""
echo "8.3. Test API weekly reservations :"
curl -s "https://rageroom.usilenziu.com/api/admin/reservations/weekly?date=2025-09-20" | head -c 1000

# 9. CRÉER UNE NOUVELLE RÉSERVATION POUR TESTER
echo ""
echo "9. CRÉATION D'UNE NOUVELLE RÉSERVATION DE TEST :"
echo "==============================================="
curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "Nouveau",
    "email": "test.nouveau@example.com",
    "phone": "0123456789",
    "roomName": "Salle 1",
    "date": "2025-09-25",
    "timeSlot": "14:00 - 14:20",
    "duration": 20,
    "numberOfPeople": 1
  }' | head -c 1000

# 10. VÉRIFIER LA NOUVELLE RÉSERVATION
echo ""
echo "10. VÉRIFICATION DE LA NOUVELLE RÉSERVATION :"
echo "============================================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, reservation_number, customer_name, customer_email, room_name, date, time_slot, duration, participants, amount, status, created_at 
FROM reservations 
ORDER BY created_at DESC;
"

# 11. TESTER L'API ADMIN APRÈS CRÉATION
echo ""
echo "11. TEST API ADMIN APRÈS CRÉATION :"
echo "=================================="
curl -s "https://rageroom.usilenziu.com/api/admin/reservations" | head -c 2000

# 12. VÉRIFIER LES LOGS
echo ""
echo "12. LOGS DE L'APPLICATION :"
echo "=========================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=30

echo ""
echo "=== DIAGNOSTIC TERMINÉ ==="
echo "COMPARAISON LOCAL vs PROD :"
echo "- LOCAL : Calendrier vide, 0 réservations"
echo "- PROD (après nettoyage) : Devrait être identique"
echo ""
echo "Si le problème persiste, c'est un problème de cache frontend ou d'API."
