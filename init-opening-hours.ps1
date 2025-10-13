# Script pour initialiser les horaires d'ouverture dynamiques
# Ce script met à jour la configuration du footer avec les horaires par défaut

Write-Host "🕐 Initialisation des horaires d'ouverture dynamiques..." -ForegroundColor Yellow

# Vérifier si le fichier SQL existe
if (-not (Test-Path "init-opening-hours.sql")) {
    Write-Host "❌ Erreur: Le fichier init-opening-hours.sql n'existe pas" -ForegroundColor Red
    exit 1
}

# Exécuter le script SQL
Write-Host "📝 Mise à jour de la configuration des horaires..." -ForegroundColor Cyan

# Utiliser docker exec pour exécuter la commande dans le conteneur PostgreSQL
docker exec -i u-silenziu-postgres psql -U postgres -d u_silenziu < init-opening-hours.sql

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Horaires d'ouverture initialisés avec succès !" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors de l'initialisation des horaires" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎯 Prochaines étapes :" -ForegroundColor Yellow
Write-Host "1. Redémarrer les services Docker" -ForegroundColor White
Write-Host "2. Vérifier l'affichage des horaires dans le bandeau" -ForegroundColor White
Write-Host "3. Tester la gestion des horaires via l'admin" -ForegroundColor White
Write-Host ""
Write-Host "📋 Horaires par défaut configurés :" -ForegroundColor Cyan
Write-Host "   - Lundi: Fermé" -ForegroundColor White
Write-Host "   - Mardi-Jeudi: 14:00 – 21:00" -ForegroundColor White
Write-Host "   - Vendredi-Samedi: 14:00 – 00:00" -ForegroundColor White
Write-Host "   - Dimanche: Sur réservation uniquement" -ForegroundColor White
Write-Host ""
