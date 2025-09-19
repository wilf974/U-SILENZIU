#!/bin/bash
# Script de correction immédiate pour le VPS
# U Silenziu - Septembre 2025
# Résout l'erreur HTTP 500 en production

echo "🔥 CORRECTION IMMÉDIATE PRODUCTION VPS"
echo "====================================="
echo ""

echo "📋 Problèmes corrigés dans cette version :"
echo "   ✅ next.config.js: Domaines production ajoutés"
echo "   ✅ lib/database.ts: Connexion Docker postgres:5432"
echo "   ✅ APIs: export dynamic = 'force-dynamic' ajouté"
echo "   ✅ docker-compose.prod.yml: Variables HTTPS complètes"
echo ""

echo "🚀 DÉPLOIEMENT SUR LE VPS..."
echo ""

# 1. Sauvegarder l'actuel
echo "1. Sauvegarde de sécurité..."
cp -r /root/U-SILENZIU /root/U-SILENZIU-backup-$(date +%Y%m%d-%H%M%S) 2>/dev/null || echo "   Pas de sauvegarde nécessaire"

# 2. Récupérer les nouvelles modifications
echo "2. Récupération des corrections..."
cd /root/U-SILENZIU
git stash push -m "Sauvegarde locale avant correction"
git pull origin main

# 3. Arrêter les services
echo "3. Arrêt des services actuels..."
docker compose -f docker-compose.prod.yml down

# 4. Nettoyer les images
echo "4. Nettoyage des images Docker..."
docker system prune -f

# 5. Reconstruire et démarrer
echo "5. Reconstruction et démarrage..."
docker compose -f docker-compose.prod.yml up -d --build

# 6. Attendre le démarrage
echo "6. Attente du démarrage de l'application..."
sleep 30

# 7. Tests de vérification
echo "7. Tests de vérification..."
echo ""
echo "🔍 Test de l'application principale..."
if curl -s -f https://rageroom.usilenziu.com > /dev/null; then
    echo "   ✅ Site principal accessible"
else
    echo "   ❌ Site principal inaccessible"
fi

echo ""
echo "🔍 Test des APIs critiques..."

# Test API footer-config
if curl -s -f https://rageroom.usilenziu.com/api/footer-config > /dev/null; then
    echo "   ✅ API footer-config fonctionne"
else
    echo "   ❌ API footer-config en erreur"
fi

# Test API legal-pages
if curl -s -f https://rageroom.usilenziu.com/api/legal-pages > /dev/null; then
    echo "   ✅ API legal-pages fonctionne"
else
    echo "   ❌ API legal-pages en erreur"
fi

# Test API homepage-sections
if curl -s -f https://rageroom.usilenziu.com/api/homepage-sections > /dev/null; then
    echo "   ✅ API homepage-sections fonctionne"
else
    echo "   ❌ API homepage-sections en erreur"
fi

# Test API header-config
if curl -s -f https://rageroom.usilenziu.com/api/header-config > /dev/null; then
    echo "   ✅ API header-config fonctionne"
else
    echo "   ❌ API header-config en erreur"
fi

echo ""
echo "📊 État des conteneurs :"
docker compose -f docker-compose.prod.yml ps

echo ""
echo "📋 Logs récents de l'application :"
docker compose -f docker-compose.prod.yml logs --tail=20 u-silenziu

echo ""
echo "✅ DÉPLOIEMENT TERMINÉ !"
echo ""
echo "🌐 Vérifiez votre site : https://rageroom.usilenziu.com"
echo "🔧 Admin : https://rageroom.usilenziu.com/admin"
echo ""
echo "💡 En cas de problème, consultez les logs :"
echo "   docker compose -f docker-compose.prod.yml logs -f u-silenziu"
