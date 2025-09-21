#!/bin/bash

echo "=== FORCE REBUILD COMPLETE ==="
echo ""

# 1. Arrêter tous les conteneurs
echo "1. 🛑 ARRÊT CONTENEURS :"
echo "========================"
docker compose -f docker-compose.prod.yml down

# 2. Nettoyer complètement Docker
echo ""
echo "2. 🧹 NETTOYAGE DOCKER :"
echo "========================"
docker system prune -a -f
docker volume prune -f

# 3. Supprimer les images spécifiques
echo ""
echo "3. 🗑️ SUPPRESSION IMAGES :"
echo "=========================="
docker rmi $(docker images -q) 2>/dev/null || echo "Aucune image à supprimer"

# 4. Rebuild complet sans cache
echo ""
echo "4. 🔨 REBUILD SANS CACHE :"
echo "=========================="
docker compose -f docker-compose.prod.yml build --no-cache

# 5. Démarrer l'application
echo ""
echo "5. 🚀 DÉMARRAGE APPLICATION :"
echo "============================="
docker compose -f docker-compose.prod.yml up -d

# 6. Attendre la stabilisation
echo ""
echo "6. ⏳ ATTENTE STABILISATION :"
echo "============================="
sleep 10

# 7. Vérifier les logs
echo ""
echo "7. 🔍 VÉRIFICATION LOGS :"
echo "========================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=20

echo ""
echo "=== REBUILD TERMINÉ ==="
