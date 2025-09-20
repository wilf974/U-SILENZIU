#!/usr/bin/env pwsh

Write-Host "=== CORRECTION NUMÉRO DE RÉSERVATION ===" -ForegroundColor Yellow
Write-Host ""

# 1. Appliquer la migration SQL
Write-Host "1. Ajout de la colonne reservation_number..." -ForegroundColor Cyan
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
ALTER TABLE reservations 
ADD COLUMN IF NOT EXISTS reservation_number VARCHAR(20) UNIQUE;

CREATE INDEX IF NOT EXISTS idx_reservations_reservation_number ON reservations(reservation_number);

UPDATE reservations 
SET reservation_number = 'RES' || LPAD(EXTRACT(EPOCH FROM created_at)::text, 10, '0')
WHERE reservation_number IS NULL;
"

Write-Host ""
Write-Host "2. Vérification de la structure de la table..." -ForegroundColor Cyan
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\d reservations;"

Write-Host ""
Write-Host "3. Vérification des données de réservation..." -ForegroundColor Cyan
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "SELECT id, reservation_number, customer_name, customer_email, room_name, date, time_slot, amount, status FROM reservations ORDER BY created_at DESC LIMIT 5;"

Write-Host ""
Write-Host "4. Redémarrage de l'application..." -ForegroundColor Cyan
docker compose -f docker-compose.prod.yml restart u-silenziu

Write-Host ""
Write-Host "5. Vérification des logs..." -ForegroundColor Cyan
Start-Sleep -Seconds 5
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=10

Write-Host ""
Write-Host "=== CORRECTION TERMINÉE ===" -ForegroundColor Green
Write-Host "Les numéros de réservation devraient maintenant apparaître dans l'interface admin." -ForegroundColor Yellow
