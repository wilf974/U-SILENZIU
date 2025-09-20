#!/bin/bash

echo "=== DIAGNOSTIC ERREUR RÉSERVATION ==="
echo ""

# 1. Vérifier les logs de l'application
echo "1. Logs de l'application (dernières 50 lignes) :"
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=50 | grep -i "error\|erreur\|reservation\|réservation" -A 2 -B 2

echo ""
echo "2. Logs PostgreSQL (dernières 30 lignes) :"
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml logs postgres --tail=30 | grep -i "error\|erreur" -A 1 -B 1

echo ""
echo "3. Vérifier la structure de la table reservations :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\d reservations;"

echo ""
echo "4. Vérifier les données de test dans reservations :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "SELECT id, room_id, user_name, user_email, start_time, end_time, status, created_at FROM reservations ORDER BY created_at DESC LIMIT 5;"

echo ""
echo "5. Tester l'API de création de réservation :"
echo "----------------------------------------"
echo "Test avec curl :"
curl -X POST https://rageroom.usilenziu.com/api/reservations \
  -H "Content-Type: application/json" \
  -d '{
    "room_id": "test-room-id",
    "user_name": "Test User",
    "user_email": "test@example.com",
    "user_phone": "0123456789",
    "start_time": "2025-09-20T14:20:00Z",
    "end_time": "2025-09-20T14:40:00Z",
    "total_price": 50,
    "participants": 2
  }' -v

echo ""
echo "6. Vérifier les conteneurs en cours d'exécution :"
echo "----------------------------------------"
docker compose -f docker-compose.prod.yml ps

echo ""
echo "7. Vérifier la connectivité de la base de données :"
echo "----------------------------------------"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "SELECT 1 as connection_test;"

echo ""
echo "=== DIAGNOSTIC TERMINÉ ==="
echo "Vérifiez les logs ci-dessus pour identifier l'erreur de réservation."
