#!/usr/bin/env pwsh

Write-Host "Diagnostic des prix des salles" -ForegroundColor Yellow
Write-Host "==============================" -ForegroundColor Yellow

$baseUrl = "http://localhost:3000"

Write-Host ""
Write-Host "1. Test des salles actives" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/rooms" -Method GET
    Write-Host "Salles actives: $($response.count)" -ForegroundColor Green
    foreach ($room in $response.data) {
        Write-Host "  - $($room.name): $($room.price)€" -ForegroundColor White
    }
} catch {
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Test des prix par salle" -ForegroundColor Cyan
$salles = @("Salle Haches", "Salle Defoulement", "Salle Shurikens", "Color Zone")

foreach ($salle in $salles) {
    try {
        $encodedName = [System.Web.HttpUtility]::UrlEncode($salle)
        $response = Invoke-RestMethod -Uri "$baseUrl/api/rooms/price?name=$encodedName" -Method GET
        Write-Host "  $salle : $($response.price)€" -ForegroundColor Green
    } catch {
        Write-Host "  $salle : NON TROUVEE" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "3. Test API admin" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/admin/rooms" -Method GET
    Write-Host "Total salles: $($response.count)" -ForegroundColor Green
    foreach ($room in $response.data) {
        $status = if ($room.is_active) { "ACTIF" } else { "INACTIF" }
        Write-Host "  - $($room.name): $($room.price)€ ($status)" -ForegroundColor White
    }
} catch {
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Diagnostic termine" -ForegroundColor Yellow
