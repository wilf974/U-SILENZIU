# Script de deploiement de la correction sur VPS
# U Silenziu - Decembre 2024

Write-Host "DEPLOIEMENT DE LA CORRECTION SUR VPS" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Yellow
Write-Host ""

Write-Host "Instructions pour le VPS :" -ForegroundColor Cyan
Write-Host "1. Se connecter au VPS via SSH" -ForegroundColor White
Write-Host "2. Aller dans le repertoire du projet" -ForegroundColor White
Write-Host "3. Executer les commandes suivantes :" -ForegroundColor White
Write-Host ""

Write-Host "Commandes a executer sur le VPS :" -ForegroundColor Green
Write-Host "cd /path/to/usilenziu" -ForegroundColor Gray
Write-Host "git pull origin main" -ForegroundColor Gray
Write-Host "docker compose -f docker-compose.prod.yml down" -ForegroundColor Gray
Write-Host "docker compose -f docker-compose.prod.yml up -d --build" -ForegroundColor Gray
Write-Host "docker compose -f docker-compose.prod.yml restart u-silenziu" -ForegroundColor Gray
Write-Host ""

Write-Host "Verification :" -ForegroundColor Cyan
Write-Host "docker compose -f docker-compose.prod.yml ps" -ForegroundColor Gray
Write-Host "curl -I https://rageroom.usilenziu.com" -ForegroundColor Gray
Write-Host ""

Write-Host "La correction des objets a detruire sera alors deployee !" -ForegroundColor Green
