#!/usr/bin/env pwsh

# Script de diagnostic pour le problème d'affichage des prix des salles
# Après modification/suppression de salles

Write-Host "🔍 DIAGNOSTIC - Problème d'affichage des prix des salles" -ForegroundColor Yellow
Write-Host "=================================================" -ForegroundColor Yellow
Write-Host ""

# Configuration
$baseUrl = "http://localhost:3000"
$adminUrl = "$baseUrl/admin"

Write-Host "📋 1. Vérification de l'état des salles dans la base de données" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------" -ForegroundColor Cyan

try {
    # Test de l'API des salles actives
    Write-Host "🔍 Récupération des salles actives..." -ForegroundColor Green
    $response = Invoke-RestMethod -Uri "$baseUrl/api/rooms" -Method GET -ContentType "application/json"
    
    if ($response.success) {
        Write-Host "✅ API des salles accessible" -ForegroundColor Green
        Write-Host "📊 Nombre de salles actives: $($response.count)" -ForegroundColor White
        
        if ($response.data.Count -gt 0) {
            Write-Host ""
            Write-Host "📋 Salles disponibles:" -ForegroundColor Yellow
            foreach ($room in $response.data) {
                Write-Host "  • $($room.name) - Prix: $($room.price)€ - Durée: $($room.duration)min - Max: $($room.max_people) personnes" -ForegroundColor White
            }
        } else {
            Write-Host "⚠️  Aucune salle active trouvée!" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Erreur API des salles: $($response.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors de la récupération des salles: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "📋 2. Test de l'API de récupération des prix" -ForegroundColor Cyan
Write-Host "--------------------------------------------" -ForegroundColor Cyan

# Liste des salles a tester (basee sur l'historique)
$sallesATester = @(
    "Salle Haches",
    "Salle Defoulement", 
    "Salle Shurikens",
    "Color Zone",
    "Salle de Defoulement U Silenziu"
)

foreach ($salle in $sallesATester) {
    try {
        Write-Host "🔍 Test du prix pour: $salle" -ForegroundColor Green
        $encodedName = [System.Web.HttpUtility]::UrlEncode($salle)
        $response = Invoke-RestMethod -Uri "$baseUrl/api/rooms/price?name=$encodedName" -Method GET -ContentType "application/json"
        
        Write-Host "  ✅ Prix trouvé: $($response.price)€ - Durée: $($response.duration)min - Max: $($response.max_people) personnes" -ForegroundColor Green
    } catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Host "  ❌ Salle non trouvée: $salle" -ForegroundColor Red
        } else {
            Write-Host "  ❌ Erreur pour $salle : $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "📋 3. Test de l'API admin des salles" -ForegroundColor Cyan
Write-Host "------------------------------------" -ForegroundColor Cyan

try {
    Write-Host "🔍 Récupération de toutes les salles (admin)..." -ForegroundColor Green
    $response = Invoke-RestMethod -Uri "$baseUrl/api/admin/rooms" -Method GET -ContentType "application/json"
    
    if ($response.success) {
        Write-Host "✅ API admin des salles accessible" -ForegroundColor Green
        Write-Host "📊 Nombre total de salles: $($response.count)" -ForegroundColor White
        
        if ($response.data.Count -gt 0) {
            Write-Host ""
            Write-Host "📋 Toutes les salles (actives et inactives):" -ForegroundColor Yellow
            foreach ($room in $response.data) {
                $status = if ($room.is_active) { "✅ Actif" } else { "❌ Inactif" }
                Write-Host "  • $($room.name) - Prix: $($room.price)€ - $status" -ForegroundColor White
            }
        }
    } else {
        Write-Host "❌ Erreur API admin des salles: $($response.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors de la récupération des salles admin: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "📋 4. Test de l'API de vérification des prix" -ForegroundColor Cyan
Write-Host "---------------------------------------------" -ForegroundColor Cyan

try {
    Write-Host "🔍 Vérification des salles sans prix..." -ForegroundColor Green
    $response = Invoke-RestMethod -Uri "$baseUrl/api/admin/rooms/ensure-prices" -Method GET -ContentType "application/json"
    
    if ($response.success) {
        Write-Host "✅ API de vérification des prix accessible" -ForegroundColor Green
        Write-Host "📊 Salles sans prix: $($response.roomsWithoutPrice)" -ForegroundColor White
        
        if ($response.roomsWithoutPrice -gt 0) {
            Write-Host "⚠️  Il y a $($response.roomsWithoutPrice) salles sans prix!" -ForegroundColor Red
        } else {
            Write-Host "✅ Toutes les salles ont un prix défini" -ForegroundColor Green
        }
    } else {
        Write-Host "❌ Erreur API de vérification des prix: $($response.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors de la vérification des prix: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "📋 5. Test de correction automatique des prix" -ForegroundColor Cyan
Write-Host "-----------------------------------------------" -ForegroundColor Cyan

try {
    Write-Host "🔍 Application du prix par défaut aux salles sans prix..." -ForegroundColor Green
    $response = Invoke-RestMethod -Uri "$baseUrl/api/admin/rooms/ensure-prices" -Method POST -ContentType "application/json" -Body '{\"defaultPrice\": 30}'
    
    if ($response.success) {
        Write-Host "✅ Correction des prix réussie" -ForegroundColor Green
        Write-Host "📊 Salles mises à jour: $($response.updatedRooms)" -ForegroundColor White
    } else {
        Write-Host "❌ Erreur lors de la correction des prix: $($response.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors de la correction des prix: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "📋 6. Test final - Vérification des prix après correction" -ForegroundColor Cyan
Write-Host "--------------------------------------------------------" -ForegroundColor Cyan

foreach ($salle in $sallesATester) {
    try {
        $encodedName = [System.Web.HttpUtility]::UrlEncode($salle)
        $response = Invoke-RestMethod -Uri "$baseUrl/api/rooms/price?name=$encodedName" -Method GET -ContentType "application/json"
        
        Write-Host "  ✅ $salle : $($response.price)€" -ForegroundColor Green
    } catch {
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Host "  ❌ $salle : Salle non trouvée" -ForegroundColor Red
        } else {
            Write-Host "  ❌ $salle : Erreur" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "🎯 RÉSUMÉ DU DIAGNOSTIC" -ForegroundColor Yellow
Write-Host "======================" -ForegroundColor Yellow
Write-Host "✅ Diagnostic terminé" -ForegroundColor Green
Write-Host "📋 Vérifiez les résultats ci-dessus pour identifier le problème" -ForegroundColor White
Write-Host "🔧 Si des salles sont manquantes, vérifiez le mapping dans ReservationForm.tsx" -ForegroundColor White
Write-Host "💰 Si les prix sont a 0€, utilisez l'API de correction automatique" -ForegroundColor White
