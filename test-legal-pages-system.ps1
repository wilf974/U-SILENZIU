# Script de test pour le système de pages légales
# U Silenziu - Test complet des pages légales

Write-Host "=== Test du Système de Pages Légales U Silenziu ===" -ForegroundColor Green
Write-Host ""

# Configuration
$baseUrl = "http://localhost:3000"
$adminUrl = "$baseUrl/admin"
$apiUrl = "$baseUrl/api"

# Fonction pour tester une URL
function Test-Url {
    param(
        [string]$Url,
        [string]$Description,
        [int]$ExpectedStatus = 200
    )
    
    Write-Host "Test: $Description" -ForegroundColor Yellow
    Write-Host "URL: $Url" -ForegroundColor Gray
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method GET -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq $ExpectedStatus) {
            Write-Host "✅ Succès - Status: $($response.StatusCode)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ Échec - Status attendu: $ExpectedStatus, reçu: $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    Write-Host ""
}

# Fonction pour tester une API
function Test-Api {
    param(
        [string]$Url,
        [string]$Description,
        [string]$Method = "GET"
    )
    
    Write-Host "Test API: $Description" -ForegroundColor Yellow
    Write-Host "URL: $Url" -ForegroundColor Gray
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method $Method -UseBasicParsing -TimeoutSec 10
        $data = $response.Content | ConvertFrom-Json
        
        if ($data.success -eq $true) {
            Write-Host "✅ Succès - API fonctionnelle" -ForegroundColor Green
            if ($data.data) {
                Write-Host "   Données reçues: $($data.data.Count) éléments" -ForegroundColor Gray
            }
            return $true
        } else {
            Write-Host "❌ Échec - API retourne success: false" -ForegroundColor Red
            if ($data.error) {
                Write-Host "   Erreur: $($data.error)" -ForegroundColor Red
            }
            return $false
        }
    } catch {
        Write-Host "❌ Erreur API: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    Write-Host ""
}

# Tests des pages légales publiques
Write-Host "=== Tests des Pages Légales Publiques ===" -ForegroundColor Cyan
Write-Host ""

$publicPages = @(
    @{ Type = "cgv"; Description = "Conditions Générales de Vente" },
    @{ Type = "privacy"; Description = "Politique de Confidentialité" },
    @{ Type = "legal"; Description = "Mentions Légales" },
    @{ Type = "cookies"; Description = "Paramètres des Cookies" }
)

$publicTestsPassed = 0
foreach ($page in $publicPages) {
    $url = "$baseUrl/legal/$($page.Type)"
    if (Test-Url -Url $url -Description $page.Description) {
        $publicTestsPassed++
    }
}

# Tests des API publiques
Write-Host "=== Tests des API Publiques ===" -ForegroundColor Cyan
Write-Host ""

$apiTestsPassed = 0
foreach ($page in $publicPages) {
    $url = "$apiUrl/legal-pages/$($page.Type)"
    if (Test-Api -Url $url -Description "API publique pour $($page.Description)") {
        $apiTestsPassed++
    }
}

# Tests de l'interface d'administration
Write-Host "=== Tests de l'Interface d'Administration ===" -ForegroundColor Cyan
Write-Host ""

$adminTestsPassed = 0

# Test de la page d'administration des pages légales
if (Test-Url -Url "$adminUrl/legal-pages" -Description "Page d'administration des pages légales") {
    $adminTestsPassed++
}

# Test de l'API d'administration
if (Test-Api -Url "$apiUrl/admin/legal-pages" -Description "API d'administration des pages légales") {
    $adminTestsPassed++
}

# Tests de validation des données
Write-Host "=== Tests de Validation des Données ===" -ForegroundColor Cyan
Write-Host ""

$validationTestsPassed = 0

