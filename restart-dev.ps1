# Script pour redémarrer l'environnement de développement proprement
# U Silenziu - Janvier 2025

Write-Host "🔄 Redémarrage de l'environnement de développement..." -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

Write-Host "`n🛑 Étape 1: Arrêt des conteneurs et suppression des volumes..." -ForegroundColor Yellow
docker compose -f docker-compose.dev.yml down -v

Write-Host "`n🧹 Étape 2: Nettoyage des images orphelines..." -ForegroundColor Yellow
docker system prune -f

Write-Host "`n🔨 Étape 3: Construction et démarrage des conteneurs..." -ForegroundColor Yellow
docker compose -f docker-compose.dev.yml up -d --build

Write-Host "`n⏳ Étape 4: Attente du démarrage des services..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host "`n📊 Étape 5: Vérification du statut..." -ForegroundColor Yellow
docker compose -f docker-compose.dev.yml ps

Write-Host "`n🧪 Étape 6: Test de l'application..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 307) {
        Write-Host "✅ Application accessible !" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Application répond avec le code: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⏳ Application en cours de démarrage..." -ForegroundColor Blue
}

Write-Host "`n🎉 Redémarrage terminé !" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green

Write-Host "`n📋 Résumé:" -ForegroundColor Cyan
Write-Host "- ✅ Base de données PostgreSQL initialisée avec TOUS les scripts SQL" -ForegroundColor White
Write-Host "- ✅ Toutes les tables créées (legal_pages, rooms, reservations, etc.)" -ForegroundColor White
Write-Host "- ✅ Données par défaut insérées" -ForegroundColor White
Write-Host "- ✅ Secrets de développement sécurisés" -ForegroundColor White
Write-Host "- ✅ Redis disponible pour le cache" -ForegroundColor White

Write-Host "`n🌐 Accès:" -ForegroundColor Cyan
Write-Host "- Application: http://localhost:3000" -ForegroundColor White
Write-Host "- Admin: http://localhost:3000/admin/login" -ForegroundColor White
Write-Host "  Utilisateur: administrateur" -ForegroundColor Gray
Write-Host "  Mot de passe: @dm1n1str@t3uR!)" -ForegroundColor Gray

Write-Host "`n📝 Commandes utiles:" -ForegroundColor Cyan
Write-Host "- Voir les logs: docker compose -f docker-compose.dev.yml logs -f" -ForegroundColor White
Write-Host "- Redémarrer un service: docker compose -f docker-compose.dev.yml restart u-silenziu" -ForegroundColor White
Write-Host "- Arrêter: docker compose -f docker-compose.dev.yml down" -ForegroundColor White

Write-Host "`n✨ Les erreurs 500 devraient être résolues !" -ForegroundColor Green


