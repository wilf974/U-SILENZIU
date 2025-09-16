# Script de test pour diagnostiquer les emails de confirmation
Write-Host "=== Test de diagnostic des emails de confirmation ===" -ForegroundColor Green

# Test 1: Vérifier l'API des salles
Write-Host "`n1. Test de l'API des salles..." -ForegroundColor Yellow
try {
    $roomsResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/rooms" -Method GET
    Write-Host "✅ API salles accessible - $($roomsResponse.count) salles trouvées"
    foreach ($room in $roomsResponse.data) {
        Write-Host "   - $($room.name) (Prix: $($room.price)€)"
    }
} catch {
    Write-Host "❌ Erreur API salles: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Créer une réservation
Write-Host "`n2. Test de création de réservation..." -ForegroundColor Yellow
$testData = @{
    firstName = "Test"
    lastName = "Email"
    email = "test@example.com"
    phone = "0123456789"
    date = "2025-01-15"
    timeSlot = "14:00 - 14:30"
    duration = 30
    numberOfPeople = 2
    formula = "standard"
    roomName = "Salle Défoulement"
} | ConvertTo-Json

Write-Host "Données envoyées: $testData"

try {
    $reservation = Invoke-RestMethod -Uri "http://localhost:3000/api/reservations" -Method POST -Body $testData -ContentType "application/json"
    Write-Host "✅ Réservation créée avec succès !" -ForegroundColor Green
    Write-Host "   ID: $($reservation.id)"
    Write-Host "   Numéro: $($reservation.reservation_number)"
    Write-Host "   Montant: $($reservation.amount) (type: $($reservation.amount.GetType().Name))"
    Write-Host "   Email: $($reservation.email)"
    Write-Host "   Statut: $($reservation.status)"
    
    # Test 3: Confirmer la réservation
    Write-Host "`n3. Test de confirmation de réservation..." -ForegroundColor Yellow
    $confirmData = @{
        status = "confirmed"
    } | ConvertTo-Json
    
    try {
        $confirmedReservation = Invoke-RestMethod -Uri "http://localhost:3000/api/admin/reservations/$($reservation.id)" -Method PUT -Body $confirmData -ContentType "application/json"
        Write-Host "✅ Réservation confirmée avec succès !" -ForegroundColor Green
        Write-Host "   Nouveau statut: $($confirmedReservation.data.status)"
    } catch {
        Write-Host "❌ Erreur lors de la confirmation: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Test 4: Nettoyer - supprimer la réservation de test
    Write-Host "`n4. Nettoyage - suppression de la réservation de test..." -ForegroundColor Yellow
    try {
        Invoke-RestMethod -Uri "http://localhost:3000/api/admin/reservations/$($reservation.id)" -Method DELETE
        Write-Host "✅ Réservation de test supprimée" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Impossible de supprimer la réservation de test: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ Erreur lors de la création de la réservation:" -ForegroundColor Red
    Write-Host "   Message: $($_.Exception.Message)"
    Write-Host "   Status Code: $($_.Exception.Response.StatusCode)"
    
    # Essayer de récupérer plus de détails sur l'erreur
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $responseBody = $reader.ReadToEnd()
        Write-Host "   Détails: $responseBody"
    }
}

Write-Host "`n=== Fin du test ===" -ForegroundColor Green
