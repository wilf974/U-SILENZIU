#!/bin/bash

echo "=== DEBUG APPROFONDI UPDATEROOM ==="
echo ""

# 1. Vérifier les logs détaillés pendant un test
echo "1. 🔍 LOGS DÉTAILLÉS PENDANT TEST :"
echo "=================================="

ROOM_ID="0b9dfff4-421a-468e-ad29-96ed6445b84f"

echo "État AVANT modification :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, name, max_people, updated_at FROM rooms WHERE id = '$ROOM_ID';
"

echo ""
echo "Test PUT avec debug - suivre les logs en temps réel :"

# Lancer les logs en arrière-plan
docker compose -f docker-compose.prod.yml logs -f u-silenziu &
LOGS_PID=$!

sleep 2

# Faire le test PUT
echo "Envoi de la requête PUT..."
curl -s -X PUT "https://rageroom.usilenziu.com/api/admin/rooms/$ROOM_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Salle Test Debug",
    "description": "Test debug max_people",
    "max_people": 7,
    "price": 25,
    "duration": 20,
    "objects_to_destroy": ["Test objet"],
    "included": ["Test inclus"],
    "is_active": true
  }' > /tmp/put_response.json

echo "Réponse PUT :"
cat /tmp/put_response.json | head -c 500

sleep 3

# Arrêter les logs
kill $LOGS_PID 2>/dev/null

echo ""
echo ""
echo "État APRÈS modification :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, name, max_people, updated_at FROM rooms WHERE id = '$ROOM_ID';
"

# 2. Vérifier directement en base
echo ""
echo "2. 🔍 TEST DIRECT EN BASE :"
echo "=========================="
echo "Test UPDATE direct en PostgreSQL :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
UPDATE rooms SET max_people = 9, updated_at = CURRENT_TIMESTAMP 
WHERE id = '$ROOM_ID';

SELECT id, name, max_people, updated_at FROM rooms WHERE id = '$ROOM_ID';
"

# 3. Vérifier les contraintes/triggers
echo ""
echo "3. 🔍 CONTRAINTES ET TRIGGERS :"
echo "==============================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
-- Vérifier les triggers
SELECT trigger_name, event_manipulation, action_statement 
FROM information_schema.triggers 
WHERE event_object_table = 'rooms';

-- Vérifier les contraintes check
SELECT constraint_name, check_clause 
FROM information_schema.check_constraints 
WHERE constraint_schema = 'public';
"

# 4. Test avec des logs PostgreSQL
echo ""
echo "4. 🔍 LOGS POSTGRESQL :"
echo "======================"
echo "Activer le logging des requêtes..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
ALTER SYSTEM SET log_statement = 'all';
SELECT pg_reload_conf();
"

sleep 2

echo "Test avec logging activé :"
curl -s -X PUT "https://rageroom.usilenziu.com/api/admin/rooms/$ROOM_ID" \
  -H "Content-Type: application/json" \
  -d '{
    "max_people": 8
  }' > /dev/null

sleep 2

echo "Logs PostgreSQL récents :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT message, detail, query
FROM pg_stat_statements 
WHERE query LIKE '%UPDATE rooms%' 
ORDER BY mean_exec_time DESC 
LIMIT 5;
" 2>/dev/null || echo "pg_stat_statements non disponible"

echo ""
echo "5. 🔍 ÉTAT FINAL :"
echo "=================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, name, max_people, updated_at FROM rooms WHERE id = '$ROOM_ID';
"

echo ""
echo "=== DEBUG TERMINÉ ==="
echo ""
echo "🔍 ANALYSES EFFECTUÉES :"
echo "• Logs application pendant PUT"
echo "• Test direct UPDATE en base"
echo "• Vérification contraintes/triggers"
echo "• Logs PostgreSQL"
echo "• État final de la salle"
