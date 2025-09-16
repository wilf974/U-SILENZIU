# Script de test pour le calendrier hebdomadaire des réservations
# Teste l'API et l'interface du calendrier

Write-Host "🧪 Test du Calendrier Hebdomadaire des Réservations" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Configuration
$baseUrl = "http://localhost:3000"
$apiUrl = "$baseUrl/api/admin/reservations/weekly"

# Fonction pour tester une URL
function Test-Url {
    param($url, $description)
    
    try {
        Write-Host "`n📡 Test: $description" -ForegroundColor Yellow
        Write-Host "URL: $url" -ForegroundColor Gray
        
        $response = Invoke-RestMethod -Uri $url -Method GET -ContentType "application/json"
        
        if ($response) {
            Write-Host "✅ Succès: $description" -ForegroundColor Green
            
            # Afficher les informations de la semaine
            if ($response.week) {
                Write-Host "   📅 Semaine: $($response.week.start) à $($response.week.end)" -ForegroundColor White
            }
            
            # Afficher les statistiques
            if ($response.statistics) {
                Write-Host "   📊 Statistiques:" -ForegroundColor White
                Write-Host "      - Total: $($response.statistics.total)" -ForegroundColor White
                Write-Host "      - Confirmées: $($response.statistics.confirmed)" -ForegroundColor Green
                Write-Host "      - En attente: $($response.statistics.pending)" -ForegroundColor Yellow
                Write-Host "      - Annulées: $($response.statistics.cancelled)" -ForegroundColor Red
                Write-Host "      - Revenus: $($response.statistics.revenue)€" -ForegroundColor Green
            }
            
            # Afficher le nombre de réservations par jour
            if ($response.reservations) {
                $totalReservations = 0
                foreach ($day in $response.reservations.PSObject.Properties) {
                    $count = $day.Value.Count
                    $totalReservations += $count
                    if ($count -gt 0) {
                        Write-Host "      - $($day.Name): $count réservation(s)" -ForegroundColor Cyan
                    }
                }
                Write-Host "   📋 Total réservations de la semaine: $totalReservations" -ForegroundColor White
            }
            
            return $true
        } else {
            Write-Host "❌ Échec: $description - Réponse vide" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "❌ Erreur: $description" -ForegroundColor Red
        Write-Host "   Détails: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Fonction pour tester l'interface web
function Test-WebInterface {
    param($url, $description)
    
    try {
        Write-Host "`n🌐 Test: $description" -ForegroundColor Yellow
        Write-Host "URL: $url" -ForegroundColor Gray
        
        $response = Invoke-WebRequest -Uri $url -Method GET -UseBasicParsing
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Succès: $description" -ForegroundColor Green
            Write-Host "   Status: $($response.StatusCode)" -ForegroundColor White
            Write-Host "   Taille: $($response.Content.Length) caractères" -ForegroundColor White
            
            # Vérifier la présence de certains éléments
            $content = $response.Content
            
            if ($content -match "Calendrier Hebdomadaire") {
                Write-Host "   ✅ Titre du calendrier trouvé" -ForegroundColor Green
            } else {
                Write-Host "   ⚠️ Titre du calendrier non trouvé" -ForegroundColor Yellow
            }
            
            if ($content -match "CalendarWeekly") {
                Write-Host "   ✅ Composant CalendarWeekly trouvé" -ForegroundColor Green
            } else {
                Write-Host "   ⚠️ Composant CalendarWeekly non trouvé" -ForegroundColor Yellow
            }
            
            return $true
        } else {
            Write-Host "❌ Échec: $description - Status: $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "❌ Erreur: $description" -ForegroundColor Red
        Write-Host "   Détails: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Tests
$testsPassed = 0
$totalTests = 0

Write-Host "`n🚀 Démarrage des tests..." -ForegroundColor Cyan

# Test 1: API - Semaine courante
$totalTests++
$currentDate = Get-Date -Format "yyyy-MM-dd"
$testUrl = "$apiUrl?week=$currentDate"
if (Test-Url -url $testUrl -description "API - Semaine courante ($currentDate)") {
    $testsPassed++
}

# Test 2: API - Semaine précédente
$totalTests++
$lastWeek = (Get-Date).AddDays(-7).ToString("yyyy-MM-dd")
$testUrl = "$apiUrl?week=$lastWeek"
if (Test-Url -url $testUrl -description "API - Semaine précédente ($lastWeek)") {
    $testsPassed++
}

# Test 3: API - Semaine suivante
$totalTests++
$nextWeek = (Get-Date).AddDays(7).ToString("yyyy-MM-dd")
$testUrl = "$apiUrl?week=$nextWeek"
if (Test-Url -url $testUrl -description "API - Semaine suivante ($nextWeek)") {
    $testsPassed++
}

# Test 4: API - Date invalide
$totalTests++
$invalidDate = "2025-13-45"
$testUrl = "$apiUrl?week=$invalidDate"
try {
    $response = Invoke-RestMethod -Uri $testUrl -Method GET -ContentType "application/json"
    Write-Host "`n❌ Test: API - Date invalide ($invalidDate)" -ForegroundColor Red
    Write-Host "   Échec: L'API devrait retourner une erreur pour une date invalide" -ForegroundColor Red
} catch {
    Write-Host "`n✅ Test: API - Date invalide ($invalidDate)" -ForegroundColor Green
    Write-Host "   Succès: L'API retourne bien une erreur pour une date invalide" -ForegroundColor Green
    $testsPassed++
}

# Test 5: API - Paramètre manquant
$totalTests++
try {
    $response = Invoke-RestMethod -Uri $apiUrl -Method GET -ContentType "application/json"
    Write-Host "`n❌ Test: API - Paramètre week manquant" -ForegroundColor Red
    Write-Host "   Échec: L'API devrait retourner une erreur sans le paramètre week" -ForegroundColor Red
} catch {
    Write-Host "`n✅ Test: API - Paramètre week manquant" -ForegroundColor Green
    Write-Host "   Succès: L'API retourne bien une erreur sans le paramètre week" -ForegroundColor Green
    $testsPassed++
}

# Test 6: Interface - Page d'administration des réservations
$totalTests++
$adminUrl = "$baseUrl/admin/reservations"
if (Test-WebInterface -url $adminUrl -description "Interface - Page d'administration des réservations") {
    $testsPassed++
}

# Test 7: Interface - Dashboard admin
$totalTests++
$dashboardUrl = "$baseUrl/admin"
if (Test-WebInterface -url $dashboardUrl -description "Interface - Dashboard admin") {
    $testsPassed++
}

# Résumé des tests
Write-Host "`n📊 Résumé des tests" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host "Tests réussis: $testsPassed/$totalTests" -ForegroundColor $(if ($testsPassed -eq $totalTests) { "Green" } else { "Yellow" })

if ($testsPassed -eq $totalTests) {
    Write-Host "`n🎉 Tous les tests sont passés avec succès !" -ForegroundColor Green
    Write-Host "Le calendrier hebdomadaire est opérationnel." -ForegroundColor Green
} else {
    Write-Host "`n⚠️ Certains tests ont échoué." -ForegroundColor Yellow
    Write-Host "Vérifiez les erreurs ci-dessus." -ForegroundColor Yellow
}

Write-Host "`n📝 Instructions d'utilisation:" -ForegroundColor Cyan
Write-Host "1. Accédez à l'interface d'administration: $adminUrl" -ForegroundColor White
Write-Host "2. Cliquez sur l'onglet 'Calendrier' pour voir la vue calendrier" -ForegroundColor White
Write-Host "3. Utilisez les flèches pour naviguer entre les semaines" -ForegroundColor White
Write-Host "4. Cliquez sur 'Aujourd'hui' pour revenir à la semaine courante" -ForegroundColor White

Write-Host "`n✨ Test terminé !" -ForegroundColor Cyan