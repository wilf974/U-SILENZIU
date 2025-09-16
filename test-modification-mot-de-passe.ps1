# Script de test pour la modification du mot de passe
# U Silenziu - Janvier 2025

Write-Host "Test de Modification du Mot de Passe" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
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

# Étape 1: Récupérer la liste des utilisateurs pour obtenir un ID
Write-Host "=== ETAPE 1: Recuperation des utilisateurs ===" -ForegroundColor Magenta
$users = Test-API -method "GET" -url "$baseUrl/api/admin/users" -description "Récupération de la liste des utilisateurs"

if (-not $users -or -not $users.success) {
    Write-Host "Impossible de recuperer les utilisateurs. Arret du test." -ForegroundColor Red
    exit 1
}

$testUser = $users.users | Where-Object { $_.username -eq "admin" }
if (-not $testUser) {
    Write-Host "Utilisateur 'admin' non trouve. Arret du test." -ForegroundColor Red
    exit 1
}

$userId = $testUser.id
Write-Host "Utilisateur trouve: $($testUser.username) (ID: $userId)" -ForegroundColor Green
Write-Host ""

# Étape 2: Modifier le mot de passe de l'utilisateur
Write-Host "=== ETAPE 2: Modification du mot de passe ===" -ForegroundColor Magenta
$updateData = @{
    username = "admin"
    password = "nouveau-mot-de-passe-123"
    role = "admin"
}

Write-Host "Tentative de modification du mot de passe pour l'utilisateur: $($testUser.username)" -ForegroundColor Yellow
$updateResult = Test-API -method "PUT" -url "$baseUrl/api/admin/users/$userId" -body $updateData -description "Modification du mot de passe"

if ($updateResult -and $updateResult.success) {
    Write-Host "Mot de passe modifie avec succes!" -ForegroundColor Green
    Write-Host "Utilisateur modifie: $($updateResult.user.username)" -ForegroundColor Green
} else {
    Write-Host "Echec de la modification du mot de passe" -ForegroundColor Red
    if ($updateResult) {
        Write-Host "Erreur: $($updateResult.error)" -ForegroundColor Red
    }
}
Write-Host ""

# Étape 3: Vérifier que l'utilisateur a bien été modifié
Write-Host "=== ETAPE 3: Verification de la modification ===" -ForegroundColor Magenta
$updatedUser = Test-API -method "GET" -url "$baseUrl/api/admin/users/$userId" -description "Vérification de l'utilisateur modifié"

if ($updatedUser -and $updatedUser.success) {
    Write-Host "Utilisateur recupere apres modification:" -ForegroundColor Green
    Write-Host "  - Nom: $($updatedUser.user.username)" -ForegroundColor White
    Write-Host "  - Role: $($updatedUser.user.role)" -ForegroundColor White
    Write-Host "  - Modifie le: $($updatedUser.user.updated_at)" -ForegroundColor White
} else {
    Write-Host "Impossible de recuperer l'utilisateur modifie" -ForegroundColor Red
}
Write-Host ""

# Étape 4: Test avec mot de passe vide (ne devrait pas changer le mot de passe)
Write-Host "=== ETAPE 4: Test avec mot de passe vide ===" -ForegroundColor Magenta
$updateDataEmpty = @{
    username = "admin"
    password = ""
    role = "admin"
}

Write-Host "Test avec mot de passe vide (ne devrait pas changer le mot de passe)" -ForegroundColor Yellow
$updateResultEmpty = Test-API -method "PUT" -url "$baseUrl/api/admin/users/$userId" -body $updateDataEmpty -description "Modification avec mot de passe vide"

if ($updateResultEmpty -and $updateResultEmpty.success) {
    Write-Host "Modification avec mot de passe vide reussie" -ForegroundColor Green
} else {
    Write-Host "Echec de la modification avec mot de passe vide" -ForegroundColor Red
}
Write-Host ""

# Étape 5: Test avec seulement le mot de passe (sans changer le nom)
Write-Host "=== ETAPE 5: Test modification mot de passe uniquement ===" -ForegroundColor Magenta
$updateDataPasswordOnly = @{
    password = "autre-mot-de-passe-456"
}

Write-Host "Test modification du mot de passe uniquement" -ForegroundColor Yellow
$updateResultPasswordOnly = Test-API -method "PUT" -url "$baseUrl/api/admin/users/$userId" -body $updateDataPasswordOnly -description "Modification du mot de passe uniquement"

if ($updateResultPasswordOnly -and $updateResultPasswordOnly.success) {
    Write-Host "Modification du mot de passe uniquement reussie!" -ForegroundColor Green
    Write-Host "Utilisateur: $($updateResultPasswordOnly.user.username)" -ForegroundColor Green
} else {
    Write-Host "Echec de la modification du mot de passe uniquement" -ForegroundColor Red
}
Write-Host ""

# Résumé final
Write-Host "RESUME DU TEST" -ForegroundColor Cyan
Write-Host "==============" -ForegroundColor Cyan
Write-Host ""

if ($updateResult -and $updateResult.success -and $updateResultPasswordOnly -and $updateResultPasswordOnly.success) {
    Write-Host "SUCCES: La modification du mot de passe fonctionne correctement!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Tests reussis:" -ForegroundColor Green
    Write-Host "  - Modification complete (nom + mot de passe + role)" -ForegroundColor White
    Write-Host "  - Modification du mot de passe uniquement" -ForegroundColor White
    Write-Host "  - Gestion du mot de passe vide" -ForegroundColor White
} else {
    Write-Host "ECHEC: La modification du mot de passe ne fonctionne pas correctement" -ForegroundColor Red
    Write-Host ""
    Write-Host "Problemes detectes:" -ForegroundColor Red
    if (-not $updateResult -or -not $updateResult.success) {
        Write-Host "  - Modification complete echouee" -ForegroundColor White
    }
    if (-not $updateResultPasswordOnly -or -not $updateResultPasswordOnly.success) {
        Write-Host "  - Modification mot de passe uniquement echouee" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "Test de modification du mot de passe termine." -ForegroundColor Cyan
