#!/bin/bash

# Script pour corriger la taille de la colonne time_slot
# Agrandit VARCHAR(10) vers VARCHAR(20) pour les créneaux horaires

echo "🔧 Correction de la taille de la colonne time_slot..."

# Obtenir l'ID du container PostgreSQL
PG_CONTAINER=$(docker compose -f docker-compose.prod.yml ps -q postgres)

if [ -z "$PG_CONTAINER" ]; then
    echo "❌ Erreur: Container PostgreSQL non trouvé"
    exit 1
fi

echo "✅ Container PostgreSQL trouvé: $PG_CONTAINER"

# Vérifier la taille actuelle de la colonne
echo "🔍 Taille actuelle de la colonne time_slot:"
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
SELECT column_name, data_type, character_maximum_length 
FROM information_schema.columns 
WHERE table_name = 'reservations' 
AND column_name = 'time_slot';
EOF

# Agrandir la colonne time_slot
echo "📏 Agrandissement de la colonne time_slot à VARCHAR(20)..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
ALTER TABLE reservations ALTER COLUMN time_slot TYPE VARCHAR(20);
EOF

# Vérifier la nouvelle taille
echo "✅ Nouvelle taille de la colonne time_slot:"
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
SELECT column_name, data_type, character_maximum_length 
FROM information_schema.columns 
WHERE table_name = 'reservations' 
AND column_name = 'time_slot';
EOF

# Tester avec une valeur exemple
echo "🧪 Test d'insertion d'un créneau horaire..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
-- Test pour vérifier que '14:00 - 14:30' peut maintenant être inséré
SELECT LENGTH('14:00 - 14:30') as longueur_creneau;
EOF

echo ""
echo "✅ Colonne time_slot élargie avec succès !"
echo ""
echo "📋 Les créneaux horaires comme '14:00 - 14:30' peuvent maintenant être stockés."
