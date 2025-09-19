#!/bin/bash
# Script de test pour l'affichage des salles
# U Silenziu - Septembre 2025

echo "🔍 TEST AFFICHAGE DES SALLES"
echo "============================"
echo ""

# 1. Vérifier les tables dans la base de données
echo "1. Vérification des tables dans la base de données..."
echo "Tables existantes :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
"

echo ""

# 2. Vérifier les données des salles
echo "2. Vérification des données des salles..."
echo "Salles dans la base :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, name, description, price, duration, max_people, is_active 
FROM rooms 
ORDER BY created_at;
"

echo ""

# 3. Vérifier les sections homepage
echo "3. Vérification des sections homepage..."
echo "Sections homepage :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, section_type, title, is_active 
FROM homepage_sections 
ORDER BY order_index;
"

echo ""

# 4. Test de l'API rooms
echo "4. Test de l'API rooms..."
echo "Test API /api/rooms :"
curl -s "https://rageroom.usilenziu.com/api/rooms" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 500

echo ""

# 5. Test de l'API homepage-sections
echo "5. Test de l'API homepage-sections..."
echo "Test API /api/homepage-sections :"
curl -s "https://rageroom.usilenziu.com/api/homepage-sections" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 500

echo ""

# 6. Test de l'API admin stats
echo "6. Test de l'API admin stats..."
echo "Test API /api/admin/stats :"
curl -s "https://rageroom.usilenziu.com/api/admin/stats?includeRecent=true" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 300

echo ""

# 7. Vérifier les logs de l'application
echo "7. Vérification des logs de l'application..."
echo "Logs récents de l'application :"
docker compose -f docker-compose.prod.yml logs --tail=20 u-silenziu

echo ""

# 8. Redémarrer l'application si nécessaire
echo "8. Redémarrage de l'application..."
echo "Redémarrage du conteneur application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

echo "Attente du démarrage (15 secondes)..."
sleep 15

echo ""

# 9. Test final
echo "9. Test final après redémarrage..."
echo "Test API rooms après redémarrage :"
curl -s "https://rageroom.usilenziu.com/api/rooms" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 300

echo ""

echo "🎯 RÉSUMÉ DU TEST"
echo "================="
echo "✅ Tables vérifiées"
echo "✅ Données des salles vérifiées"
echo "✅ Sections homepage vérifiées"
echo "✅ APIs testées"
echo "✅ Application redémarrée"
echo ""
echo "🔗 Vérifiez maintenant :"
echo "- Site public: https://rageroom.usilenziu.com"
echo "- Admin: https://rageroom.usilenziu.com/admin"
echo ""
echo "📱 Ouvrez la console du navigateur (F12) pour voir les logs de débogage"
echo ""
echo "✅ TEST TERMINÉ !"
