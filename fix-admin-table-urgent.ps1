# Script de correction urgente table admin_users
# U Silenziu - Septembre 2025

Write-Host "🚨 CORRECTION URGENTE TABLE ADMIN_USERS" -ForegroundColor Red
Write-Host "=======================================" -ForegroundColor Red
Write-Host ""

# 1. Vérifier l'état actuel de la table
Write-Host "1. Vérification de l'état actuel de la table admin_users..." -ForegroundColor Yellow

$checkTableQuery = @"
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'admin_users' 
ORDER BY ordinal_position;
"@

Write-Host "Structure actuelle de la table admin_users :" -ForegroundColor Cyan
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "$checkTableQuery"

Write-Host ""

# 2. Vérifier les utilisateurs existants
Write-Host "2. Vérification des utilisateurs existants..." -ForegroundColor Yellow

$checkUsersQuery = @"
SELECT id, username, role, created_at 
FROM admin_users;
"@

Write-Host "Utilisateurs existants :" -ForegroundColor Cyan
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "$checkUsersQuery"

Write-Host ""

# 3. Corriger le schéma de la table
Write-Host "3. Correction du schéma de la table admin_users..." -ForegroundColor Yellow

$fixSchemaQuery = @"
-- Supprimer la contrainte existante si elle existe
ALTER TABLE admin_users DROP CONSTRAINT IF EXISTS admin_users_role_check;

-- Ajouter la nouvelle contrainte avec les bonnes valeurs
ALTER TABLE admin_users ADD CONSTRAINT admin_users_role_check 
CHECK (role IN ('admin', 'super-admin'));

-- Mettre à jour les rôles existants
UPDATE admin_users SET role = 'super-admin' WHERE role = 'super_admin';

-- Vérifier que la contrainte fonctionne
SELECT role, COUNT(*) FROM admin_users GROUP BY role;
"@

Write-Host "Application des corrections de schéma..." -ForegroundColor Cyan
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "$fixSchemaQuery"

Write-Host ""

# 4. Créer l'utilisateur administrateur s'il n'existe pas
Write-Host "4. Création de l'utilisateur administrateur..." -ForegroundColor Yellow

$createAdminQuery = @"
-- Vérifier si l'utilisateur existe
DO $$
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
END $$;
"@

Write-Host "Création de l'utilisateur administrateur..." -ForegroundColor Cyan
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "$createAdminQuery"

Write-Host ""

# 5. Vérifier la correction
Write-Host "5. Vérification de la correction..." -ForegroundColor Yellow

$verifyQuery = @"
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
"@

Write-Host "Vérification finale :" -ForegroundColor Cyan
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "$verifyQuery"

Write-Host ""

# 6. Redémarrer l'application
Write-Host "6. Redémarrage de l'application..." -ForegroundColor Yellow

Write-Host "Redémarrage du conteneur application..." -ForegroundColor Cyan
docker compose -f docker-compose.prod.yml restart u-silenziu

Write-Host "Attente du démarrage (15 secondes)..." -ForegroundColor Cyan
Start-Sleep -Seconds 15

Write-Host ""

# 7. Test de l'API admin
Write-Host "7. Test de l'API admin login..." -ForegroundColor Yellow

$testApiQuery = @"
-- Test de récupération de l'utilisateur
SELECT 
    id, 
    username, 
    role, 
    password_hash,
    created_at
FROM admin_users 
WHERE username = 'administrateur';
"@

Write-Host "Test de récupération utilisateur :" -ForegroundColor Cyan
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "$testApiQuery"

Write-Host ""

# 8. Test de l'API HTTP
Write-Host "8. Test de l'API HTTP admin login..." -ForegroundColor Yellow

$testBody = @{
    username = "administrateur"
    password = "@dm1n1str@t3uR!)"
} | ConvertTo-Json

Write-Host "Test de l'API admin login..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "https://rageroom.usilenziu.com/api/admin/auth/login" -Method POST -Body $testBody -ContentType "application/json" -TimeoutSec 30
    Write-Host "✅ API admin login fonctionne :" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 3)
} catch {
    Write-Host "❌ Erreur API admin login :" -ForegroundColor Red
    Write-Host $_.Exception.Message
    Write-Host "Status Code: $($_.Exception.Response.StatusCode)"
}

Write-Host ""

Write-Host "🎯 RÉSUMÉ DE LA CORRECTION" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green
Write-Host "✅ Schéma admin_users corrigé" -ForegroundColor White
Write-Host "✅ Contrainte de rôle mise à jour" -ForegroundColor White
Write-Host "✅ Utilisateur administrateur créé/vérifié" -ForegroundColor White
Write-Host "✅ Application redémarrée" -ForegroundColor White
Write-Host ""
Write-Host "🔗 Testez maintenant : https://rageroom.usilenziu.com/admin/login" -ForegroundColor Cyan
Write-Host "Identifiants : administrateur / @dm1n1str@t3uR!)" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ CORRECTION TERMINÉE !" -ForegroundColor Green
