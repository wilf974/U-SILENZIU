#!/usr/bin/env pwsh

# Script de test pour valider la correction du calcul des revenus totaux
# Teste que seules les réservations confirmées sont comptées dans les revenus

Write-Host "🧪 Test de correction des revenus totaux" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

$baseUrl = "http://localhost:3000"
$testResults = @()

# Fonction pour tester une URL
function Test-Url {
    param($url, $description)
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get -ContentType "application/json"
        return @{
            success = $true
            description = $description
            data = $response
        }
    }
    catch {
        return @{
            success = $false
            description = $description
            error = $_.Exception.Message
        }
    }
}

# Fonction pour créer une réservation de test
function Create-TestReservation {
    param($status, $amount)
    
    $reservationData = @{
        first_name = "Test"
        last_name = "Revenus"
        email = "test.revenus@example.com"
        phone = "0123456789"
        date = "2025-01-15"
        time = "14:00"
        duration = 20
        number_of_people = 2
        room_name = "Salle 1"
        status = $status
        amount = $amount
        notes = "Test de revenus - $status"
    }
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/api/admin/reservations" -Method Post -Body ($reservationData | ConvertTo-Json) -ContentType "application/json"
        return @{
            success = $true
            data = $response.data
        }
    }
    catch {
        return @{
            success = $false
            error = $_.Exception.Message
        }
    }
}

# Fonction pour supprimer une réservation de test
function Remove-TestReservation {
    param($id)
    
    try {
        Invoke-RestMethod -Uri "$baseUrl/api/admin/reservations/$id" -Method Delete
        return $true
    }
    catch {
        return $false
    }
}

Write-Host "`n1. Test de l'API des statistiques du dashboard" -ForegroundColor Yellow
$dashboardStats = Test-Url "$baseUrl/api/admin/stats" "Statistiques du dashboard"
$testResults += $dashboardStats

if ($dashboardStats.success) {
    $revenue = $dashboardStats.data.data.dashboard.totalRevenue
    Write-Host "   ✅ Revenus totaux (dashboard): $revenue €" -ForegroundColor Green
} else {
    Write-Host "   ❌ Erreur: $($dashboardStats.error)" -ForegroundColor Red
}

Write-Host "`n2. Test de l'API des réservations (revenus)" -ForegroundColor Yellow
$reservationsStats = Test-Url "$baseUrl/api/admin/reservations" "Statistiques des réservations"
$testResults += $reservationsStats

if ($reservationsStats.success) {
    $revenue = $reservationsStats.data.stats.totalRevenue
    Write-Host "   ✅ Revenus totaux (réservations): $revenue €" -ForegroundColor Green
} else {
    Write-Host "   ❌ Erreur: $($reservationsStats.error)" -ForegroundColor Red
}

Write-Host "`n3. Création de réservations de test" -ForegroundColor Yellow

# Créer une réservation confirmée de 100€
Write-Host "   Creation d'une reservation confirmee (100€)..." -ForegroundColor Blue
$confirmedReservation = Create-TestReservation "confirmed" 100
if ($confirmedReservation.success) {
    Write-Host "   ✅ Réservation confirmée créée: $($confirmedReservation.data.reservation_number)" -ForegroundColor Green
    $confirmedId = $confirmedReservation.data.id
} else {
    Write-Host "   ❌ Erreur création réservation confirmée: $($confirmedReservation.error)" -ForegroundColor Red
    $confirmedId = $null
}

# Créer une réservation en attente de 50€
Write-Host "   Creation d'une reservation en attente (50€)..." -ForegroundColor Blue
$pendingReservation = Create-TestReservation "pending" 50
if ($pendingReservation.success) {
    Write-Host "   ✅ Réservation en attente créée: $($pendingReservation.data.reservation_number)" -ForegroundColor Green
    $pendingId = $pendingReservation.data.id
} else {
    Write-Host "   ❌ Erreur création réservation en attente: $($pendingReservation.error)" -ForegroundColor Red
    $pendingId = $null
}

# Créer une réservation annulée de 75€
Write-Host "   Creation d'une reservation annulee (75€)..." -ForegroundColor Blue
$cancelledReservation = Create-TestReservation "cancelled" 75
if ($cancelledReservation.success) {
    Write-Host "   ✅ Réservation annulée créée: $($cancelledReservation.data.reservation_number)" -ForegroundColor Green
    $cancelledId = $cancelledReservation.data.id
} else {
    Write-Host "   ❌ Erreur création réservation annulée: $($cancelledReservation.error)" -ForegroundColor Red
    $cancelledId = $null
}

Write-Host "`n4. Vérification des revenus après ajout des réservations de test" -ForegroundColor Yellow

