#!/usr/bin/env pwsh

# Script de test simple pour valider la correction du calcul des revenus totaux

Write-Host "Test de correction des revenus totaux" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$baseUrl = "http://localhost:3000"

try {
    # Test de l'API des réservations
    Write-Host "`nTest de l'API des réservations..." -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "$baseUrl/api/admin/reservations" -Method Get -ContentType "application/json"
    
    if ($response.success) {
        $revenue = $response.stats.totalRevenue
        $confirmed = $response.stats.confirmed
        $pending = $response.stats.pending
        $cancelled = $response.stats.cancelled
        
        Write-Host "Revenus totaux: $revenue €" -ForegroundColor Green
        Write-Host "Reservations confirmees: $confirmed" -ForegroundColor Green
        Write-Host "Reservations en attente: $pending" -ForegroundColor Green
        Write-Host "Reservations annulees: $cancelled" -ForegroundColor Green
        
        # Vérifier que les revenus correspondent aux réservations confirmées
        $expectedRevenue = 0
        foreach ($reservation in $response.data) {
            if ($reservation.status -eq "confirmed") {
                $expectedRevenue += $reservation.amount
            }
        }
        
        Write-Host "`nVerification:" -ForegroundColor Yellow
        Write-Host "Revenus affiches: $revenue €" -ForegroundColor Cyan
        Write-Host "Revenus calcules (confirmees uniquement): $expectedRevenue €" -ForegroundColor Cyan
        
        if ($revenue -eq $expectedRevenue) {
            Write-Host "`n✅ CORRECTION VALIDEE: Les revenus correspondent aux réservations confirmées uniquement!" -ForegroundColor Green
        } else {
            Write-Host "`n❌ PROBLÈME: Les revenus ne correspondent pas aux réservations confirmées" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Erreur API: $($response.error)" -ForegroundColor Red
    }
    
    # Test de l'API des statistiques du dashboard
    Write-Host "`nTest de l'API des statistiques du dashboard..." -ForegroundColor Yellow
    $statsResponse = Invoke-RestMethod -Uri "$baseUrl/api/admin/stats" -Method Get -ContentType "application/json"
    
    if ($statsResponse.success) {
        $dashboardRevenue = $statsResponse.data.dashboard.totalRevenue
        Write-Host "Revenus dashboard: $dashboardRevenue €" -ForegroundColor Green
        
        if ($revenue -eq $dashboardRevenue) {
            Write-Host "✅ Les revenus sont cohérents entre les deux APIs" -ForegroundColor Green
        } else {
            Write-Host "❌ Incohérence entre les APIs" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Erreur API stats: $($statsResponse.error)" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nURLs de test:" -ForegroundColor Blue
Write-Host "Dashboard admin: $baseUrl/admin" -ForegroundColor Blue
Write-Host "Gestion reservations: $baseUrl/admin/reservations" -ForegroundColor Blue
