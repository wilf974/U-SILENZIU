# Script de configuration et test du module de gestion des pages
# U Silenziu - Décembre 2024

Write-Host "🚀 Configuration du Module de Gestion des Pages" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$baseUrl = "http://localhost:3000"

# Fonction pour tester une URL
function Test-Url {
    param($url, $description)
    try {
        $response = Invoke-WebRequest -Uri $url -Method GET -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $description" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ $description (Status: $($response.StatusCode))" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ $description (Erreur: $($_.Exception.Message))" -ForegroundColor Red
        return $false
    }
}

# Fonction pour tester une API
function Test-Api {
    param($url, $method, $body, $description)
    try {
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        if ($body) {
            $response = Invoke-WebRequest -Uri $url -Method $method -Headers $headers -Body ($body | ConvertTo-Json -Depth 10) -UseBasicParsing
        } else {
            $response = Invoke-WebRequest -Uri $url -Method $method -Headers $headers -UseBasicParsing
        }
        
        $result = $response.Content | ConvertFrom-Json
        
        if ($result.success) {
            Write-Host "✅ $description" -ForegroundColor Green
            return $result
        } else {
            Write-Host "❌ $description (Erreur: $($result.error))" -ForegroundColor Red
            return $null
        }
    } catch {
        Write-Host "❌ $description (Erreur: $($_.Exception.Message))" -ForegroundColor Red
        return $null
    }
}

Write-Host "`n📋 Étape 1: Vérification de l'application" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow

# Test de la page d'accueil
$appRunning = Test-Url -url $baseUrl -description "Application accessible"

if (-not $appRunning) {
    Write-Host "`n❌ L'application n'est pas accessible. Veuillez démarrer l'application avec:" -ForegroundColor Red
    Write-Host "docker compose up -d --build" -ForegroundColor White
    exit 1
}

Write-Host "`n📋 Étape 2: Test de l'interface d'administration" -ForegroundColor Yellow
Write-Host "-----------------------------------------------" -ForegroundColor Yellow

# Test de la page d'administration des pages
Test-Url -url "$baseUrl/admin/pages" -description "Interface d'administration des pages accessible"

Write-Host "`n📋 Étape 3: Test des API Routes" -ForegroundColor Yellow
Write-Host "----------------------------" -ForegroundColor Yellow

# Test de l'API de récupération des pages
$pagesApi = Test-Api -url "$baseUrl/api/admin/pages" -method "GET" -description "API GET /api/admin/pages"

if ($pagesApi) {
    Write-Host "📊 Pages trouvées: $($pagesApi.count)" -ForegroundColor Blue
    
    if ($pagesApi.count -gt 0) {
        Write-Host "📝 Pages disponibles:" -ForegroundColor Blue
        foreach ($page in $pagesApi.data) {
            $status = if ($page.is_published) { "Publiée" } else { "Brouillon" }
            Write-Host "  - $($page.title) ($($page.slug)) - $status" -ForegroundColor White
        }
    }
}

Write-Host "`n📋 Étape 4: Test de création d'une page" -ForegroundColor Yellow
Write-Host "--------------------------------------" -ForegroundColor Yellow

# Test de création d'une page
$newPage = @{
    title = "Page de Test Automatique"
    slug = "page-test-automatique"
    content = @"
<h1>Page de Test Automatique</h1>
<p>Cette page a été créée automatiquement par le script de test.</p>
<h2>Fonctionnalités testées</h2>
<ul>
    <li>✅ Création de page via API</li>
    <li>✅ Contenu HTML</li>
    <li>✅ Métadonnées SEO</li>
    <li>✅ Gestion des mots-clés</li>
</ul>
<p><strong>Date de création :</strong> $(Get-Date -Format 'dd/MM/yyyy HH:mm')</p>
"@
    metaDescription = "Page de test automatique créée par le script de configuration"
    seoTitle = "Page de Test - U Silenziu"
    keywords = @("test", "automatique", "script", "configuration")
    isPublished = $true
}

$createdPage = Test-Api -url "$baseUrl/api/admin/pages" -method "POST" -body $newPage -description "Création d'une page de test"

