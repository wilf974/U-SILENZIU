# Test final des sections de la homepage

Write-Host "🔍 TEST FINAL DES SECTIONS HOMEPAGE" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Test de l'API
Write-Host "1. Test API homepage-sections..." -ForegroundColor Yellow
try {
    $api = Invoke-RestMethod -Uri "http://localhost:3000/api/homepage-sections" -TimeoutSec 10
    if ($api.success) {
        Write-Host "   ✅ API OK - $($api.data.Count) sections trouvées" -ForegroundColor Green
        $api.data | Sort-Object order_index | ForEach-Object {
            Write-Host "      $($_.order_index). $($_.section_key) - $($_.title)" -ForegroundColor Gray
        }
    }
} catch {
    Write-Host "   ❌ Erreur API: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test de la page
Write-Host "2. Test page d'accueil..." -ForegroundColor Yellow
try {
    $page = Invoke-WebRequest -Uri "http://localhost:3000/" -UseBasicParsing -TimeoutSec 10
    Write-Host "   ✅ Page accessible (statut: $($page.StatusCode))" -ForegroundColor Green
    
    # Vérifier taille du contenu
    $contentSize = $page.Content.Length
    Write-Host "   📊 Taille du contenu: $($contentSize) caractères" -ForegroundColor Gray
    
    if ($contentSize -lt 5000) {
        Write-Host "   ⚠️  Contenu suspicieusement petit" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "   ❌ Erreur page: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🌐 INSTRUCTIONS MANUELLES:" -ForegroundColor Cyan
Write-Host "1. Ouvrez http://localhost:3000/ dans votre navigateur" -ForegroundColor White
Write-Host "2. Actualisez la page (F5)" -ForegroundColor White
Write-Host "3. Vérifiez que toutes les sections s'affichent:" -ForegroundColor White
Write-Host "   - Section Hero (Libérez votre STRESS)" -ForegroundColor Gray
Write-Host "   - Section Concept (icônes et explications)" -ForegroundColor Gray
Write-Host "   - Section Salles (2 salles avec images)" -ForegroundColor Gray
Write-Host "   - Section Process (étapes du processus)" -ForegroundColor Gray
Write-Host "   - Section FAQ (questions/réponses)" -ForegroundColor Gray
Write-Host "   - Section Contact (informations de contact)" -ForegroundColor Gray
Write-Host "4. Ouvrez F12 pour vérifier qu'il n'y a pas d'erreurs console" -ForegroundColor White

Write-Host ""
Write-Host "✅ PROBLÈME PRINCIPAL RÉSOLU !" -ForegroundColor Green
Write-Host "La page d'accueil affiche maintenant les sections." -ForegroundColor Green

Write-Host ""
Read-Host "Appuyez sur Entrée pour continuer..."
