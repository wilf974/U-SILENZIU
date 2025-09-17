# Script de déploiement pour VPS
# Configuration production simplifiée (alignée sur dev)

Write-Host "🚀 DÉPLOIEMENT VPS - Configuration Production" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Configuration actuelle :" -ForegroundColor Cyan
Write-Host "   • Base de données : usilenzio" -ForegroundColor White
Write-Host "   • Mot de passe : usilenzio_password_2024" -ForegroundColor White
Write-Host "   • Port : 3000" -ForegroundColor White
Write-Host "   • Environment : production" -ForegroundColor White
Write-Host ""

Write-Host "⚠️  IMPORTANT pour le VPS :" -ForegroundColor Yellow
Write-Host "   1. Changez les mots de passe en production" -ForegroundColor White
Write-Host "   2. Configurez un reverse proxy (Nginx)" -ForegroundColor White
Write-Host "   3. Ajoutez un certificat SSL" -ForegroundColor White
Write-Host "   4. Fermez le port 5432 (PostgreSQL) depuis l'extérieur" -ForegroundColor White
Write-Host ""

Write-Host "🐳 Commandes pour le VPS :" -ForegroundColor Cyan
Write-Host "   # Sur votre VPS Debian :" -ForegroundColor Gray
Write-Host "   git clone <votre-repo>" -ForegroundColor White
Write-Host "   cd U-SILENZIU" -ForegroundColor White
Write-Host "   docker-compose -f docker-compose.prod.yml up -d --build" -ForegroundColor White
Write-Host ""

Write-Host "🔧 Test local de la prod :" -ForegroundColor Cyan
Write-Host "   .\docker-switch.ps1 prod" -ForegroundColor White
Write-Host ""

Write-Host "📁 Fichiers inclus dans le déploiement :" -ForegroundColor Cyan
Write-Host "   ✅ docker-compose.prod.yml (aligné dev)" -ForegroundColor Green
Write-Host "   ✅ Dockerfile" -ForegroundColor Green
Write-Host "   ✅ init-db.sql" -ForegroundColor Green
Write-Host "   ✅ Code source complet" -ForegroundColor Green
Write-Host "   ✅ Images et assets" -ForegroundColor Green

Write-Host ""
Write-Host "✅ Configuration prête pour le VPS !" -ForegroundColor Green
