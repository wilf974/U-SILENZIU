# Script de test pour la page d'entrée U Silenziu
# Teste la création, configuration et affichage de la page d'entrée

Write-Host "=== Test de la Page d'Entrée U Silenziu ===" -ForegroundColor Green
Write-Host ""

# Configuration
$baseUrl = "http://localhost:3000"
$adminUrl = "$baseUrl/admin"

# Fonction pour tester une URL
function Test-Url {
    param($url, $description)
    try {
        $response = Invoke-WebRequest -Uri $url -Method GET -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $description" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ $description (Code: $($response.StatusCode))" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ $description (Erreur: $($_.Exception.Message))" -ForegroundColor Red
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
            $response = Invoke-WebRequest -Uri $url -Method $method -Body ($body | ConvertTo-Json) -Headers $headers -TimeoutSec 10
        } else {
            $response = Invoke-WebRequest -Uri $url -Method $method -Headers $headers -TimeoutSec 10
        }
        
        if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 201) {
            Write-Host "✅ $description" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ $description (Code: $($response.StatusCode))" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ $description (Erreur: $($_.Exception.Message))" -ForegroundColor Red
        return $false
    }
}

Write-Host "1. Test des pages publiques" -ForegroundColor Yellow
Write-Host ""

# Test de la page d'entrée
$entryPageTest = Test-Url "$baseUrl/entry" "Page d'entrée accessible"

# Test de la redirection depuis la page d'accueil
$homeRedirectTest = Test-Url "$baseUrl/" "Redirection depuis la page d'accueil"

# Test de la page principale du site
$homePageTest = Test-Url "$baseUrl/home" "Page principale du site accessible"

Write-Host ""
Write-Host "2. Test des API de configuration" -ForegroundColor Yellow
Write-Host ""

# Test de l'API publique de configuration
$publicApiTest = Test-Api "$baseUrl/api/entry-page-config" "GET" $null "API publique de configuration"

# Test de l'API admin de configuration
$adminApiTest = Test-Api "$adminUrl/api/admin/entry-page-config" "GET" $null "API admin de configuration"

Write-Host ""
Write-Host "3. Test des interfaces d'administration" -ForegroundColor Yellow
Write-Host ""

# Test de la page d'administration de la page d'entrée
$adminPageTest = Test-Url "$adminUrl/entry-page" "Interface d'administration de la page d'entrée"

# Test du dashboard admin
$dashboardTest = Test-Url "$adminUrl" "Dashboard admin"

Write-Host ""
Write-Host "4. Test de la base de données" -ForegroundColor Yellow
Write-Host ""

# Test de création de la table (via script SQL)
Write-Host "📋 Exécution du script SQL de création de la table..." -ForegroundColor Cyan
try {
    # Note: En production, vous devriez exécuter le script SQL via psql ou votre outil de gestion de base de données
    Write-Host "⚠️  Veuillez exécuter manuellement le script: create-entry-page-config-table.sql" -ForegroundColor Yellow
    Write-Host "   Commande: psql -d usilenzio -f create-entry-page-config-table.sql" -ForegroundColor Gray
} catch {
    Write-Host "❌ Erreur lors de l'exécution du script SQL" -ForegroundColor Red
}

Write-Host ""
Write-Host "5. Test de configuration dynamique" -ForegroundColor Yellow
Write-Host ""

# Test de mise à jour de la configuration
$updateConfig = @{
    title = "U SILENZIU - TEST"
    subtitle = "Zone de défoulement - Test"
    description = "Test de la configuration dynamique"
    button_text = "ENTRER - TEST"
    background_type = "image"
    background_image_url = "/images/test-bg.jpg"
    background_video_url = "/videos/test-bg.mp4"
    is_active = $true
}

# Note: Ce test nécessite une authentification admin
Write-Host "⚠️  Test de mise à jour de configuration nécessite une authentification admin" -ForegroundColor Yellow

Write-Host ""
Write-Host "6. Résumé des tests" -ForegroundColor Yellow
Write-Host ""

$totalTests = 8
$passedTests = 0

if ($entryPageTest) { $passedTests++ }
if ($homeRedirectTest) { $passedTests++ }
if ($homePageTest) { $passedTests++ }
if ($publicApiTest) { $passedTests++ }
if ($adminApiTest) { $passedTests++ }
if ($adminPageTest) { $passedTests++ }
if ($dashboardTest) { $passedTests++ }

Write-Host "Tests réussis: $passedTests/$totalTests" -ForegroundColor $(if ($passedTests -eq $totalTests) { "Green" } else { "Yellow" })

if ($passedTests -eq $totalTests) {
    Write-Host ""
    Write-Host "🎉 Tous les tests sont passés avec succès !" -ForegroundColor Green
    Write-Host "La page d'entrée est maintenant opérationnelle." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "⚠️  Certains tests ont échoué. Vérifiez les erreurs ci-dessus." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Instructions d'utilisation ===" -ForegroundColor Cyan
Write-Host "1. Accédez à $baseUrl pour voir la page d'entrée" -ForegroundColor White
Write-Host "2. Cliquez sur 'ENTRER DANS LE SITE' pour accéder au site principal" -ForegroundColor White
Write-Host "3. Configurez la page d'entrée via $adminUrl/entry-page" -ForegroundColor White
Write-Host "4. Ajoutez vos images/vidéos dans le dossier public/images/ ou public/videos/" -ForegroundColor White
Write-Host ""

Write-Host "=== Fichiers créés ===" -ForegroundColor Cyan
Write-Host "• components/EntryPage.tsx - Composant de la page d'entrée" -ForegroundColor White
Write-Host "• app/entry/page.tsx - Route de la page d'entrée" -ForegroundColor White
Write-Host "• app/home/page.tsx - Page principale du site" -ForegroundColor White
Write-Host "• app/admin/entry-page/page.tsx - Interface d'administration" -ForegroundColor White
Write-Host "• app/api/entry-page-config/route.ts - API publique" -ForegroundColor White
Write-Host "• app/api/admin/entry-page-config/route.ts - API admin" -ForegroundColor White
Write-Host "• create-entry-page-config-table.sql - Script de création de table" -ForegroundColor White
Write-Host "• lib/database.ts - Fonctions de base de données ajoutées" -ForegroundColor White
Write-Host ""

Write-Host "Test terminé !" -ForegroundColor Green
