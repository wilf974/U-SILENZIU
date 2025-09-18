#!/bin/bash
# Script pour corriger le mot de passe admin sur le VPS

echo "🔧 Correction du mot de passe administrateur..."

# Récupérer l'ID du conteneur PostgreSQL
PG_CONTAINER=$(docker compose -f docker-compose.prod.yml ps -q postgres)

if [ -z "$PG_CONTAINER" ]; then
    echo "❌ Conteneur PostgreSQL introuvable"
    exit 1
fi

echo "📊 Conteneur PostgreSQL: $PG_CONTAINER"

# Supprimer l'ancien utilisateur et en créer un nouveau avec le bon mot de passe
echo "🗑️  Suppression de l'ancien utilisateur..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
DELETE FROM admin_users WHERE username = 'administrateur';
EOF

echo "👤 Création du nouvel utilisateur avec le mot de passe @dm1n!str@t3uR!..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
INSERT INTO admin_users (id, username, password_hash, role, is_active, created_at, updated_at)
VALUES (
    gen_random_uuid(),
    'administrateur',
    crypt('@dm1n!str@t3uR!', gen_salt('bf', 12)),
    'super-admin',
    true,
    NOW(),
    NOW()
);
EOF

echo "✅ Vérification de l'utilisateur créé..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
SELECT username, role, is_active, created_at FROM admin_users WHERE username = 'administrateur';
EOF

echo "🔐 Test de connexion..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
SELECT 
    username,
    CASE 
        WHEN password_hash = crypt('@dm1n!str@t3uR!', password_hash) 
        THEN 'Mot de passe CORRECT' 
        ELSE 'Mot de passe INCORRECT' 
    END as test_password
FROM admin_users 
WHERE username = 'administrateur';
EOF

echo ""
echo "✅ Utilisateur administrateur reconfiguré !"
echo "📝 Identifiants :"
echo "   - Nom d'utilisateur: administrateur"
echo "   - Mot de passe: @dm1n!str@t3uR!"
echo ""
echo "🌐 Teste maintenant sur: https://rageroom.usilenziu.com/admin/login"
