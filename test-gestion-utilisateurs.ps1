# Script de test pour la gestion des utilisateurs administrateurs
# U Silenziu - Janvier 2025

Write-Host "Test de la Gestion des Utilisateurs Administrateurs" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan
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

# Test 1: Récupérer la liste des utilisateurs
Write-Host "=== TEST 1: Liste des utilisateurs ===" -ForegroundColor Magenta
$users = Test-API -method "GET" -url "$baseUrl/api/admin/users" -description "Récupération de la liste des utilisateurs"

if ($users -and $users.success) {
    Write-Host "Nombre d'utilisateurs trouves: $($users.users.Count)" -ForegroundColor Green
    foreach ($user in $users.users) {
        Write-Host "  - $($user.username) ($($user.role))" -ForegroundColor White
    }
} else {
    Write-Host "Echec de la recuperation des utilisateurs" -ForegroundColor Red
}
Write-Host ""

# Test 2: Créer un nouvel utilisateur
Write-Host "=== TEST 2: Creation d'un nouvel utilisateur ===" -ForegroundColor Magenta
$newUser = @{
    username = "test-admin"
    password = "test123"
    role = "admin"
}

$createdUser = Test-API -method "POST" -url "$baseUrl/api/admin/users" -body $newUser -description "Création d'un nouvel utilisateur admin"

if ($createdUser -and $createdUser.success) {
    Write-Host "Utilisateur cree avec succes: $($createdUser.user.username)" -ForegroundColor Green
    $userId = $createdUser.user.id
} else {
    Write-Host "Echec de la creation de l'utilisateur" -ForegroundColor Red
    $userId = $null
}
Write-Host ""

# Test 3: Récupérer un utilisateur spécifique
if ($userId) {
    Write-Host "=== TEST 3: Recuperation d'un utilisateur specifique ===" -ForegroundColor Magenta
    $specificUser = Test-API -method "GET" -url "$baseUrl/api/admin/users/$userId" -description "Récupération d'un utilisateur spécifique"
    
    if ($specificUser -and $specificUser.success) {
        Write-Host "Utilisateur recupere: $($specificUser.user.username)" -ForegroundColor Green
    } else {
        Write-Host "Echec de la recuperation de l'utilisateur" -ForegroundColor Red
    }
    Write-Host ""
}

# Test 4: Modifier un utilisateur
if ($userId) {
    Write-Host "=== TEST 4: Modification d'un utilisateur ===" -ForegroundColor Magenta
    $updateData = @{
        username = "test-admin-updated"
        role = "super-admin"
    }
    
    $updatedUser = Test-API -method "PUT" -url "$baseUrl/api/admin/users/$userId" -body $updateData -description "Modification d'un utilisateur"
    
    if ($updatedUser -and $updatedUser.success) {
        Write-Host "Utilisateur modifie avec succes: $($updatedUser.user.username)" -ForegroundColor Green
    } else {
        Write-Host "Echec de la modification de l'utilisateur" -ForegroundColor Red
    }
    Write-Host ""
}

# Test 5: Supprimer un utilisateur
if ($userId) {
    Write-Host "=== TEST 5: Suppression d'un utilisateur ===" -ForegroundColor Magenta
    $deleteResult = Test-API -method "DELETE" -url "$baseUrl/api/admin/users/$userId" -description "Suppression d'un utilisateur"
    
    if ($deleteResult -and $deleteResult.success) {
        Write-Host "Utilisateur supprime avec succes" -ForegroundColor Green
    } else {
        Write-Host "Echec de la suppression de l'utilisateur" -ForegroundColor Red
    }
    Write-Host ""
}

# Test 6: Vérifier que l'utilisateur a été supprimé
if ($userId) {
    Write-Host "=== TEST 6: Verification de la suppression ===" -ForegroundColor Magenta
    $deletedUser = Test-API -method "GET" -url "$baseUrl/api/admin/users/$userId" -description "Vérification que l'utilisateur a été supprimé"
    
    if (-not $deletedUser -or -not $deletedUser.success) {
        Write-Host "Utilisateur correctement supprime (non trouve)" -ForegroundColor Green
    } else {
        Write-Host "Erreur: l'utilisateur existe encore" -ForegroundColor Red
    }
    Write-Host ""
}

# Test 7: Test de validation des données
Write-Host "=== TEST 7: Test de validation des donnees ===" -ForegroundColor Magenta

# Test avec des données invalides
$invalidUser = @{
    username = ""
    password = ""
    role = "invalid-role"
}

$invalidResult = Test-API -method "POST" -url "$baseUrl/api/admin/users" -body $invalidUser -description "Test avec des données invalides"

if (-not $invalidResult -or -not $invalidResult.success) {
    Write-Host "Validation des donnees fonctionne correctement" -ForegroundColor Green
} else {
    Write-Host "Erreur: validation des donnees ne fonctionne pas" -ForegroundColor Red
}
Write-Host ""

# Test 8: Test de création d'utilisateur avec nom existant
Write-Host "=== TEST 8: Test de nom d'utilisateur existant ===" -ForegroundColor Magenta
$duplicateUser = @{
    username = "admin"
    password = "password123"
    role = "admin"
}

$duplicateResult = Test-API -method "POST" -url "$baseUrl/api/admin/users" -body $duplicateUser -description "Test avec nom d'utilisateur existant"

if (-not $duplicateResult -or -not $duplicateResult.success) {
    Write-Host "Prevention des doublons fonctionne correctement" -ForegroundColor Green
} else {
    Write-Host "Erreur: prevention des doublons ne fonctionne pas" -ForegroundColor Red
}
Write-Host ""

# Résumé final
Write-Host "RESUME DES TESTS" -ForegroundColor Cyan
Write-Host "================" -ForegroundColor Cyan
Write-Host ""

# Vérifier l'état final de la base de données
$finalUsers = Test-API -method "GET" -url "$baseUrl/api/admin/users" -description "Vérification finale de la liste des utilisateurs"

if ($finalUsers -and $finalUsers.success) {
    Write-Host "Utilisateurs finaux dans la base de donnees:" -ForegroundColor Green
    foreach ($user in $finalUsers.users) {
        Write-Host "  - $($user.username) ($($user.role))" -ForegroundColor White
    }
} else {
    Write-Host "Impossible de recuperer la liste finale des utilisateurs" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test de la gestion des utilisateurs termine." -ForegroundColor Cyan
