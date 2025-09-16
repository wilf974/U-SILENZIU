# Script de test pour l'authentification via base de données
# U Silenziu - Janvier 2025

Write-Host "Test d'Authentification via Base de Donnees" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$baseUrl = "http://localhost:3000"

# Fonction pour tester une API
function Test-API {
    param(
        [string]$method,
        [string]$url,
        [hashtable]$body = $null,
        [string]$description
    )
    
    Write-Host "Test: $description" -ForegroundColor Yellow
    
    try {
        $headers = @{
            'Content-Type' = 'application/json'
        }
        
        if ($body) {
            $jsonBody = $body | ConvertTo-Json
            $response = Invoke-RestMethod -Uri $url -Method $method -Body $jsonBody -Headers $headers
        } else {
            $response = Invoke-RestMethod -Uri $url -Method $method -Headers $headers
        }
        
        Write-Host "Succes: $description" -ForegroundColor Green
        return $response
    }
    catch {
        Write-Host "Erreur: $description - $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Étape 1: Test de connexion avec les identifiants par défaut
Write-Host "=== ETAPE 1: Test connexion avec identifiants par defaut ===" -ForegroundColor Magenta

# Test connexion super admin
$loginDataSuperAdmin = @{
    username = "administrateur"
    password = "@dm1n1str@t3uR!"
}

Write-Host "Test connexion Super Admin (administrateur / @dm1n1str@t3uR!)" -ForegroundColor Yellow
$loginResultSuperAdmin = Test-API -method "POST" -url "$baseUrl/api/admin/auth/login" -body $loginDataSuperAdmin -description "Connexion Super Admin"

if ($loginResultSuperAdmin -and $loginResultSuperAdmin.success) {
    Write-Host "Connexion Super Admin reussie!" -ForegroundColor Green
    Write-Host "  - Utilisateur: $($loginResultSuperAdmin.user.username)" -ForegroundColor White
    Write-Host "  - Role: $($loginResultSuperAdmin.user.role)" -ForegroundColor White
    Write-Host "  - Token: $($loginResultSuperAdmin.token)" -ForegroundColor White
} else {
    Write-Host "Echec connexion Super Admin" -ForegroundColor Red
    if ($loginResultSuperAdmin) {
        Write-Host "  Erreur: $($loginResultSuperAdmin.error)" -ForegroundColor Red
    }
}
Write-Host ""

# Test connexion admin standard
$loginDataAdmin = @{
    username = "admin"
    password = "admin123"
}

Write-Host "Test connexion Admin Standard (admin / admin123)" -ForegroundColor Yellow
$loginResultAdmin = Test-API -method "POST" -url "$baseUrl/api/admin/auth/login" -body $loginDataAdmin -description "Connexion Admin Standard"

if ($loginResultAdmin -and $loginResultAdmin.success) {
    Write-Host "Connexion Admin Standard reussie!" -ForegroundColor Green
    Write-Host "  - Utilisateur: $($loginResultAdmin.user.username)" -ForegroundColor White
    Write-Host "  - Role: $($loginResultAdmin.user.role)" -ForegroundColor White
    Write-Host "  - Token: $($loginResultAdmin.token)" -ForegroundColor White
} else {
    Write-Host "Echec connexion Admin Standard" -ForegroundColor Red
    if ($loginResultAdmin) {
        Write-Host "  Erreur: $($loginResultAdmin.error)" -ForegroundColor Red
    }
}
Write-Host ""

# Étape 2: Modifier le mot de passe de l'admin
Write-Host "=== ETAPE 2: Modification du mot de passe admin ===" -ForegroundColor Magenta

# Récupérer la liste des utilisateurs pour obtenir l'ID
$users = Test-API -method "GET" -url "$baseUrl/api/admin/users" -description "Récupération de la liste des utilisateurs"

if (-not $users -or -not $users.success) {
    Write-Host "Impossible de recuperer les utilisateurs. Arret du test." -ForegroundColor Red
    exit 1
}

$adminUser = $users.users | Where-Object { $_.username -eq "admin" }
if (-not $adminUser) {
    Write-Host "Utilisateur 'admin' non trouve. Arret du test." -ForegroundColor Red
    exit 1
}

$adminUserId = $adminUser.id
Write-Host "Utilisateur admin trouve (ID: $adminUserId)" -ForegroundColor Green

# Modifier le mot de passe
$newPassword = "nouveau-mot-de-passe-2025"
$updateData = @{
    username = "admin"
    password = $newPassword
    role = "admin"
}

Write-Host "Modification du mot de passe admin vers: $newPassword" -ForegroundColor Yellow
$updateResult = Test-API -method "PUT" -url "$baseUrl/api/admin/users/$adminUserId" -body $updateData -description "Modification du mot de passe admin"

if ($updateResult -and $updateResult.success) {
    Write-Host "Mot de passe modifie avec succes!" -ForegroundColor Green
} else {
    Write-Host "Echec de la modification du mot de passe" -ForegroundColor Red
    if ($updateResult) {
        Write-Host "  Erreur: $($updateResult.error)" -ForegroundColor Red
    }
}
Write-Host ""

# Étape 3: Tester la connexion avec l'ancien mot de passe (doit échouer)
Write-Host "=== ETAPE 3: Test connexion avec ancien mot de passe (doit echouer) ===" -ForegroundColor Magenta

$oldLoginData = @{
    username = "admin"
    password = "admin123"
}

Write-Host "Test connexion avec ancien mot de passe (admin / admin123)" -ForegroundColor Yellow
$oldLoginResult = Test-API -method "POST" -url "$baseUrl/api/admin/auth/login" -body $oldLoginData -description "Connexion avec ancien mot de passe"

if (-not $oldLoginResult -or -not $oldLoginResult.success) {
    Write-Host "SUCCES: L'ancien mot de passe est bien rejete!" -ForegroundColor Green
    Write-Host "  Erreur attendue: $($oldLoginResult.error)" -ForegroundColor White
} else {
    Write-Host "ECHEC: L'ancien mot de passe fonctionne encore!" -ForegroundColor Red
}
Write-Host ""

# Étape 4: Tester la connexion avec le nouveau mot de passe (doit réussir)
Write-Host "=== ETAPE 4: Test connexion avec nouveau mot de passe (doit reussir) ===" -ForegroundColor Magenta

$newLoginData = @{
    username = "admin"
    password = $newPassword
}

Write-Host "Test connexion avec nouveau mot de passe (admin / $newPassword)" -ForegroundColor Yellow
$newLoginResult = Test-API -method "POST" -url "$baseUrl/api/admin/auth/login" -body $newLoginData -description "Connexion avec nouveau mot de passe"

if ($newLoginResult -and $newLoginResult.success) {
    Write-Host "SUCCES: Le nouveau mot de passe fonctionne!" -ForegroundColor Green
    Write-Host "  - Utilisateur: $($newLoginResult.user.username)" -ForegroundColor White
    Write-Host "  - Role: $($newLoginResult.user.role)" -ForegroundColor White
} else {
    Write-Host "ECHEC: Le nouveau mot de passe ne fonctionne pas!" -ForegroundColor Red
    if ($newLoginResult) {
        Write-Host "  Erreur: $($newLoginResult.error)" -ForegroundColor Red
    }
}
Write-Host ""

# Résumé final
Write-Host "RESUME DU TEST" -ForegroundColor Cyan
Write-Host "==============" -ForegroundColor Cyan
Write-Host ""

if ($updateResult -and $updateResult.success -and 
    (-not $oldLoginResult -or -not $oldLoginResult.success) -and 
    $newLoginResult -and $newLoginResult.success) {
    Write-Host "SUCCES COMPLET: L'authentification via base de donnees fonctionne!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Tests reussis:" -ForegroundColor Green
    Write-Host "  - Connexion avec identifiants par defaut" -ForegroundColor White
    Write-Host "  - Modification du mot de passe" -ForegroundColor White
    Write-Host "  - Rejet de l'ancien mot de passe" -ForegroundColor White
    Write-Host "  - Acceptation du nouveau mot de passe" -ForegroundColor White
} else {
    Write-Host "ECHEC: L'authentification via base de donnees ne fonctionne pas correctement" -ForegroundColor Red
    Write-Host ""
    Write-Host "Problemes detectes:" -ForegroundColor Red
    if (-not $updateResult -or -not $updateResult.success) {
        Write-Host "  - Modification du mot de passe echouee" -ForegroundColor White
    }
    if ($oldLoginResult -and $oldLoginResult.success) {
        Write-Host "  - L'ancien mot de passe fonctionne encore" -ForegroundColor White
    }
    if (-not $newLoginResult -or -not $newLoginResult.success) {
        Write-Host "  - Le nouveau mot de passe ne fonctionne pas" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "Test d'authentification via base de donnees termine." -ForegroundColor Cyan
