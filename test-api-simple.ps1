# Test simple de l'API
Write-Host "Test API /api/legal-pages..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/legal-pages" -UseBasicParsing -TimeoutSec 5
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    Write-Host "Pages trouvées: $($data.data.Count)" -ForegroundColor Cyan
    foreach ($page in $data.data) {
        Write-Host "- $($page.page_type): $($page.title)" -ForegroundColor White
    }
} catch {
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
}