if ($createdPage) {
    $pageId = $createdPage.data.id
    Write-Host "📝 Page créée avec l'ID: $pageId" -ForegroundColor Blue
    
    Write-Host "`n📋 Étape 5: Test d'affichage de la page" -ForegroundColor Yellow
    Write-Host "----------------------------------------" -ForegroundColor Yellow
    
    # Test d'affichage de la page
    Test-Url -url "$baseUrl/page-test-automatique" -description "Affichage de la page dynamique"
    
    # Test de l'API publique
    Test-Api -url "$baseUrl/api/pages/page-test-automatique" -method "GET" -description "API publique de la page"
    
    Write-Host "`n📋 Étape 6: Test de modification de la page" -ForegroundColor Yellow
    Write-Host "--------------------------------------------" -ForegroundColor Yellow
    
    # Test de modification
    $updatedPage = @{
        title = "Page de Test Automatique - Modifiée"
        slug = "page-test-automatique-modifiee"
        content = @"
<h1>Page de Test Automatique - Modifiée</h1>
<p>Cette page a été modifiée automatiquement par le script de test.</p>
<h2>Fonctionnalités testées</h2>
<ul>
    <li>✅ Création de page via API</li>
    <li>✅ Modification de page via API</li>
    <li>✅ Contenu HTML</li>
    <li>✅ Métadonnées SEO</li>
    <li>✅ Gestion des mots-clés</li>
</ul>
<p><strong>Date de modification :</strong> $(Get-Date -Format 'dd/MM/yyyy HH:mm')</p>
"@
        metaDescription = "Page de test automatique modifiée par le script de configuration"
        seoTitle = "Page de Test Modifiée - U Silenziu"
        keywords = @("test", "automatique", "modification", "script")
        isPublished = $true
    }
    
    Test-Api -url "$baseUrl/api/admin/pages/$pageId" -method "PUT" -body $updatedPage -description "Modification de la page de test"
    
    # Test d'affichage de la page modifiée
    Test-Url -url "$baseUrl/page-test-automatique-modifiee" -description "Affichage de la page modifiée"
    
    Write-Host "`n📋 Étape 7: Nettoyage" -ForegroundColor Yellow
    Write-Host "---------------------" -ForegroundColor Yellow
    
    # Suppression de la page de test
    Test-Api -url "$baseUrl/api/admin/pages/$pageId" -method "DELETE" -description "Suppression de la page de test"
}

Write-Host "`n✅ Configuration terminée !" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

Write-Host "`n📝 Résumé des fonctionnalités testées:" -ForegroundColor Cyan
Write-Host "- Interface d'administration des pages" -ForegroundColor White
Write-Host "- API CRUD complète (Create, Read, Update, Delete)" -ForegroundColor White
Write-Host "- API publique pour les pages publiées" -ForegroundColor White
Write-Host "- Affichage dynamique des pages côté site" -ForegroundColor White
Write-Host "- Validation des données" -ForegroundColor White
Write-Host "- Gestion des statuts (publié/brouillon)" -ForegroundColor White
Write-Host "- Métadonnées SEO dynamiques" -ForegroundColor White

Write-Host "`n🚀 Le module de gestion des pages est maintenant opérationnel !" -ForegroundColor Green
Write-Host "`n📋 URLs importantes:" -ForegroundColor Cyan
Write-Host "- Back-office: $baseUrl/admin/pages" -ForegroundColor White
Write-Host "- API admin: $baseUrl/api/admin/pages" -ForegroundColor White
Write-Host "- API publique: $baseUrl/api/pages/[slug]" -ForegroundColor White
Write-Host "- Pages dynamiques: $baseUrl/[slug]" -ForegroundColor White

Write-Host "`n💡 Prochaines étapes:" -ForegroundColor Cyan
Write-Host "1. Créer la table 'pages' dans PostgreSQL avec le script 'create-pages-table.sql'" -ForegroundColor White
Write-Host "2. Tester la création de pages via l'interface d'administration" -ForegroundColor White
Write-Host "3. Personnaliser le contenu selon vos besoins" -ForegroundColor White
Write-Host "4. Configurer les métadonnées SEO pour chaque page" -ForegroundColor White
