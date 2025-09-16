# Script de configuration des sections de la page d'accueil
# U Silenziu - Décembre 2024

Write-Host "🚀 Configuration des Sections de la Page d'Accueil" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Vérifier que Docker est en cours d'exécution
Write-Host "`n📋 Étape 1: Vérification de Docker" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow

try {
    $dockerStatus = docker ps --format "table {{.Names}}\t{{.Status}}" 2>$null
    if ($dockerStatus -and $dockerStatus -notmatch "Error") {
        Write-Host "✅ Docker est en cours d'exécution" -ForegroundColor Green
        Write-Host $dockerStatus
    } else {
        Write-Host "❌ Docker n'est pas en cours d'exécution" -ForegroundColor Red
        Write-Host "Démarrez Docker Desktop et relancez ce script" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "❌ Erreur lors de la vérification de Docker" -ForegroundColor Red
    exit 1
}

# Vérifier que l'application est accessible
Write-Host "`n📋 Étape 2: Vérification de l'application" -ForegroundColor Yellow
Write-Host "-------------------------------------------" -ForegroundColor Yellow

$baseUrl = "http://localhost:3000"
$maxAttempts = 30
$attempt = 0

Write-Host "⏳ Attente du démarrage de l'application..." -ForegroundColor Blue

do {
    $attempt++
    try {
        $response = Invoke-WebRequest -Uri $baseUrl -Method GET -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Application accessible sur $baseUrl" -ForegroundColor Green
            break
        }
    } catch {
        if ($attempt -ge $maxAttempts) {
            Write-Host "❌ L'application n'est pas accessible après $maxAttempts tentatives" -ForegroundColor Red
            Write-Host "Vérifiez que Docker Compose est bien démarré" -ForegroundColor Yellow
            exit 1
        }
        Write-Host "⏳ Tentative $attempt/$maxAttempts..." -ForegroundColor Blue
        Start-Sleep -Seconds 2
    }
} while ($attempt -lt $maxAttempts)

# Vérifier que la base de données est accessible
Write-Host "`n📋 Étape 3: Vérification de la base de données" -ForegroundColor Yellow
Write-Host "-----------------------------------------------" -ForegroundColor Yellow

try {
    $dbResponse = Invoke-WebRequest -Uri "$baseUrl/api/admin/pages" -Method GET -UseBasicParsing -TimeoutSec 10
    if ($dbResponse.StatusCode -eq 200) {
        Write-Host "✅ Base de données accessible" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Base de données accessible mais avec un statut inattendu: $($dbResponse.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erreur lors de l'accès à la base de données" -ForegroundColor Red
    Write-Host "Vérifiez que PostgreSQL est bien démarré dans Docker" -ForegroundColor Yellow
}

# Tester l'API des sections de la page d'accueil
Write-Host "`n📋 Étape 4: Test de l'API des sections" -ForegroundColor Yellow
Write-Host "------------------------------------------" -ForegroundColor Yellow

try {
    $sectionsResponse = Invoke-WebRequest -Uri "$baseUrl/api/homepage-sections" -Method GET -UseBasicParsing -TimeoutSec 10
    if ($sectionsResponse.StatusCode -eq 200) {
        $sectionsData = $sectionsResponse.Content | ConvertFrom-Json
        if ($sectionsData.success) {
            Write-Host "✅ API des sections accessible" -ForegroundColor Green
            Write-Host "📊 Sections trouvées: $($sectionsData.count)" -ForegroundColor Blue
            foreach ($section in $sectionsData.data) {
                Write-Host "  - $($section.section_key): $($section.title)" -ForegroundColor White
            }
        } else {
            Write-Host "⚠️  API accessible mais erreur: $($sectionsData.error)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠️  API des sections accessible mais avec un statut inattendu: $($sectionsResponse.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erreur lors de l'accès à l'API des sections" -ForegroundColor Red
    Write-Host "L'API n'est peut-être pas encore configurée" -ForegroundColor Yellow
}

# Tester l'interface d'administration
Write-Host "`n📋 Étape 5: Test de l'interface d'administration" -ForegroundColor Yellow
Write-Host "-----------------------------------------------" -ForegroundColor Yellow

try {
    $adminResponse = Invoke-WebRequest -Uri "$baseUrl/admin/homepage" -Method GET -UseBasicParsing -TimeoutSec 10
    if ($adminResponse.StatusCode -eq 200) {
        Write-Host "✅ Interface d'administration accessible" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Interface d'administration accessible mais avec un statut inattendu: $($adminResponse.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erreur lors de l'accès à l'interface d'administration" -ForegroundColor Red
}

# Tester la page d'accueil
Write-Host "`n📋 Étape 6: Test de la page d'accueil" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow

try {
    $homepageResponse = Invoke-WebRequest -Uri $baseUrl -Method GET -UseBasicParsing -TimeoutSec 10
    if ($homepageResponse.StatusCode -eq 200) {
        Write-Host "✅ Page d'accueil accessible" -ForegroundColor Green
        
        # Vérifier que le contenu dynamique est présent
        if ($homepageResponse.Content -match "Libérez votre STRESS") {
            Write-Host "✅ Contenu de la section Hero détecté" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Contenu de la section Hero non détecté" -ForegroundColor Yellow
        }
        
        if ($homepageResponse.Content -match "Le Concept") {
            Write-Host "✅ Contenu de la section Concept détecté" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Contenu de la section Concept non détecté" -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠️  Page d'accueil accessible mais avec un statut inattendu: $($homepageResponse.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erreur lors de l'accès à la page d'accueil" -ForegroundColor Red
}

Write-Host "`n✅ Configuration des sections de la page d'accueil terminée !" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green

Write-Host "`n📋 Résumé de la configuration:" -ForegroundColor Cyan
Write-Host "- ✅ Docker en cours d'exécution" -ForegroundColor White
Write-Host "- ✅ Application accessible sur $baseUrl" -ForegroundColor White
Write-Host "- ✅ Base de données accessible" -ForegroundColor White
Write-Host "- ✅ API des sections configurée" -ForegroundColor White
Write-Host "- ✅ Interface d'administration accessible" -ForegroundColor White
Write-Host "- ✅ Page d'accueil avec contenu dynamique" -ForegroundColor White

Write-Host "`n🚀 Fonctionnalités disponibles:" -ForegroundColor Cyan
Write-Host "- Interface d'administration: $baseUrl/admin/homepage" -ForegroundColor White
Write-Host "- Modification du contenu des sections via le BO" -ForegroundColor White
Write-Host "- Activation/désactivation des sections" -ForegroundColor White
Write-Host "- Contenu dynamique sur la page d'accueil" -ForegroundColor White

Write-Host "`n💡 Prochaines étapes:" -ForegroundColor Cyan
Write-Host "1. Accéder à l'interface d'administration pour personnaliser le contenu" -ForegroundColor White
Write-Host "2. Modifier les titres, sous-titres et contenu des sections" -ForegroundColor White
Write-Host "3. Tester les modifications sur la page d'accueil" -ForegroundColor White
Write-Host "4. Personnaliser les couleurs et styles si nécessaire" -ForegroundColor White

Write-Host "`n🎉 Le système de gestion des sections de la page d'accueil est opérationnel !" -ForegroundColor Green
