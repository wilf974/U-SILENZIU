# Script de test pour vérifier le calcul du prix total des réservations
# Teste que le prix est bien calculé comme : prix par personne × nombre de personnes

Write-Host "🧪 Test du Calcul du Prix Total des Réservations" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

# Configuration
$baseUrl = "http://localhost:3000"
$testData = @{
    firstName = "Test"
    lastName = "Prix"
    email = "test.prix@example.com"
    phone = "0123456789"
    date = "2025-01-15"
    timeSlot = "15:30 - 15:50"
    duration = 20
    numberOfPeople = 4
    formula = "pas-content"
    roomName = "Salle Haches"
}

Write-Host "📋 Données de test:" -ForegroundColor Yellow
Write-Host "  - Salle: $($testData.roomName)" -ForegroundColor White
Write-Host "  - Nombre de personnes: $($testData.numberOfPeople)" -ForegroundColor White
Write-Host "  - Prix attendu par personne: 35€" -ForegroundColor White
Write-Host "  - Prix total attendu: $($testData.numberOfPeople * 35)€" -ForegroundColor White
Write-Host ""

# Test 1: Récupérer le prix de la salle
Write-Host "🔍 Test 1: Récupération du prix de la salle" -ForegroundColor Cyan
try {
    $priceResponse = Invoke-RestMethod -Uri "$baseUrl/api/rooms/price?name=$($testData.roomName)" -Method GET
    Write-Host "  ✅ Prix par personne récupéré: $($priceResponse.price)€" -ForegroundColor Green
    
    if ($priceResponse.price -eq 35) {
        Write-Host "  ✅ Prix correct (35€)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Prix incorrect. Attendu: 35€, Reçu: $($priceResponse.price)€" -ForegroundColor Red
    }
} catch {
    Write-Host "  ❌ Erreur lors de la récupération du prix: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 2: Créer une réservation et vérifier le montant
Write-Host "🔍 Test 2: Création d'une réservation avec calcul du prix total" -ForegroundColor Cyan
try {
    $reservationResponse = Invoke-RestMethod -Uri "$baseUrl/api/reservations" -Method POST -Body ($testData | ConvertTo-Json) -ContentType "application/json"
    Write-Host "  ✅ Réservation créée avec succès" -ForegroundColor Green
    Write-Host "  📝 Numéro de réservation: $($reservationResponse.reservation_number)" -ForegroundColor White
    Write-Host "  💰 Montant enregistré: $($reservationResponse.amount)€" -ForegroundColor White
    
    $expectedAmount = $testData.numberOfPeople * 35
    if ($reservationResponse.amount -eq $expectedAmount) {
        Write-Host "  ✅ Montant correct: $($reservationResponse.amount)€ (35€ × $($testData.numberOfPeople) personnes)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Montant incorrect. Attendu: $expectedAmount€, Reçu: $($reservationResponse.amount)€" -ForegroundColor Red
    }
} catch {
    Write-Host "  ❌ Erreur lors de la création de la réservation: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 3: Vérifier dans l'API admin
Write-Host "🔍 Test 3: Vérification dans l'API admin" -ForegroundColor Cyan
try {
    $adminResponse = Invoke-RestMethod -Uri "$baseUrl/api/admin/reservations" -Method GET
    $latestReservation = $adminResponse.data | Sort-Object created_at -Descending | Select-Object -First 1
    
    if ($latestReservation) {
        Write-Host "  ✅ Réservation trouvée dans l'admin" -ForegroundColor Green
        Write-Host "  📝 Numéro: $($latestReservation.reservation_number)" -ForegroundColor White
        Write-Host "  👥 Personnes: $($latestReservation.number_of_people)" -ForegroundColor White
        Write-Host "  💰 Montant: $($latestReservation.amount)€" -ForegroundColor White
        
        $expectedAmount = $latestReservation.number_of_people * 35
        if ($latestReservation.amount -eq $expectedAmount) {
            Write-Host "  ✅ Montant correct dans l'admin: $($latestReservation.amount)€" -ForegroundColor Green
        } else {
            Write-Host "  ❌ Montant incorrect dans l'admin. Attendu: $expectedAmount€, Reçu: $($latestReservation.amount)€" -ForegroundColor Red
        }
        
        # Vérifier les statistiques
        Write-Host "  📊 Revenus totaux: $($adminResponse.stats.totalRevenue)€" -ForegroundColor White
    } else {
        Write-Host "  ❌ Aucune réservation trouvée dans l'admin" -ForegroundColor Red
    }
} catch {
    Write-Host "  ❌ Erreur lors de la vérification admin: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 4: Test avec différentes configurations
Write-Host "🔍 Test 4: Test avec 2 personnes" -ForegroundColor Cyan
$testData2 = $testData.Clone()
$testData2.numberOfPeople = 2
$testData2.email = "test2.prix@example.com"

try {
    $reservationResponse2 = Invoke-RestMethod -Uri "$baseUrl/api/reservations" -Method POST -Body ($testData2 | ConvertTo-Json) -ContentType "application/json"
    Write-Host "  ✅ Réservation 2 personnes créée" -ForegroundColor Green
    Write-Host "  💰 Montant: $($reservationResponse2.amount)€" -ForegroundColor White
    
    $expectedAmount2 = 2 * 35
    if ($reservationResponse2.amount -eq $expectedAmount2) {
        Write-Host "  ✅ Montant correct pour 2 personnes: $($reservationResponse2.amount)€" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Montant incorrect pour 2 personnes. Attendu: $expectedAmount2€, Reçu: $($reservationResponse2.amount)€" -ForegroundColor Red
    }
} catch {
    Write-Host "  ❌ Erreur lors du test 2 personnes: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

Write-Host "🎯 Résumé du test:" -ForegroundColor Green
Write-Host "  - Le prix par personne doit être récupéré correctement depuis la base de données" -ForegroundColor White
Write-Host "  - Le montant total doit être calculé comme: prix par personne × nombre de personnes" -ForegroundColor White
Write-Host "  - Les statistiques admin doivent refléter le bon montant total" -ForegroundColor White
Write-Host "  - Le back-office doit afficher le montant total correct" -ForegroundColor White
Write-Host ""
Write-Host "✅ Test terminé!" -ForegroundColor Green
