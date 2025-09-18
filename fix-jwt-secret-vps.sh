#!/bin/bash
# Script pour corriger le JWT_SECRET manquant

echo "🔐 Correction de la variable JWT_SECRET..."

# Vérifier si ADMIN_JWT_SECRET est dans docker-compose.prod.yml
if grep -q "ADMIN_JWT_SECRET" docker-compose.prod.yml; then
    echo "✅ ADMIN_JWT_SECRET trouvé dans docker-compose.prod.yml"
else
    echo "❌ ADMIN_JWT_SECRET manquant, ajout en cours..."
    
    # Créer une sauvegarde
    cp docker-compose.prod.yml docker-compose.prod.yml.backup
    
    # Ajouter ADMIN_JWT_SECRET à la section environment
    sed -i '/- DATABASE_URL=/a\      - ADMIN_JWT_SECRET=super_secret_admin_jwt_key_2024_usilenzio_very_long_and_secure' docker-compose.prod.yml
fi

echo "🔍 Variables d'environnement actuelles dans docker-compose.prod.yml :"
grep -A 15 "environment:" docker-compose.prod.yml

echo ""
echo "🚀 Redémarrage des conteneurs..."
docker compose -f docker-compose.prod.yml up -d --build

echo ""
echo "📊 Vérification du statut..."
docker compose -f docker-compose.prod.yml ps

echo ""
echo "🔍 Test des logs (attendre 10 secondes)..."
sleep 10
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=20
