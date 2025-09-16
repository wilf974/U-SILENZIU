# Script de diagnostic Docker
Write-Host "=== Diagnostic Docker ===" -ForegroundColor Green
Write-Host ""

Write-Host "1. Vérification de Docker Desktop" -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker installé: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker non installé ou non démarré" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "2. Vérification des conteneurs" -ForegroundColor Yellow
try {
    $containers = docker ps -a
    if ($containers) {
        Write-Host "✅ Conteneurs trouvés:" -ForegroundColor Green
        $containers | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    } else {
        Write-Host "❌ Aucun conteneur trouvé" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors de la vérification des conteneurs" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Vérification du fichier docker-compose.yml" -ForegroundColor Yellow
if (Test-Path "docker-compose.yml") {
    Write-Host "✅ docker-compose.yml trouvé" -ForegroundColor Green
} else {
    Write-Host "❌ docker-compose.yml non trouvé" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Tentative de démarrage des services" -ForegroundColor Yellow
try {
    Write-Host "Arrêt des services existants..." -ForegroundColor Gray
    docker-compose down 2>$null
    
    Write-Host "Démarrage des services..." -ForegroundColor Gray
    docker-compose up -d --build
    
    Write-Host "Attente du démarrage..." -ForegroundColor Gray
    Start-Sleep -Seconds 15
    
    Write-Host "Vérification de l'état des conteneurs..." -ForegroundColor Gray
    docker ps
    
} catch {
    Write-Host "❌ Erreur lors du démarrage: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "5. Test de l'application" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Application accessible sur http://localhost:3000" -ForegroundColor Green
    } else {
        Write-Host "❌ Application non accessible (Code: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Application non accessible (Erreur: $($_.Exception.Message))" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Diagnostic terminé ===" -ForegroundColor Green
