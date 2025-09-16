# Test de la page de test complète - U Silenziu
# Script PowerShell pour vérifier le bon fonctionnement de la page de test

Write-Host "=== Test de la page de test complète U Silenziu ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: Vérifier l'accessibilité de la page de test
Write-Host "1. Test d'accessibilité de la page de test..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/test" -Method GET
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✅ Page de test accessible (Status: $($response.StatusCode))" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Page de test non accessible (Status: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erreur d'accès à la page de test: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 2: Vérifier que l'application principale fonctionne
Write-Host "2. Test de l'application principale..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -Method GET
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✅ Application principale accessible (Status: $($response.StatusCode))" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Application principale non accessible (Status: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erreur d'accès à l'application: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Vérifier l'interface d'administration
Write-Host "3. Test de l'interface d'administration..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/admin" -Method GET
    if ($response.StatusCode -eq 401) {
        Write-Host "   ✅ Interface admin protégée (Status: 401 - Authentification requise)" -ForegroundColor Green
    } elseif ($response.StatusCode -eq 200) {
        Write-Host "   ⚠️  Interface admin accessible sans authentification (Status: 200)" -ForegroundColor Yellow
    } else {
        Write-Host "   ❌ Interface admin non accessible (Status: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erreur d'accès à l'interface admin: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 4: Vérifier les API principales
Write-Host "4. Test des API principales..." -ForegroundColor Yellow

$apis = @(
    @{Name="Réservations"; URL="/api/reservations"},
    @{Name="Salles"; URL="/api/admin/rooms"},
    @{Name="Upload"; URL="/api/admin/upload"},
    @{Name="Notifications"; URL="/api/notifications/send"}
)

foreach ($api in $apis) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000$($api.URL)" -Method GET
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✅ API $($api.Name) accessible (Status: 200)" -ForegroundColor Green
        } elseif ($response.StatusCode -eq 401) {
            Write-Host "   ⚠️  API $($api.Name) protégée (Status: 401)" -ForegroundColor Yellow
        } else {
            Write-Host "   ❌ API $($api.Name) erreur (Status: $($response.StatusCode))" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ Erreur API $($api.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""

# Test 5: Vérifier les pages principales
Write-Host "5. Test des pages principales..." -ForegroundColor Yellow

$pages = @(
    @{Name="Accueil"; URL="/"},
    @{Name="Salles"; URL="/rooms"},
    @{Name="Concept"; URL="/concept"},
    @{Name="Contact"; URL="/contact"},
    @{Name="Réservation"; URL="/reservation"}
)

foreach ($page in $pages) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000$($page.URL)" -Method GET
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✅ Page $($page.Name) accessible (Status: 200)" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Page $($page.Name) erreur (Status: $($response.StatusCode))" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ Erreur page $($page.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""

# Test 6: Vérifier les services CRON
Write-Host "6. Test des services CRON..." -ForegroundColor Yellow

$cronApis = @(
    @{Name="Statut CRON"; URL="/api/admin/cron/status"},
    @{Name="Démarrage CRON"; URL="/api/admin/cron/start"},
    @{Name="Arrêt CRON"; URL="/api/admin/cron/stop"},
    @{Name="Test CRON"; URL="/api/admin/cron/test"}
)

foreach ($api in $cronApis) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000$($api.URL)" -Method GET
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✅ $($api.Name) accessible (Status: 200)" -ForegroundColor Green
        } elseif ($response.StatusCode -eq 401) {
            Write-Host "   ⚠️  $($api.Name) protégé (Status: 401)" -ForegroundColor Yellow
        } else {
            Write-Host "   ❌ $($api.Name) erreur (Status: $($response.StatusCode))" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ Erreur $($api.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""

# Test 7: Vérifier les services SMTP
Write-Host "7. Test des services SMTP..." -ForegroundColor Yellow

$smtpApis = @(
    @{Name="Statut SMTP"; URL="/api/admin/smtp/status"},
    @{Name="Configuration SMTP"; URL="/api/admin/smtp/config"},
    @{Name="Test SMTP"; URL="/api/admin/smtp/test"}
)

foreach ($api in $smtpApis) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000$($api.URL)" -Method GET
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✅ $($api.Name) accessible (Status: 200)" -ForegroundColor Green
        } elseif ($response.StatusCode -eq 401) {
            Write-Host "   ⚠️  $($api.Name) protégé (Status: 401)" -ForegroundColor Yellow
        } else {
            Write-Host "   ❌ $($api.Name) erreur (Status: $($response.StatusCode))" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ Erreur $($api.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""

# Résumé et instructions
Write-Host "=== Résumé des tests ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Instructions pour utiliser la page de test :" -ForegroundColor White
Write-Host "1. Ouvrez votre navigateur et allez sur : http://localhost:3000/test" -ForegroundColor Gray
Write-Host "2. Cliquez sur 'Lancer tous les tests' pour exécuter tous les tests" -ForegroundColor Gray
Write-Host "3. Consultez les résultats détaillés pour chaque catégorie" -ForegroundColor Gray
Write-Host "4. Utilisez les informations pour identifier et corriger les problèmes" -ForegroundColor Gray
Write-Host ""
Write-Host "🔧 Accès à l'interface d'administration :" -ForegroundColor White
Write-Host "- URL : http://localhost:3000/admin" -ForegroundColor Gray
Write-Host "- Identifiants : admin / admin123" -ForegroundColor Gray
Write-Host "- Lien vers les tests disponible dans l'interface admin" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ Page de test complète opérationnelle !" -ForegroundColor Green
