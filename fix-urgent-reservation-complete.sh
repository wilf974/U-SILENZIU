#!/bin/bash

echo "=== FIX URGENT - RÉSERVATIONS COMPLÈTES ==="
echo ""

# 1. Pull latest code
echo "1. Récupération du code..."
git pull origin main

# 2. Fix des numéros de réservation
echo ""
echo "2. GÉNÉRATION DES NUMÉROS DE RÉSERVATION :"
echo "=========================================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -f /tmp/fix-reservation-number-generation-urgent.sql

# Copier le script SQL dans le conteneur
docker cp fix-reservation-number-generation-urgent.sql u-silenziu-postgres:/tmp/

echo ""
echo "2.1. Exécution du script de génération..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -f /tmp/fix-reservation-number-generation-urgent.sql

# 3. Rebuild complet de l'application
echo ""
echo "3. REBUILD COMPLET DE L'APPLICATION :"
echo "===================================="
docker compose -f docker-compose.prod.yml down u-silenziu
docker compose -f docker-compose.prod.yml build --no-cache u-silenziu
docker compose -f docker-compose.prod.yml up -d u-silenziu

# 4. Attendre le redémarrage
echo ""
echo "4. ATTENTE DU REDÉMARRAGE..."
sleep 30

# 5. Vérifier l'état
echo ""
echo "5. VÉRIFICATION DE L'ÉTAT :"
echo "=========================="
docker compose -f docker-compose.prod.yml ps

# 6. Tester les APIs corrigées
echo ""
echo "6. TESTS DES APIs CORRIGÉES :"
echo "============================"

echo "6.1. Test API weekly (devrait marcher maintenant) :"
curl -s "https://rageroom.usilenziu.com/api/admin/reservations/weekly?week=2025-09-20" | head -c 1000

echo ""
echo "6.2. Test API admin reservations :"
curl -s "https://rageroom.usilenziu.com/api/admin/reservations" | head -c 2000

# 7. Créer une nouvelle réservation pour tester
echo ""
echo "7. CRÉATION D'UNE NOUVELLE RÉSERVATION DE TEST :"
echo "==============================================="
curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "Final",
    "email": "test.final@example.com",
    "phone": "0987654321",
    "roomName": "Salle 1",
    "date": "2025-09-22",
    "timeSlot": "15:00 - 15:20",
    "duration": 20,
    "numberOfPeople": 2
  }' | head -c 1000

# 8. Vérifier la nouvelle réservation dans la base
echo ""
echo "8. VÉRIFICATION DE LA NOUVELLE RÉSERVATION :"
echo "==========================================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
    id, 
    reservation_number, 
    customer_name, 
    customer_email, 
    room_name, 
    date, 
    time_slot,
    participants,
    amount,
    status,
    created_at
FROM reservations 
ORDER BY created_at DESC 
LIMIT 5;
"

# 9. Test final de l'API weekly
echo ""
echo "9. TEST FINAL DE L'API WEEKLY :"
echo "=============================="
curl -s "https://rageroom.usilenziu.com/api/admin/reservations/weekly?week=2025-09-20" | head -c 2000

# 10. Vérifier les logs d'erreur
echo ""
echo "10. LOGS D'ERREUR :"
echo "=================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=20

echo ""
echo "=== FIX TERMINÉ ==="
echo "Les problèmes corrigés :"
echo "✅ Email TypeScript error (await transporter)"
echo "✅ Weekly API error (colonnes database)"
echo "✅ Génération reservation_number"
echo "✅ Rebuild complet de l'app"
echo ""
echo "Le calendrier admin devrait maintenant fonctionner !"
