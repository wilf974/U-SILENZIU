# Script de debug pour la configuration de l'en-tete
# U Silenziu - Decembre 2024

Write-Host "DEBUG DE LA CONFIGURATION DE L'EN-TETE" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. Test de l'API GET /api/admin/header-config..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "https://rageroom.usilenziu.com/api/admin/header-config" -Method GET
    Write-Host "Reponse GET:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "Erreur GET:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body:" -ForegroundColor Red
        Write-Host $responseBody -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "2. Test de l'API PUT /api/admin/header-config..." -ForegroundColor Cyan

$body = @{
    site_name = "U SILENZIU"
    logo_type = "text"
    logo_text = "U SILENZIU"
    logo_alt_text = "Logo U Silenziu"
} | ConvertTo-Json

Write-Host "Donnees envoyees:" -ForegroundColor Yellow
Write-Host $body -ForegroundColor Gray

try {
    $response = Invoke-RestMethod -Uri "https://rageroom.usilenziu.com/api/admin/header-config" -Method PUT -Body $body -ContentType "application/json"
    Write-Host "Reponse PUT:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "Erreur PUT:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response Body:" -ForegroundColor Red
        Write-Host $responseBody -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "3. Verification en base de donnees..." -ForegroundColor Cyan
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT * FROM header_config ORDER BY created_at DESC LIMIT 1;
"

Write-Host ""
Write-Host "4. Verification de la structure de la table..." -ForegroundColor Cyan
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
\d header_config;
"

Write-Host ""
Write-Host "DEBUG TERMINE !" -ForegroundColor Green
