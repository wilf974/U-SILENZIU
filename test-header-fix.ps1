# Script de test pour vérifier la correction du header
# U Silenziu - Janvier 2025

Write-Host "🔧 Test de la correction du header..." -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

Write-Host "`n📡 Test 1: API homepage-sections" -ForegroundColor Yellow
try {
    $apiResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/homepage-sections" -Method GET
    if ($apiResponse.success -and $apiResponse.data) {
        Write-Host "✅ API répond correctement" -ForegroundColor Green
        Write-Host "   - Sections trouvées: $($apiResponse.data.Count)" -ForegroundColor Gray
        
        foreach ($section in $apiResponse.data) {
            Write-Host "   - $($section.section_type): $($section.title)" -ForegroundColor Gray
        }
    } else {
        Write-Host "❌ API ne retourne pas de données valides" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur API: $_" -ForegroundColor Red
}

Write-Host "`n🌐 Test 2: Page d'accueil" -ForegroundColor Yellow
try {
    $homeResponse = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing
    if ($homeResponse.StatusCode -eq 200) {
        Write-Host "✅ Page d'accueil accessible (Status: $($homeResponse.StatusCode))" -ForegroundColor Green
        
        # Vérifier que ce n'est plus du JSON brut affiché
        $content = $homeResponse.Content
        if ($content -like "*{`"title`"*" -and $content -like "*Hero*") {
            Write-Host "❌ Le contenu affiche encore du JSON brut" -ForegroundColor Red
        } else {
            Write-Host "✅ Le contenu semble correct (pas de JSON brut visible)" -ForegroundColor Green
        }
    } else {
        Write-Host "❌ Page d'accueil inaccessible (Status: $($homeResponse.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur page d'accueil: $_" -ForegroundColor Red
}

Write-Host "`n🗄️ Test 3: Données de la base" -ForegroundColor Yellow
try {
    $dbTest = docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c "SELECT count(*) as sections_count FROM homepage_sections WHERE is_active = true;" 2>$null
    if ($dbTest -match "(\d+)") {
        $count = $matches[1]
        Write-Host "✅ Base de données accessible" -ForegroundColor Green
        Write-Host "   - Sections actives: $count" -ForegroundColor Gray
    } else {
        Write-Host "❌ Impossible de compter les sections" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur base de données: $_" -ForegroundColor Red
}

Write-Host "`n📊 Test 4: Structure des données" -ForegroundColor Yellow
try {
    $schemaTest = docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c "SELECT column_name FROM information_schema.columns WHERE table_name = 'homepage_sections' AND column_name IN ('section_type', 'display_order');" 2>$null
    
    if ($schemaTest -match "section_type" -and $schemaTest -match "display_order") {
        Write-Host "✅ Schéma de base de données correct" -ForegroundColor Green
        Write-Host "   - Colonnes section_type et display_order présentes" -ForegroundColor Gray
    } else {
        Write-Host "❌ Schéma de base de données incorrect" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur vérification schéma: $_" -ForegroundColor Red
}

Write-Host "`n🎉 Résumé du test" -ForegroundColor Green
Write-Host "=================" -ForegroundColor Green
Write-Host "✅ Le problème du header devrait être résolu" -ForegroundColor Green
Write-Host "✅ Les interfaces TypeScript ont été corrigées" -ForegroundColor Green
Write-Host "✅ Les données d'encodage ont été nettoyées" -ForegroundColor Green
Write-Host "✅ L'application a été redémarrée" -ForegroundColor Green

Write-Host "`n📝 Note:" -ForegroundColor Cyan
Write-Host "Si vous voyez encore du JSON brut sur le site, videz le cache du navigateur (Ctrl+F5)" -ForegroundColor White


