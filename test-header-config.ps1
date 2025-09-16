# Script de test pour la gestion de la configuration de l'en-tête
# Teste les API routes, l'interface d'administration et l'affichage côté site

Write-Host "=== Test de la Configuration de l'En-tête ===" -ForegroundColor Green
Write-Host ""

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
        
        if ($method -eq "GET") {
            $response = Invoke-WebRequest -Uri $url -Method GET -UseBasicParsing -TimeoutSec 10
        } else {
            $response = Invoke-WebRequest -Uri $url -Method $method -Body $body -Headers $headers -UseBasicParsing -TimeoutSec 10
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

Write-Host "1. Test des API Routes" -ForegroundColor Yellow
Write-Host ""

# Test API publique
$apiPublicTest = Test-Api "$apiUrl/header-config" "GET" $null "API publique - Récupération de la configuration"

# Test API admin
$apiAdminTest = Test-Api "$apiUrl/admin/header-config" "GET" $null "API admin - Récupération de la configuration"

Write-Host ""
Write-Host "2. Test de l'Interface d'Administration" -ForegroundColor Yellow
Write-Host ""

# Test page d'administration
$adminPageTest = Test-Url "$adminUrl/homepage" "Page d'administration - Configuration de l'en-tête"

Write-Host ""
Write-Host "3. Test de l'Affichage Côté Site" -ForegroundColor Yellow
Write-Host ""

# Test page d'accueil
$homePageTest = Test-Url "$baseUrl" "Page d'accueil - Affichage du header dynamique"

Write-Host ""
Write-Host "4. Test de Modification de la Configuration" -ForegroundColor Yellow
Write-Host ""

# Test de modification avec un nom personnalisé
$updateData = @{
    site_name = "U SILENZIU - Test"
    logo_type = "text"
    logo_text = "U"
    logo_alt_text = "Logo U Silenziu Test"
} | ConvertTo-Json

$updateTest = Test-Api "$apiUrl/admin/header-config" "PUT" $updateData "Modification de la configuration - Nom personnalisé"

# Test de modification avec une image
$updateImageData = @{
    site_name = "U SILENZIU - Image Test"
    logo_type = "image"
    logo_image_url = "https://via.placeholder.com/100x100/8B7355/FFFFFF?text=U"
    logo_alt_text = "Logo U Silenziu Image Test"
} | ConvertTo-Json

$updateImageTest = Test-Api "$apiUrl/admin/header-config" "PUT" $updateImageData "Modification de la configuration - Logo image"

# Restaurer la configuration par défaut
$restoreData = @{
    site_name = "U SILENZIU"
    logo_type = "text"
    logo_text = "U"
    logo_alt_text = "Logo U Silenziu"
} | ConvertTo-Json

$restoreTest = Test-Api "$apiUrl/admin/header-config" "PUT" $restoreData "Restauration de la configuration par défaut"

Write-Host ""
Write-Host "5. Test de Validation des Données" -ForegroundColor Yellow
Write-Host ""

# Test avec des données invalides
$invalidData = @{
    site_name = ""
    logo_type = "invalid"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "$apiUrl/admin/header-config" -Method PUT -Body $invalidData -Headers @{"Content-Type" = "application/json"} -UseBasicParsing -TimeoutSec 10
    Write-Host "❌ Validation des données - Devrait échouer avec des données invalides" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 400) {
        Write-Host "✅ Validation des données - Rejet correct des données invalides" -ForegroundColor Green
    } else {
        Write-Host "❌ Validation des données - Code d'erreur inattendu: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Résumé des Tests ===" -ForegroundColor Green
Write-Host ""

$totalTests = 8
$passedTests = 0

if ($apiPublicTest) { $passedTests++ }
if ($apiAdminTest) { $passedTests++ }
if ($adminPageTest) { $passedTests++ }
if ($homePageTest) { $passedTests++ }
if ($updateTest) { $passedTests++ }
if ($updateImageTest) { $passedTests++ }
if ($restoreTest) { $passedTests++ }
if ($_.Exception.Response.StatusCode -eq 400) { $passedTests++ }

Write-Host "Tests réussis: $passedTests/$totalTests" -ForegroundColor $(if ($passedTests -eq $totalTests) { "Green" } else { "Yellow" })

if ($passedTests -eq $totalTests) {
    Write-Host ""
    Write-Host "🎉 Tous les tests sont passés avec succès !" -ForegroundColor Green
    Write-Host "Le système de configuration de l'en-tête fonctionne correctement." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "⚠️  Certains tests ont échoué. Vérifiez les erreurs ci-dessus." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Instructions d'Utilisation ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Accédez à l'interface d'administration:" -ForegroundColor White
Write-Host "   $adminUrl/homepage" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Cliquez sur 'Modifier' dans la section 'Configuration de l'En-tête'" -ForegroundColor White
Write-Host ""
Write-Host "3. Modifiez le nom du site et/ou le logo selon vos besoins:" -ForegroundColor White
Write-Host "   - Nom du site: Texte affiché à côté du logo" -ForegroundColor Gray
Write-Host "   - Type de logo: Texte ou Image" -ForegroundColor Gray
Write-Host "   - Texte du logo: Caractère affiché dans le carré (si type = texte)" -ForegroundColor Gray
Write-Host "   - URL de l'image: Lien vers l'image du logo (si type = image)" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Cliquez sur 'Sauvegarder' pour appliquer les changements" -ForegroundColor White
Write-Host ""
Write-Host "5. Vérifiez les modifications sur le site public:" -ForegroundColor White
Write-Host "   $baseUrl" -ForegroundColor Gray
Write-Host ""

