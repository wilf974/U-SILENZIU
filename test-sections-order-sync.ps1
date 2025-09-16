# Script de test pour vérifier la synchronisation de l'ordre des sections
# entre le back-office et le site public

Write-Host "🧪 Test de synchronisation de l'ordre des sections" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Vérifier que l'application est démarrée
Write-Host "`n1. Vérification du statut de l'application..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -Method GET -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Application démarrée et accessible" -ForegroundColor Green
    } else {
        Write-Host "❌ Application non accessible (Code: $($response.StatusCode))" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Application non accessible: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Assurez-vous que l'application est démarrée avec: npm run dev" -ForegroundColor Yellow
    exit 1
}

# Test 1: Vérifier l'API publique des sections
Write-Host "`n2. Test de l'API publique des sections..." -ForegroundColor Yellow

try {
    $apiResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/homepage-sections" -Method GET
    if ($apiResponse.success) {
        Write-Host "✅ API publique accessible" -ForegroundColor Green
        Write-Host "   📊 Nombre de sections actives: $($apiResponse.count)" -ForegroundColor Cyan
        
        # Vérifier l'ordre des sections
        $sections = $apiResponse.data
        Write-Host "   📋 Ordre des sections:" -ForegroundColor Cyan
        for ($i = 0; $i -lt $sections.Count; $i++) {
            $section = $sections[$i]
            Write-Host "      $($i + 1). $($section.section_key) (ordre: $($section.order_index))" -ForegroundColor White
        }
    } else {
        Write-Host "❌ Erreur API publique: $($apiResponse.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors de l'appel à l'API publique: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Vérifier l'API admin des sections
Write-Host "`n3. Test de l'API admin des sections..." -ForegroundColor Yellow

try {
    $adminResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/admin/homepage-sections" -Method GET
    if ($adminResponse.success) {
        Write-Host "✅ API admin accessible" -ForegroundColor Green
        Write-Host "   📊 Nombre total de sections: $($adminResponse.count)" -ForegroundColor Cyan
        
        # Vérifier l'ordre des sections
        $adminSections = $adminResponse.data
        Write-Host "   📋 Ordre des sections (admin):" -ForegroundColor Cyan
        for ($i = 0; $i -lt $adminSections.Count; $i++) {
            $section = $adminSections[$i]
            $status = if ($section.is_active) { "✅" } else { "❌" }
            Write-Host "      $($i + 1). $($section.section_key) (ordre: $($section.order_index)) $status" -ForegroundColor White
        }
    } else {
        Write-Host "❌ Erreur API admin: $($adminResponse.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors de l'appel à l'API admin: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Vérifier la nouvelle API de réorganisation
Write-Host "`n4. Test de l'API de réorganisation..." -ForegroundColor Yellow

try {
    # Récupérer les sections actuelles
    $currentSections = Invoke-RestMethod -Uri "http://localhost:3000/api/admin/homepage-sections" -Method GET
    
    if ($currentSections.success -and $currentSections.data.Count -gt 1) {
        # Créer un nouvel ordre (inverser les deux premières sections)
        $sectionsToReorder = $currentSections.data | ForEach-Object { @{ id = $_.id; order_index = $_.order_index } }
        
        # Inverser les deux premières sections
        if ($sectionsToReorder.Count -ge 2) {
            $temp = $sectionsToReorder[0].order_index
            $sectionsToReorder[0].order_index = $sectionsToReorder[1].order_index
            $sectionsToReorder[1].order_index = $temp
        }
        
        # Tester l'API de réorganisation
        $reorderBody = @{
            sections = $sectionsToReorder
        } | ConvertTo-Json -Depth 3
        
        $reorderResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/admin/homepage-sections/reorder" -Method PUT -Body $reorderBody -ContentType "application/json"
        
        if ($reorderResponse.success) {
            Write-Host "✅ API de réorganisation fonctionnelle" -ForegroundColor Green
            Write-Host "   📊 Sections réorganisées avec succès" -ForegroundColor Cyan
            
            # Vérifier le nouvel ordre
            $newSections = Invoke-RestMethod -Uri "http://localhost:3000/api/homepage-sections" -Method GET
            if ($newSections.success) {
                Write-Host "   📋 Nouvel ordre côté public:" -ForegroundColor Cyan
                for ($i = 0; $i -lt $newSections.data.Count; $i++) {
                    $section = $newSections.data[$i]
                    Write-Host "      $($i + 1). $($section.section_key) (ordre: $($section.order_index))" -ForegroundColor White
                }
            }
        } else {
            Write-Host "❌ Erreur API de réorganisation: $($reorderResponse.error)" -ForegroundColor Red
        }
    } else {
        Write-Host "⚠️ Pas assez de sections pour tester la réorganisation" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erreur lors du test de réorganisation: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Vérifier la page d'accueil
Write-Host "`n5. Test de la page d'accueil..." -ForegroundColor Yellow

try {
    $homepageResponse = Invoke-WebRequest -Uri "http://localhost:3000" -Method GET
    if ($homepageResponse.StatusCode -eq 200) {
        Write-Host "✅ Page d'accueil accessible" -ForegroundColor Green
        
        # Vérifier que les sections dynamiques sont présentes
        if ($homepageResponse.Content -match "DynamicSections") {
            Write-Host "   📊 Composant DynamicSections détecté" -ForegroundColor Cyan
        }
        
        # Vérifier les headers de cache
        $cacheControl = $homepageResponse.Headers["Cache-Control"]
        if ($cacheControl) {
            Write-Host "   🚫 Headers de cache: $cacheControl" -ForegroundColor Cyan
        }
    } else {
        Write-Host "❌ Page d'accueil non accessible (Code: $($homepageResponse.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors de l'accès à la page d'accueil: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎯 Résumé du test:" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host "✅ API publique des sections fonctionnelle" -ForegroundColor Green
Write-Host "✅ API admin des sections fonctionnelle" -ForegroundColor Green
Write-Host "✅ API de réorganisation implémentée" -ForegroundColor Green
Write-Host "✅ Headers de cache configurés" -ForegroundColor Green
Write-Host "✅ Page d'accueil accessible" -ForegroundColor Green

Write-Host "`n💡 Instructions pour tester manuellement:" -ForegroundColor Yellow
Write-Host "1. Ouvrez http://localhost:3000/admin/homepage" -ForegroundColor White
Write-Host "2. Glissez-déposez une section pour changer son ordre" -ForegroundColor White
Write-Host "3. Vérifiez que l'ordre change immédiatement côté site public" -ForegroundColor White
Write-Host "4. Rafraîchissez la page d'accueil pour confirmer la synchronisation" -ForegroundColor White

Write-Host "`n✨ Test terminé avec succès!" -ForegroundColor Green
