# Script de debug pour les objets a detruire
# U Silenziu - Decembre 2024

Write-Host "DEBUG DES OBJETS A DETRUIRE" -ForegroundColor Yellow
Write-Host "============================" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. Etat actuel des salles en base de donnees..." -ForegroundColor Cyan
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, name, objects_to_destroy, included 
FROM rooms 
ORDER BY created_at;
"

Write-Host ""
Write-Host "2. Test de l'API avec objets_to_destroy vide..." -ForegroundColor Cyan

# Recuperer l'ID de la premiere salle
$ROOM_ID = docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -t -c "SELECT id FROM rooms LIMIT 1;"
$ROOM_ID = $ROOM_ID.Trim()
Write-Host "ID de la salle a tester: $ROOM_ID" -ForegroundColor Green

# Test avec objets_to_destroy vide
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

Write-Host "Donnees envoyees a l'API:" -ForegroundColor Yellow
Write-Host $body -ForegroundColor Gray

try {
    $response = Invoke-RestMethod -Uri "https://rageroom.usilenziu.com/api/admin/rooms/$ROOM_ID" -Method PUT -Body $body -ContentType "application/json"
    Write-Host "Reponse de l'API:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3
} catch {
    Write-Host "Erreur lors de l'appel API:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Verification en base de donnees apres mise a jour..." -ForegroundColor Cyan
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, name, objects_to_destroy, included 
FROM rooms 
WHERE id = '$ROOM_ID';
"

Write-Host ""
Write-Host "4. Test de l'API avec objets_to_destroy contenant des elements..." -ForegroundColor Cyan

$body2 = @{
    name = "Salle Test"
    description = "Test de mise a jour"
    duration = 20
    price = 25
    max_people = 4
    objects_to_destroy = @("Assiettes", "Verres")
    included = @("Equipements de protection")
    is_active = $true
} | ConvertTo-Json

Write-Host "Donnees envoyees a l'API (avec objets):" -ForegroundColor Yellow
Write-Host $body2 -ForegroundColor Gray

try {
    $response2 = Invoke-RestMethod -Uri "https://rageroom.usilenziu.com/api/admin/rooms/$ROOM_ID" -Method PUT -Body $body2 -ContentType "application/json"
    Write-Host "Reponse de l'API:" -ForegroundColor Green
    $response2 | ConvertTo-Json -Depth 3
} catch {
    Write-Host "Erreur lors de l'appel API:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""
Write-Host "5. Verification finale en base de donnees..." -ForegroundColor Cyan
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, name, objects_to_destroy, included 
FROM rooms 
WHERE id = '$ROOM_ID';
"

Write-Host ""
Write-Host "DEBUG TERMINE !" -ForegroundColor Green
