# Script de test pour l'API de réservation U Silenziu

Write-Host "Test de l'API de réservation U Silenziu" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Test 1: Récupérer toutes les réservations (doit retourner un tableau vide)
Write-Host "`n1. Test GET /api/reservations" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/reservations" -Method GET
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Reponse: $($response.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Créer une nouvelle réservation
Write-Host "`n2. Test POST /api/reservations" -ForegroundColor Yellow
$reservationData = @{
    firstName = "Jean"
    lastName = "Dupont"
    email = "jean.dupont@test.com"
    phone = "0123456789"
    date = "2024-12-25"
    timeSlot = "14:00 - 16:00"
    duration = 120
    numberOfPeople = 4
    formula = "Escape Game"
    roomName = "Salle Mystere"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/reservations" -Method POST -Body $reservationData -ContentType "application/json"
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Reponse: $($response.Content)" -ForegroundColor Cyan
    
    # Extraire le numéro de réservation pour les tests suivants
    $reservation = $response.Content | ConvertFrom-Json
    $reservationNumber = $reservation.reservationNumber
    Write-Host "Numero de reservation genere: $reservationNumber" -ForegroundColor Magenta
    
} catch {
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $errorResponse = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorResponse)
        $errorContent = $reader.ReadToEnd()
        Write-Host "Details de l'erreur: $errorContent" -ForegroundColor Red
    }
}

# Test 3: Récupérer la réservation créée
if ($reservationNumber) {
    Write-Host "`n3. Test GET /api/reservations/$reservationNumber" -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000/api/reservations/$reservationNumber" -Method GET
        Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "Reponse: $($response.Content)" -ForegroundColor Cyan
    } catch {
        Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test 4: Mettre à jour le statut de la réservation
if ($reservationNumber) {
    Write-Host "`n4. Test PUT /api/reservations/$reservationNumber" -ForegroundColor Yellow
    $updateData = @{
        status = "confirmed"
    } | ConvertTo-Json
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000/api/reservations/$reservationNumber" -Method PUT -Body $updateData -ContentType "application/json"
        Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "Reponse: $($response.Content)" -ForegroundColor Cyan
    } catch {
        Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test 5: Récupérer les réservations par date
Write-Host "`n5. Test GET /api/reservations/date/2024-12-25" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/reservations/date/2024-12-25" -Method GET
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Reponse: $($response.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Récupérer toutes les réservations (doit maintenant contenir la réservation créée)
Write-Host "`n6. Test GET /api/reservations (apres creation)" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/reservations" -Method GET
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Reponse: $($response.Content)" -ForegroundColor Cyan
} catch {
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTests termines !" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
