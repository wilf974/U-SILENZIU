#!/bin/bash

# Script pour corriger les colonnes de la table reservations
# Ajoute les colonnes manquantes

echo "🔧 Correction des colonnes de la table reservations..."

# Obtenir l'ID du container PostgreSQL
PG_CONTAINER=$(docker compose -f docker-compose.prod.yml ps -q postgres)

if [ -z "$PG_CONTAINER" ]; then
    echo "❌ Erreur: Container PostgreSQL non trouvé"
    exit 1
fi

echo "✅ Container PostgreSQL trouvé: $PG_CONTAINER"

# Vérifier la structure actuelle
echo "🔍 Structure actuelle de la table reservations:"
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
\d reservations
EOF

# Ajouter les colonnes manquantes si elles n'existent pas
echo "➕ Ajout des colonnes manquantes..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
-- Ajouter room_name si elle n'existe pas
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='reservations' AND column_name='room_name') THEN
        ALTER TABLE reservations ADD COLUMN room_name VARCHAR(255) NOT NULL DEFAULT 'Salle Douce';
        ALTER TABLE reservations ALTER COLUMN room_name DROP DEFAULT;
    END IF;
END $$;

-- Ajouter time si elle n'existe pas
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='reservations' AND column_name='time') THEN
        ALTER TABLE reservations ADD COLUMN time VARCHAR(20) NOT NULL DEFAULT '14:00';
        ALTER TABLE reservations ALTER COLUMN time DROP DEFAULT;
    END IF;
END $$;

-- Ajouter duration si elle n'existe pas
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='reservations' AND column_name='duration') THEN
        ALTER TABLE reservations ADD COLUMN duration INTEGER NOT NULL DEFAULT 30;
        ALTER TABLE reservations ALTER COLUMN duration DROP DEFAULT;
    END IF;
END $$;

-- Ajouter number_of_people si elle n'existe pas
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='reservations' AND column_name='number_of_people') THEN
        ALTER TABLE reservations ADD COLUMN number_of_people INTEGER NOT NULL DEFAULT 1;
        ALTER TABLE reservations ALTER COLUMN number_of_people DROP DEFAULT;
    END IF;
END $$;

-- Ajouter status si elle n'existe pas
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='reservations' AND column_name='status') THEN
        ALTER TABLE reservations ADD COLUMN status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled'));
    END IF;
END $$;

-- Ajouter amount si elle n'existe pas
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='reservations' AND column_name='amount') THEN
        ALTER TABLE reservations ADD COLUMN amount DECIMAL(10,2) NOT NULL DEFAULT 0;
        ALTER TABLE reservations ALTER COLUMN amount DROP DEFAULT;
    END IF;
END $$;

-- Ajouter notes si elle n'existe pas
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='reservations' AND column_name='notes') THEN
        ALTER TABLE reservations ADD COLUMN notes TEXT;
    END IF;
END $$;
EOF

# Vérifier la nouvelle structure
echo "✅ Nouvelle structure de la table reservations:"
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
\d reservations

-- Afficher les colonnes dans l'ordre
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'reservations' 
ORDER BY ordinal_position;
EOF

echo ""
echo "✅ Colonnes de la table reservations corrigées !"
echo ""
echo "📋 La table est maintenant compatible avec l'API de réservations."
