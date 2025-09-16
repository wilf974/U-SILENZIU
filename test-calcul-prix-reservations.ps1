# Script de test pour valider le calcul automatique des prix lors des reservations
# Teste les routes API pour s'assurer que le montant est correctement calcule

Write-Host "Test du calcul automatique des prix des reservations" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

$baseUrl = "http://localhost:3000"
$testResults = @()

# Fonction pour tester une API
function Test-API {
    param(
        [string]$Method,
        [string]$Url,
        [object]$Body = $null,
        [string]$Description
    )
    
    Write-Host "`n$Description" -ForegroundColor Yellow
    
    try {
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        if ($Body) {
            $jsonBody = $Body | ConvertTo-Json -Depth 10
            Write-Host "   Donnees envoyees: $jsonBody" -ForegroundColor Gray
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Headers $headers -Body $jsonBody
        } else {
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Headers $headers
        }
        
        Write-Host "   Succès" -ForegroundColor Green
        return $response
    }
    catch {
        Write-Host "   Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Test 1: Verifier les salles disponibles et leurs prix
Write-Host "`nTest 1: Recuperation des salles et leurs prix" -ForegroundColor Magenta
$rooms = Test-API -Method "GET" -Url "$baseUrl/api/admin/rooms" -Description "Recuperation des salles"

if ($rooms -and $rooms.success) {
    Write-Host "   Salles trouvees:" -ForegroundColor Green
    foreach ($room in $rooms.data) {
        Write-Host "   - $($room.name): $($room.price)€" -ForegroundColor White
    }
} else {
    Write-Host "   Impossible de recuperer les salles" -ForegroundColor Red
    $testResults += "Recuperation des salles: ECHEC"
}

# Test 2: Creer une reservation via l'API publique (doit calculer le prix automatiquement)
Write-Host "`nTest 2: Creation de reservation via API publique" -ForegroundColor Magenta

$reservationData = @{
    firstName = "Test"
    lastName = "Prix"
    email = "test.prix@example.com"
    phone = "0123456789"
    date = "2025-01-15"
    timeSlot = "14:00 - 14:20"
    duration = 20
    numberOfPeople = 2
    formula = "pas-content"
    roomName = "Salle Haches"
}

$reservation = Test-API -Method "POST" -Url "$baseUrl/api/reservations" -Body $reservationData -Description "Creation reservation publique"

if ($reservation) {
    Write-Host "   Montant calcule: $($reservation.amount)€" -ForegroundColor Green
    if ($reservation.amount -gt 0) {
        Write-Host "   Prix correctement calcule" -ForegroundColor Green
        $testResults += "API publique: Prix calcule correctement ($($reservation.amount)€)"
    } else {
        Write-Host "   Prix non calcule (0€)" -ForegroundColor Red
        $testResults += "API publique: Prix non calcule"
    }
} else {
    $testResults += "API publique: Echec de creation"
}

# Test 3: Creer une reservation via l'API admin (doit calculer le prix automatiquement)
Write-Host "`nTest 3: Creation de reservation via API admin" -ForegroundColor Magenta

$adminReservationData = @{
    first_name = "Admin"
    last_name = "Test"
    email = "admin.test@example.com"
    phone = "0987654321"
    date = "2025-01-16"
    time = "15:00:00"
    duration = 30
    number_of_people = 4
    room_name = "Salle Défoulement"
    status = "pending"
    notes = "Test calcul prix automatique"
}

$adminReservation = Test-API -Method "POST" -Url "$baseUrl/api/admin/reservations" -Body $adminReservationData -Description "Creation reservation admin"

if ($adminReservation -and $adminReservation.success) {
    $amount = $adminReservation.data.amount
    Write-Host "   Montant calcule: $amount€" -ForegroundColor Green
    if ($amount -gt 0) {
        Write-Host "   Prix correctement calcule" -ForegroundColor Green
        $testResults += "API admin: Prix calcule correctement ($amount€)"
    } else {
        Write-Host "   Prix non calcule (0€)" -ForegroundColor Red
        $testResults += "API admin: Prix non calcule"
    }
} else {
    $testResults += "API admin: Echec de creation"
}

# Test 4: Verifier les reservations creees
Write-Host "`nTest 4: Verification des reservations creees" -ForegroundColor Magenta

$allReservations = Test-API -Method "GET" -Url "$baseUrl/api/admin/reservations" -Description "Recuperation des reservations"

if ($allReservations -and $allReservations.success) {
    $recentReservations = $allReservations.data | Where-Object { $_.first_name -like "*Test*" -or $_.first_name -like "*Admin*" }
    Write-Host "   Reservations de test trouvees:" -ForegroundColor Green
    foreach ($res in $recentReservations) {
        Write-Host "   - $($res.reservation_number): $($res.first_name) $($res.last_name) - $($res.room_name) - $($res.amount)€" -ForegroundColor White
    }
    
    # Verifier le revenu total
    $totalRevenue = $allReservations.stats.totalRevenue
    Write-Host "   Revenus totaux: $totalRevenue€" -ForegroundColor Green
    if ($totalRevenue -gt 0) {
        Write-Host "   Revenus correctement calcules" -ForegroundColor Green
        $testResults += "Revenus totaux: $totalRevenue€"
    } else {
        Write-Host "   Revenus non calcules" -ForegroundColor Red
        $testResults += "Revenus totaux: Non calcules"
    }
} else {
    $testResults += "Recuperation reservations: Echec"
}

# Test 5: Test avec une salle inexistante
Write-Host "`nTest 5: Test avec salle inexistante" -ForegroundColor Magenta

$invalidRoomData = @{
    firstName = "Test"
    lastName = "SalleInexistante"
    email = "test.invalid@example.com"
    phone = "0111111111"
    date = "2025-01-17"
    timeSlot = "16:00 - 16:20"
    duration = 20
    numberOfPeople = 2
    formula = "pas-content"
    roomName = "Salle Inexistante"
}

$invalidReservation = Test-API -Method "POST" -Url "$baseUrl/api/reservations" -Body $invalidRoomData -Description "Test salle inexistante"

if ($invalidReservation) {
    Write-Host "   Montant avec salle inexistante: $($invalidReservation.amount)€" -ForegroundColor Yellow
    if ($invalidReservation.amount -eq 0) {
        Write-Host "   Gestion correcte de la salle inexistante (0€)" -ForegroundColor Green
        $testResults += "Salle inexistante: Gestion correcte (0€)"
    } else {
        Write-Host "   Prix inattendu pour salle inexistante" -ForegroundColor Yellow
        $testResults += "Salle inexistante: Prix inattendu"
    }
} else {
    $testResults += "Test salle inexistante: Echec"
}

# Resume des tests
Write-Host "`nRESUME DES TESTS" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan

$successCount = ($testResults | Where-Object { $_ -like "*correctement*" -or $_ -like "*correcte*" -or $_ -like "*€*" }).Count
$failureCount = ($testResults | Where-Object { $_ -like "*ECHEC*" -or $_ -like "*non calcule*" -or $_ -like "*Echec*" }).Count
$warningCount = ($testResults | Where-Object { $_ -like "*inattendu*" }).Count

Write-Host "`nResultats:" -ForegroundColor White
foreach ($result in $testResults) {
    Write-Host "  $result" -ForegroundColor White
}

Write-Host "`nStatistiques:" -ForegroundColor White
Write-Host "  Succès: $successCount" -ForegroundColor Green
Write-Host "  Echecs: $failureCount" -ForegroundColor Red
Write-Host "  Avertissements: $warningCount" -ForegroundColor Yellow

if ($failureCount -eq 0) {
    Write-Host "`nTOUS LES TESTS SONT PASSES !" -ForegroundColor Green
    Write-Host "Le systeme de calcul automatique des prix fonctionne correctement." -ForegroundColor Green
} else {
    Write-Host "`nCERTAINS TESTS ONT ECHOUE" -ForegroundColor Yellow
    Write-Host "Verifiez les erreurs ci-dessus et corrigez les problemes." -ForegroundColor Yellow
}

Write-Host "`nInstructions de nettoyage:" -ForegroundColor Cyan
Write-Host "Pour supprimer les reservations de test creees, utilisez l'interface admin:" -ForegroundColor White
Write-Host "1. Allez sur http://localhost:3000/admin/reservations" -ForegroundColor White
Write-Host "2. Recherchez les reservations avec 'Test' ou 'Admin' dans le nom" -ForegroundColor White
Write-Host "3. Supprimez-les via l'interface" -ForegroundColor White

Write-Host "`nTest termine !" -ForegroundColor Cyan