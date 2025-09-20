#!/bin/bash

echo "=== CORRECTION DISPONIBILITÉS ET AFFICHAGE RÉSERVATIONS ==="
echo ""

# 1. Récupérer les dernières modifications
echo "1. Récupération des modifications..."
git pull origin main

echo ""
echo "2. Vérifier les réservations existantes dans la base :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, reservation_number, customer_name, customer_email, room_name, date, time_slot, duration, participants, status 
FROM reservations 
ORDER BY created_at DESC;
"

echo ""
echo "3. Tester l'API de disponibilité :"
echo "----------------------------------------"
curl -v "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-20&endDate=2025-09-21&roomName=Salle%202"

echo ""
echo "4. Redémarrage de l'application avec les corrections :"
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml build --no-cache u-silenziu
docker compose -f docker-compose.prod.yml up -d

echo ""
echo "5. Attendre que l'application démarre..."
sleep 15

echo ""
echo "6. Vérifier l'état des conteneurs :"
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml ps

echo ""
echo "7. Tester l'API de disponibilité après redémarrage :"
echo "----------------------------------------"
curl -v "https://rageroom.usilenziu.com/api/reservations/availability?startDate=2025-09-20&endDate=2025-09-21&roomName=Salle%202"

echo ""
echo "8. Tester l'API admin des réservations :"
echo "----------------------------------------"
curl -v "https://rageroom.usilenziu.com/api/admin/reservations"

echo ""
echo "9. Vérifier les logs de l'application :"
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=20

echo ""
echo "=== CORRECTION TERMINÉE ==="
echo "Les créneaux réservés devraient maintenant être grisés dans le calendrier !"
echo "Les numéros de réservation et noms de clients devraient s'afficher dans l'admin !"
