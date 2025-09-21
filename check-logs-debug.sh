#!/bin/bash

echo "=== VÉRIFICATION LOGS DEBUG ==="
echo ""

# 1. Voir tous les logs récents avec nos marqueurs
echo "1. 🔍 RECHERCHE LOGS DEBUG :"
echo "============================"
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=50 | grep -E "🔧|PUT.*rooms|updateRoom"

# 2. Voir les erreurs de compilation récentes
echo ""
echo "2. 🔍 ERREURS DE COMPILATION :"
echo "=============================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=100 | grep -i "error\|failed\|syntaxerror"

# 3. Test simple pour forcer l'affichage du log
echo ""
echo "3. 🧪 TEST SIMPLE AVEC LOGS :"
echo "=============================="

# Lancer logs en temps réel
docker compose -f docker-compose.prod.yml logs -f u-silenziu &
LOGS_PID=$!

sleep 2

# Test très simple
echo "Test PUT simple..."
curl -s -X PUT "https://rageroom.usilenziu.com/api/admin/rooms/0b9dfff4-421a-468e-ad29-96ed6445b84f" \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Log Debug"}' > /dev/null

sleep 3

# Arrêter les logs
kill $LOGS_PID 2>/dev/null

echo ""
echo "4. 🔍 LOGS DEPUIS LE DERNIER REDÉMARRAGE :"
echo "=========================================="
docker compose -f docker-compose.prod.yml logs u-silenziu --since="10m" | tail -30

# 5. Vérifier que les logs console.log s'affichent
echo ""
echo "5. 🧪 TEST AVEC LOG SIMPLE :"
echo "============================"
echo "Redémarrage pour forcer la lecture du nouveau code..."
docker compose -f docker-compose.prod.yml restart u-silenziu

sleep 10

echo "Test après redémarrage :"
curl -s -X PUT "https://rageroom.usilenziu.com/api/admin/rooms/0b9dfff4-421a-468e-ad29-96ed6445b84f" \
  -H "Content-Type: application/json" \
  -d '{"name": "Test After Restart"}' > /dev/null

sleep 3

echo ""
echo "Logs après redémarrage :"
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=20
