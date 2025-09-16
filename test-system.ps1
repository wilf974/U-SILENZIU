# Script de test simple pour le système de gestion des sections
# U Silenziu - Décembre 2024

Write-Host "🧪 Test du Système de Gestion des Sections" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

$baseUrl = "http://localhost:3000"

# Test 1: Vérification de l'API des sections
Write-Host "`n📋 Test 1: API des sections" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/homepage-sections" -Method GET -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ API des sections accessible" -ForegroundColor Green
        $data = $response.Content | ConvertFrom-Json
        Write-Host "📊 Sections trouvées: $($data.count)" -ForegroundColor Blue
    } else {
        Write-Host "❌ Erreur API: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors du test de l'API: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Vérification de l'API admin
Write-Host "`n📋 Test 2: API admin" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/admin/homepage-sections" -Method GET -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ API admin accessible" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur API admin: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors du test de l'API admin: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Vérification de l'interface d'administration
Write-Host "`n📋 Test 3: Interface d'administration" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/admin/homepage" -Method GET -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Interface d'administration accessible" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur interface admin: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors du test de l'interface admin: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Vérification de la page d'accueil
Write-Host "`n📋 Test 4: Page d'accueil" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $baseUrl -Method GET -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Page d'accueil accessible" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur page d'accueil: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors du test de la page d'accueil: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n✅ Tests terminés !" -ForegroundColor Green
Write-Host "==================" -ForegroundColor Green

Write-Host "`n🚀 URLs utiles:" -ForegroundColor Cyan
Write-Host "- Page d'accueil: $baseUrl" -ForegroundColor White
Write-Host "- Interface d'administration: $baseUrl/admin/homepage" -ForegroundColor White
Write-Host "- API des sections: $baseUrl/api/homepage-sections" -ForegroundColor White
