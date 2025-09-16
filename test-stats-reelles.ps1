# Script de test pour valider les statistiques réelles du dashboard
# Ce script teste l'API des statistiques et vérifie que les données sont correctement calculées

Write-Host "🧪 Test des Statistiques Réelles du Dashboard U Silenziu" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$baseUrl = "http://localhost:3000"
$apiUrl = "$baseUrl/api/admin/stats"

# Fonction pour tester une URL
function Test-ApiEndpoint {
    param(
        [string]$url,
        [string]$description
    )
    
    Write-Host "🔍 Test: $description" -ForegroundColor Yellow
    Write-Host "   URL: $url" -ForegroundColor Gray
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method GET -ContentType "application/json"
        
        if ($response.success) {
            Write-Host "   ✅ Succès" -ForegroundColor Green
            return $response
        } else {
            Write-Host "   ❌ Échec: $($response.error)" -ForegroundColor Red
            return $null
        }
    } catch {
        Write-Host "   ❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Fonction pour afficher les statistiques
function Show-Stats {
    param($stats)
    
    Write-Host "📊 Statistiques du Dashboard:" -ForegroundColor Cyan
    Write-Host "   • Total Réservations: $($stats.dashboard.totalReservations)" -ForegroundColor White
    Write-Host "   • Réservations Aujourd'hui: $($stats.dashboard.todayReservations)" -ForegroundColor White
    Write-Host "   • Revenus Totaux: $($stats.dashboard.totalRevenue)€" -ForegroundColor White
    Write-Host "   • Salles Actives: $($stats.dashboard.activeRooms)" -ForegroundColor White
    Write-Host "   • En Attente: $($stats.dashboard.pendingReservations)" -ForegroundColor Yellow
    Write-Host "   • Confirmées: $($stats.dashboard.confirmedReservations)" -ForegroundColor Green
    Write-Host "   • Annulées: $($stats.dashboard.cancelledReservations)" -ForegroundColor Red
    Write-Host ""
}

# Fonction pour afficher le statut du système
function Show-SystemStatus {
    param($system)
    
    Write-Host "🔧 Statut du Système:" -ForegroundColor Cyan
    $smtpStatus = if ($system.smtp) { "✅ Configuré" } else { "❌ Non configuré" }
    $notifStatus = if ($system.notifications) { "✅ Actives" } else { "❌ Inactives" }
    $dbStatus = if ($system.database) { "✅ Opérationnelle" } else { "❌ Erreur" }
    
    Write-Host "   • SMTP: $smtpStatus" -ForegroundColor White
    Write-Host "   • Notifications: $notifStatus" -ForegroundColor White
    Write-Host "   • Base de données: $dbStatus" -ForegroundColor White
    Write-Host ""
}

# Fonction pour afficher les réservations récentes
function Show-RecentReservations {
    param($reservations)
    
    if ($reservations -and $reservations.Count -gt 0) {
        Write-Host "📋 Réservations Récentes:" -ForegroundColor Cyan
        foreach ($reservation in $reservations) {
            $statusColor = switch ($reservation.status) {
                "confirmed" { "Green" }
                "pending" { "Yellow" }
                "cancelled" { "Red" }
                default { "White" }
            }
            Write-Host "   • $($reservation.reservation_number) - $($reservation.first_name) $($reservation.last_name) - $($reservation.room_name) - $($reservation.status) - $($reservation.amount)€" -ForegroundColor $statusColor
        }
    } else {
        Write-Host "📋 Aucune réservation récente trouvée" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Test 1: Statistiques de base
Write-Host "1️⃣ Test des statistiques de base" -ForegroundColor Magenta
$statsResponse = Test-ApiEndpoint -url $apiUrl -description "Récupération des statistiques de base"

if ($statsResponse) {
    Show-Stats -stats $statsResponse.data
    Show-SystemStatus -system $statsResponse.data.system
}

# Test 2: Statistiques avec réservations récentes
Write-Host "2️⃣ Test avec réservations récentes" -ForegroundColor Magenta
$recentUrl = "$apiUrl?includeRecent=true"
$recentResponse = Test-ApiEndpoint -url $recentUrl -description "Récupération avec réservations récentes"

if ($recentResponse) {
    Show-RecentReservations -reservations $recentResponse.data.recentReservations
}

# Test 3: Statistiques par période
Write-Host "3️⃣ Test des revenus par période" -ForegroundColor Magenta
$periods = @("today", "week", "month", "year")

foreach ($period in $periods) {
    $periodUrl = "$apiUrl?period=$period"
    $periodResponse = Test-ApiEndpoint -url $periodUrl -description "Revenus pour la période: $period"
    
    if ($periodResponse -and $periodResponse.data.periodRevenue -ne $null) {
        Write-Host "   💰 Revenus $period : $($periodResponse.data.periodRevenue)€" -ForegroundColor Green
    }
}

# Test 4: Vérification de la cohérence des données
Write-Host "4️⃣ Vérification de la cohérence des données" -ForegroundColor Magenta

if ($statsResponse) {
    $dashboard = $statsResponse.data.dashboard
    $totalCalculated = $dashboard.pendingReservations + $dashboard.confirmedReservations + $dashboard.cancelledReservations
    
    Write-Host "   🔍 Vérification des totaux:" -ForegroundColor Yellow
    Write-Host "      Total affiché: $($dashboard.totalReservations)" -ForegroundColor White
    Write-Host "      Total calculé: $totalCalculated" -ForegroundColor White
    
    if ($dashboard.totalReservations -eq $totalCalculated) {
        Write-Host "      ✅ Les totaux correspondent" -ForegroundColor Green
    } else {
        Write-Host "      ❌ Incohérence dans les totaux" -ForegroundColor Red
    }
    
    # Vérification des revenus
    if ($dashboard.totalRevenue -ge 0) {
        Write-Host "      ✅ Revenus cohérents" -ForegroundColor Green
    } else {
        Write-Host "      ❌ Revenus négatifs" -ForegroundColor Red
    }
}

# Test 5: Test de performance
Write-Host "5️⃣ Test de performance" -ForegroundColor Magenta
$startTime = Get-Date
$perfResponse = Test-ApiEndpoint -url $apiUrl -description "Test de performance"
$endTime = Get-Date
$duration = ($endTime - $startTime).TotalMilliseconds

if ($perfResponse) {
    Write-Host "   ⏱️ Temps de réponse: $([math]::Round($duration, 2))ms" -ForegroundColor White
    
    if ($duration -lt 1000) {
        Write-Host "   ✅ Performance excellente" -ForegroundColor Green
    } elseif ($duration -lt 3000) {
        Write-Host "   ⚠️ Performance acceptable" -ForegroundColor Yellow
    } else {
        Write-Host "   ❌ Performance lente" -ForegroundColor Red
    }
}

# Résumé final
Write-Host ""
Write-Host "📋 Résumé des Tests" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan

$totalTests = 5
$passedTests = 0

if ($statsResponse) { $passedTests++ }
if ($recentResponse) { $passedTests++ }
if ($periodResponse) { $passedTests++ }
if ($statsResponse -and $dashboard.totalReservations -eq $totalCalculated) { $passedTests++ }
if ($perfResponse -and $duration -lt 3000) { $passedTests++ }

Write-Host "Tests réussis: $passedTests/$totalTests" -ForegroundColor $(if ($passedTests -eq $totalTests) { "Green" } else { "Yellow" })

if ($passedTests -eq $totalTests) {
    Write-Host ""
    Write-Host "🎉 Tous les tests sont passés avec succès !" -ForegroundColor Green
    Write-Host "✅ Les statistiques du dashboard sont maintenant réelles et fonctionnelles" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "⚠️ Certains tests ont échoué. Vérifiez la configuration." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🔗 URLs testées:" -ForegroundColor Cyan
Write-Host "   • Statistiques de base: $apiUrl" -ForegroundColor Gray
Write-Host "   • Avec réservations récentes: $recentUrl" -ForegroundColor Gray
Write-Host "   • Par période: $apiUrl?period=[today|week|month|year]" -ForegroundColor Gray

Write-Host ""
Write-Host "📝 Prochaines étapes:" -ForegroundColor Cyan
Write-Host "   1. Vérifiez le dashboard admin: $baseUrl/admin" -ForegroundColor White
Write-Host "   2. Les statistiques devraient maintenant afficher les vraies données" -ForegroundColor White
Write-Host "   3. Testez la création de nouvelles réservations pour voir les stats se mettre à jour" -ForegroundColor White