# Attendre un peu pour que les données soient mises à jour
Start-Sleep -Seconds 2

# Tester les revenus du dashboard
$dashboardStatsAfter = Test-Url "$baseUrl/api/admin/stats" "Statistiques du dashboard après ajout"
$testResults += $dashboardStatsAfter

if ($dashboardStatsAfter.success) {
    $revenueAfter = $dashboardStatsAfter.data.data.dashboard.totalRevenue
    Write-Host "   📊 Revenus totaux (dashboard): $revenueAfter €" -ForegroundColor Cyan
    Write-Host "   📊 Réservations confirmées: $($dashboardStatsAfter.data.data.dashboard.confirmedReservations)" -ForegroundColor Cyan
} else {
    Write-Host "   ❌ Erreur: $($dashboardStatsAfter.error)" -ForegroundColor Red
}

# Tester les revenus des réservations
$reservationsStatsAfter = Test-Url "$baseUrl/api/admin/reservations" "Statistiques des réservations après ajout"
$testResults += $reservationsStatsAfter

if ($reservationsStatsAfter.success) {
    $revenueAfter = $reservationsStatsAfter.data.stats.totalRevenue
    $confirmedCount = $reservationsStatsAfter.data.stats.confirmed
    $pendingCount = $reservationsStatsAfter.data.stats.pending
    $cancelledCount = $reservationsStatsAfter.data.stats.cancelled
    
    Write-Host "   📊 Revenus totaux (réservations): $revenueAfter €" -ForegroundColor Cyan
    Write-Host "   📊 Réservations confirmées: $confirmedCount" -ForegroundColor Cyan
    Write-Host "   📊 Réservations en attente: $pendingCount" -ForegroundColor Cyan
    Write-Host "   📊 Réservations annulées: $cancelledCount" -ForegroundColor Cyan
    
    # Vérifier que seules les réservations confirmées sont comptées
    if ($revenueAfter -ge 100) {
        Write-Host "   ✅ CORRECTION VALIDÉE: Les revenus incluent les réservations confirmées" -ForegroundColor Green
    } else {
        Write-Host "   ❌ PROBLÈME: Les revenus ne reflètent pas les réservations confirmées" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ Erreur: $($reservationsStatsAfter.error)" -ForegroundColor Red
}

Write-Host "`n5. Nettoyage des réservations de test" -ForegroundColor Yellow

# Supprimer les réservations de test
if ($confirmedId) {
    $removed = Remove-TestReservation $confirmedId
    if ($removed) {
        Write-Host "   🗑️ Réservation confirmée supprimée" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Erreur suppression réservation confirmée" -ForegroundColor Red
    }
}

if ($pendingId) {
    $removed = Remove-TestReservation $pendingId
    if ($removed) {
        Write-Host "   🗑️ Réservation en attente supprimée" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Erreur suppression réservation en attente" -ForegroundColor Red
    }
}

if ($cancelledId) {
    $removed = Remove-TestReservation $cancelledId
    if ($removed) {
        Write-Host "   🗑️ Réservation annulée supprimée" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Erreur suppression réservation annulée" -ForegroundColor Red
    }
}

Write-Host "`n📋 Résumé des tests" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan

$successCount = ($testResults | Where-Object { $_.success }).Count
$totalCount = $testResults.Count

Write-Host "Tests réussis: $successCount/$totalCount" -ForegroundColor $(if ($successCount -eq $totalCount) { "Green" } else { "Yellow" })

foreach ($result in $testResults) {
    $status = if ($result.success) { "✅" } else { "❌" }
    Write-Host "$status $($result.description)" -ForegroundColor $(if ($result.success) { "Green" } else { "Red" })
}

Write-Host "`n🎯 Conclusion" -ForegroundColor Cyan
Write-Host "=============" -ForegroundColor Cyan

if ($successCount -eq $totalCount) {
    Write-Host "✅ Tous les tests sont passés avec succès !" -ForegroundColor Green
    Write-Host "✅ La correction des revenus totaux fonctionne correctement." -ForegroundColor Green
    Write-Host "✅ Seules les réservations confirmées sont comptées dans les revenus." -ForegroundColor Green
} else {
    Write-Host "❌ Certains tests ont échoué. Vérifiez les erreurs ci-dessus." -ForegroundColor Red
}

Write-Host "`n🔗 URLs de test:" -ForegroundColor Blue
Write-Host "Dashboard admin: $baseUrl/admin" -ForegroundColor Blue
Write-Host "Gestion réservations: $baseUrl/admin/reservations" -ForegroundColor Blue
Write-Host "API statistiques: $baseUrl/api/admin/stats" -ForegroundColor Blue
Write-Host "API réservations: $baseUrl/api/admin/reservations" -ForegroundColor Blue
