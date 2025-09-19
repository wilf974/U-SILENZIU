#!/bin/bash
# Script de diagnostic complet pour les salles et sections manquantes
# U Silenziu - Septembre 2025

echo "🔍 DIAGNOSTIC COMPLET - SALLES ET SECTIONS"
echo "=========================================="
echo ""

# 1. Vérifier l'état de l'application
echo "1. Vérification de l'état de l'application..."
echo "Conteneurs en cours d'exécution :"
docker compose -f docker-compose.prod.yml ps

echo ""

# 2. Vérifier les logs de l'application
echo "2. Vérification des logs de l'application..."
echo "Logs récents (20 dernières lignes) :"
docker compose -f docker-compose.prod.yml logs --tail=20 u-silenziu

echo ""

# 3. Vérifier les données dans la base
echo "3. Vérification des données dans la base..."
echo "Salles actives :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, name, description, price, duration, max_people, is_active 
FROM rooms 
WHERE is_active = true
ORDER BY created_at;
"

echo ""

echo "Sections homepage :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, section_type, title, is_active, is_visible
FROM homepage_sections 
ORDER BY order_index;
"

echo ""

# 4. Test des APIs
echo "4. Test des APIs..."
echo "Test API /api/rooms :"
curl -s "https://rageroom.usilenziu.com/api/rooms" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 500

echo ""

echo "Test API /api/homepage-sections :"
curl -s "https://rageroom.usilenziu.com/api/homepage-sections" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 500

echo ""

# 5. Vérifier les fichiers de composants
echo "5. Vérification des fichiers de composants..."
echo "Fichiers de composants salles :"
ls -la components/Rooms*.tsx components/Salles.tsx 2>/dev/null || echo "Fichiers non trouvés"

echo ""

# 6. Test de l'API depuis l'intérieur du conteneur
echo "6. Test de l'API depuis l'intérieur du conteneur..."
echo "Test API rooms depuis le conteneur :"
docker exec u-silenziu-app curl -s "http://localhost:3000/api/rooms" 2>/dev/null | head -c 300 || echo "Erreur: curl non disponible dans le conteneur"

echo ""

# 7. Vérifier les variables d'environnement
echo "7. Vérification des variables d'environnement..."
echo "Variables critiques dans le conteneur :"
docker exec u-silenziu-app printenv | grep -E "(NODE_ENV|DATABASE_URL|NEXT_PUBLIC)" | head -10

echo ""

# 8. Redémarrer l'application
echo "8. Redémarrage de l'application..."
echo "Redémarrage du conteneur application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

echo "Attente du démarrage (20 secondes)..."
sleep 20

echo ""

# 9. Test final après redémarrage
echo "9. Test final après redémarrage..."
echo "Test API rooms après redémarrage :"
curl -s "https://rageroom.usilenziu.com/api/rooms" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 300

echo ""

echo "Test API homepage-sections après redémarrage :"
curl -s "https://rageroom.usilenziu.com/api/homepage-sections" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 300

echo ""

# 10. Instructions de débogage
echo "10. INSTRUCTIONS DE DÉBOGAGE"
echo "============================"
echo ""
echo "📱 Pour déboguer côté navigateur :"
echo "1. Ouvrez https://rageroom.usilenziu.com"
echo "2. Appuyez sur F12 pour ouvrir la console"
echo "3. Regardez les logs qui commencent par 🔄, 📡, 📦, 🏠, ✅, ❌"
echo "4. Vérifiez s'il y a des erreurs en rouge"
echo ""
echo "🔧 Si les salles ne s'affichent toujours pas :"
echo "1. Vérifiez que l'API /api/rooms retourne bien les données"
echo "2. Vérifiez que le composant RoomsSimple se charge"
echo "3. Vérifiez qu'il n'y a pas d'erreurs JavaScript"
echo ""
echo "📋 Sections manquantes à ajouter :"
echo "- Comment fonctionne une séance ?"
echo "- Foire aux Questions (FAQ)"
echo ""

echo "✅ DIAGNOSTIC TERMINÉ !"
