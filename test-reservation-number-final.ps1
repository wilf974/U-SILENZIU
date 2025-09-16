# Test final du format de numéro de réservation
# Format: YYMMDD + numéro séquentiel (ex: 250904001)

Write-Host "=== Test final du format de numéro de réservation ===" -ForegroundColor Green
Write-Host "Format: YYMMDD + numéro séquentiel sur 3 chiffres" -ForegroundColor Yellow
Write-Host "Exemple: 250904001 (1ère réservation du 4 septembre 2025)" -ForegroundColor Yellow
Write-Host ""

# Test de l'API de création de réservation
Write-Host "1. Test de création d'une réservation..." -ForegroundColor Cyan

$reservationData = @{
    firstName = "Test"
    lastName = "Final"
    email = "test.final@example.com"
    phone = "0123456789"
    date = "2025-09-04"
    timeSlot = "14:00 - 14:20"
    duration = 20
    numberOfPeople = 2
    formula = "pas-content"
    roomName = "Salle de Défoulement U Silenziu"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/reservations" -Method POST -Body $reservationData -ContentType "application/json"
    
    Write-Host "✅ Réservation créée avec succès!" -ForegroundColor Green
    Write-Host "Numéro de réservation: $($response.reservation_number)" -ForegroundColor Yellow
    
    # Vérifier le format du numéro
    $reservationNumber = $response.reservation_number
    if ($reservationNumber -match '^\d{6}\d{3}$') {
        Write-Host "✅ Format du numéro correct: $reservationNumber" -ForegroundColor Green
        
        # Extraire la date du numéro
        $datePart = $reservationNumber.Substring(0, 6)
        $sequencePart = $reservationNumber.Substring(6, 3)
        
        Write-Host "   - Date: $datePart" -ForegroundColor White
        Write-Host "   - Séquence: $sequencePart" -ForegroundColor White
        
        # Vérifier que la date correspond à aujourd'hui
        $today = Get-Date -Format "yyMMdd"
        if ($datePart -eq $today) {
            Write-Host "✅ Date correspond à aujourd'hui ($today)" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Date ne correspond pas à aujourd'hui (attendu: $today, reçu: $datePart)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ Format du numéro incorrect: $reservationNumber" -ForegroundColor Red
        Write-Host "   Format attendu: YYMMDD + 3 chiffres" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Erreur lors de la création de la réservation:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Test de création d'une deuxième réservation..." -ForegroundColor Cyan

$reservationData2 = @{
    firstName = "Test2"
    lastName = "Final2"
    email = "test2.final@example.com"
    phone = "0987654321"
    date = "2025-09-04"
    timeSlot = "15:00 - 15:20"
    duration = 20
    numberOfPeople = 1
    formula = "pas-content"
    roomName = "Salle de Défoulement U Silenziu"
} | ConvertTo-Json

try {
    $response2 = Invoke-RestMethod -Uri "http://localhost:3000/api/reservations" -Method POST -Body $reservationData2 -ContentType "application/json"
    
    Write-Host "✅ Deuxième réservation créée avec succès!" -ForegroundColor Green
    Write-Host "Numéro de réservation: $($response2.reservation_number)" -ForegroundColor Yellow
    
    # Vérifier que le numéro séquentiel a été incrémenté
    $reservationNumber2 = $response2.reservation_number
    $sequencePart2 = $reservationNumber2.Substring(6, 3)
    
    if ($sequencePart2 -eq "002") {
        Write-Host "✅ Numéro séquentiel correctement incrémenté: $sequencePart2" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Numéro séquentiel inattendu: $sequencePart2 (attendu: 002)" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ Erreur lors de la création de la deuxième réservation:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Test terminé ===" -ForegroundColor Green
