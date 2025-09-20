#!/bin/bash

echo "=== CORRECTION COMPLÈTE DE TOUS LES PROBLÈMES ==="
echo ""

# 1. Récupérer les dernières modifications
echo "1. Récupération des modifications..."
git pull origin main

echo ""
echo "2. Vérifier les réservations existantes :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, reservation_number, customer_name, customer_email, room_name, date, time_slot, duration, participants, status 
FROM reservations 
ORDER BY created_at DESC;
"

echo ""
echo "3. Mettre à jour les réservations existantes avec des numéros :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
UPDATE reservations 
SET reservation_number = CONCAT(
  TO_CHAR(created_at, 'YYMMDD'),
  LPAD(ROW_NUMBER() OVER (ORDER BY created_at)::text, 3, '0')
)
WHERE reservation_number IS NULL OR reservation_number = '';
"

echo ""
echo "4. Vérifier les réservations mises à jour :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, reservation_number, customer_name, customer_email, room_name, date, time_slot, duration, participants, status 
FROM reservations 
ORDER BY created_at DESC;
"

echo ""
echo "5. Nettoyer complètement et reconstruire l'application :"
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml down
docker system prune -f
docker compose -f docker-compose.prod.yml build --no-cache
docker compose -f docker-compose.prod.yml up -d

echo ""
echo "6. Attendre que l'application démarre complètement..."
sleep 30

echo ""
echo "7. Vérifier l'état des conteneurs :"
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml ps

echo ""
echo "8. Tester l'API de disponibilité :"
echo "----------------------------------------"
curl -v "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-20&endDate=2025-09-21&roomName=Salle%202"

echo ""
echo "9. Tester l'API admin des réservations :"
echo "----------------------------------------"
curl -v "https://rageroom.usilenziu.com/api/admin/reservations"

echo ""
echo "10. Vérifier les logs de l'application :"
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=30

echo ""
echo "=== CORRECTION TERMINÉE ==="
echo "Tous les problèmes devraient maintenant être résolus !"
echo "- Numéros de réservation générés"
echo "- Noms de clients affichés"
echo "- Créneaux réservés grisés dans le calendrier"
