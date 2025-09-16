# Test simple du Module de Gestion des Salles
$baseUrl = "http://localhost:3000"

Write-Host "Test du Module de Gestion des Salles" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Test 1: Récupération des salles
Write-Host "Test 1: Recuperation des salles" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/admin/rooms"
    if ($response.success) {
        Write-Host "SUCCESS: Recuperation des salles" -ForegroundColor Green
        Write-Host "Nombre de salles: $($response.data.Count)" -ForegroundColor White
    } else {
        Write-Host "ERROR: $($response.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Création d'une salle
Write-Host "Test 2: Creation d'une salle" -ForegroundColor Yellow
$newRoom = @{
    name = "Salle Test"
    description = "Salle de test"
    duration = 30
    price = 25
    max_people = 6
    objects_to_destroy = @("Bouteilles", "Vaisselle")
    included = @("Equipement", "Protection")
    is_active = $true
}

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/admin/rooms" -Method POST -ContentType "application/json" -Body ($newRoom | ConvertTo-Json)
    if ($response.success) {
        Write-Host "SUCCESS: Creation de salle" -ForegroundColor Green
    } else {
        Write-Host "ERROR: $($response.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Test termine!" -ForegroundColor Green
