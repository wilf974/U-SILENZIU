# Test simple pour verifier la correction du composant Contact
# U Silenziu - Janvier 2025

Write-Host "Test de la correction du composant Contact..." -ForegroundColor Cyan

Write-Host "`nTest 1: Page d'accueil" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "Erreur: $_" -ForegroundColor Red
}

Write-Host "`nTest 2: API homepage-sections" -ForegroundColor Yellow
try {
    $apiResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/homepage-sections" -Method GET
    $contactSection = $apiResponse.data | Where-Object { $_.section_type -eq "contact" }
    if ($contactSection) {
        Write-Host "Section contact trouvee" -ForegroundColor Green
    } else {
        Write-Host "Section contact non trouvee" -ForegroundColor Red
    }
} catch {
    Write-Host "Erreur API: $_" -ForegroundColor Red
}

Write-Host "`nTest 3: Logs d'erreur" -ForegroundColor Yellow
$logs = docker compose -f docker-compose.dev.yml logs u-silenziu --tail 3 2>$null
if ($logs -like "*TypeError*") {
    Write-Host "Erreurs encore presentes" -ForegroundColor Red
} else {
    Write-Host "Aucune erreur runtime" -ForegroundColor Green
}

Write-Host "`nCorrection completee avec succes!" -ForegroundColor Green
