#!/usr/bin/env pwsh

Write-Host "=== DIAGNOSTIC ERREUR RÉSERVATION ===" -ForegroundColor Yellow
Write-Host ""

# 1. Vérifier les logs de l'application
Write-Host "1. Logs de l'application (dernières 50 lignes) :" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Gray
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=50 | Select-String -Pattern "error|Error|ERROR|erreur|Erreur|reservation|réservation" -Context 2

Write-Host ""
Write-Host "2. Logs PostgreSQL (dernières 30 lignes) :" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Gray
docker compose -f docker-compose.prod.yml logs postgres --tail=30 | Select-String -Pattern "error|Error|ERROR|erreur|Erreur" -Context 1

Write-Host ""
Write-Host "3. Vérifier la structure de la table reservations :" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Gray
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\d reservations;"

Write-Host ""
Write-Host "4. Vérifier les données de test dans reservations :" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Gray
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "SELECT id, room_id, user_name, user_email, start_time, end_time, status, created_at FROM reservations ORDER BY created_at DESC LIMIT 5;"

Write-Host ""
Write-Host "5. Tester l'API de création de réservation :" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Gray
$testData = @{
    room_id = "test-room-id"
    user_name = "Test User"
    user_email = "test@example.com"
    user_phone = "0123456789"
    start_time = "2025-09-20T14:20:00Z"
    end_time = "2025-09-20T14:40:00Z"
    total_price = 50
    participants = 2
} | ConvertTo-Json

Write-Host "Test avec curl :"
Write-Host "curl -X POST https://rageroom.usilenziu.com/api/reservations -H 'Content-Type: application/json' -d '$testData' -v"

Write-Host ""
Write-Host "6. Vérifier les conteneurs en cours d'exécution :" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Gray
docker compose -f docker-compose.prod.yml ps

Write-Host ""
Write-Host "7. Vérifier la connectivité de la base de données :" -ForegroundColor Cyan
Write-Host "----------------------------------------" -ForegroundColor Gray
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "SELECT 1 as connection_test;"

Write-Host ""
Write-Host "=== DIAGNOSTIC TERMINÉ ===" -ForegroundColor Green
Write-Host "Vérifiez les logs ci-dessus pour identifier l'erreur de réservation." -ForegroundColor Yellow
