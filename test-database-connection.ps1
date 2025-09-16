# Test de connexion à la base de données et génération de numéro
Write-Host "=== Test de connexion à la base de données ===" -ForegroundColor Green
Write-Host ""

# Test simple de l'API GET
Write-Host "1. Test de l'API GET /api/reservations..." -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/reservations" -Method GET
    Write-Host "✅ API GET fonctionne!" -ForegroundColor Green
    Write-Host "Nombre de réservations: $($response.Count)" -ForegroundColor Yellow
    
    if ($response.Count -gt 0) {
        $lastReservation = $response[-1]
        Write-Host "Dernière réservation:" -ForegroundColor White
        Write-Host "  - Numéro: $($lastReservation.reservation_number)" -ForegroundColor White
        Write-Host "  - Date: $($lastReservation.date)" -ForegroundColor White
        Write-Host "  - Créée le: $($lastReservation.created_at)" -ForegroundColor White
    }
    
} catch {
    Write-Host "❌ Erreur API GET:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Test de création avec données minimales..." -ForegroundColor Cyan

$minimalData = @{
    firstName = "Test"
    lastName = "Minimal"
    email = "test@test.com"
    phone = "0123456789"
    date = "2025-09-05"
    timeSlot = "14:00 - 14:20"
    duration = 20
    numberOfPeople = 1
    formula = "pas-content"
    roomName = "Salle Test"
} | ConvertTo-Json

try {
    Write-Host "Données envoyées:" -ForegroundColor Yellow
    Write-Host $minimalData -ForegroundColor White
    
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/reservations" -Method POST -Body $minimalData -ContentType "application/json"
    
    Write-Host "✅ Réservation créée avec succès!" -ForegroundColor Green
    Write-Host "Numéro: $($response.reservation_number)" -ForegroundColor Yellow
    Write-Host "ID: $($response.id)" -ForegroundColor White
    
} catch {
    Write-Host "❌ Erreur lors de la création:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Réponse d'erreur: $responseBody" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Test terminé ===" -ForegroundColor Green
