# Test simple du calendrier hebdomadaire
Write-Host "Test Simple du Calendrier Hebdomadaire" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$baseUrl = "http://localhost:3000"
$apiUrl = "$baseUrl/api/admin/reservations/weekly"
$currentDate = Get-Date -Format "yyyy-MM-dd"

Write-Host "`nTest de l'API hebdomadaire..." -ForegroundColor Yellow
Write-Host "URL: $apiUrl?week=$currentDate" -ForegroundColor Gray

try {
    $response = Invoke-RestMethod -Uri "$apiUrl?week=$currentDate" -Method GET
    Write-Host "API fonctionnelle !" -ForegroundColor Green
    
    if ($response.week) {
        Write-Host "Semaine: $($response.week.start) a $($response.week.end)" -ForegroundColor White
    }
    
    if ($response.statistics) {
        Write-Host "Statistiques:" -ForegroundColor White
        Write-Host "   - Total: $($response.statistics.total)" -ForegroundColor White
        Write-Host "   - Confirmees: $($response.statistics.confirmed)" -ForegroundColor Green
        Write-Host "   - En attente: $($response.statistics.pending)" -ForegroundColor Yellow
        Write-Host "   - Annulees: $($response.statistics.cancelled)" -ForegroundColor Red
        Write-Host "   - Revenus: $($response.statistics.revenue) euros" -ForegroundColor Green
    }
    
    Write-Host "`nTest de l'interface web..." -ForegroundColor Yellow
    $webResponse = Invoke-WebRequest -Uri "$baseUrl/admin/reservations" -UseBasicParsing
    
    if ($webResponse.StatusCode -eq 200) {
        Write-Host "Interface accessible !" -ForegroundColor Green
        Write-Host "Status: $($webResponse.StatusCode)" -ForegroundColor White
    }
    
    Write-Host "`nLe calendrier hebdomadaire est operationnel !" -ForegroundColor Green
    Write-Host "`nInstructions:" -ForegroundColor Cyan
    Write-Host "1. Accedez a: $baseUrl/admin/reservations" -ForegroundColor White
    Write-Host "2. Cliquez sur l'onglet 'Calendrier'" -ForegroundColor White
    Write-Host "3. Naviguez entre les semaines avec les fleches" -ForegroundColor White
    
} catch {
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTest termine !" -ForegroundColor Cyan