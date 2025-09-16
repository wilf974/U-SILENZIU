#!/usr/bin/env pwsh

Write-Host "Test des prix apres correction" -ForegroundColor Yellow
Write-Host "=============================" -ForegroundColor Yellow

$baseUrl = "http://localhost:3000"

Write-Host ""
Write-Host "Test des prix pour les nouvelles salles" -ForegroundColor Cyan

$salles = @("Salle 1", "Salle 2")

foreach ($salle in $salles) {
    try {
        $encodedName = [System.Web.HttpUtility]::UrlEncode($salle)
        $response = Invoke-RestMethod -Uri "$baseUrl/api/rooms/price?name=$encodedName" -Method GET
        Write-Host "  $salle : $($response.price)€" -ForegroundColor Green
    } catch {
        Write-Host "  $salle : ERREUR - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Test des URLs de reservation" -ForegroundColor Cyan

$urls = @(
    "$baseUrl/reservation?formule=Salle%201",
    "$baseUrl/reservation?formule=Salle%202",
    "$baseUrl/reservation?formule=Pas%20Content!",
    "$baseUrl/reservation?formule=Vraiment%20pas%20Content!"
)

foreach ($url in $urls) {
    Write-Host "  Test URL: $url" -ForegroundColor White
    try {
        $response = Invoke-WebRequest -Uri $url -Method GET -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "    ✅ Page accessible" -ForegroundColor Green
        } else {
            Write-Host "    ❌ Erreur: $($response.StatusCode)" -ForegroundColor Red
        }
    } catch {
        Write-Host "    ❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Test termine" -ForegroundColor Yellow
