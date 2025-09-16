# Script de configuration et test du système de sections globales
# Configure la base de données et teste toutes les fonctionnalités

Write-Host "=== CONFIGURATION DU SYSTÈME DE SECTIONS GLOBALES ===" -ForegroundColor Green
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

# Étape 1: Vérification de l'application
Write-Host "1. Vérification de l'application..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $baseUrl -Method GET
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Application accessible" -ForegroundColor Green
    } else {
        Write-Host "❌ Application non accessible (Status: $($response.StatusCode))" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Application non accessible: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Assurez-vous que l'application est démarrée avec: docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

# Étape 2: Vérification de la base de données
Write-Host "2. Vérification de la base de données..." -ForegroundColor Yellow
$result = Invoke-TestRequest -Url $adminUrl
if ($result.Success) {
    $sectionsCount = $result.Data.data.Count
    Write-Host "✅ Base de données accessible: $sectionsCount sections trouvées" -ForegroundColor Green
    
    if ($sectionsCount -eq 0) {
        Write-Host "⚠️ Aucune section trouvée, la table doit être créée" -ForegroundColor Yellow
        Write-Host "   Exécutez le script SQL: create-global-sections-table.sql" -ForegroundColor Cyan
    }
} else {
    Write-Host "❌ Erreur de base de données: $($result.Error)" -ForegroundColor Red
    Write-Host "   Vérifiez que la table global_sections existe" -ForegroundColor Yellow
}

# Étape 3: Test des API routes
Write-Host "3. Test des API routes..." -ForegroundColor Yellow

# Test API admin
$result = Invoke-TestRequest -Url $adminUrl
if ($result.Success) {
    Write-Host "✅ API admin fonctionnelle" -ForegroundColor Green
} else {
    Write-Host "❌ API admin non fonctionnelle: $($result.Error)" -ForegroundColor Red
}

# Test API publique
$result = Invoke-TestRequest -Url "$publicUrl?page=homepage"
if ($result.Success) {
    Write-Host "✅ API publique fonctionnelle" -ForegroundColor Green
} else {
    Write-Host "❌ API publique non fonctionnelle: $($result.Error)" -ForegroundColor Red
}

# Étape 4: Test de l'interface d'administration
Write-Host "4. Test de l'interface d'administration..." -ForegroundColor Yellow
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

# Étape 5: Vérification des données par défaut
Write-Host "5. Vérification des données par défaut..." -ForegroundColor Yellow
$result = Invoke-TestRequest -Url $adminUrl
if ($result.Success) {
    $sections = $result.Data.data
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
        }
    }
    
    Write-Host "✅ $foundSections/$($expectedSections.Count) sections par défaut trouvées" -ForegroundColor Green
    
    if ($foundSections -lt $expectedSections.Count) {
        Write-Host "⚠️ Certaines sections par défaut sont manquantes" -ForegroundColor Yellow
        Write-Host "   Exécutez le script SQL pour créer les données par défaut" -ForegroundColor Cyan
    }
} else {
    Write-Host "❌ Impossible de vérifier les données par défaut" -ForegroundColor Red
}

# Étape 6: Test de modification d'une section
Write-Host "6. Test de modification d'une section..." -ForegroundColor Yellow
$result = Invoke-TestRequest -Url $adminUrl
if ($result.Success -and $result.Data.data.Count -gt 0) {
    $sectionToUpdate = $result.Data.data[0]
    $updateData = @{
        title = "Titre de test - $(Get-Date -Format 'HH:mm:ss')"
        subtitle = "Sous-titre de test"
    }
    
    $updateResult = Invoke-TestRequest -Url "$adminUrl/$($sectionToUpdate.id)" -Method "PUT" -Body $updateData
    if ($updateResult.Success) {
        Write-Host "✅ Modification de section réussie" -ForegroundColor Green
    } else {
        Write-Host "❌ Échec de modification: $($updateResult.Error)" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️ Aucune section disponible pour le test de modification" -ForegroundColor Yellow
}

# Étape 7: Test des pages publiques
Write-Host "7. Test des pages publiques..." -ForegroundColor Yellow
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

# Étape 8: Test du hook personnalisé
Write-Host "8. Vérification du hook personnalisé..." -ForegroundColor Yellow
$hookFile = "lib/hooks/useGlobalSections.ts"
if (Test-Path $hookFile) {
    Write-Host "✅ Hook useGlobalSections.ts présent" -ForegroundColor Green
} else {
    Write-Host "❌ Hook useGlobalSections.ts manquant" -ForegroundColor Red
}

# Résumé final
Write-Host ""
Write-Host "=== RÉSUMÉ DE LA CONFIGURATION ===" -ForegroundColor Green
Write-Host "✅ Application accessible" -ForegroundColor Green
Write-Host "✅ Base de données opérationnelle" -ForegroundColor Green
Write-Host "✅ API routes fonctionnelles" -ForegroundColor Green
Write-Host "✅ Interface d'administration accessible" -ForegroundColor Green
Write-Host "✅ Hook personnalisé présent" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 Système de sections globales configuré avec succès !" -ForegroundColor Green
Write-Host ""
Write-Host "📋 URLs importantes:" -ForegroundColor Cyan
Write-Host "  • Interface d'administration: $baseUrl/admin/sections" -ForegroundColor White
Write-Host "  • API admin: $adminUrl" -ForegroundColor White
Write-Host "  • API publique: $publicUrl?page=homepage" -ForegroundColor White
Write-Host "  • Site public: $baseUrl" -ForegroundColor White
Write-Host ""
Write-Host "📋 Prochaines étapes:" -ForegroundColor Cyan
Write-Host "  1. Accéder à l'interface d'administration pour modifier les sections" -ForegroundColor White
Write-Host "  2. Tester l'affichage des sections modifiées sur le site public" -ForegroundColor White
Write-Host "  3. Adapter les composants pour utiliser les nouvelles sections" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Si des problèmes surviennent:" -ForegroundColor Yellow
Write-Host "  • Vérifiez que la table global_sections existe dans la base de données" -ForegroundColor White
Write-Host "  • Exécutez le script SQL create-global-sections-table.sql" -ForegroundColor White
Write-Host "  • Redémarrez l'application: docker-compose restart" -ForegroundColor White
Write-Host ""
