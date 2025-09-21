#!/bin/bash

echo "🔍 DIAGNOSTIC ERREUR 502 BAD GATEWAY - U SILENZIU"
echo "================================================="

# 1. État des conteneurs Docker
echo ""
echo "📋 1. ÉTAT DES CONTENEURS DOCKER"
echo "================================"
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 2. Vérification du statut de santé
echo ""
echo "🏥 2. VÉRIFICATION DU STATUT DE SANTÉ"
echo "===================================="
APP_STATUS=$(docker inspect --format '{{.State.Health.Status}}' "u-silenziu-app" 2>/dev/null || echo "unknown")
echo "Statut de santé de u-silenziu-app : $APP_STATUS"

if [ "$APP_STATUS" != "healthy" ] && [ "$APP_STATUS" != "unknown" ]; then
    echo ""
    echo "⚠️  Conteneur en mauvais état, analyse du healthcheck :"
    docker inspect --format '{{json .State.Health}}' "u-silenziu-app" 2>/dev/null | jq . || echo "Impossible de récupérer les détails du healthcheck"
fi

# 3. Logs de l'application
echo ""
echo "📄 3. LOGS DE L'APPLICATION (DERNIÈRES 50 LIGNES)"
echo "================================================="
docker logs "u-silenziu-app" --tail 50 || echo "Impossible de lire les logs"

# 4. Logs de Nginx
echo ""
echo "🌐 4. LOGS DE NGINX (DERNIÈRES 20 LIGNES)"
echo "========================================="
docker logs "u-silenziu-nginx-prod" --tail 20 || echo "Impossible de lire les logs Nginx"

# 5. Test de connectivité interne
echo ""
echo "🔍 5. TEST DE CONNECTIVITÉ INTERNE"
echo "================================="
echo "Test de l'application en interne :"
docker exec "u-silenziu-app" curl -sS http://localhost:3000/ | head -10 || echo "Application non accessible en interne"

echo ""
echo "Test de l'endpoint de santé :"
docker exec "u-silenziu-app" curl -sS http://localhost:3000/health || echo "Endpoint de santé indisponible"

# 6. Vérification des ports
echo ""
echo "🔌 6. VÉRIFICATION DES PORTS"
echo "==========================="
echo "Ports en écoute sur le système :"
netstat -tlnp | grep -E ":(80|443|3000)" || echo "Aucun port pertinent trouvé"

echo ""
echo "Ports dans le conteneur Next.js :"
docker exec "u-silenziu-app" netstat -tlnp 2>/dev/null | grep ":3000" || echo "Port 3000 non trouvé dans le conteneur"

# 7. Vérification de la configuration Nginx
echo ""
echo "⚙️ 7. VÉRIFICATION DE LA CONFIGURATION NGINX"
echo "==========================================="
echo "Configuration Nginx actuelle :"
docker exec "u-silenziu-nginx-prod" cat /etc/nginx/conf.d/default.conf || echo "Configuration Nginx non accessible"

# 8. Test de résolution DNS interne
echo ""
echo "🌐 8. TEST DE RÉSOLUTION DNS INTERNE"
echo "==================================="
echo "Résolution de u-silenziu-app depuis Nginx :"
docker exec "u-silenziu-nginx-prod" nslookup u-silenziu-app || echo "Résolution DNS échouée"

# 9. Vérification des réseaux Docker
echo ""
echo "🔗 9. VÉRIFICATION DES RÉSEAUX DOCKER"
echo "===================================="
echo "Réseaux Docker :"
docker network ls

echo ""
echo "Conteneurs sur le réseau u-silenziu-prod-network :"
docker network inspect u-silenziu-prod-network 2>/dev/null | jq '.[0].Containers' || echo "Réseau non trouvé ou problème d'inspection"

# 10. Test de connectivité directe
echo ""
echo "🔍 10. TEST DE CONNECTIVITÉ DIRECTE"
echo "=================================="
echo "Test direct vers l'IP du conteneur Next.js :"
APP_IP=$(docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "u-silenziu-app" 2>/dev/null)
if [ -n "$APP_IP" ]; then
    echo "IP du conteneur Next.js : $APP_IP"
    curl -sS --connect-timeout 5 "http://$APP_IP:3000/" | head -5 || echo "Connexion directe échouée"
else
    echo "Impossible de récupérer l'IP du conteneur"
fi

echo ""
echo "✅ DIAGNOSTIC TERMINÉ"
echo "===================="
echo "Vérifiez les résultats ci-dessus pour identifier la cause de l'erreur 502."
