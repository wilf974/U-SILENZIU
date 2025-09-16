# Test de l'upload automatique avec sauvegarde en BDD
Write-Host "=== Test Upload Automatique avec Sauvegarde BDD ===" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:3000"

Write-Host "1. Attente du démarrage de l'application..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Write-Host "2. Vérification de la configuration actuelle" -ForegroundColor Yellow
try {
    $config = Invoke-RestMethod -Uri "$baseUrl/api/entry-page-config" -Method GET -TimeoutSec 10
    Write-Host "✅ Configuration actuelle:" -ForegroundColor Green
    Write-Host "  - Type: $($config.background_type)" -ForegroundColor Gray
    Write-Host "  - Image: $($config.background_image_url)" -ForegroundColor Gray
    Write-Host "  - Vidéo: $($config.background_video_url)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Erreur récupération config: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Test upload d'image avec sauvegarde automatique" -ForegroundColor Yellow
try {
    # Créer un fichier image de test
    $testImageData = [Convert]::FromBase64String("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==")
    $testImagePath = "test-auto-image.png"
    [System.IO.File]::WriteAllBytes($testImagePath, $testImageData)
    
    $boundary = [System.Guid]::NewGuid().ToString()
    $LF = "`r`n"
    $bodyLines = (
        "--$boundary",
        "Content-Disposition: form-data; name=`"file`"; filename=`"test-auto-image.png`"",
        "Content-Type: image/png$LF",
        [System.Text.Encoding]::UTF8.GetString($testImageData),
        "--$boundary",
        "Content-Disposition: form-data; name=`"type`"$LF",
        "image",
        "--$boundary--$LF"
    ) -join $LF
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/media/upload" -Method POST -Body $bodyLines -ContentType "multipart/form-data; boundary=$boundary" -TimeoutSec 10
    Write-Host "✅ Image uploadée: $($response.url)" -ForegroundColor Green
    
    # Nettoyer le fichier de test
    Remove-Item $testImagePath -Force
    
    # Vérifier que la configuration a été mise à jour
    Start-Sleep -Seconds 2
    $updatedConfig = Invoke-RestMethod -Uri "$baseUrl/api/entry-page-config" -Method GET -TimeoutSec 10
    Write-Host "✅ Configuration mise à jour:" -ForegroundColor Green
    Write-Host "  - Type: $($updatedConfig.background_type)" -ForegroundColor Gray
    Write-Host "  - Image: $($updatedConfig.background_image_url)" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Erreur upload image: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Test de la page d'entrée" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/entry" -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Page d'entrée accessible" -ForegroundColor Green
        Write-Host "  - Vérifiez que l'image s'affiche correctement" -ForegroundColor Gray
    } else {
        Write-Host "❌ Page d'entrée non accessible (Code: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur page d'entrée: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Instructions ===" -ForegroundColor Cyan
Write-Host "1. Accédez à l'interface d'administration: $baseUrl/admin/entry-page" -ForegroundColor White
Write-Host "2. Cliquez sur 'Modifier' pour activer l'édition" -ForegroundColor White
Write-Host "3. Upload une image ou vidéo - elle sera automatiquement sauvegardée en BDD" -ForegroundColor White
Write-Host "4. Vérifiez la page d'entrée: $baseUrl/entry" -ForegroundColor White
Write-Host "5. L'image/vidéo devrait s'afficher immédiatement" -ForegroundColor White
Write-Host ""

Write-Host "Test terminé !" -ForegroundColor Green
