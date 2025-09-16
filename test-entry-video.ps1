# Test de la page d'entrée avec vidéo
Write-Host "=== Test Page d'Entrée avec Vidéo ===" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:3000"

Write-Host "1. Attente du démarrage de l'application..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host "2. Test de l'accès à la vidéo" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/videos/entry/entry-bg.mp4" -Method HEAD -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Vidéo accessible: $baseUrl/videos/entry/entry-bg.mp4" -ForegroundColor Green
    } else {
        Write-Host "❌ Vidéo non accessible (Code: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Vidéo non accessible (Erreur: $($_.Exception.Message))" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Test de l'accès à l'image poster" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/images/entry/entry-bg.jpg" -Method HEAD -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Image poster accessible: $baseUrl/images/entry/entry-bg.jpg" -ForegroundColor Green
    } else {
        Write-Host "❌ Image poster non accessible (Code: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Image poster non accessible (Erreur: $($_.Exception.Message))" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Test de la page d'entrée" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/entry" -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Page d'entrée accessible" -ForegroundColor Green
        Write-Host "  - URL: $baseUrl/entry" -ForegroundColor Gray
        Write-Host "  - Vérifiez que la vidéo s'affiche en arrière-plan" -ForegroundColor Gray
    } else {
        Write-Host "❌ Page d'entrée non accessible (Code: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Page d'entrée non accessible (Erreur: $($_.Exception.Message))" -ForegroundColor Red
}

Write-Host ""
Write-Host "5. Test de l'API de configuration" -ForegroundColor Yellow
try {
    $config = Invoke-RestMethod -Uri "$baseUrl/api/entry-page-config" -Method GET -TimeoutSec 10
    Write-Host "✅ Configuration récupérée:" -ForegroundColor Green
    Write-Host "  - Type: $($config.background_type)" -ForegroundColor Gray
    Write-Host "  - Image: $($config.background_image_url)" -ForegroundColor Gray
    Write-Host "  - Vidéo: $($config.background_video_url)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Erreur API configuration: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Instructions ===" -ForegroundColor Cyan
Write-Host "1. Ouvrez votre navigateur et allez sur: $baseUrl/entry" -ForegroundColor White
Write-Host "2. Vous devriez voir la vidéo en arrière-plan (comme le Hero)" -ForegroundColor White
Write-Host "3. Si la vidéo ne s'affiche pas, vérifiez la console du navigateur" -ForegroundColor White
Write-Host "4. La structure est maintenant identique au Hero qui fonctionne" -ForegroundColor White
Write-Host ""

Write-Host "Test terminé !" -ForegroundColor Green
