#!/bin/bash

echo "🔍 Test complet du site U Silenziu"
echo "=================================="

# 1. Vérifier l'état des conteneurs
echo "📊 1. État des conteneurs Docker"
echo "--------------------------------"
docker ps -a

echo ""
echo "📋 2. Logs de l'application Next.js (dernières 20 lignes)"
echo "--------------------------------------------------------"
docker logs u-silenziu-app --tail 20

echo ""
echo "📋 3. Logs de nginx (dernières 10 lignes)"
echo "----------------------------------------"
docker logs u-silenziu-nginx-prod --tail 10

echo ""
echo "🌐 4. Test de connectivité interne"
echo "--------------------------------"
echo "Test depuis nginx vers l'app :"
docker exec u-silenziu-nginx-prod wget -q --spider http://u-silenziu-app:3000 && echo "✅ Connexion nginx -> app OK" || echo "❌ Connexion nginx -> app FAILED"

echo ""
echo "Test depuis l'app vers localhost :"
docker exec u-silenziu-app wget -q --spider http://localhost:3000 && echo "✅ App répond sur localhost:3000" || echo "❌ App ne répond pas sur localhost:3000"

echo ""
echo "🔗 5. Test de résolution DNS"
echo "---------------------------"
nslookup rageroom.usilenziu.com

echo ""
echo "🌍 6. Test HTTP externe"
echo "----------------------"
echo "Test HTTP direct :"
curl -I http://rageroom.usilenziu.com

echo ""
echo "Test HTTPS (si configuré) :"
curl -I https://rageroom.usilenziu.com 2>/dev/null || echo "HTTPS non configuré"

echo ""
echo "🔧 7. Vérification des ports"
echo "---------------------------"
netstat -tlnp | grep -E ":(80|443|3000)"

echo ""
echo "📁 8. Vérification des fichiers de configuration"
echo "-----------------------------------------------"
echo "Configuration nginx :"
cat nginx/conf.d/default.conf

echo ""
echo "Configuration docker-compose :"
grep -A 20 "u-silenziu:" docker-compose.prod.yml

echo ""
echo "🔍 9. Test de l'application Next.js en interne"
echo "---------------------------------------------"
echo "Test de la page d'accueil :"
docker exec u-silenziu-app wget -q -O - http://localhost:3000 | head -20

echo ""
echo "Test de l'API :"
docker exec u-silenziu-app wget -q -O - http://localhost:3000/api/rooms | head -10

echo ""
echo "✅ Test complet terminé"
echo "======================"
echo "Si le site ne fonctionne toujours pas, vérifiez :"
echo "1. Les logs d'erreur ci-dessus"
echo "2. La configuration nginx"
echo "3. La connectivité réseau entre conteneurs"
echo "4. Les variables d'environnement"
