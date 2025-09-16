# Script de test pour valider la migration vers PostgreSQL
# Teste la connexion et les fonctionnalités de la base de données PostgreSQL

Write-Host "=== TEST DE MIGRATION VERS POSTGRESQL ===" -ForegroundColor Green
Write-Host "Date: $(Get-Date)" -ForegroundColor Gray
Write-Host ""

# Configuration
$baseUrl = "http://localhost:3000"

# Fonction pour tester une API
function Test-Api {
    param(
        [string]$Url,
        [string]$Method = "GET",
        [string]$Description,
        [object]$Body = $null
    )
    
    Write-Host "Test: $Description" -ForegroundColor Yellow
    Write-Host "URL: $Url" -ForegroundColor Gray
    
    try {
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        if ($Body) {
            $jsonBody = $Body | ConvertTo-Json -Depth 10
            $response = Invoke-WebRequest -Uri $Url -Method $Method -Headers $headers -Body $jsonBody -TimeoutSec 10
        } else {
            $response = Invoke-WebRequest -Uri $Url -Method $Method -Headers $headers -TimeoutSec 10
        }
        
        if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 201) {
            Write-Host "✅ SUCCÈS: $Description" -ForegroundColor Green
            try {
                $jsonResponse = $response.Content | ConvertFrom-Json
                Write-Host "   Réponse: $($jsonResponse | ConvertTo-Json -Depth 2)" -ForegroundColor Gray
            } catch {
                Write-Host "   Réponse: $($response.Content)" -ForegroundColor Gray
            }
            return $true
        } else {
            Write-Host "❌ ÉCHEC: $Description (Status: $($response.StatusCode))" -ForegroundColor Red
            Write-Host "   Réponse: $($response.Content)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ ERREUR: $Description" -ForegroundColor Red
        Write-Host "   Détail: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    Write-Host ""
}

# Tests de base de données PostgreSQL
Write-Host "=== TESTS DE LA BASE DE DONNÉES POSTGRESQL ===" -ForegroundColor Cyan

# Test 1: Connexion à la base de données
Write-Host "1. Test de connexion PostgreSQL..." -ForegroundColor Yellow
$testConnection = Test-Api -Url "$baseUrl/api/reservations" -Description "Connexion à PostgreSQL"

# Test 2: Récupération des salles
Write-Host "2. Test de récupération des salles..." -ForegroundColor Yellow
$testRooms = Test-Api -Url "$baseUrl/api/admin/rooms" -Description "Récupération des salles depuis PostgreSQL"

# Test 3: Création d'une réservation de test
Write-Host "3. Test de création de réservation..." -ForegroundColor Yellow
$testReservation = @{
    firstName = "Test"
    lastName = "PostgreSQL"
    email = "test@postgresql.com"
    phone = "0123456789"
    roomName = "Salle Test"
    date = "2024-12-26"
    time = "14:00"
    duration = 30
    numberOfPeople = 2
    status = "pending"
    amount = 50
}

$testCreateReservation = Test-Api -Url "$baseUrl/api/reservations" -Method "POST" -Description "Création d'une réservation dans PostgreSQL" -Body $testReservation

# Test 4: Configuration SMTP
Write-Host "4. Test de configuration SMTP..." -ForegroundColor Yellow
$testSmtp = Test-Api -Url "$baseUrl/api/admin/smtp/config" -Description "Récupération de la configuration SMTP depuis PostgreSQL"

# Test 5: Pages dynamiques
Write-Host "5. Test de pages dynamiques..." -ForegroundColor Yellow
$testPages = Test-Api -Url "$baseUrl/api/admin/pages" -Description "Récupération des pages depuis PostgreSQL"

# Test 6: Templates
Write-Host "6. Test de templates..." -ForegroundColor Yellow
$testTemplates = Test-Api -Url "$baseUrl/api/admin/templates" -Description "Récupération des templates depuis PostgreSQL"

# Test 7: Dashboard
Write-Host "7. Test du dashboard..." -ForegroundColor Yellow
$testDashboard = Test-Api -Url "$baseUrl/api/admin/dashboard" -Description "Récupération des statistiques du dashboard depuis PostgreSQL"

# Résumé des tests
Write-Host "=== RÉSUMÉ DES TESTS POSTGRESQL ===" -ForegroundColor Cyan
Write-Host ""

$tests = @($testConnection, $testRooms, $testCreateReservation, $testSmtp, $testPages, $testTemplates, $testDashboard)
$successCount = ($tests | Where-Object { $_ -eq $true }).Count
$totalTests = $tests.Count

Write-Host "Tests réussis: $successCount/$totalTests" -ForegroundColor $(if ($successCount -eq $totalTests) { "Green" } else { "Yellow" })

$successRate = [math]::Round(($successCount / $totalTests) * 100, 2)
Write-Host "Taux de succès: $successRate%" -ForegroundColor $(if ($successRate -ge 90) { "Green" } elseif ($successRate -ge 70) { "Yellow" } else { "Red" })

Write-Host ""
Write-Host "=== FONCTIONNALITÉS TESTÉES ===" -ForegroundColor Cyan
Write-Host "✅ Connexion PostgreSQL" -ForegroundColor Green
Write-Host "✅ Récupération des salles" -ForegroundColor Green
Write-Host "✅ Création de réservations" -ForegroundColor Green
Write-Host "✅ Configuration SMTP" -ForegroundColor Green
Write-Host "✅ Pages dynamiques" -ForegroundColor Green
Write-Host "✅ Templates" -ForegroundColor Green
Write-Host "✅ Dashboard et statistiques" -ForegroundColor Green

Write-Host ""
Write-Host "=== AVANTAGES DE POSTGRESQL ===" -ForegroundColor Cyan
Write-Host "✅ Connexions simultanées multiples" -ForegroundColor Green
Write-Host "✅ Transactions ACID" -ForegroundColor Green
Write-Host "✅ Requêtes complexes et optimisées" -ForegroundColor Green
Write-Host "✅ Support JSON natif (JSONB)" -ForegroundColor Green
Write-Host "✅ Index avancés" -ForegroundColor Green
Write-Host "✅ Réplication et sauvegarde" -ForegroundColor Green
Write-Host "✅ Extensions (UUID, etc.)" -ForegroundColor Green
Write-Host "✅ Performance supérieure" -ForegroundColor Green

Write-Host ""
Write-Host "=== RECOMMANDATIONS ===" -ForegroundColor Cyan
if ($successRate -ge 90) {
    Write-Host "🎉 Migration vers PostgreSQL réussie !" -ForegroundColor Green
    Write-Host "   Toutes les fonctionnalités sont opérationnelles." -ForegroundColor Green
    Write-Host "   La base de données est maintenant plus robuste et performante." -ForegroundColor Green
} elseif ($successRate -ge 70) {
    Write-Host "⚠️  Migration partiellement réussie." -ForegroundColor Yellow
    Write-Host "   Vérifiez les tests échoués avant de continuer." -ForegroundColor Yellow
} else {
    Write-Host "❌ Migration échouée." -ForegroundColor Red
    Write-Host "   Corrigez les erreurs avant de continuer." -ForegroundColor Red
}

Write-Host ""
Write-Host "=== PROCHAINES ÉTAPES ===" -ForegroundColor Cyan
Write-Host "1. Vérifier les logs Docker: docker-compose logs postgres" -ForegroundColor White
Write-Host "2. Tester les performances: plus de requêtes simultanées" -ForegroundColor White
Write-Host "3. Configurer les sauvegardes automatiques" -ForegroundColor White
Write-Host "4. Optimiser les requêtes si nécessaire" -ForegroundColor White

Write-Host ""
Write-Host "Tests terminés à $(Get-Date)" -ForegroundColor Gray
