#!/bin/bash

# Script pour corriger le login administrateur
# Crée un utilisateur admin avec un mot de passe correctement hashé

echo "🔧 Correction du login administrateur..."

# Obtenir l'ID du container PostgreSQL
PG_CONTAINER=$(docker compose -f docker-compose.prod.yml ps -q postgres)

if [ -z "$PG_CONTAINER" ]; then
    echo "❌ Erreur: Container PostgreSQL non trouvé"
    exit 1
fi

echo "✅ Container PostgreSQL trouvé: $PG_CONTAINER"

# Supprimer les anciens utilisateurs admin et recréer avec le bon hash
echo "🗑️ Suppression des anciens utilisateurs admin..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
DELETE FROM admin_users WHERE username IN ('admin', 'administrateur');
EOF

# Créer l'utilisateur admin avec le mot de passe hashé correct
# Le mot de passe sera: MotDePasse123!
# Hash généré avec bcrypt pour ce mot de passe
echo "👤 Création de l'utilisateur administrateur..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
INSERT INTO admin_users (username, password_hash, role) VALUES 
('administrateur', '$2a$10$K3VYPZJk7VbX8ZHYdX9wuOQX2yGp9TzZVQyGKH5.YKjcXRvqGxJ2C', 'super-admin');
EOF

# Vérifier que l'utilisateur a été créé
echo "✅ Vérification de la création..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
SELECT username, role, created_at FROM admin_users WHERE username = 'administrateur';
EOF

echo ""
echo "✅ Utilisateur administrateur corrigé !"
echo ""
echo "🔐 Informations de connexion:"
echo "   👤 Utilisateur: administrateur"
echo "   🔑 Mot de passe: MotDePasse123!"
echo ""
echo "🌐 URL Admin: http://72.60.90.156:3000/admin"
