# Script de test pour la correction du bouton "Mettre à jour"
# U Silenziu - Decembre 2024

Write-Host "TEST DE LA CORRECTION DU BOUTON METTRE A JOUR" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. Verification de l'etat actuel des salles..." -ForegroundColor Cyan
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, name, objects_to_destroy, included 
FROM rooms 
ORDER BY created_at;
"

Write-Host ""
Write-Host "2. Test de mise a jour avec objets_to_destroy vide..." -ForegroundColor Cyan

# Recuperer l'ID de la premiere salle
$ROOM_ID = docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -t -c "SELECT id FROM rooms LIMIT 1;"
$ROOM_ID = $ROOM_ID.Trim()
Write-Host "ID de la salle a tester: $ROOM_ID" -ForegroundColor Green

# Test de mise a jour avec objets_to_destroy vide
$body = @{
    name = "Salle Test"
    description = "Test de mise a jour"
    duration = 20
    price = 25
    max_people = 4
    objects_to_destroy = @()
    included = @("Equipements de protection")
    is_active = $true
} | ConvertTo-Json

Write-Host "Donnees envoyees:" -ForegroundColor Yellow
Write-Host $body -ForegroundColor Gray

$response = Invoke-RestMethod -Uri "https://rageroom.usilenziu.com/api/admin/rooms/$ROOM_ID" -Method PUT -Body $body -ContentType "application/json"

Write-Host "Reponse de l'API:" -ForegroundColor Yellow
$response | ConvertTo-Json -Depth 3

Write-Host ""
Write-Host "3. Verification de l'etat apres mise a jour..." -ForegroundColor Cyan
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, name, objects_to_destroy, included 
FROM rooms 
WHERE id = '$ROOM_ID';
"

Write-Host ""
Write-Host "TEST TERMINE !" -ForegroundColor Green
