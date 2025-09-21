#!/bin/bash

echo "🔧 CORRECTION RAPIDE ERREUR 502 BAD GATEWAY"
echo "==========================================="

# 1. Arrêter tous les conteneurs
echo ""
echo "🛑 1. ARRÊT DES CONTENEURS"
echo "========================="
docker stop u-silenziu-app u-silenziu-nginx-prod 2>/dev/null || echo "Certains conteneurs déjà arrêtés"

# 2. Nettoyer les conteneurs orphelins
echo ""
echo "🧹 2. NETTOYAGE DES CONTENEURS"
echo "============================="
docker rm u-silenziu-app u-silenziu-nginx-prod 2>/dev/null || echo "Conteneurs déjà supprimés"

# 3. Vérifier la configuration Docker Compose
echo ""
echo "📋 3. VÉRIFICATION DE LA CONFIGURATION"
echo "====================================="
if [ -f "docker-compose.prod.yml" ]; then
    echo "✅ docker-compose.prod.yml trouvé"
    echo "Vérification de la syntaxe :"
    docker compose -f docker-compose.prod.yml config > /dev/null && echo "✅ Syntaxe valide" || echo "❌ Erreur de syntaxe"
else
    echo "❌ docker-compose.prod.yml non trouvé"
    exit 1
fi

# 4. Redémarrer les services
echo ""
echo "🚀 4. REDÉMARRAGE DES SERVICES"
echo "============================="
echo "Démarrage avec Docker Compose..."
docker compose -f docker-compose.prod.yml up -d

# 5. Attendre que les services soient prêts
echo ""
echo "⏳ 5. ATTENTE DU DÉMARRAGE"
echo "========================="
echo "Attente de 30 secondes pour que les services démarrent..."
sleep 30

# 6. Vérifier le statut
echo ""
echo "📊 6. VÉRIFICATION DU STATUT"
echo "==========================="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 7. Test de connectivité
echo ""
echo "🔍 7. TEST DE CONNECTIVITÉ"
echo "========================="
echo "Test HTTPS :"
curl -LskI https://rageroom.usilenziu.com | head -5 || echo "❌ HTTPS non accessible"

echo ""
echo "Test HTTP (redirection) :"
curl -sI http://rageroom.usilenziu.com | head -5 || echo "❌ HTTP non accessible"

# 8. Vérification des logs en cas d'échec
echo ""
echo "📄 8. VÉRIFICATION DES LOGS"
echo "=========================="
echo "Logs de l'application (dernières 10 lignes) :"
docker logs u-silenziu-app --tail 10

echo ""
echo "Logs de Nginx (dernières 10 lignes) :"
docker logs u-silenziu-nginx-prod --tail 10

echo ""
echo "✅ CORRECTION TERMINÉE"
echo "====================="
echo "Si l'erreur 502 persiste, exécutez : ./diagnose-502-error.sh"