# Test avec un type invalide
Write-Host "Test: Type de page invalide" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$apiUrl/legal-pages/invalid" -Method GET -UseBasicParsing -TimeoutSec 10
    Write-Host "❌ Échec - L'API devrait retourner une erreur 400" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 400) {
        Write-Host "✅ Succès - Erreur 400 retournée comme attendu" -ForegroundColor Green
        $validationTestsPassed++
    } else {
        Write-Host "❌ Échec - Status inattendu: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}
Write-Host ""

# Test avec une page inexistante
Write-Host "Test: Page inexistante" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$apiUrl/legal-pages/nonexistent" -Method GET -UseBasicParsing -TimeoutSec 10
    Write-Host "❌ Échec - L'API devrait retourner une erreur 404" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Host "✅ Succès - Erreur 404 retournée comme attendu" -ForegroundColor Green
        $validationTestsPassed++
    } else {
        Write-Host "❌ Échec - Status inattendu: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}
Write-Host ""

# Tests de contenu
Write-Host "=== Tests de Contenu ===" -ForegroundColor Cyan
Write-Host ""

$contentTestsPassed = 0

# Test du contenu des pages
foreach ($page in $publicPages) {
    Write-Host "Test: Contenu de la page $($page.Type)" -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "$apiUrl/legal-pages/$($page.Type)" -Method GET -UseBasicParsing -TimeoutSec 10
        $data = $response.Content | ConvertFrom-Json
        
        if ($data.success -and $data.data) {
            $pageData = $data.data
            if ($pageData.title -and $pageData.content -and $pageData.is_published -eq $true) {
                Write-Host "✅ Succès - Page $($page.Type) a un contenu valide" -ForegroundColor Green
                Write-Host "   Titre: $($pageData.title)" -ForegroundColor Gray
                Write-Host "   Publié: $($pageData.is_published)" -ForegroundColor Gray
                $contentTestsPassed++
            } else {
                Write-Host "❌ Échec - Page $($page.Type) manque de contenu ou n'est pas publiée" -ForegroundColor Red
            }
        } else {
            Write-Host "❌ Échec - Impossible de récupérer les données de la page $($page.Type)" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Erreur lors du test de contenu pour $($page.Type): $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""
}

# Résumé des tests
Write-Host "=== Résumé des Tests ===" -ForegroundColor Magenta
Write-Host ""

$totalTests = $publicPages.Count + $publicPages.Count + 2 + 2 + $publicPages.Count
$totalPassed = $publicTestsPassed + $apiTestsPassed + $adminTestsPassed + $validationTestsPassed + $contentTestsPassed

Write-Host "Pages publiques: $publicTestsPassed/$($publicPages.Count)" -ForegroundColor $(if ($publicTestsPassed -eq $publicPages.Count) { "Green" } else { "Red" })
Write-Host "API publiques: $apiTestsPassed/$($publicPages.Count)" -ForegroundColor $(if ($apiTestsPassed -eq $publicPages.Count) { "Green" } else { "Red" })
Write-Host "Interface admin: $adminTestsPassed/2" -ForegroundColor $(if ($adminTestsPassed -eq 2) { "Green" } else { "Red" })
Write-Host "Validation: $validationTestsPassed/2" -ForegroundColor $(if ($validationTestsPassed -eq 2) { "Green" } else { "Red" })
Write-Host "Contenu: $contentTestsPassed/$($publicPages.Count)" -ForegroundColor $(if ($contentTestsPassed -eq $publicPages.Count) { "Green" } else { "Red" })
Write-Host ""
Write-Host "Total: $totalPassed/$totalTests tests réussis" -ForegroundColor $(if ($totalPassed -eq $totalTests) { "Green" } else { "Yellow" })

if ($totalPassed -eq $totalTests) {
    Write-Host ""
    Write-Host "🎉 Tous les tests sont passés avec succès !" -ForegroundColor Green
    Write-Host "Le système de pages légales fonctionne correctement." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "⚠️  Certains tests ont échoué. Vérifiez les erreurs ci-dessus." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== URLs à tester manuellement ===" -ForegroundColor Cyan
Write-Host "Pages publiques:"
foreach ($page in $publicPages) {
    Write-Host "  - $baseUrl/legal/$($page.Type)" -ForegroundColor Gray
}
Write-Host ""
Write-Host "Interface d'administration:"
Write-Host "  - $adminUrl/legal-pages" -ForegroundColor Gray
Write-Host ""
Write-Host "=== Fin des Tests ===" -ForegroundColor Green