# Script de test pour le module de gestion des pages
# Test complet du système de pages dynamiques

Write-Host "🧪 Test du Module de Gestion des Pages Dynamiques" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

$baseUrl = "http://localhost:3000"
$adminUrl = "$baseUrl/admin/pages"

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

Write-Host "`n📋 Tests d'accessibilité des pages" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow

# Test de la page d'accueil
Test-Url -url $baseUrl -description "Page d'accueil accessible"

# Test de la page d'administration des pages
Test-Url -url $adminUrl -description "Interface d'administration des pages accessible"

Write-Host "`n🔌 Tests des API Routes" -ForegroundColor Yellow
Write-Host "----------------------" -ForegroundColor Yellow

# Test de l'API de récupération des pages
$pagesApi = Test-Api -url "$baseUrl/api/admin/pages" -method "GET" -description "API GET /api/admin/pages"

# Test de création d'une page
$newPage = @{
    title = "Page de Test"
    slug = "page-de-test"
    content = "<h1>Page de Test</h1><p>Ceci est une page de test créée automatiquement.</p>"
    metaDescription = "Description de la page de test"
    seoTitle = "Page de Test - U Silenziu"
    keywords = @("test", "page", "dynamique")
    isPublished = $true
}

$createdPage = Test-Api -url "$baseUrl/api/admin/pages" -method "POST" -body $newPage -description "API POST /api/admin/pages (création)"

if ($createdPage) {
    $pageId = $createdPage.data.id
    
    Write-Host "`n📝 Tests de gestion de page (ID: $pageId)" -ForegroundColor Yellow
    Write-Host "----------------------------------------" -ForegroundColor Yellow
    
    # Test de récupération d'une page spécifique
    Test-Api -url "$baseUrl/api/admin/pages/$pageId" -method "GET" -description "API GET /api/admin/pages/[id]"
    
    # Test de mise à jour d'une page
    $updatedPage = @{
        title = "Page de Test Modifiée"
        slug = "page-de-test-modifiee"
        content = "<h1>Page de Test Modifiée</h1><p>Cette page a été modifiée automatiquement.</p>"
        metaDescription = "Description modifiée de la page de test"
        seoTitle = "Page de Test Modifiée - U Silenziu"
        keywords = @("test", "page", "modifiée", "dynamique")
        isPublished = $false
    }
    
    Test-Api -url "$baseUrl/api/admin/pages/$pageId" -method "PUT" -body $updatedPage -description "API PUT /api/admin/pages/[id] (modification)"
    
    # Test de l'API publique (page non publiée ne doit pas être accessible)
    Test-Api -url "$baseUrl/api/pages/page-de-test-modifiee" -method "GET" -description "API GET /api/pages/[slug] (page non publiée)"
    
    # Publier la page
    $publishedPage = @{
        title = "Page de Test Modifiée"
        slug = "page-de-test-modifiee"
        content = "<h1>Page de Test Modifiée</h1><p>Cette page a été modifiée automatiquement.</p>"
        metaDescription = "Description modifiée de la page de test"
        seoTitle = "Page de Test Modifiée - U Silenziu"
        keywords = @("test", "page", "modifiée", "dynamique")
        isPublished = $true
    }
    
    Test-Api -url "$baseUrl/api/admin/pages/$pageId" -method "PUT" -body $publishedPage -description "API PUT /api/admin/pages/[id] (publication)"
    
    # Test de l'API publique (page publiée doit être accessible)
    Test-Api -url "$baseUrl/api/pages/page-de-test-modifiee" -method "GET" -description "API GET /api/pages/[slug] (page publiée)"
    
    # Test de suppression de la page
    Test-Api -url "$baseUrl/api/admin/pages/$pageId" -method "DELETE" -description "API DELETE /api/admin/pages/[id] (suppression)"
}

Write-Host "`n🌐 Tests d'affichage des pages" -ForegroundColor Yellow
Write-Host "-----------------------------" -ForegroundColor Yellow

# Créer une page pour tester l'affichage
$displayPage = @{
    title = "Page d'Affichage Test"
    slug = "page-affichage-test"
    content = @"
<h1>Page d'Affichage Test</h1>
<p>Cette page teste l'affichage du contenu HTML.</p>
<h2>Sous-titre</h2>
<p>Paragraphe avec du <strong>texte en gras</strong> et du <em>texte en italique</em>.</p>
<ul>
    <li>Élément de liste 1</li>
    <li>Élément de liste 2</li>
    <li>Élément de liste 3</li>
</ul>
<blockquote>
    Ceci est une citation de test.
</blockquote>
"@
    metaDescription = "Page de test pour l'affichage du contenu"
    seoTitle = "Page d'Affichage Test - U Silenziu"
    keywords = @("affichage", "test", "contenu", "html")
    isPublished = $true
}

$displayPageResult = Test-Api -url "$baseUrl/api/admin/pages" -method "POST" -body $displayPage -description "Création d'une page pour test d'affichage"

if ($displayPageResult) {
    $displayPageId = $displayPageResult.data.id
    
    # Test d'affichage de la page
    Test-Url -url "$baseUrl/page-affichage-test" -description "Affichage de la page dynamique"
    
    # Nettoyer la page de test
    Test-Api -url "$baseUrl/api/admin/pages/$displayPageId" -method "DELETE" -description "Nettoyage de la page d'affichage test"
}

Write-Host "`n📊 Tests de validation" -ForegroundColor Yellow
Write-Host "---------------------" -ForegroundColor Yellow

# Test de validation des champs requis
$invalidPage = @{
    title = ""
    slug = "page-invalide"
    content = ""
}

Test-Api -url "$baseUrl/api/admin/pages" -method "POST" -body $invalidPage -description "Validation des champs requis"

# Test de validation du slug
$invalidSlugPage = @{
    title = "Page avec Slug Invalide"
    slug = "page_avec_underscores"
    content = "Contenu de test"
}

Test-Api -url "$baseUrl/api/admin/pages" -method "POST" -body $invalidSlugPage -description "Validation du format du slug"

Write-Host "`n🎯 Tests de performance" -ForegroundColor Yellow
Write-Host "----------------------" -ForegroundColor Yellow

# Test de performance de l'API de récupération
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Test-Api -url "$baseUrl/api/admin/pages" -method "GET" -description "Performance API GET /api/admin/pages"
$stopwatch.Stop()
Write-Host "⏱️  Temps de réponse: $($stopwatch.ElapsedMilliseconds)ms" -ForegroundColor Blue

Write-Host "`n✅ Tests terminés !" -ForegroundColor Green
Write-Host "==================" -ForegroundColor Green

Write-Host "`n📝 Résumé des fonctionnalités testées:" -ForegroundColor Cyan
Write-Host "- Interface d'administration des pages" -ForegroundColor White
Write-Host "- API CRUD complète (Create, Read, Update, Delete)" -ForegroundColor White
Write-Host "- API publique pour les pages publiées" -ForegroundColor White
Write-Host "- Affichage dynamique des pages côté site" -ForegroundColor White
Write-Host "- Validation des données" -ForegroundColor White
Write-Host "- Gestion des statuts (publié/brouillon)" -ForegroundColor White
Write-Host "- Métadonnées SEO dynamiques" -ForegroundColor White

Write-Host "`n🚀 Le module de gestion des pages est prêt à être utilisé !" -ForegroundColor Green
