# Script de test des environnements Docker

Write-Host "🧪 Test des environnements Docker U Silenziu" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

function Test-Environment {
    param([string]$Name, [string]$Url, [string]$DbName)
    
    Write-Host "Test de l'environnement $Name..." -ForegroundColor Yellow
    
    # Test de l'application
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✅ Application accessible" -ForegroundColor Green
            Write-Host "   📊 Taille: $($response.Content.Length) caractères" -ForegroundColor Gray
        }
    } catch {
        Write-Host "   ❌ Application inaccessible: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Test de l'API
    try {
        $apiResponse = Invoke-RestMethod -Uri "$Url/api/homepage-sections" -TimeoutSec 5
        if ($apiResponse.success) {
            Write-Host "   ✅ API fonctionnelle ($($apiResponse.data.Count) sections)" -ForegroundColor Green
        }
    } catch {
        Write-Host "   ❌ API inaccessible" -ForegroundColor Red
    }
    
    Write-Host ""
}

# Test de l'environnement actuel
Write-Host "Test de l'environnement ACTUEL..." -ForegroundColor Yellow
Test-Environment "ACTUEL" "http://localhost:3000" "current"

# Afficher les conteneurs en cours
Write-Host "📦 Conteneurs en cours d'exécution :" -ForegroundColor Cyan
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

Write-Host ""
Write-Host "🔧 Commandes disponibles :" -ForegroundColor Cyan
Write-Host "   • Basculer en DEV    : .\docker-switch.ps1 dev" -ForegroundColor White
Write-Host "   • Basculer en PROD   : .\docker-switch.ps1 prod" -ForegroundColor White
Write-Host "   • Arrêter tout       : .\docker-switch.ps1 stop" -ForegroundColor White
Write-Host "   • Logs dev           : docker-compose -f docker-compose.dev.yml logs -f" -ForegroundColor White
Write-Host "   • Logs prod          : docker-compose -f docker-compose.prod.yml logs -f" -ForegroundColor White

Write-Host ""
Write-Host "✅ Test terminé !" -ForegroundColor Green
