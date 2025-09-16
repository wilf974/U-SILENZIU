# Script de test simple pour la configuration de la page d'accueil

Write-Host "Test de la configuration de la page d'accueil" -ForegroundColor Cyan

# Variables
$BASE_URL = "http://localhost:3000"

Write-Host "`n1. Test de l'API publique" -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/homepage-config" -Method GET
    Write-Host "API publique OK - Titre: $($response.data.main_title)" -ForegroundColor Green
} catch {
    Write-Host "Erreur API publique: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n2. Test de l'API admin" -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/admin/homepage-config" -Method GET
    Write-Host "API admin OK - Configurations chargees" -ForegroundColor Green
} catch {
    Write-Host "Erreur API admin: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n3. Test de modification" -ForegroundColor Yellow

try {
    $testData = @{
        main_title = "U Silenziu - TEST"
        contact_email = "test@usilenziu.fr"
    }
    
    $jsonBody = $testData | ConvertTo-Json
    $response = Invoke-RestMethod -Uri "$BASE_URL/api/admin/homepage-config" -Method PUT -Body $jsonBody -ContentType "application/json"
    
    if ($response.success) {
        Write-Host "Modification OK - Titre: $($response.data.main_title)" -ForegroundColor Green
    } else {
        Write-Host "Erreur modification: $($response.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "Erreur modification: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTest termine" -ForegroundColor Green

