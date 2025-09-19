#!/bin/bash
# Script de résolution du conflit Git sur le VPS
# U Silenziu - Septembre 2025

echo "🔧 RÉSOLUTION CONFLIT GIT SUR VPS"
echo "================================="
echo ""

echo "📋 Problème détecté :"
echo "   - Modifications locales sur docker-compose.prod.yml"
echo "   - Modifications locales sur fix-final-prod.sh" 
echo "   - Conflit avec les nouvelles corrections"
echo ""

echo "🔄 1. Sauvegarde des modifications locales..."
git stash push -m "Sauvegarde VPS avant corrections HTTP 500 - $(date)"

echo ""
echo "🔄 2. Récupération des corrections depuis Git..."
git pull origin main

echo ""
echo "🔄 3. Arrêt des services actuels..."
docker compose -f docker-compose.prod.yml down

echo ""
echo "🔄 4. Nettoyage Docker..."
docker system prune -f

echo ""
echo "🔄 5. Reconstruction avec les corrections..."
docker compose -f docker-compose.prod.yml up -d --build

echo ""
echo "🔄 6. Attente du démarrage (30 secondes)..."
sleep 30

echo ""
echo "🔍 7. Tests de vérification..."

# Test du site principal
echo "   Test site principal..."
if curl -s -I https://rageroom.usilenziu.com | grep -q "200\|301\|302"; then
    echo "   ✅ Site principal : OK"
else
    echo "   ❌ Site principal : ERREUR"
fi

# Test des APIs critiques
echo "   Test API footer-config..."
if curl -s https://rageroom.usilenziu.com/api/footer-config | grep -q '"success":true'; then
    echo "   ✅ API footer-config : OK"
else
    echo "   ❌ API footer-config : ERREUR"
fi

echo "   Test API header-config..."
if curl -s https://rageroom.usilenziu.com/api/header-config | grep -q '"success":true'; then
    echo "   ✅ API header-config : OK"
else
    echo "   ❌ API header-config : ERREUR"
fi

echo "   Test API legal-pages..."
if curl -s https://rageroom.usilenziu.com/api/legal-pages | grep -q '"success":true'; then
    echo "   ✅ API legal-pages : OK"
else
    echo "   ❌ API legal-pages : ERREUR"
fi

echo "   Test API homepage-sections..."
if curl -s https://rageroom.usilenziu.com/api/homepage-sections | grep -q '"success":true'; then
    echo "   ✅ API homepage-sections : OK"
else
    echo "   ❌ API homepage-sections : ERREUR"
fi

echo ""
echo "📊 État final des conteneurs :"
docker compose -f docker-compose.prod.yml ps

echo ""
echo "📋 Logs récents (dernières 10 lignes) :"
docker compose -f docker-compose.prod.yml logs --tail=10 u-silenziu

echo ""
echo "✅ DÉPLOIEMENT TERMINÉ !"
echo ""
echo "🌐 Testez maintenant : https://rageroom.usilenziu.com"
echo "🔧 Administration : https://rageroom.usilenziu.com/admin"
echo ""
echo "💾 Vos modifications locales sont sauvées avec : git stash list"
echo "🔄 Pour les restaurer plus tard : git stash pop"
echo ""
echo "📚 En cas de problème :"
echo "   - Logs détaillés : docker compose -f docker-compose.prod.yml logs -f u-silenziu"
echo "   - Redémarrage : docker compose -f docker-compose.prod.yml restart u-silenziu"
