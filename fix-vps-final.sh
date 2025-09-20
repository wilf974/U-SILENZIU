#!/bin/bash
# Script de correction finale pour que le VPS ressemble au local
# U Silenziu - Septembre 2025

echo "🔧 CORRECTION FINALE VPS"
echo "======================="
echo ""

# 1. Récupérer les dernières corrections
echo "1. Récupération des dernières corrections..."
git pull origin main

echo ""

# 2. Vérifier et ajouter les données des salles
echo "2. Vérification des données des salles..."
chmod +x check-rooms-data.sh
./check-rooms-data.sh

echo ""

# 3. Arrêter l'application
echo "3. Arrêt de l'application..."
docker compose -f docker-compose.prod.yml down

echo ""

# 4. Nettoyer les images Docker
echo "4. Nettoyage des images Docker..."
docker system prune -f
docker image rm u-silenziu-u-silenziu || true

echo ""

# 5. Rebuild complet
echo "5. Rebuild complet de l'application..."
docker compose -f docker-compose.prod.yml build --no-cache u-silenziu

echo ""

# 6. Redémarrer l'application
echo "6. Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml up -d

echo "Attente du démarrage (30 secondes)..."
sleep 30

echo ""

# 7. Vérifier les composants dans le conteneur
echo "7. Vérification des composants..."
docker exec u-silenziu-app ls -la /app/components/ | grep -E "(Salles|Rooms)" || echo "Composants non trouvés"

echo ""

# 8. Vérifier les salles dans la base
echo "8. Vérification des salles dans la base..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT name, description, price, is_active 
FROM rooms 
WHERE is_active = true 
ORDER BY created_at;
"

echo ""

# 9. Test de l'API
echo "9. Test de l'API rooms..."
curl -s "https://rageroom.usilenziu.com/api/rooms" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 500

echo ""

# 10. Vérifier les logs
echo "10. Vérification des logs..."
docker compose -f docker-compose.prod.yml logs --tail=5 u-silenziu

echo ""

echo "✅ CORRECTION FINALE TERMINÉE !"
echo ""
echo "🔗 Vérifiez maintenant :"
echo "- Site: https://rageroom.usilenziu.com"
echo "- Le site devrait maintenant ressembler au local (2 salles, pas de debug)"
