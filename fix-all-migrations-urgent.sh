#!/bin/bash

echo "=== CORRECTION URGENTE TOUTES MIGRATIONS ==="
echo ""

# 1. Pull du code latest
echo "1. 📥 PULL LATEST :"
echo "=================="
git pull origin main

# 2. Appliquer les migrations homepage_sections
echo ""
echo "2. 🔧 MIGRATION HOMEPAGE SECTIONS :"
echo "==================================="
docker exec -i u-silenziu-postgres psql -U usilenzio_user -d usilenzio < fix-homepage-sections-schema.sql

# 3. Appliquer les migrations legal_pages
echo ""
echo "3. 🔧 MIGRATION LEGAL PAGES :"
echo "=============================="
docker exec -i u-silenziu-postgres psql -U usilenzio_user -d usilenzio < fix-legal-pages-schema.sql

# 4. Nettoyage Docker complet
echo ""
echo "4. 🧹 NETTOYAGE DOCKER COMPLET :"
echo "================================"
docker compose -f docker-compose.prod.yml down
docker system prune -f
docker image rm u-silenziu-u-silenziu 2>/dev/null || true
docker builder prune -f

# 5. Rebuild sans cache
echo ""
echo "5. 🔧 REBUILD SANS CACHE :"
echo "=========================="
docker compose -f docker-compose.prod.yml build --no-cache u-silenziu

# 6. Restart complet
echo ""
echo "6. 🔄 RESTART COMPLET :"
echo "======================"
docker compose -f docker-compose.prod.yml up -d

# 7. Attendre stabilisation
echo ""
echo "7. ⏳ ATTENTE STABILISATION :"
echo "============================"
sleep 20

# 8. Test avec logs debug
echo ""
echo "8. 🧪 TEST AVEC LOGS DEBUG :"
echo "============================"

# Lancer logs en temps réel
docker compose -f docker-compose.prod.yml logs -f u-silenziu | grep "🔧" &
LOGS_PID=$!

sleep 3

echo "Test PUT max_people avec logs :"
curl -s -X PUT "https://rageroom.usilenziu.com/api/admin/rooms/0b9dfff4-421a-468e-ad29-96ed6445b84f" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Final Debug",
    "max_people": 25
  }' > /tmp/final_test.json

sleep 5

# Arrêter les logs
kill $LOGS_PID 2>/dev/null

echo ""
echo "Réponse API :"
cat /tmp/final_test.json

echo ""
echo ""
echo "État en base :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT name, max_people, updated_at FROM rooms WHERE id = '0b9dfff4-421a-468e-ad29-96ed6445b84f';
"

# 9. Vérifier logs généraux
echo ""
echo "9. 🔍 LOGS FINAUX :"
echo "=================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=20 | grep -E "🔧|Ready|error"

echo ""
echo "=== CORRECTION TERMINÉE ==="
echo ""
echo "✅ Actions effectuées :"
echo "• Migrations homepage_sections et legal_pages"
echo "• Nettoyage Docker complet"
echo "• Rebuild sans cache"
echo "• Test avec logs debug"
echo ""
echo "🔍 À vérifier :"
echo "• Si logs '🔧' apparaissent maintenant"
echo "• Si max_people se met à jour"
echo "• Si updated_at change"
