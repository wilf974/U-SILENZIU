# Script pour démarrer l'environnement de DÉVELOPPEMENT

Write-Host "🚀 Démarrage de l'environnement de DÉVELOPPEMENT" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host ""

# Arrêter tous les conteneurs existants
Write-Host "1. Arrêt des conteneurs existants..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml down
docker-compose -f docker-compose.prod.yml down 2>$null

Write-Host ""

# Vérifier si .env.dev existe
if (Test-Path ".env.dev") {
    Write-Host "2. Chargement des variables d'environnement de développement..." -ForegroundColor Yellow
    Copy-Item ".env.dev" ".env" -Force
} else {
    Write-Host "⚠️  Fichier .env.dev non trouvé, utilisation des valeurs par défaut" -ForegroundColor Yellow
}

Write-Host ""

# Démarrer l'environnement de développement
Write-Host "3. Démarrage des conteneurs de développement..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml up -d --build

Write-Host ""

# Attendre que les services soient prêts
Write-Host "4. Attente du démarrage des services..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

# Vérifier l'état des services
Write-Host "5. Vérification de l'état des services..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml ps

Write-Host ""
Write-Host "✅ Environnement de DÉVELOPPEMENT démarré !" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 URL de développement :" -ForegroundColor Cyan
Write-Host "   • Application : http://localhost:3000" -ForegroundColor White
Write-Host "   • Admin : http://localhost:3000/admin" -ForegroundColor White
Write-Host "   • Base de données : localhost:5432 (usilenzio_dev)" -ForegroundColor White
Write-Host "   • Redis : localhost:6379" -ForegroundColor White
Write-Host ""
Write-Host "📋 Commandes utiles :" -ForegroundColor Cyan
Write-Host "   • Logs : docker-compose -f docker-compose.dev.yml logs -f" -ForegroundColor White
Write-Host "   • Arrêt : docker-compose -f docker-compose.dev.yml down" -ForegroundColor White
Write-Host "   • Rebuild : docker-compose -f docker-compose.dev.yml up -d --build" -ForegroundColor White

Write-Host ""
Read-Host "Appuyez sur Entrée pour continuer..."
