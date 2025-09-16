# Test du système d'édition intuitive des sections de la page d'accueil
# U Silenziu - Décembre 2024

Write-Host "🧪 Test du système d'édition intuitive des sections de la page d'accueil" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

# Configuration
$baseUrl = "http://localhost:3000"
$adminUrl = "$baseUrl/admin/homepage"

# Fonction pour tester une URL
function Test-Url {
    param($url, $description)
    try {
        $response = Invoke-WebRequest -Uri $url -Method GET -TimeoutSec 10
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

# Fonction pour tester l'API
function Test-Api {
    param($url, $method = "GET", $description)
    try {
        $response = Invoke-WebRequest -Uri $url -Method $method -TimeoutSec 10
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

Write-Host "`n📋 Phase 1: Vérification de l'accessibilité" -ForegroundColor Yellow

# Test de l'application principale
$mainSiteOk = Test-Url -url $baseUrl -description "Site principal accessible"

# Test de l'interface d'administration
$adminOk = Test-Url -url $adminUrl -description "Interface d'administration accessible"

Write-Host "`n📋 Phase 2: Test des API de sections" -ForegroundColor Yellow

# Test de l'API publique des sections
$publicSections = Test-Api -url "$baseUrl/api/homepage-sections" -description "API publique des sections"

# Test de l'API admin des sections
$adminSections = Test-Api -url "$baseUrl/api/admin/homepage-sections" -description "API admin des sections"

Write-Host "`n📋 Phase 3: Validation des données" -ForegroundColor Yellow

if ($publicSections -and $adminSections) {
    $publicCount = $publicSections.data.Count
    $adminCount = $adminSections.data.Count
    
    Write-Host "📊 Sections publiques: $publicCount" -ForegroundColor Blue
    Write-Host "📊 Sections admin: $adminCount" -ForegroundColor Blue
    
    # Vérifier que les sections publiques sont bien filtrées (actives uniquement)
    $activeSections = $adminSections.data | Where-Object { $_.is_active -eq $true }
    if ($publicCount -eq $activeSections.Count) {
        Write-Host "✅ Filtrage des sections actives correct" -ForegroundColor Green
    } else {
        Write-Host "❌ Problème de filtrage des sections actives" -ForegroundColor Red
    }
    
    # Afficher les sections disponibles
    Write-Host "`n📋 Sections disponibles:" -ForegroundColor Yellow
    foreach ($section in $adminSections.data) {
        $status = if ($section.is_active) { "🟢 Active" } else { "🔴 Inactive" }
        Write-Host "  - $($section.section_key): $($section.title) ($status)" -ForegroundColor White
    }
}

Write-Host "`n📋 Phase 4: Test de modification d'une section" -ForegroundColor Yellow

if ($adminSections) {
    # Prendre la première section pour le test
    $testSection = $adminSections.data[0]
    if ($testSection) {
        Write-Host "🧪 Test de modification de la section: $($testSection.section_key)" -ForegroundColor Blue
        
        # Préparer les données de test
        $testData = @{
            title = "Titre de test - $(Get-Date -Format 'HH:mm:ss')"
            subtitle = "Sous-titre de test"
            content = $testSection.content
            image_url = $testSection.image_url
            video_url = $testSection.video_url
            background_color = $testSection.background_color
            text_color = $testSection.text_color
            is_active = $testSection.is_active
        }
        
        # Test de modification
        try {
            $jsonData = $testData | ConvertTo-Json -Depth 10
            $response = Invoke-WebRequest -Uri "$baseUrl/api/admin/homepage-sections/$($testSection.id)" -Method PUT -Body $jsonData -ContentType "application/json" -TimeoutSec 10
            $result = $response.Content | ConvertFrom-Json
            
            if ($result.success) {
                Write-Host "✅ Modification de section réussie" -ForegroundColor Green
                
                # Restaurer les données originales
                $originalData = @{
                    title = $testSection.title
                    subtitle = $testSection.subtitle
                    content = $testSection.content
                    image_url = $testSection.image_url
                    video_url = $testSection.video_url
                    background_color = $testSection.background_color
                    text_color = $testSection.text_color
                    is_active = $testSection.is_active
                }
                
                $originalJson = $originalData | ConvertTo-Json -Depth 10
                $restoreResponse = Invoke-WebRequest -Uri "$baseUrl/api/admin/homepage-sections/$($testSection.id)" -Method PUT -Body $originalJson -ContentType "application/json" -TimeoutSec 10
                $restoreResult = $restoreResponse.Content | ConvertFrom-Json
                
                if ($restoreResult.success) {
                    Write-Host "✅ Restauration des données originales réussie" -ForegroundColor Green
                } else {
                    Write-Host "⚠️  Restauration des données originales échouée" -ForegroundColor Yellow
                }
            } else {
                Write-Host "❌ Modification de section échouée: $($result.error)" -ForegroundColor Red
            }
        } catch {
            Write-Host "❌ Erreur lors de la modification: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "`n📋 Phase 5: Test de basculement de statut" -ForegroundColor Yellow

if ($adminSections) {
    $testSection = $adminSections.data[0]
    if ($testSection) {
        $newStatus = -not $testSection.is_active
        
        try {
            $statusData = @{ is_active = $newStatus } | ConvertTo-Json
            $response = Invoke-WebRequest -Uri "$baseUrl/api/admin/homepage-sections/$($testSection.id)" -Method PUT -Body $statusData -ContentType "application/json" -TimeoutSec 10
            $result = $response.Content | ConvertFrom-Json
            
            if ($result.success) {
                Write-Host "✅ Basculement de statut réussi (nouveau statut: $newStatus)" -ForegroundColor Green
                
                # Restaurer le statut original
                $originalStatusData = @{ is_active = $testSection.is_active } | ConvertTo-Json
                $restoreResponse = Invoke-WebRequest -Uri "$baseUrl/api/admin/homepage-sections/$($testSection.id)" -Method PUT -Body $originalStatusData -ContentType "application/json" -TimeoutSec 10
                $restoreResult = $restoreResponse.Content | ConvertFrom-Json
                
                if ($restoreResult.success) {
                    Write-Host "✅ Restauration du statut original réussie" -ForegroundColor Green
                } else {
                    Write-Host "⚠️  Restauration du statut original échouée" -ForegroundColor Yellow
                }
            } else {
                Write-Host "❌ Basculement de statut échoué: $($result.error)" -ForegroundColor Red
            }
        } catch {
            Write-Host "❌ Erreur lors du basculement de statut: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "`n📋 Phase 6: Validation de l'interface utilisateur" -ForegroundColor Yellow

# Vérifier que l'interface d'administration contient les éléments attendus
if ($adminOk) {
    try {
        $response = Invoke-WebRequest -Uri $adminUrl -Method GET -TimeoutSec 10
        $content = $response.Content
        
        # Vérifier la présence d'éléments clés
        $checks = @(
            @{ Pattern = "Gestion de la Page d'Accueil"; Description = "Titre principal" },
            @{ Pattern = "Modifiez le contenu de votre page d'accueil de manière intuitive"; Description = "Description" },
            @{ Pattern = "Voir le site"; Description = "Bouton de prévisualisation" },
            @{ Pattern = "Sections de la Page d'Accueil"; Description = "Liste des sections" },
            @{ Pattern = "Modifier"; Description = "Boutons de modification" }
        )
        
        foreach ($check in $checks) {
            if ($content -match $check.Pattern) {
                Write-Host "✅ $($check.Description) présent dans l'interface" -ForegroundColor Green
            } else {
                Write-Host "❌ $($check.Description) manquant dans l'interface" -ForegroundColor Red
            }
        }
    } catch {
        Write-Host "❌ Erreur lors de la vérification de l'interface: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n📋 Phase 7: Test de prévisualisation" -ForegroundColor Yellow

# Vérifier que le site principal affiche correctement les sections
if ($mainSiteOk -and $publicSections) {
    try {
        $response = Invoke-WebRequest -Uri $baseUrl -Method GET -TimeoutSec 10
        $content = $response.Content
        
        # Vérifier que les sections sont bien affichées
        foreach ($section in $publicSections.data) {
            if ($section.title -and $content -match [regex]::Escape($section.title)) {
                Write-Host "✅ Section '$($section.section_key)' affichée sur le site" -ForegroundColor Green
            } else {
                Write-Host "⚠️  Section '$($section.section_key)' non trouvée sur le site" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "❌ Erreur lors de la vérification du site: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n🎯 Résumé du test" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan

$tests = @(
    @{ Name = "Site principal"; Result = $mainSiteOk },
    @{ Name = "Interface admin"; Result = $adminOk },
    @{ Name = "API publique"; Result = $publicSections -ne $null },
    @{ Name = "API admin"; Result = $adminSections -ne $null }
)

$passedTests = 0
foreach ($test in $tests) {
    if ($test.Result) {
        Write-Host "✅ $($test.Name): OK" -ForegroundColor Green
        $passedTests++
    } else {
        Write-Host "❌ $($test.Name): ÉCHEC" -ForegroundColor Red
    }
}

Write-Host "`n📊 Résultat: $passedTests/$($tests.Count) tests réussis" -ForegroundColor Cyan

if ($passedTests -eq $tests.Count) {
    Write-Host "🎉 Tous les tests sont passés avec succès !" -ForegroundColor Green
    Write-Host "🚀 Le système d'édition intuitive des sections est opérationnel." -ForegroundColor Green
} else {
    Write-Host "⚠️  Certains tests ont échoué. Vérifiez la configuration." -ForegroundColor Yellow
}

Write-Host "`n🔗 URLs utiles:" -ForegroundColor Cyan
Write-Host "  - Site principal: $baseUrl" -ForegroundColor White
Write-Host "  - Interface admin: $adminUrl" -ForegroundColor White
Write-Host "  - API publique: $baseUrl/api/homepage-sections" -ForegroundColor White
Write-Host "  - API admin: $baseUrl/api/admin/homepage-sections" -ForegroundColor White

Write-Host "`n✨ Test terminé !" -ForegroundColor Cyan
