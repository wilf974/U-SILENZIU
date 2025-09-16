# Test simple de l'API
Write-Host "=== Test de l'API Entry Page Config ===" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:3000"

Write-Host "1. Test de l'API GET" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/admin/entry-page-config" -Method GET -TimeoutSec 10
    Write-Host "✅ API GET fonctionne" -ForegroundColor Green
    Write-Host "Configuration récupérée:" -ForegroundColor Gray
    $response | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor Gray
} catch {
    Write-Host "❌ Erreur API GET: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode
        Write-Host "Code de statut: $statusCode" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "2. Test de l'API PUT" -ForegroundColor Yellow
try {
    $testData = @{
        id = 1
        title = "U SILENZIU"
        subtitle = "Zone de défoulement"
        description = "Libérez votre stress dans nos salles sécurisées"
        button_text = "ENTRER DANS LE SITE"
        background_type = "image"
        background_image_url = "/images/entry-bg.jpg"
        background_video_url = "/videos/entry-bg.mp4"
        is_active = $true
    }
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/admin/entry-page-config" -Method PUT -Body ($testData | ConvertTo-Json) -ContentType "application/json" -TimeoutSec 10
    Write-Host "✅ API PUT fonctionne" -ForegroundColor Green
    Write-Host "Configuration mise à jour:" -ForegroundColor Gray
    $response | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor Gray
} catch {
    Write-Host "❌ Erreur API PUT: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode
        Write-Host "Code de statut: $statusCode" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "3. Test de l'interface web" -ForegroundColor Yellow
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
Write-Host "=== Test terminé ===" -ForegroundColor Green