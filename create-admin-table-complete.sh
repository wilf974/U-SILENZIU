#!/bin/bash
# Script de création complète de la table admin_users
# U Silenziu - Septembre 2025

echo "🚀 CRÉATION COMPLÈTE TABLE ADMIN_USERS"
echo "======================================"
echo ""

# 1. Vérifier l'état de la base de données
echo "1. Vérification de l'état de la base de données..."
echo "Tables existantes :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
"

echo ""

# 2. Créer la table admin_users avec le bon schéma
echo "2. Création de la table admin_users..."
echo "Création du schéma complet..."

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
-- Extension pour UUIDs si pas encore fait
CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";

-- Table admin_users avec le bon schéma
CREATE TABLE IF NOT EXISTS admin_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'super-admin')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE
);

-- Créer un index sur le nom d'utilisateur
CREATE INDEX IF NOT EXISTS idx_admin_users_username ON admin_users(username);

-- Vérifier que la table a été créée
SELECT 'Table admin_users créée avec succès' as status;
"

echo ""

# 3. Insérer l'utilisateur administrateur
echo "3. Création de l'utilisateur administrateur..."
echo "Insertion de l'utilisateur administrateur..."

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
-- Insérer l'utilisateur administrateur
INSERT INTO admin_users (username, password_hash, role) 
VALUES ('administrateur', '@dm1n1str@t3uR!)', 'super-admin')
ON CONFLICT (username) DO UPDATE SET 
    password_hash = EXCLUDED.password_hash,
    role = EXCLUDED.role,
    updated_at = CURRENT_TIMESTAMP;

-- Vérifier l'insertion
SELECT id, username, role, created_at 
FROM admin_users 
WHERE username = 'administrateur';
"

echo ""

# 4. Vérifier la structure finale
echo "4. Vérification de la structure finale..."
echo "Structure de la table admin_users :"

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'admin_users' 
ORDER BY ordinal_position;
"

echo ""

# 5. Tester la contrainte de rôle
echo "5. Test de la contrainte de rôle..."
echo "Test des contraintes..."

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
-- Test insertion avec rôle valide
INSERT INTO admin_users (username, password_hash, role) 
VALUES ('test_admin', 'test123', 'admin')
ON CONFLICT (username) DO NOTHING;

-- Test insertion avec rôle invalide (doit échouer)
DO \$\$
BEGIN
    INSERT INTO admin_users (username, password_hash, role) 
    VALUES ('test_invalid', 'test123', 'invalid-role');
    RAISE NOTICE 'ERREUR: Contrainte de rôle non respectée';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE 'SUCCÈS: Contrainte de rôle fonctionne correctement';
END \$\$;

-- Nettoyer le test
DELETE FROM admin_users WHERE username = 'test_admin';
"

echo ""

# 6. Redémarrer l'application
echo "6. Redémarrage de l'application..."
echo "Redémarrage du conteneur application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

echo "Attente du démarrage (20 secondes)..."
sleep 20

echo ""

# 7. Test de l'API admin
echo "7. Test de l'API admin login..."
echo "Test de l'API admin login..."

# Test de récupération depuis la base
echo "Test de récupération utilisateur depuis la base :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
    id, 
    username, 
    role, 
    created_at
FROM admin_users 
WHERE username = 'administrateur';
"

echo ""

# Test de l'API HTTP
echo "Test de l'API HTTP admin login :"
curl -s -X POST "https://rageroom.usilenziu.com/api/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"administrateur","password":"@dm1n1str@t3uR!)"}' \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 500

echo ""

# 8. Test de l'API status
echo "8. Test de l'API status..."
echo "Test de l'API status :"
curl -s "https://rageroom.usilenziu.com/api/admin/auth/status" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 200

echo ""

echo "🎯 RÉSUMÉ DE LA CRÉATION"
echo "========================"
echo "✅ Table admin_users créée avec le bon schéma"
echo "✅ Contrainte de rôle configurée correctement"
echo "✅ Utilisateur administrateur créé"
echo "✅ Application redémarrée"
echo "✅ Tests API effectués"
echo ""
echo "🔗 Testez maintenant : https://rageroom.usilenziu.com/admin/login"
echo "Identifiants : administrateur / @dm1n1str@t3uR!)"
echo ""
echo "✅ CRÉATION TERMINÉE !"
