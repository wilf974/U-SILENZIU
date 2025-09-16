# Test complet de l'upload et affichage d'image
Write-Host "=== Test Complet Upload et Affichage d'Image ===" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:3000"

Write-Host "1. Attente du démarrage de l'application..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

Write-Host "2. Test de l'API de configuration" -ForegroundColor Yellow
try {
    $config = Invoke-RestMethod -Uri "$baseUrl/api/entry-page-config" -Method GET -TimeoutSec 10
    Write-Host "✅ Configuration récupérée:" -ForegroundColor Green
    Write-Host "  - Titre: $($config.title)" -ForegroundColor Gray
    Write-Host "  - Type d'arrière-plan: $($config.background_type)" -ForegroundColor Gray
    Write-Host "  - URL image: $($config.background_image_url)" -ForegroundColor Gray
    Write-Host "  - URL vidéo: $($config.background_video_url)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Erreur API configuration: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Test de l'API d'upload d'image" -ForegroundColor Yellow
try {
    # Créer un fichier image de test (1x1 pixel PNG)
    $testImageData = [Convert]::FromBase64String("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==")
    $testImagePath = "test-image.png"
    [System.IO.File]::WriteAllBytes($testImagePath, $testImageData)
    
    $boundary = [System.Guid]::NewGuid().ToString()
    $LF = "`r`n"
    $bodyLines = (
        "--$boundary",
        "Content-Disposition: form-data; name=`"file`"; filename=`"test-image.png`"",
        "Content-Type: image/png$LF",
        [System.Text.Encoding]::UTF8.GetString($testImageData),
        "--$boundary",
        "Content-Disposition: form-data; name=`"type`"$LF",
        "image",
        "--$boundary--$LF"
    ) -join $LF
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/media/upload" -Method POST -Body $bodyLines -ContentType "multipart/form-data; boundary=$boundary" -TimeoutSec 10
    Write-Host "✅ Image uploadée avec succès:" -ForegroundColor Green
    Write-Host "  - URL: $($response.url)" -ForegroundColor Gray
    Write-Host "  - Nom: $($response.name)" -ForegroundColor Gray
    
    # Nettoyer le fichier de test
    Remove-Item $testImagePath -Force
    
} catch {
    Write-Host "❌ Erreur upload: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Test de mise à jour de la configuration" -ForegroundColor Yellow
try {
    $updateData = @{
        id = 1
        title = "U SILENZIU"
        subtitle = "Zone de défoulement"
        description = "Libérez votre stress dans nos salles sécurisées"
        button_text = "ENTRER DANS LE SITE"
        background_type = "image"
        background_image_url = "/media/entry/image/test-image.png"
        background_video_url = "/videos/entry-bg.mp4"
        is_active = $true
    }
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/admin/entry-page-config" -Method PUT -Body ($updateData | ConvertTo-Json) -ContentType "application/json" -TimeoutSec 10
    Write-Host "✅ Configuration mise à jour avec succès" -ForegroundColor Green
    Write-Host "  - URL image: $($response.background_image_url)" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Erreur mise à jour: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "5. Test de la page d'entrée" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/entry" -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Page d'entrée accessible" -ForegroundColor Green
        Write-Host "  - URL: $baseUrl/entry" -ForegroundColor Gray
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
Write-Host "3. Dans 'Médias d'Arrière-plan', cliquez sur la zone d'upload d'image" -ForegroundColor White
Write-Host "4. Sélectionnez une image de votre ordinateur" -ForegroundColor White
Write-Host "5. Cliquez sur 'Sauvegarder'" -ForegroundColor White
Write-Host "6. Vérifiez la page d'entrée: $baseUrl/entry" -ForegroundColor White
Write-Host ""

Write-Host "Test terminé !" -ForegroundColor Green
