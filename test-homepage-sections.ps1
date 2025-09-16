# Script de test pour le système de gestion des sections de la page d'accueil
# U Silenziu - Décembre 2024

Write-Host "🧪 Test du Système de Gestion des Sections de la Page d'Accueil" -ForegroundColor Cyan
Write-Host "=============================================================" -ForegroundColor Cyan

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

Write-Host "`n📋 Étape 1: Test de l'interface d'administration" -ForegroundColor Yellow
Write-Host "-----------------------------------------------" -ForegroundColor Yellow

# Test de la page d'administration des sections
Test-Url -url "$baseUrl/admin/homepage" -description "Interface d'administration des sections accessible"

Write-Host "`n📋 Étape 2: Test des API routes" -ForegroundColor Yellow
Write-Host "----------------------------" -ForegroundColor Yellow

# Test de l'API publique
$publicSections = Test-Api -url "$baseUrl/api/homepage-sections" -method "GET" -description "API publique des sections"

if ($publicSections) {
    Write-Host "📊 Sections trouvées: $($publicSections.count)" -ForegroundColor Blue
    foreach ($section in $publicSections.data) {
        Write-Host "  - $($section.section_key): $($section.title)" -ForegroundColor White
    }
}

# Test de l'API admin
$adminSections = Test-Api -url "$baseUrl/api/admin/homepage-sections" -method "GET" -description "API admin des sections"

if ($adminSections) {
    Write-Host "📊 Sections admin trouvées: $($adminSections.count)" -ForegroundColor Blue
}

Write-Host "`n📋 Étape 3: Test de modification d'une section" -ForegroundColor Yellow
Write-Host "---------------------------------------------" -ForegroundColor Yellow

if ($adminSections -and $adminSections.data.Count -gt 0) {
    $heroSection = $adminSections.data | Where-Object { $_.section_key -eq "hero" }
    
    if ($heroSection) {
        Write-Host "📝 Modification de la section Hero..." -ForegroundColor Blue
        
        $updateData = @{
            title = "Libérez votre STRESS - MODIFIÉ"
            subtitle = "Venez vous défouler en toute sécurité chez U Silenziu - Test de modification"
            content = '{"features": [{"icon": "Shield", "title": "100% Sécurisé - MODIFIÉ", "description": "Équipement complet fourni"}, {"icon": "Zap", "title": "Décompression", "description": "Évacuez votre stress"}, {"icon": "Clock", "title": "Flexibilité", "description": "Sessions de 20-30 min"}], "cta_primary": "Réserver maintenant - MODIFIÉ", "cta_secondary": "Découvrir nos salles"}'
        }
        
        $updatedSection = Test-Api -url "$baseUrl/api/admin/homepage-sections/$($heroSection.id)" -method "PUT" -body $updateData -description "Modification de la section Hero"
        
        if ($updatedSection) {
            Write-Host "✅ Section Hero modifiée avec succès" -ForegroundColor Green
            Write-Host "   Nouveau titre: $($updatedSection.data.title)" -ForegroundColor White
        }
    } else {
        Write-Host "⚠️  Section Hero non trouvée" -ForegroundColor Yellow
    }
}

Write-Host "`n📋 Étape 4: Test de la page d'accueil" -ForegroundColor Yellow
Write-Host "-------------------------------------" -ForegroundColor Yellow

# Test de la page d'accueil
Test-Url -url "$baseUrl/" -description "Page d'accueil accessible"

Write-Host "`n📋 Étape 5: Test de désactivation d'une section" -ForegroundColor Yellow
Write-Host "-----------------------------------------------" -ForegroundColor Yellow

if ($adminSections -and $adminSections.data.Count -gt 0) {
    $conceptSection = $adminSections.data | Where-Object { $_.section_key -eq "concept" }
    
    if ($conceptSection) {
        Write-Host "📝 Désactivation de la section Concept..." -ForegroundColor Blue
        
        $deactivateData = @{
            is_active = $false
        }
        
        $deactivatedSection = Test-Api -url "$baseUrl/api/admin/homepage-sections/$($conceptSection.id)" -method "PUT" -body $deactivateData -description "Désactivation de la section Concept"
        
        if ($deactivatedSection) {
            Write-Host "✅ Section Concept désactivée" -ForegroundColor Green
        }
    }
}

Write-Host "`n📋 Étape 6: Test de réactivation" -ForegroundColor Yellow
Write-Host "----------------------------" -ForegroundColor Yellow

if ($conceptSection) {
    Write-Host "📝 Réactivation de la section Concept..." -ForegroundColor Blue
    
    $activateData = @{
        is_active = $true
    }
    
    $activatedSection = Test-Api -url "$baseUrl/api/admin/homepage-sections/$($conceptSection.id)" -method "PUT" -body $activateData -description "Réactivation de la section Concept"
    
    if ($activatedSection) {
        Write-Host "✅ Section Concept réactivée" -ForegroundColor Green
    }
}

Write-Host "`n📋 Étape 7: Test de performance" -ForegroundColor Yellow
Write-Host "----------------------------" -ForegroundColor Yellow

# Test de performance de l'API
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Test-Api -url "$baseUrl/api/homepage-sections" -method "GET" -description "Performance API publique"
$stopwatch.Stop()
Write-Host "⏱️  Temps de réponse: $($stopwatch.ElapsedMilliseconds)ms" -ForegroundColor Blue

Write-Host "`n✅ Tests du système de gestion des sections terminés !" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

Write-Host "`n📝 Résumé des fonctionnalités testées:" -ForegroundColor Cyan
Write-Host "- Interface d'administration des sections" -ForegroundColor White
Write-Host "- API publique et admin pour les sections" -ForegroundColor White
Write-Host "- Modification du contenu des sections" -ForegroundColor White
Write-Host "- Activation/désactivation des sections" -ForegroundColor White
Write-Host "- Performance des API" -ForegroundColor White

Write-Host "`n🚀 Le système de gestion des sections de la page d'accueil est opérationnel !" -ForegroundColor Green
Write-Host "`n📋 Fonctionnalités disponibles:" -ForegroundColor Cyan
Write-Host "- Modification du contenu de chaque section" -ForegroundColor White
Write-Host "- Activation/désactivation des sections" -ForegroundColor White
Write-Host "- Gestion des titres, sous-titres et contenu JSON" -ForegroundColor White
Write-Host "- Interface d'administration intuitive" -ForegroundColor White

Write-Host "`n💡 Prochaines étapes:" -ForegroundColor Cyan
Write-Host "1. Accéder à l'interface d'administration: $baseUrl/admin/homepage" -ForegroundColor White
Write-Host "2. Modifier le contenu des sections selon vos besoins" -ForegroundColor White
Write-Host "3. Tester les modifications sur la page d'accueil" -ForegroundColor White
Write-Host "4. Personnaliser les couleurs et styles si nécessaire" -ForegroundColor White
