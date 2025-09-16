# Script de configuration de la base de données pour les sections de la page d'accueil
# U Silenziu - Décembre 2024

Write-Host "🗄️  Configuration de la Base de Données - Sections de la Page d'Accueil" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan

# Vérifier que Docker est en cours d'exécution
Write-Host "`n📋 Étape 1: Vérification de Docker" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow

try {
    $dockerStatus = docker ps --format "table {{.Names}}\t{{.Status}}" 2>$null
    if ($dockerStatus -and $dockerStatus -notmatch "Error") {
        Write-Host "✅ Docker est en cours d'exécution" -ForegroundColor Green
        
        # Chercher le conteneur PostgreSQL
        $postgresContainer = $dockerStatus | Select-String "postgres"
        if ($postgresContainer) {
            Write-Host "✅ Conteneur PostgreSQL trouvé:" -ForegroundColor Green
            Write-Host $postgresContainer
        } else {
            Write-Host "⚠️  Conteneur PostgreSQL non trouvé" -ForegroundColor Yellow
            Write-Host "Vérifiez que docker-compose est bien démarré" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ Docker n'est pas en cours d'exécution" -ForegroundColor Red
        Write-Host "Démarrez Docker Desktop et relancez ce script" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "❌ Erreur lors de la vérification de Docker" -ForegroundColor Red
    exit 1
}

# Vérifier que le fichier SQL existe
Write-Host "`n📋 Étape 2: Vérification du fichier SQL" -ForegroundColor Yellow
Write-Host "------------------------------------------" -ForegroundColor Yellow

$sqlFile = "create-homepage-sections-table.sql"
if (Test-Path $sqlFile) {
    Write-Host "✅ Fichier SQL trouvé: $sqlFile" -ForegroundColor Green
    $sqlContent = Get-Content $sqlFile -Raw
    Write-Host "📏 Taille du fichier: $($sqlContent.Length) caractères" -ForegroundColor Blue
} else {
    Write-Host "❌ Fichier SQL non trouvé: $sqlFile" -ForegroundColor Red
    Write-Host "Vérifiez que le fichier est dans le répertoire courant" -ForegroundColor Yellow
    exit 1
}

# Vérifier que l'application est accessible
Write-Host "`n📋 Étape 3: Vérification de l'application" -ForegroundColor Yellow
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

# Tester l'API des sections avant configuration
Write-Host "`n📋 Étape 4: Test de l'API avant configuration" -ForegroundColor Yellow
Write-Host "-----------------------------------------------" -ForegroundColor Yellow

try {
    $sectionsResponse = Invoke-WebRequest -Uri "$baseUrl/api/homepage-sections" -Method GET -UseBasicParsing -TimeoutSec 10
    if ($sectionsResponse.StatusCode -eq 200) {
        $sectionsData = $sectionsResponse.Content | ConvertFrom-Json
        if ($sectionsData.success) {
            Write-Host "✅ API des sections déjà configurée" -ForegroundColor Green
            Write-Host "📊 Sections trouvées: $($sectionsData.count)" -ForegroundColor Blue
            foreach ($section in $sectionsData.data) {
                Write-Host "  - $($section.section_key): $($section.title)" -ForegroundColor White
            }
            Write-Host "`n💡 La base de données est déjà configurée !" -ForegroundColor Cyan
            Write-Host "Vous pouvez passer directement aux tests." -ForegroundColor White
        } else {
            Write-Host "⚠️  API accessible mais erreur: $($sectionsData.error)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠️  API des sections accessible mais avec un statut inattendu: $($sectionsResponse.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "ℹ️  API des sections non accessible - Configuration nécessaire" -ForegroundColor Blue
}

# Instructions pour la configuration manuelle
Write-Host "`n📋 Étape 5: Configuration de la base de données" -ForegroundColor Yellow
Write-Host "-----------------------------------------------" -ForegroundColor Yellow

Write-Host "ℹ️  Pour configurer la base de données, vous devez:" -ForegroundColor Blue
Write-Host "1. Exécuter le script SQL dans votre base PostgreSQL" -ForegroundColor White
Write-Host "2. Ou utiliser l'interface d'administration si elle est configurée" -ForegroundColor White

Write-Host "`n📝 Contenu du script SQL:" -ForegroundColor Cyan
Write-Host "------------------------" -ForegroundColor Cyan

# Afficher les premières lignes du script SQL
$sqlLines = Get-Content $sqlFile | Select-Object -First 20
foreach ($line in $sqlLines) {
    Write-Host $line -ForegroundColor Gray
}

if ((Get-Content $sqlFile).Count -gt 20) {
    Write-Host "... (fichier tronqué pour l'affichage)" -ForegroundColor Gray
}

Write-Host "`n💡 Options de configuration:" -ForegroundColor Cyan
Write-Host "1. Exécuter le script SQL directement dans PostgreSQL" -ForegroundColor White
Write-Host "2. Utiliser l'interface d'administration: $baseUrl/admin/homepage" -ForegroundColor White
Write-Host "3. Utiliser un client PostgreSQL comme pgAdmin ou DBeaver" -ForegroundColor White

Write-Host "`n🚀 Après la configuration:" -ForegroundColor Cyan
Write-Host "- Testez l'API: $baseUrl/api/homepage-sections" -ForegroundColor White
Write-Host "- Accédez à l'interface d'administration: $baseUrl/admin/homepage" -ForegroundColor White
Write-Host "- Vérifiez la page d'accueil: $baseUrl" -ForegroundColor White

Write-Host "`n✅ Script de configuration terminé !" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

Write-Host "`n📋 Prochaines étapes:" -ForegroundColor Cyan
Write-Host "1. Exécuter le script SQL dans PostgreSQL" -ForegroundColor White
Write-Host "2. Lancer le script de test: .\test-homepage-sections.ps1" -ForegroundColor White
Write-Host "3. Personnaliser le contenu via l'interface d'administration" -ForegroundColor White
