#!/bin/bash
# Script de déploiement complet pour corriger l'affichage des salles
# U Silenziu - Septembre 2025

echo "🚀 DÉPLOIEMENT CORRECTION SALLES"
echo "================================"
echo ""

# 1. Récupérer les dernières modifications
echo "1. Récupération des dernières modifications..."
git pull origin main
echo ""

# 2. Arrêter l'application
echo "2. Arrêt de l'application..."
docker compose -f docker-compose.prod.yml down
echo ""

# 3. Nettoyer les images Docker
echo "3. Nettoyage des images Docker..."
docker image prune -f
docker rmi u-silenziu-u-silenziu:latest || true
echo ""

# 4. Rebuild complet sans cache
echo "4. Rebuild complet de l'application (cela peut prendre du temps)..."
docker compose -f docker-compose.prod.yml build --no-cache u-silenziu
echo ""

# 5. Redémarrer l'application
echo "5. Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml up -d
echo ""

# 6. Attendre le démarrage
echo "6. Attente du démarrage (30 secondes)..."
sleep 30
echo ""

# 7. Vérifier que les salles sont bien désactivées
echo "7. Vérification des salles dans la base de données..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT name, is_active, created_at 
FROM rooms 
ORDER BY created_at;
"

echo ""

# 8. Test de l'API rooms
echo "8. Test de l'API /api/rooms..."
curl -s "https://rageroom.usilenziu.com/api/rooms" | head -c 200
echo ""

# 9. Vérification des logs
echo "9. Logs récents de l'application..."
docker compose -f docker-compose.prod.yml logs --tail=10 u-silenziu
echo ""

echo "✅ DÉPLOIEMENT TERMINÉ !"
echo ""
echo "🔗 Vérifiez maintenant :"
echo "- Site: https://rageroom.usilenziu.com"
echo "- Les salles désactivées ne doivent plus s'afficher"
echo "- Plus de panneau debug visible"
echo "- Actualisation automatique toutes les 30 secondes"
