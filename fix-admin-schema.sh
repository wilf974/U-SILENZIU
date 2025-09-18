#!/bin/bash

# Script pour corriger le schéma de la table admin_users et créer l'utilisateur admin correct
# Résout les problèmes de types de données et de hashage de mot de passe

echo "🔧 Correction du schéma admin_users et création de l'utilisateur..."

# Obtenir l'ID du container PostgreSQL
PG_CONTAINER=$(docker compose -f docker-compose.prod.yml ps -q postgres)

if [ -z "$PG_CONTAINER" ]; then
    echo "❌ Erreur: Container PostgreSQL non trouvé"
    exit 1
fi

echo "✅ Container PostgreSQL trouvé: $PG_CONTAINER"

# Supprimer et recréer la table admin_users avec le bon schéma
echo "🗑️ Suppression de l'ancienne table admin_users..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
DROP TABLE IF EXISTS admin_users CASCADE;
EOF

# Créer la nouvelle table avec UUID et le bon schéma
echo "🏗️ Création de la nouvelle table admin_users..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
CREATE TABLE admin_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'super-admin')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE
);

-- Créer un index sur le nom d'utilisateur pour les performances
CREATE INDEX idx_admin_users_username ON admin_users(username);
EOF

# Créer l'utilisateur administrateur avec un hash bcrypt correct
echo "👤 Création de l'utilisateur administrateur avec hash bcrypt..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
-- Insérer l'utilisateur avec un hash bcrypt généré par PostgreSQL
-- Mot de passe: MotDePasse123!
INSERT INTO admin_users (username, password_hash, role) VALUES 
('administrateur', crypt('MotDePasse123!', gen_salt('bf')), 'super-admin');
EOF

# Vérifier que l'utilisateur a été créé avec les bons types
echo "✅ Vérification de la création..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
SELECT 
    id, 
    username, 
    role, 
    created_at, 
    length(password_hash) as hash_length,
    substr(password_hash, 1, 10) as hash_preview
FROM admin_users 
WHERE username = 'administrateur';

-- Vérifier le type de la colonne id
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'admin_users' 
AND column_name = 'id';
EOF

# Redémarrer l'application pour s'assurer que tout est bien pris en compte
echo "🔄 Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

echo "⏳ Attente du redémarrage (8 secondes)..."
sleep 8

echo ""
echo "✅ Schéma admin_users corrigé et utilisateur créé !"
echo ""
echo "🔐 Informations de connexion:"
echo "   👤 Utilisateur: administrateur"
echo "   🔑 Mot de passe: MotDePasse123!"
echo ""
echo "🌐 URL Admin: http://72.60.90.156:3000/admin"
echo ""
echo "📋 En cas de problème, vérifiez les logs:"
echo "   docker compose -f docker-compose.prod.yml logs --tail=30 u-silenziu"
