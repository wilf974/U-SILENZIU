#!/bin/bash

echo "=== DIAGNOSTIC COMPLET DU SITE ET ADMIN ==="
echo ""

# 1. État des conteneurs
echo "1. ÉTAT DES CONTENEURS :"
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml ps

echo ""
echo "2. VÉRIFICATION DE LA BASE DE DONNÉES :"
echo "----------------------------------------"
echo "2.1. Structure de la table reservations :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\d reservations;"

echo ""
echo "2.2. Réservations existantes :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, reservation_number, customer_name, customer_email, room_name, date, time_slot, duration, participants, status, created_at 
FROM reservations 
ORDER BY created_at DESC;
"

echo ""
echo "2.3. Vérifier les salles :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, name, price, max_people, duration, is_active 
FROM rooms 
ORDER BY name;
"

echo ""
echo "2.4. Vérifier la configuration SMTP :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, host, port, username, from_email, from_name, secure, is_active 
FROM smtp_config;
"

echo ""
echo "2.5. Vérifier la configuration de la page d'accueil :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, site_title, site_description, site_name, contact_email, contact_phone, is_active 
FROM homepage_config 
WHERE is_active = true;
"

echo ""
echo "2.6. Vérifier la configuration de l'en-tête :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, site_name, logo_type, logo_text, logo_image_url 
FROM header_config;
"

echo ""
echo "3. TEST DES APIs PUBLIQUES :"
echo "----------------------------------------"
echo "3.1. Test de l'API de disponibilité :"
curl -s "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-20&endDate=2025-09-21&roomName=Salle%202" | jq '.' 2>/dev/null || echo "Erreur JSON ou jq non installé"

echo ""
echo "3.2. Test de l'API des salles :"
curl -s "https://rageroom.usilenziu.com/api/rooms" | jq '.' 2>/dev/null || echo "Erreur JSON ou jq non installé"

echo ""
echo "3.3. Test de l'API de configuration de la page d'accueil :"
curl -s "https://rageroom.usilenziu.com/api/homepage-config" | jq '.' 2>/dev/null || echo "Erreur JSON ou jq non installé"

echo ""
echo "3.4. Test de création d'une réservation :"
curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "Diagnostic",
    "email": "test.diagnostic@example.com",
    "phone": "0123456789",
    "roomName": "Salle 1",
    "date": "2025-09-22",
    "timeSlot": "14:00 - 14:20",
    "duration": 20,
    "numberOfPeople": 1,
    "specialRequests": "Test diagnostic"
  }' | jq '.' 2>/dev/null || echo "Erreur JSON ou jq non installé"

echo ""
echo "4. TEST DES APIs ADMIN :"
echo "----------------------------------------"
echo "4.1. Test de l'API admin des réservations :"
curl -s "https://rageroom.usilenziu.com/api/admin/reservations" | jq '.' 2>/dev/null || echo "Erreur JSON ou jq non installé"

echo ""
echo "4.2. Test de l'API admin des salles :"
curl -s "https://rageroom.usilenziu.com/api/admin/rooms" | jq '.' 2>/dev/null || echo "Erreur JSON ou jq non installé"

echo ""
echo "4.3. Test de l'API admin de configuration de la page d'accueil :"
curl -s "https://rageroom.usilenziu.com/api/admin/homepage-config" | jq '.' 2>/dev/null || echo "Erreur JSON ou jq non installé"

echo ""
echo "4.4. Test de l'API admin de configuration de l'en-tête :"
curl -s "https://rageroom.usilenziu.com/api/admin/header-config" | jq '.' 2>/dev/null || echo "Erreur JSON ou jq non installé"

echo ""
echo "5. VÉRIFICATION DES LOGS :"
echo "----------------------------------------"
echo "5.1. Logs de l'application (dernières 50 lignes) :"
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=50

echo ""
echo "5.2. Logs PostgreSQL (dernières 20 lignes) :"
docker compose -f docker-compose.prod.yml logs u-silenziu-postgres --tail=20

echo ""
echo "5.3. Logs Nginx (dernières 20 lignes) :"
docker compose -f docker-compose.prod.yml logs u-silenziu-nginx-prod --tail=20

echo ""
echo "6. VÉRIFICATION DES RESSOURCES SYSTÈME :"
echo "----------------------------------------"
echo "6.1. Utilisation de la mémoire :"
docker stats --no-stream

echo ""
echo "6.2. Espace disque :"
df -h

echo ""
echo "6.3. Processus en cours :"
ps aux | grep -E "(node|postgres|nginx)" | head -10

echo ""
echo "7. TEST DE CONNECTIVITÉ :"
echo "----------------------------------------"
echo "7.1. Test de connectivité à la base de données :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  current_database() as database,
  current_user as user,
  version() as postgres_version,
  now() as current_time,
  (SELECT COUNT(*) FROM reservations) as total_reservations,
  (SELECT COUNT(*) FROM rooms) as total_rooms;
"

echo ""
echo "7.2. Test de génération d'un numéro de réservation :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  CONCAT(
    TO_CHAR(CURRENT_DATE, 'YYMMDD'),
    LPAD(COALESCE(COUNT(*)::integer, 0) + 1, 3, '0')
  ) as next_reservation_number
FROM reservations 
WHERE DATE(created_at) = CURRENT_DATE;
"

echo ""
echo "8. VÉRIFICATION DES ERREURS SPÉCIFIQUES :"
echo "----------------------------------------"
echo "8.1. Recherche d'erreurs dans les logs :"
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=100 | grep -i "error\|erreur\|failed\|exception" | tail -10

echo ""
echo "8.2. Vérification des erreurs de base de données :"
docker compose -f docker-compose.prod.yml logs u-silenziu-postgres --tail=50 | grep -i "error\|erreur\|failed" | tail -5

echo ""
echo "8.3. Vérification des erreurs Nginx :"
docker compose -f docker-compose.prod.yml logs u-silenziu-nginx-prod --tail=50 | grep -i "error\|erreur\|failed" | tail -5

echo ""
echo "9. TEST DE PERFORMANCE :"
echo "----------------------------------------"
echo "9.1. Temps de réponse de la page d'accueil :"
time curl -s -o /dev/null -w "Temps de réponse: %{time_total}s\nCode HTTP: %{http_code}\n" "https://rageroom.usilenziu.com/"

echo ""
echo "9.2. Temps de réponse de l'API de disponibilité :"
time curl -s -o /dev/null -w "Temps de réponse: %{time_total}s\nCode HTTP: %{http_code}\n" "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-20&endDate=2025-09-21"

echo ""
echo "10. RÉSUMÉ DES PROBLÈMES DÉTECTÉS :"
echo "----------------------------------------"
echo "Vérifiez les sections ci-dessus pour identifier :"
echo "- Erreurs de base de données"
echo "- Problèmes d'APIs"
echo "- Erreurs dans les logs"
echo "- Problèmes de performance"
echo "- Données manquantes ou incorrectes"

echo ""
echo "=== DIAGNOSTIC TERMINÉ ==="
echo "Consultez les résultats ci-dessus pour identifier les problèmes."
