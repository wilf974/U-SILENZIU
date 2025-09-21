#!/bin/bash

echo "🔍 Diagnostic React Error #31 - U Silenziu (PRODUCTION)"
echo "======================================================="

# 1. Vérifier l'état des conteneurs
echo "📊 1. État des conteneurs Docker"
echo "--------------------------------"
docker ps -a

echo ""
echo "📋 2. Logs de l'application Next.js (dernières 50 lignes)"
echo "--------------------------------------------------------"
docker logs u-silenziu-app --tail 50

echo ""
echo "🔧 3. Vérifier les erreurs de build"
echo "----------------------------------"
docker logs u-silenziu-app | grep -i error

echo ""
echo "🌐 4. Test de connectivité"
echo "-------------------------"
echo "Test HTTPS :"
curl -I https://rageroom.usilenziu.com

echo ""
echo "Test HTTP (redirection) :"
curl -I http://rageroom.usilenziu.com

echo ""
echo "🔍 5. Vérifier la configuration de production"
echo "--------------------------------------------"
echo "Variables d'environnement :"
docker exec u-silenziu-app env | grep -E "(NODE_ENV|NEXT_PUBLIC|DATABASE|PAYPLUG)"

echo ""
echo "📁 6. Vérifier les fichiers de configuration"
echo "-------------------------------------------"
echo "Configuration nginx :"
cat nginx/conf.d/default.conf

echo ""
echo "Configuration docker-compose :"
grep -A 10 "u-silenziu:" docker-compose.prod.yml

echo ""
echo "🔧 7. Redémarrage propre de l'application"
echo "---------------------------------------"
echo "Arrêt de l'application..."
docker stop u-silenziu-app

echo "Suppression du conteneur..."
docker rm u-silenziu-app

echo "Reconstruction et redémarrage..."
docker compose -f docker-compose.prod.yml up -d --build u-silenziu

echo "Attente du redémarrage (60 secondes)..."
sleep 60

echo ""
echo "📊 8. Vérification post-redémarrage"
echo "---------------------------------"
echo "État des conteneurs :"
docker ps

echo ""
echo "Logs de l'application :"
docker logs u-silenziu-app --tail 20

echo ""
echo "Test final HTTPS :"
curl -I https://rageroom.usilenziu.com

echo ""
echo "🔍 9. Diagnostic des erreurs React spécifiques"
echo "---------------------------------------------"
echo "Vérification des erreurs dans les logs :"
docker logs u-silenziu-app | grep -i "react\|error\|exception" | tail -10

echo ""
echo "Test de l'API pour vérifier la connectivité base de données :"
curl -s https://rageroom.usilenziu.com/api/rooms | head -100

echo ""
echo "✅ Diagnostic terminé"
echo "===================="
echo "Si l'erreur React #31 persiste :"
echo "1. Vérifiez les logs ci-dessus pour des erreurs spécifiques"
echo "2. Le problème peut venir des props d'un composant (title, subtitle)"
echo "3. Vérifiez la configuration des variables d'environnement"
echo "4. Le problème peut être lié aux données de la base de données"
echo "5. Considérez un rollback vers une version stable si nécessaire"
