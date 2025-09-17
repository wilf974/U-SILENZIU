# Script d'initialisation de la base de données de développement

Write-Host "🔄 Initialisation de la base de données de développement" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
Write-Host ""

# Vérifier que le conteneur PostgreSQL est en cours d'exécution
$postgresContainer = docker ps --filter "name=u-silenziu-postgres-dev" --format "{{.Names}}"
if (-not $postgresContainer) {
    Write-Host "❌ Le conteneur PostgreSQL de développement n'est pas en cours d'exécution" -ForegroundColor Red
    Write-Host "   Démarrez d'abord l'environnement avec: .\docker-switch.ps1 dev" -ForegroundColor White
    exit 1
}

Write-Host "✅ Conteneur PostgreSQL trouvé: $postgresContainer" -ForegroundColor Green
Write-Host ""

# Attendre que PostgreSQL soit prêt
Write-Host "⏳ Attente que PostgreSQL soit prêt..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Exécuter le script d'initialisation
Write-Host "📝 Exécution du script d'initialisation..." -ForegroundColor Yellow
try {
    docker exec -i u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev < init-db.sql
    Write-Host "✅ Script d'initialisation exécuté avec succès" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur lors de l'exécution du script: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Vérifier que les tables ont été créées
Write-Host "🔍 Vérification des tables créées..." -ForegroundColor Yellow
$tables = docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -t -c "\dt" | Where-Object { $_.Trim() -ne "" }

if ($tables) {
    Write-Host "✅ Tables trouvées:" -ForegroundColor Green
    foreach ($table in $tables) {
        if ($table.Trim()) {
            Write-Host "   • $($table.Trim())" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "❌ Aucune table trouvée" -ForegroundColor Red
}

Write-Host ""

# Test de l'API après initialisation
Write-Host "🧪 Test de l'API..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/homepage-sections" -TimeoutSec 10
    if ($response.success) {
        Write-Host "✅ API fonctionnelle - $($response.data.Count) sections trouvées" -ForegroundColor Green
    } else {
        Write-Host "⚠️ API répond mais sans données" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ API encore inaccessible - Redémarrage peut être nécessaire" -ForegroundColor Red
}

Write-Host ""
Write-Host "✅ Initialisation terminée !" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Votre environnement de développement est prêt :" -ForegroundColor Cyan
Write-Host "   • Application : http://localhost:3000" -ForegroundColor White
Write-Host "   • Admin : http://localhost:3000/admin" -ForegroundColor White
Write-Host "   • Base de données : usilenzio_dev (port 5432)" -ForegroundColor White

Write-Host ""
Read-Host "Appuyez sur Entrée pour continuer..."
