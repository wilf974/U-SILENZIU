Write-Host "Creation de la table footer_config..." -ForegroundColor Cyan

$sqlContent = Get-Content -Path "create-footer-config-table.sql" -Raw
$result = docker exec u-silenziu-postgres psql -U postgres -d usilenziu -c $sqlContent

if ($LASTEXITCODE -eq 0) {
    Write-Host "Table creee avec succes !" -ForegroundColor Green
} else {
    Write-Host "Erreur lors de la creation" -ForegroundColor Red
}

Write-Host "Test de l'API..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/footer-config" -UseBasicParsing
    Write-Host "API fonctionne ! Status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "Erreur API: $($_.Exception.Message)" -ForegroundColor Red
}
