#!/bin/bash

# Script pour créer/corriger la table reservations
# Corrige les erreurs de réservation

echo "🔧 Création/correction de la table reservations..."

# Obtenir l'ID du container PostgreSQL
PG_CONTAINER=$(docker compose -f docker-compose.prod.yml ps -q postgres)

if [ -z "$PG_CONTAINER" ]; then
    echo "❌ Erreur: Container PostgreSQL non trouvé"
    exit 1
fi

echo "✅ Container PostgreSQL trouvé: $PG_CONTAINER"

# Créer la table reservations si elle n'existe pas
echo "📅 Création de la table reservations..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
CREATE TABLE IF NOT EXISTS reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_number VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    room_name VARCHAR(255) NOT NULL,
    date DATE NOT NULL,
    time VARCHAR(10) NOT NULL,
    duration INTEGER NOT NULL DEFAULT 30,
    number_of_people INTEGER NOT NULL DEFAULT 1,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled')),
    amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Créer des index pour les performances
CREATE INDEX IF NOT EXISTS idx_reservations_date ON reservations(date);
CREATE INDEX IF NOT EXISTS idx_reservations_status ON reservations(status);
CREATE INDEX IF NOT EXISTS idx_reservations_room_name ON reservations(room_name);
CREATE INDEX IF NOT EXISTS idx_reservations_number ON reservations(reservation_number);

-- Vérifier la structure de la table
\d reservations
EOF

# Vérifier que la table existe et afficher quelques infos
echo "✅ Vérification de la table reservations..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
-- Compter les réservations existantes
SELECT COUNT(*) as total_reservations FROM reservations;

-- Vérifier les colonnes
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'reservations' 
ORDER BY ordinal_position;
EOF

echo ""
echo "✅ Table reservations créée/vérifiée avec succès !"
echo ""
echo "📋 La table est maintenant prête pour les réservations."
