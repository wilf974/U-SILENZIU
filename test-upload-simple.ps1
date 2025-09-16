# Test simple de l'upload de médias
Write-Host "=== Test de l'Upload de Médias ===" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:3000"

Write-Host "1. Test de l'interface d'administration" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/admin/entry-page" -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Interface d'administration accessible" -ForegroundColor Green
    } else {
        Write-Host "❌ Interface d'administration non accessible (Code: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Interface d'administration (Erreur: $($_.Exception.Message))" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Test de l'API d'upload" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/media/entry/image" -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ API de médias accessible" -ForegroundColor Green
    } else {
        Write-Host "❌ API de médias non accessible (Code: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ API de médias (Erreur: $($_.Exception.Message))" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Instructions d'utilisation ===" -ForegroundColor Cyan
Write-Host "1. Accédez à l'interface d'administration: $baseUrl/admin/entry-page" -ForegroundColor White
Write-Host "2. Cliquez sur 'Modifier' pour activer l'édition" -ForegroundColor White
Write-Host "3. Dans la section 'Médias d'Arrière-plan':" -ForegroundColor White
Write-Host "   • Cliquez sur la zone d'upload d'image pour ajouter une image" -ForegroundColor Gray
Write-Host "   • Cliquez sur la zone d'upload de vidéo pour ajouter une vidéo" -ForegroundColor Gray
Write-Host "   • Ou saisissez une URL manuellement dans les champs de texte" -ForegroundColor Gray
Write-Host "4. Sauvegardez vos modifications" -ForegroundColor White
Write-Host "5. Prévisualisez la page d'entrée" -ForegroundColor White
Write-Host ""

Write-Host "=== Formats supportés ===" -ForegroundColor Cyan
Write-Host "• Images: JPG, PNG, GIF, WebP (max 10MB)" -ForegroundColor White
Write-Host "• Vidéos: MP4, WebM, MOV, AVI (max 10MB)" -ForegroundColor White
Write-Host ""

Write-Host "Test terminé !" -ForegroundColor Green
