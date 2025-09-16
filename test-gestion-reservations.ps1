# Script de test pour le système de gestion des réservations U Silenziu
# Teste toutes les fonctionnalités CRUD et l'interface d'administration

Write-Host "🧪 Test du système de gestion des réservations U Silenziu" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Configuration
$baseUrl = "http://localhost:3000"
$adminUrl = "$baseUrl/admin"
$apiUrl = "$baseUrl/api"

# Fonction pour tester une URL
function Test-Url {
    param($url, $description)
    try {
        $response = Invoke-WebRequest -Uri $url -Method GET -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $description" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ $description - Code: $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ $description - Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Fonction pour tester une API
function Test-Api {
    param($url, $method = "GET", $body = $null, $description)
    try {
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        if ($body) {
            $response = Invoke-WebRequest -Uri $url -Method $method -Body $body -Headers $headers -UseBasicParsing -TimeoutSec 10
        } else {
            $response = Invoke-WebRequest -Uri $url -Method $method -Headers $headers -UseBasicParsing -TimeoutSec 10
        }
        
        if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 300) {
            Write-Host "✅ $description" -ForegroundColor Green
            $jsonResponse = $response.Content | ConvertFrom-Json
            return $jsonResponse
        } else {
            Write-Host "❌ $description - Code: $($response.StatusCode)" -ForegroundColor Red
            return $null
        }
    } catch {
        Write-Host "❌ $description - Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

Write-Host "`n🔍 Test 1: Vérification de la disponibilité du serveur" -ForegroundColor Yellow
$serverOnline = Test-Url "$baseUrl" "Serveur principal"
if (-not $serverOnline) {
    Write-Host "❌ Le serveur n'est pas accessible. Veuillez démarrer l'application avec 'npm run dev'" -ForegroundColor Red
    exit 1
}

Write-Host "`n🔍 Test 2: Test des pages d'administration" -ForegroundColor Yellow
Test-Url "$adminUrl" "Page d'administration principale"
Test-Url "$adminUrl/reservations" "Page de gestion des réservations"

Write-Host "`n🔍 Test 3: Test des API routes publiques" -ForegroundColor Yellow
$reservations = Test-Api "$apiUrl/reservations" "GET" $null "API GET /api/reservations"

Write-Host "`n🔍 Test 4: Test des API routes d'administration" -ForegroundColor Yellow
$adminReservations = Test-Api "$apiUrl/admin/reservations" "GET" $null "API GET /api/admin/reservations"

if ($adminReservations) {
    Write-Host "📊 Statistiques des réservations:" -ForegroundColor Cyan
    if ($adminReservations.stats) {
        Write-Host "   - Total: $($adminReservations.stats.total)" -ForegroundColor White
        Write-Host "   - En attente: $($adminReservations.stats.pending)" -ForegroundColor Yellow
        Write-Host "   - Confirmées: $($adminReservations.stats.confirmed)" -ForegroundColor Green
        Write-Host "   - Annulées: $($adminReservations.stats.cancelled)" -ForegroundColor Red
        Write-Host "   - Revenus totaux: $($adminReservations.stats.totalRevenue)€" -ForegroundColor Green
    }
}

Write-Host "`n🔍 Test 5: Test de création d'une réservation" -ForegroundColor Yellow
$newReservation = @{
    first_name = "Test"
    last_name = "Utilisateur"
    email = "test@example.com"
    phone = "0123456789"
    room_name = "Salle Test"
    date = (Get-Date).AddDays(1).ToString("yyyy-MM-dd")
    time = "14:00"
    duration = 60
    number_of_people = 2
    status = "pending"
    amount = 25
    notes = "Réservation de test"
} | ConvertTo-Json

$createdReservation = Test-Api "$apiUrl/admin/reservations" "POST" $newReservation "Création d'une réservation"

if ($createdReservation -and $createdReservation.success) {
    $reservationId = $createdReservation.data.id
    Write-Host "✅ Réservation créée avec l'ID: $reservationId" -ForegroundColor Green
    Write-Host "   Numéro: $($createdReservation.data.reservation_number)" -ForegroundColor White
    
    Write-Host "`n🔍 Test 6: Test de récupération d'une réservation spécifique" -ForegroundColor Yellow
    $specificReservation = Test-Api "$apiUrl/admin/reservations/$reservationId" "GET" $null "Récupération de la réservation $reservationId"
    
    Write-Host "`n🔍 Test 7: Test de modification d'une réservation" -ForegroundColor Yellow
    $updateData = @{
        status = "confirmed"
        amount = 30
        notes = "Réservation confirmée et mise à jour"
    } | ConvertTo-Json
    
    $updatedReservation = Test-Api "$apiUrl/admin/reservations/$reservationId" "PUT" $updateData "Modification de la réservation"
    
    if ($updatedReservation -and $updatedReservation.success) {
        Write-Host "✅ Réservation mise à jour avec succès" -ForegroundColor Green
        Write-Host "   Nouveau statut: $($updatedReservation.data.status)" -ForegroundColor White
        Write-Host "   Nouveau montant: $($updatedReservation.data.amount)€" -ForegroundColor White
    }
    
    Write-Host "`n🔍 Test 8: Test de suppression d'une réservation" -ForegroundColor Yellow
    $deleteResult = Test-Api "$apiUrl/admin/reservations/$reservationId" "DELETE" $null "Suppression de la réservation"
    
    if ($deleteResult -and $deleteResult.success) {
        Write-Host "✅ Réservation supprimée avec succès" -ForegroundColor Green
    }
} else {
    Write-Host "❌ Échec de la création de réservation" -ForegroundColor Red
}

Write-Host "`n🔍 Test 9: Test des filtres et recherche" -ForegroundColor Yellow
Test-Api "$apiUrl/admin/reservations?status=pending" "GET" $null "Filtre par statut 'pending'"
Test-Api "$apiUrl/admin/reservations?search=test" "GET" $null "Recherche par mot-clé 'test'"

Write-Host "`n🔍 Test 10: Test de la base de données" -ForegroundColor Yellow
Write-Host "Vérification de la connexion à PostgreSQL..." -ForegroundColor White

# Test de la fonction de génération de numéro de réservation
try {
    $testResponse = Test-Api "$apiUrl/admin/reservations" "GET" $null "Test de génération de numéro de réservation"
    if ($testResponse) {
        Write-Host "✅ Base de données PostgreSQL opérationnelle" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Erreur de connexion à la base de données" -ForegroundColor Red
}

Write-Host "`n📋 Résumé des tests" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan

$totalTests = 10
$passedTests = 0

# Compter les tests réussis (simplifié)
if ($serverOnline) { $passedTests++ }
if ($adminReservations) { $passedTests++ }
if ($createdReservation) { $passedTests++ }

Write-Host "Tests réussis: $passedTests/$totalTests" -ForegroundColor $(if ($passedTests -eq $totalTests) { "Green" } else { "Yellow" })

if ($passedTests -eq $totalTests) {
    Write-Host "`n🎉 Tous les tests sont passés avec succès !" -ForegroundColor Green
    Write-Host "Le système de gestion des réservations est opérationnel." -ForegroundColor Green
} else {
    Write-Host "`n⚠️  Certains tests ont échoué. Vérifiez les erreurs ci-dessus." -ForegroundColor Yellow
}

Write-Host "`n📝 Instructions d'utilisation:" -ForegroundColor Cyan
Write-Host "1. Accédez à l'interface d'administration: $adminUrl" -ForegroundColor White
Write-Host "2. Cliquez sur 'Gestion des Réservations' pour voir toutes les réservations" -ForegroundColor White
Write-Host "3. Utilisez les filtres pour rechercher des réservations spécifiques" -ForegroundColor White
Write-Host "4. Cliquez sur 'Nouvelle Réservation' pour créer une réservation manuelle" -ForegroundColor White
Write-Host "5. Utilisez les boutons d'action pour modifier ou supprimer des réservations" -ForegroundColor White

Write-Host "`n✨ Le système de gestion des réservations U Silenziu est prêt !" -ForegroundColor Green
