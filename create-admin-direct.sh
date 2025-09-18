#!/bin/bash

# Script pour créer directement l'utilisateur admin via l'API de l'application
# Utilise l'API interne pour hasher correctement le mot de passe

echo "🔧 Création de l'utilisateur administrateur via l'application..."

# Obtenir l'ID du container PostgreSQL
PG_CONTAINER=$(docker compose -f docker-compose.prod.yml ps -q postgres)

if [ -z "$PG_CONTAINER" ]; then
    echo "❌ Erreur: Container PostgreSQL non trouvé"
    exit 1
fi

echo "✅ Container PostgreSQL trouvé: $PG_CONTAINER"

# Supprimer les anciens utilisateurs admin
echo "🗑️ Suppression des anciens utilisateurs admin..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
DELETE FROM admin_users WHERE username IN ('admin', 'administrateur');
EOF

# Créer l'utilisateur admin en utilisant directement bcrypt dans PostgreSQL
# Nous allons utiliser l'extension pgcrypto pour hasher le mot de passe
echo "👤 Création de l'utilisateur administrateur avec hash bcrypt..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
-- Insérer l'utilisateur avec un hash bcrypt généré par PostgreSQL
INSERT INTO admin_users (username, password_hash, role) VALUES 
('administrateur', crypt('MotDePasse123!', gen_salt('bf')), 'super-admin');
EOF

# Vérifier que l'utilisateur a été créé
echo "✅ Vérification de la création..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
SELECT username, role, created_at, length(password_hash) as hash_length FROM admin_users WHERE username = 'administrateur';
EOF

# Redémarrer l'application pour s'assurer que tout est bien pris en compte
echo "🔄 Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

echo "⏳ Attente du redémarrage (5 secondes)..."
sleep 5

echo ""
echo "✅ Utilisateur administrateur créé avec succès !"
echo ""
echo "🔐 Informations de connexion:"
echo "   👤 Utilisateur: administrateur"
echo "   🔑 Mot de passe: MotDePasse123!"
echo ""
echo "🌐 URL Admin: http://72.60.90.156:3000/admin"
echo ""
echo "📋 Si le login ne fonctionne toujours pas, vérifiez les logs:"
echo "   docker compose -f docker-compose.prod.yml logs --tail=20 u-silenziu"
