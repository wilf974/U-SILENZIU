# Script utilitaire pour basculer entre les environnements Docker

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "prod", "stop")]
    [string]$Environment
)

function Show-Header {
    param([string]$Title, [string]$Color = "Cyan")
    Write-Host ""
    Write-Host "🐳 $Title" -ForegroundColor $Color
    Write-Host ("=" * ($Title.Length + 3)) -ForegroundColor $Color
    Write-Host ""
}

function Stop-AllEnvironments {
    Show-Header "Arrêt de tous les environnements Docker"
    
    Write-Host "Arrêt de l'environnement de développement..." -ForegroundColor Yellow
    docker-compose -f docker-compose.dev.yml down 2>$null
    
    Write-Host "Arrêt de l'environnement de production..." -ForegroundColor Yellow
    docker-compose -f docker-compose.prod.yml down 2>$null
    
    Write-Host "Arrêt de l'environnement par défaut..." -ForegroundColor Yellow
    docker-compose down 2>$null
    
    Write-Host ""
    Write-Host "✅ Tous les environnements ont été arrêtés" -ForegroundColor Green
}

function Start-DevEnvironment {
    Show-Header "Démarrage de l'environnement de DÉVELOPPEMENT" "Green"
    
    # Arrêter tous les autres environnements
    Stop-AllEnvironments
    
    # Vérifier le fichier d'environnement
    if ((Test-Path "env.dev.example") -and (-not (Test-Path ".env.dev"))) {
        Write-Host "⚠️  Création de .env.dev depuis l'exemple..." -ForegroundColor Yellow
        Copy-Item "env.dev.example" ".env.dev"
        Write-Host "   Modifiez .env.dev selon vos besoins" -ForegroundColor Gray
    }
    
    # Démarrer le développement
    Write-Host "Démarrage des conteneurs de développement..." -ForegroundColor Yellow
    docker-compose -f docker-compose.dev.yml up -d --build
    
    # Attendre et vérifier
    Write-Host "Attente du démarrage..." -ForegroundColor Yellow
    Start-Sleep -Seconds 15
    
    Show-Services "dev"
    Show-DevInfo
}

function Start-ProdEnvironment {
    Show-Header "Démarrage de l'environnement de PRODUCTION" "Red"
    
    # Vérifications de sécurité
    if (-not (Test-Path ".env.prod")) {
        Write-Host "❌ ERREUR : Fichier .env.prod manquant !" -ForegroundColor Red
        Write-Host "   1. Copiez env.prod.example vers .env.prod" -ForegroundColor White
        Write-Host "   2. Modifiez toutes les valeurs de sécurité" -ForegroundColor White
        Write-Host "   3. Relancez ce script" -ForegroundColor White
        exit 1
    }
    
    # Arrêter tous les autres environnements
    Stop-AllEnvironments
    
    # Démarrer la production
    Write-Host "Démarrage des conteneurs de production..." -ForegroundColor Yellow
    docker-compose -f docker-compose.prod.yml up -d --build
    
    # Attendre et vérifier
    Write-Host "Attente du démarrage (plus long en production)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 25
    
    Show-Services "prod"
    Show-ProdInfo
}

function Show-Services {
    param([string]$Env)
    
    Write-Host "État des services $Env :" -ForegroundColor Cyan
    if ($Env -eq "dev") {
        docker-compose -f docker-compose.dev.yml ps
    } else {
        docker-compose -f docker-compose.prod.yml ps
    }
    Write-Host ""
}

function Show-DevInfo {
    Write-Host "🌐 URLs de développement :" -ForegroundColor Cyan
    Write-Host "   • Application : http://localhost:3000" -ForegroundColor White
    Write-Host "   • Admin : http://localhost:3000/admin" -ForegroundColor White
    Write-Host "   • PostgreSQL : localhost:5432 (usilenzio_dev)" -ForegroundColor White
    Write-Host "   • Redis : localhost:6379" -ForegroundColor White
    Write-Host ""
    Write-Host "📋 Commandes utiles :" -ForegroundColor Cyan
    Write-Host "   • Logs : docker-compose -f docker-compose.dev.yml logs -f" -ForegroundColor White
    Write-Host "   • Rebuild : .\docker-switch.ps1 dev" -ForegroundColor White
    Write-Host "   • Arrêt : .\docker-switch.ps1 stop" -ForegroundColor White
}

function Show-ProdInfo {
    Write-Host "🌐 URLs de production :" -ForegroundColor Cyan
    Write-Host "   • Application : http://localhost:3000" -ForegroundColor White
    Write-Host "   • Admin : http://localhost:3000/admin" -ForegroundColor White
    Write-Host "   • Nginx HTTP : http://localhost:80" -ForegroundColor White
    Write-Host "   • Nginx HTTPS : https://localhost:443" -ForegroundColor White
    Write-Host ""
    Write-Host "📋 Commandes utiles :" -ForegroundColor Cyan
    Write-Host "   • Logs : docker-compose -f docker-compose.prod.yml logs -f" -ForegroundColor White
    Write-Host "   • Sauvegarde : docker exec u-silenziu-backup /backup.sh" -ForegroundColor White
    Write-Host "   • Arrêt : .\docker-switch.ps1 stop" -ForegroundColor White
}

# Exécution principale
switch ($Environment) {
    "dev" { Start-DevEnvironment }
    "prod" { Start-ProdEnvironment }
    "stop" { Stop-AllEnvironments }
}

Write-Host ""
Write-Host "✅ Opération terminée !" -ForegroundColor Green
