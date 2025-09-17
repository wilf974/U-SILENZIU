# Test des sections de la homepage

Write-Host "Test des sections de la homepage U Silenziu" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:3000"

# Test 1: API homepage-sections
Write-Host "1. Test de l'API homepage-sections..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/homepage-sections" -Method GET -TimeoutSec 10
    if ($response.success) {
        Write-Host "   Succes: API fonctionnelle" -ForegroundColor Green
        Write-Host "   Nombre de sections: $($response.data.Count)" -ForegroundColor Gray
        
        $activeSections = $response.data | Where-Object { $_.is_active -eq $true } | Sort-Object order_index
        Write-Host "   Sections actives dans l'ordre:" -ForegroundColor Gray
        foreach ($section in $activeSections) {
            Write-Host "     $($section.order_index). $($section.section_key) - $($section.title)" -ForegroundColor White
        }
    }
} catch {
    Write-Host "   Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 2: Page d'accueil
Write-Host "2. Test de la page d'accueil..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/" -Method GET -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "   Succes: Page accessible (statut $($response.StatusCode))" -ForegroundColor Green
        
        # Vérifier la présence des sections dans le HTML
        $sectionsToCheck = @("hero", "concept", "salles", "process", "faq", "contact")
        foreach ($section in $sectionsToCheck) {
            if ($response.Content -like "*id=`"$section`"*" -or $response.Content -like "*$section*") {
                Write-Host "   ✓ Section '$section' trouvee" -ForegroundColor Green
            } else {
                Write-Host "   ✗ Section '$section' manquante" -ForegroundColor Red
            }
        }
    }
} catch {
    Write-Host "   Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Vérification des erreurs de console
Write-Host "3. Instructions de test manuel..." -ForegroundColor Yellow
Write-Host "   1. Actualisez votre navigateur (F5)" -ForegroundColor Gray
Write-Host "   2. Ouvrez les outils de développement (F12)" -ForegroundColor Gray
Write-Host "   3. Vérifiez la console pour les erreurs" -ForegroundColor Gray
Write-Host "   4. Vérifiez que toutes les sections s'affichent sur la page" -ForegroundColor Gray

Write-Host ""
Write-Host "Test termine !" -ForegroundColor Green

Write-Host ""
Read-Host "Appuyez sur Entree pour continuer..."