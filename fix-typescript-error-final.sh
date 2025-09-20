#!/bin/bash

echo "=== FIX TYPESCRIPT ERROR FINAL ==="
echo ""

# 1. Pull la correction TypeScript
echo "1. PULL CORRECTION TYPESCRIPT :"
echo "==============================="
git pull origin main

# 2. Rebuild directement (plus rapide, DB déjà corrigée)
echo ""
echo "2. REBUILD RAPIDE :"
echo "=================="
docker compose -f docker-compose.prod.yml build --no-cache u-silenziu

# 3. Redémarrer l'app
echo ""
echo "3. REDÉMARRAGE APPLICATION :"
echo "=========================="
docker compose -f docker-compose.prod.yml up -d u-silenziu

# 4. Attendre stabilisation
echo ""
echo "4. ATTENTE STABILISATION :"
echo "========================="
sleep 30

# 5. Vérifier l'état
echo ""
echo "5. ÉTAT DES CONTENEURS :"
echo "======================="
docker compose -f docker-compose.prod.yml ps

# 6. Vérifier les logs de compilation
echo ""
echo "6. LOGS DE COMPILATION :"
echo "======================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=20

# 7. Test API immédiat
echo ""
echo "7. TEST API :"
echo "==========="
curl -s "https://rageroom.usilenziu.com/api/admin/reservations" | head -c 200

# 8. Test réservation immédiat
echo ""
echo "8. TEST RÉSERVATION :"
echo "==================="
curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "TypeScript Fix",
    "email": "jean.maillot14@gmail.com",
    "phone": "0123456789",
    "roomName": "Salle 1",
    "date": "2025-09-29",
    "timeSlot": "21:00 - 21:20",
    "duration": 20,
    "numberOfPeople": 1,
    "specialRequests": "Test après fix TypeScript final"
  }'

# 9. Vérifier logs email
echo ""
echo "9. LOGS EMAIL :"
echo "=============="
sleep 5
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=15 | grep -i -E "email|smtp|configuration.*smtp|envoi|erreur"

echo ""
echo "=== FIX TYPESCRIPT TERMINÉ ==="
echo "Si ça compile maintenant, l'email devrait fonctionner !"
