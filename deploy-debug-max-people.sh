#!/bin/bash

echo "=== DÉPLOIEMENT DEBUG MAX_PEOPLE ==="
echo ""

# 1. Pull code avec logs debug
echo "1. 📥 PULL LOGS DEBUG :"
echo "======================"
git pull origin main

# 2. Rebuild rapide avec logs
echo ""
echo "2. 🔧 REBUILD AVEC LOGS :"
echo "========================"
docker compose -f docker-compose.prod.yml build u-silenziu

# 3. Restart
echo ""
echo "3. 🔄 RESTART :"
echo "==============="
docker compose -f docker-compose.prod.yml restart u-silenziu

# 4. Attendre stabilisation
echo ""
echo "4. ⏳ ATTENTE :"
echo "==============="
sleep 15

# 5. Test avec suivi logs en temps réel
echo ""
echo "5. 🔍 TEST AVEC LOGS EN TEMPS RÉEL :"
echo "===================================="

ROOM_ID="0b9dfff4-421a-468e-ad29-96ed6445b84f"

# Lancer les logs en arrière-plan
docker compose -f docker-compose.prod.yml logs -f u-silenziu | grep "🔧 API PUT Room\|🔧 updateRoom" &
LOGS_PID=$!

sleep 3

echo "Envoi PUT max_people=12 :"
curl -s -X PUT "https://rageroom.usilenziu.com/api/admin/rooms/$ROOM_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Salle Test Max People",
    "description": "Test final",
    "max_people": 12,
    "price": 25,
    "duration": 20,
    "objects_to_destroy": [],
    "included": [],
    "is_active": true
  }' > /tmp/response_debug.json

sleep 5

# Arrêter les logs
kill $LOGS_PID 2>/dev/null

echo ""
echo "Réponse API :"
cat /tmp/response_debug.json | head -c 300

echo ""
echo ""
echo "État final en base :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT name, max_people, updated_at FROM rooms WHERE id = '$ROOM_ID';
"

echo ""
echo "=== LOGS COMPLETS DES 30 DERNIÈRES LIGNES ==="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=30 | grep -A2 -B2 "🔧"

echo ""
echo "=== ANALYSE ==="
echo "Si vous voyez les logs '🔧', on saura exactement où ça bloque !"
echo "Si pas de logs '🔧', le problème est avant updateRoom"
