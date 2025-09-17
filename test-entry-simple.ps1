# Test simple de la page d'entree

Write-Host "Test de la page d'entree U Silenziu" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:3000"

# Test 1: API de configuration
Write-Host "1. Test de l'API de configuration..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/entry-page-config" -Method GET -TimeoutSec 10
    Write-Host "   Succes: Configuration recuperee" -ForegroundColor Green
    Write-Host "   Titre: $($response.title)" -ForegroundColor Gray
    Write-Host "   Type arriere-plan: $($response.background_type)" -ForegroundColor Gray
} catch {
    Write-Host "   Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 2: Page d'entree
Write-Host "2. Test de la page d'entree..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/entry" -Method GET -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "   Succes: Page accessible (statut $($response.StatusCode))" -ForegroundColor Green
        if ($response.Content -like "*U SILENZIU*") {
            Write-Host "   Succes: Contenu correct trouve" -ForegroundColor Green
        } else {
            Write-Host "   Attention: Contenu attendu non trouve" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   Erreur: Statut $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "   Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Interface d'administration
Write-Host "3. Test de l'interface d'administration..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/admin/entry-page" -Method GET -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "   Succes: Interface admin accessible" -ForegroundColor Green
    } else {
        Write-Host "   Erreur: Statut $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "   Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 4: API admin
Write-Host "4. Test de l'API d'administration..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/admin/entry-page-config" -Method GET -TimeoutSec 10
    Write-Host "   Succes: API admin fonctionnelle" -ForegroundColor Green
    Write-Host "   ID configuration: $($response.id)" -ForegroundColor Gray
} catch {
    Write-Host "   Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Tests termines !" -ForegroundColor Green
Write-Host ""
Write-Host "URLs de test :" -ForegroundColor White
Write-Host "  Page d'entree : $baseUrl/entry" -ForegroundColor Gray
Write-Host "  Administration : $baseUrl/admin/entry-page" -ForegroundColor Gray
Write-Host "  Dashboard : $baseUrl/admin" -ForegroundColor Gray

Write-Host ""
Read-Host "Appuyez sur Entree pour continuer..."
