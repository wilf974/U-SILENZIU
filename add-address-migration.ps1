# Script pour ajouter la colonne address à la table reservations
# Ce script doit être exécuté sur le VPS

Write-Host "🔧 Ajout de la colonne address à la table reservations..." -ForegroundColor Yellow

# Vérifier si le fichier SQL existe
if (-not (Test-Path "add-address-column.sql")) {
    Write-Host "❌ Erreur: Le fichier add-address-column.sql n'existe pas" -ForegroundColor Red
    exit 1
}

# Exécuter la migration SQL
Write-Host "📝 Exécution de la migration SQL..." -ForegroundColor Cyan

# Utiliser docker exec pour exécuter la commande dans le conteneur PostgreSQL
docker exec -i u-silenziu-postgres psql -U postgres -d u_silenziu < add-address-column.sql

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Migration réussie ! La colonne address a été ajoutée." -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors de la migration" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎯 Prochaines étapes :" -ForegroundColor Yellow
Write-Host "1. Redémarrer les services Docker" -ForegroundColor White
Write-Host "2. Tester la création de réservation avec adresse" -ForegroundColor White
Write-Host ""
