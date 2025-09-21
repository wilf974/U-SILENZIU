# Script pour démarrer l'environnement de développement avec Nginx
# Usage: .\start-dev-with-nginx.ps1

Write-Host "🚀 Démarrage de l'environnement de développement avec Nginx..." -ForegroundColor Green

# Arrêter les anciens conteneurs dev s'ils existent
Write-Host "🛑 Arrêt des anciens conteneurs..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml down

# Construire et démarrer les nouveaux conteneurs
Write-Host "🔨 Construction et démarrage..." -ForegroundColor Blue
docker-compose -f docker-compose.dev.yml up -d --build

# Attendre que les services démarrent
Write-Host "⏱️ Attente du démarrage des services..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Vérifier le statut
Write-Host "📊 Statut des conteneurs:" -ForegroundColor Cyan
docker-compose -f docker-compose.dev.yml ps

# Tester la connexion Nginx
Write-Host "🧪 Test de connexion via Nginx..." -ForegroundColor Magenta
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 10 -UseBasicParsing
    Write-Host "✅ Nginx répond avec le code: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur de connexion Nginx: $($_.Exception.Message)" -ForegroundColor Red
}

# Afficher les logs récents
Write-Host "`n📋 Logs récents Nginx:" -ForegroundColor Cyan
docker logs u-silenziu-nginx-dev --tail=10

Write-Host "`n📋 Logs récents Application:" -ForegroundColor Cyan  
docker logs u-silenziu-app-dev --tail=10

Write-Host "`n🌐 Accès:" -ForegroundColor Green
Write-Host "  • Application via Nginx: http://localhost:8080" -ForegroundColor White
Write-Host "  • Admin: http://localhost:8080/admin" -ForegroundColor White
Write-Host "  • Upload test: http://localhost:8080/uploads/" -ForegroundColor White

Write-Host "`n✅ Environnement de développement démarré !" -ForegroundColor Green



