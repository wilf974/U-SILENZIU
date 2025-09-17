# Test de correction de l'API rooms

Write-Host "Test de l'API rooms apres correction" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:3000"

# Test API rooms
Write-Host "1. Test de l'API /api/rooms..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/rooms" -Method GET -TimeoutSec 10
    Write-Host "   Succes: API fonctionnelle" -ForegroundColor Green
    Write-Host "   Nombre de salles: $($response.data.Count)" -ForegroundColor Gray
    Write-Host "   Timestamp: $($response.timestamp)" -ForegroundColor Gray
} catch {
    Write-Host "   Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test page d'accueil avec section salles
Write-Host "2. Test de la page d'accueil..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/" -Method GET -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "   Succes: Page accessible" -ForegroundColor Green
        if ($response.Content -like "*salles*") {
            Write-Host "   Succes: Section salles presente" -ForegroundColor Green
        } else {
            Write-Host "   Attention: Section salles non trouvee" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "   Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test tentative d'accès à /rooms (qui devrait maintenant retourner 404 proprement)
Write-Host "3. Test de la route /rooms (doit etre 404)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/rooms" -Method GET -UseBasicParsing -TimeoutSec 10
    Write-Host "   Attention: La route /rooms existe encore" -ForegroundColor Yellow
} catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host "   Succes: Route /rooms retourne 404 (correct)" -ForegroundColor Green
    } else {
        Write-Host "   Erreur inattendue: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Test termine !" -ForegroundColor Green
Write-Host ""
Write-Host "Instructions:" -ForegroundColor White
Write-Host "1. Actualisez votre navigateur (F5)" -ForegroundColor Gray
Write-Host "2. Testez la navigation 'Nos salles' dans le header" -ForegroundColor Gray
Write-Host "3. Verifiez que les salles s'affichent correctement" -ForegroundColor Gray

Write-Host ""
Read-Host "Appuyez sur Entree pour continuer..."
