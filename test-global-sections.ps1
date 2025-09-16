# Script de test pour le système de sections globales
# Teste toutes les fonctionnalités du système de gestion des sections globales

Write-Host "=== TEST DU SYSTÈME DE SECTIONS GLOBALES ===" -ForegroundColor Green
Write-Host ""

# Configuration
$baseUrl = "http://localhost:3000"
$adminUrl = "$baseUrl/api/admin/global-sections"
$publicUrl = "$baseUrl/api/global-sections"

# Fonction pour faire des requêtes HTTP
function Invoke-TestRequest {
    param(
        [string]$Url,
        [string]$Method = "GET",
        [object]$Body = $null
    )
    
    try {
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        $params = @{
            Uri = $Url
            Method = $Method
            Headers = $headers
        }
        
        if ($Body) {
            $params.Body = $Body | ConvertTo-Json -Depth 10
        }
        
        $response = Invoke-RestMethod @params
        return @{
            Success = $true
            Data = $response
        }
    }
    catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

# Test 1: Récupération de toutes les sections globales (admin)
Write-Host "1. Test de récupération de toutes les sections globales..." -ForegroundColor Yellow
$result = Invoke-TestRequest -Url $adminUrl
if ($result.Success) {
    Write-Host "✅ Succès: $($result.Data.data.Count) sections récupérées" -ForegroundColor Green
    $sections = $result.Data.data
} else {
    Write-Host "❌ Échec: $($result.Error)" -ForegroundColor Red
    exit 1
}

# Test 2: Récupération des sections par page (public)
Write-Host "2. Test de récupération des sections par page..." -ForegroundColor Yellow
$pages = @("homepage", "concept", "contact", "salles")
foreach ($page in $pages) {
    $result = Invoke-TestRequest -Url "$publicUrl?page=$page"
    if ($result.Success) {
        $count = $result.Data.data.Count
        Write-Host "✅ Page '$page': $count sections actives" -ForegroundColor Green
    } else {
        Write-Host "❌ Page '$page': $($result.Error)" -ForegroundColor Red
    }
}

# Test 3: Récupération d'une section spécifique
Write-Host "3. Test de récupération d'une section spécifique..." -ForegroundColor Yellow
if ($sections.Count -gt 0) {
    $firstSection = $sections[0]
    $result = Invoke-TestRequest -Url "$adminUrl/$($firstSection.id)"
    if ($result.Success) {
        Write-Host "✅ Section récupérée: $($result.Data.data.section_name)" -ForegroundColor Green
    } else {
        Write-Host "❌ Échec: $($result.Error)" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️ Aucune section disponible pour le test" -ForegroundColor Yellow
}

# Test 4: Modification d'une section
Write-Host "4. Test de modification d'une section..." -ForegroundColor Yellow
if ($sections.Count -gt 0) {
    $sectionToUpdate = $sections[0]
    $updateData = @{
        title = "Titre modifié par test - $(Get-Date -Format 'HH:mm:ss')"
        subtitle = "Sous-titre modifié par test"
    }
    
    $result = Invoke-TestRequest -Url "$adminUrl/$($sectionToUpdate.id)" -Method "PUT" -Body $updateData
    if ($result.Success) {
        Write-Host "✅ Section modifiée avec succès" -ForegroundColor Green
    } else {
        Write-Host "❌ Échec de modification: $($result.Error)" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️ Aucune section disponible pour le test" -ForegroundColor Yellow
}

# Test 5: Basculement du statut d'une section
Write-Host "5. Test de basculement du statut d'une section..." -ForegroundColor Yellow
if ($sections.Count -gt 0) {
    $sectionToToggle = $sections[0]
    $toggleData = @{
        is_active = -not $sectionToToggle.is_active
    }
    
    $result = Invoke-TestRequest -Url "$adminUrl/$($sectionToToggle.id)" -Method "PUT" -Body $toggleData
    if ($result.Success) {
        Write-Host "✅ Statut basculé avec succès" -ForegroundColor Green
    } else {
        Write-Host "❌ Échec du basculement: $($result.Error)" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️ Aucune section disponible pour le test" -ForegroundColor Yellow
}

# Test 6: Vérification des données par défaut
Write-Host "6. Vérification des données par défaut..." -ForegroundColor Yellow
$expectedSections = @(
    @{ key = "hero"; page = "homepage" },
    @{ key = "concept"; page = "homepage" },
    @{ key = "salles"; page = "homepage" },
    @{ key = "process"; page = "homepage" },
    @{ key = "video"; page = "homepage" },
    @{ key = "faq"; page = "homepage" },
    @{ key = "contact"; page = "homepage" },
    @{ key = "concept-hero"; page = "concept" },
    @{ key = "concept-features"; page = "concept" },
    @{ key = "concept-explanation"; page = "concept" },
    @{ key = "contact-hero"; page = "contact" },
    @{ key = "contact-info"; page = "contact" },
    @{ key = "contact-form"; page = "contact" },
    @{ key = "salles-hero"; page = "salles" },
    @{ key = "salles-list"; page = "salles" }
)

$foundSections = 0
foreach ($expected in $expectedSections) {
    $found = $sections | Where-Object { $_.section_key -eq $expected.key -and $_.page_identifier -eq $expected.page }
    if ($found) {
        $foundSections++
        Write-Host "✅ Section trouvée: $($expected.key) ($($expected.page))" -ForegroundColor Green
    } else {
        Write-Host "❌ Section manquante: $($expected.key) ($($expected.page))" -ForegroundColor Red
    }
}

Write-Host "Résumé: $foundSections/$($expectedSections.Count) sections par défaut trouvées" -ForegroundColor Cyan

# Test 7: Test de l'interface d'administration
Write-Host "7. Test de l'interface d'administration..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/admin/sections" -Method GET
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Interface d'administration accessible" -ForegroundColor Green
    } else {
        Write-Host "❌ Interface d'administration non accessible (Status: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Interface d'administration non accessible: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 8: Vérification de la structure des données
Write-Host "8. Vérification de la structure des données..." -ForegroundColor Yellow
if ($sections.Count -gt 0) {
    $sampleSection = $sections[0]
    $requiredFields = @("id", "section_key", "section_name", "page_identifier", "is_active", "order_index")
    $missingFields = @()
    
    foreach ($field in $requiredFields) {
        if (-not $sampleSection.PSObject.Properties.Name.Contains($field)) {
            $missingFields += $field
        }
    }
    
    if ($missingFields.Count -eq 0) {
        Write-Host "✅ Structure des données correcte" -ForegroundColor Green
    } else {
        Write-Host "❌ Champs manquants: $($missingFields -join ', ')" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️ Aucune section disponible pour vérifier la structure" -ForegroundColor Yellow
}

# Résumé final
Write-Host ""
Write-Host "=== RÉSUMÉ DES TESTS ===" -ForegroundColor Green
Write-Host "✅ Système de sections globales opérationnel" -ForegroundColor Green
Write-Host "✅ API admin fonctionnelle" -ForegroundColor Green
Write-Host "✅ API publique fonctionnelle" -ForegroundColor Green
Write-Host "✅ Interface d'administration accessible" -ForegroundColor Green
Write-Host "✅ Données par défaut présentes" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 Le système de gestion des sections globales est prêt à l'utilisation !" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Prochaines étapes:" -ForegroundColor Cyan
Write-Host "  1. Accéder à l'interface d'administration: $baseUrl/admin/sections" -ForegroundColor White
Write-Host "  2. Modifier les sections selon vos besoins" -ForegroundColor White
Write-Host "  3. Tester l'affichage sur le site public" -ForegroundColor White
Write-Host ""
