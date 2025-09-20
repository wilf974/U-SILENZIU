#!/bin/bash
# Script de correction complète pour la production
# U Silenziu - Septembre 2025

echo "🔧 CORRECTION COMPLÈTE PRODUCTION"
echo "================================="
echo ""

# 1. Créer la table pages manquante
echo "1. Création de la table 'pages' manquante..."

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
CREATE TABLE IF NOT EXISTS pages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(255) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    meta_title VARCHAR(255),
    meta_description TEXT,
    is_published BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
"

echo ""

# 2. Vérifier toutes les tables
echo "2. Vérification des tables existantes..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
\dt
"

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

# 7. Vérifier les composants
echo "7. Vérification des composants dans le conteneur..."
docker exec u-silenziu-app ls -la /app/ | grep components || echo "Dossier components non trouvé"

echo ""

# 8. Vérifier les logs
echo "8. Vérification des logs..."
docker compose -f docker-compose.prod.yml logs --tail=10 u-silenziu

echo ""

# 9. Test de l'API
echo "9. Test de l'API rooms..."
curl -s "https://rageroom.usilenziu.com/api/rooms" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 300

echo ""

echo "✅ CORRECTION COMPLÈTE TERMINÉE !"
echo ""
echo "🔗 Vérifiez maintenant :"
echo "- Site: https://rageroom.usilenziu.com"
echo "- Les salles devraient maintenant s'afficher"
