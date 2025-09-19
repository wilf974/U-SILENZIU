#!/bin/bash
# Script de correction complète pour le VPS
# U Silenziu - Septembre 2025

echo "🔧 CORRECTION COMPLÈTE VPS"
echo "=========================="
echo ""

# 1. Récupérer les dernières corrections
echo "1. Récupération des dernières corrections..."
git pull origin main

echo ""

# 2. Créer la table homepage_config
echo "2. Création de la table homepage_config..."
chmod +x create-homepage-config-table.sh
./create-homepage-config-table.sh

echo ""

# 3. Ajouter les sections manquantes avec SQL corrigé
echo "3. Ajout des sections manquantes..."
chmod +x fix-sections-sql.sh
./fix-sections-sql.sh

echo ""

# 4. Redémarrer l'application
echo "4. Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

echo "Attente du démarrage (20 secondes)..."
sleep 20

echo ""

# 5. Test des APIs critiques
echo "5. Test des APIs critiques..."

echo "Test API /api/admin/homepage-config :"
curl -s "https://rageroom.usilenziu.com/api/admin/homepage-config" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 300

echo ""

echo "Test API /api/homepage-sections :"
curl -s "https://rageroom.usilenziu.com/api/homepage-sections" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 300

echo ""

echo "Test API /api/rooms :"
curl -s "https://rageroom.usilenziu.com/api/rooms" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 300

echo ""

# 6. Vérification des logs
echo "6. Vérification des logs récents..."
docker compose -f docker-compose.prod.yml logs --tail=10 u-silenziu

echo ""

echo "✅ CORRECTION COMPLÈTE TERMINÉE !"
echo ""
echo "🔗 Vérifiez maintenant :"
echo "- Site public: https://rageroom.usilenziu.com"
echo "- Admin: https://rageroom.usilenziu.com/admin"
echo ""
echo "📱 Ouvrez la console du navigateur (F12) pour voir les logs de débogage"
