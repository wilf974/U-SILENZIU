# Script pour démarrer l'environnement de PRODUCTION

Write-Host "🚀 Démarrage de l'environnement de PRODUCTION" -ForegroundColor Red
Write-Host "===============================================" -ForegroundColor Red
Write-Host ""

# Vérification des prérequis
Write-Host "1. Vérification des prérequis..." -ForegroundColor Yellow

# Vérifier si .env.prod existe
if (-not (Test-Path ".env.prod")) {
    Write-Host "❌ ERREUR : Fichier .env.prod manquant !" -ForegroundColor Red
    Write-Host "   Créez le fichier .env.prod avec les variables de production" -ForegroundColor White
    Write-Host "   Exemple : SESSION_SECRET, JWT_SECRET, POSTGRES_PASSWORD, etc." -ForegroundColor White
    exit 1
}

# Vérifier si les certificats SSL existent (optionnel)
if (-not (Test-Path "nginx/ssl")) {
    Write-Host "⚠️  Répertoire SSL manquant - HTTPS ne sera pas disponible" -ForegroundColor Yellow
    Write-Host "   Créez le répertoire nginx/ssl avec vos certificats" -ForegroundColor White
}

Write-Host ""

# Arrêter l'environnement de développement
Write-Host "2. Arrêt de l'environnement de développement..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml down 2>$null

Write-Host ""

# Charger les variables de production
Write-Host "3. Chargement des variables d'environnement de production..." -ForegroundColor Yellow
Copy-Item ".env.prod" ".env" -Force

Write-Host ""

# Construire et démarrer la production
Write-Host "4. Construction et démarrage de l'environnement de production..." -ForegroundColor Yellow
docker-compose -f docker-compose.prod.yml up -d --build

Write-Host ""

# Attendre que les services soient prêts
Write-Host "5. Attente du démarrage des services..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Vérifier l'état des services
Write-Host "6. Vérification de l'état des services..." -ForegroundColor Yellow
docker-compose -f docker-compose.prod.yml ps

Write-Host ""

# Tests de santé
Write-Host "7. Tests de santé des services..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✅ Application accessible" -ForegroundColor Green
    }
} catch {
    Write-Host "   ❌ Erreur d'accès à l'application" -ForegroundColor Red
}

Write-Host ""
Write-Host "✅ Environnement de PRODUCTION démarré !" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 URLs de production :" -ForegroundColor Cyan
Write-Host "   • Application : http://localhost:3000" -ForegroundColor White
Write-Host "   • Admin : http://localhost:3000/admin" -ForegroundColor White
Write-Host "   • Nginx (HTTP) : http://localhost:80" -ForegroundColor White
Write-Host "   • Nginx (HTTPS) : https://localhost:443" -ForegroundColor White
Write-Host ""
Write-Host "📋 Commandes utiles :" -ForegroundColor Cyan
Write-Host "   • Logs : docker-compose -f docker-compose.prod.yml logs -f" -ForegroundColor White
Write-Host "   • Arrêt : docker-compose -f docker-compose.prod.yml down" -ForegroundColor White
Write-Host "   • Sauvegarde DB : docker exec u-silenziu-backup /backup.sh" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  IMPORTANT : Configurez vos certificats SSL et votre domaine !" -ForegroundColor Yellow

Write-Host ""
Read-Host "Appuyez sur Entrée pour continuer..."
