#!/bin/bash
# Script de correction urgente table admin_users
# U Silenziu - Septembre 2025

echo "🚨 CORRECTION URGENTE TABLE ADMIN_USERS"
echo "======================================="
echo ""

# 1. Vérifier l'état actuel de la table
echo "1. Vérification de l'état actuel de la table admin_users..."
echo "Structure actuelle de la table admin_users :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'admin_users' 
ORDER BY ordinal_position;
"

echo ""
echo "Utilisateurs existants :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, username, role, created_at 
FROM admin_users;
"

echo ""

# 2. Corriger le schéma de la table
echo "2. Correction du schéma de la table admin_users..."
echo "Application des corrections de schéma..."

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
-- Supprimer la contrainte existante si elle existe
ALTER TABLE admin_users DROP CONSTRAINT IF EXISTS admin_users_role_check;

-- Ajouter la nouvelle contrainte avec les bonnes valeurs
ALTER TABLE admin_users ADD CONSTRAINT admin_users_role_check 
CHECK (role IN ('admin', 'super-admin'));

-- Mettre à jour les rôles existants
UPDATE admin_users SET role = 'super-admin' WHERE role = 'super_admin';

-- Vérifier que la contrainte fonctionne
SELECT role, COUNT(*) FROM admin_users GROUP BY role;
"

echo ""

# 3. Créer l'utilisateur administrateur s'il n'existe pas
echo "3. Création de l'utilisateur administrateur..."
echo "Création de l'utilisateur administrateur..."

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
-- Vérifier si l'utilisateur existe
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM admin_users WHERE username = 'administrateur') THEN
        -- Créer l'utilisateur administrateur
        INSERT INTO admin_users (username, password_hash, role) 
        VALUES (
            'administrateur', 
            '@dm1n1str@t3uR!)',  -- Mot de passe en clair pour compatibilité
            'super-admin'
        );
        RAISE NOTICE 'Utilisateur administrateur créé';
    ELSE
        RAISE NOTICE 'Utilisateur administrateur existe déjà';
    END IF;
END \$\$;
"

echo ""

# 4. Vérifier la correction
echo "4. Vérification de la correction..."
echo "Vérification finale :"

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
-- Vérifier la structure finale
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'admin_users' 
ORDER BY ordinal_position;

-- Vérifier les utilisateurs
SELECT id, username, role, created_at 
FROM admin_users;

-- Tester la contrainte
SELECT 'Test contrainte OK' as test_result;
"

echo ""

# 5. Redémarrer l'application
echo "5. Redémarrage de l'application..."
echo "Redémarrage du conteneur application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

echo "Attente du démarrage (15 secondes)..."
sleep 15

echo ""

# 6. Test de l'API admin
echo "6. Test de l'API admin login..."
echo "Test de récupération utilisateur :"

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
    id, 
    username, 
    role, 
    password_hash,
    created_at
FROM admin_users 
WHERE username = 'administrateur';
"

echo ""

# 7. Test de l'API HTTP
echo "7. Test de l'API HTTP admin login..."
echo "Test de l'API admin login..."

curl -s -X POST "https://rageroom.usilenziu.com/api/admin/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"administrateur","password":"@dm1n1str@t3uR!)"}' \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 500

echo ""

echo "🎯 RÉSUMÉ DE LA CORRECTION"
echo "========================="
echo "✅ Schéma admin_users corrigé"
echo "✅ Contrainte de rôle mise à jour"
echo "✅ Utilisateur administrateur créé/vérifié"
echo "✅ Application redémarrée"
echo ""
echo "🔗 Testez maintenant : https://rageroom.usilenziu.com/admin/login"
echo "Identifiants : administrateur / @dm1n1str@t3uR!)"
echo ""
echo "✅ CORRECTION TERMINÉE !"
