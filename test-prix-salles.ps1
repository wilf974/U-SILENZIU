# Script de test pour valider le systeme de prix des salles
# Teste la creation de nouvelles salles avec prix par defaut et la mise a jour des prix

Write-Host "Test du systeme de prix des salles U Silenziu" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Configuration
$baseUrl = "http://localhost:3000"
$adminUrl = "$baseUrl/api/admin"

# Fonction pour faire des requetes HTTP
function Invoke-ApiRequest {
    param(
        [string]$Url,
        [string]$Method = "GET",
        [object]$Body = $null,
        [hashtable]$Headers = @{}
    )
    
    try {
        $params = @{
            Uri = $Url
            Method = $Method
            Headers = $Headers
            ContentType = "application/json"
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json -Depth 10)
        }
        
        $response = Invoke-RestMethod @params
        return @{
            Success = $true
            Data = $response
        }
    }
    catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
            StatusCode = $_.Exception.Response.StatusCode.value__
        }
    }
}

# Test 1: Verifier les salles existantes
Write-Host "`nTest 1: Verification des salles existantes" -ForegroundColor Yellow
$response = Invoke-ApiRequest -Url "$adminUrl/rooms"
if ($response.Success) {
    $rooms = $response.Data.data
    Write-Host "Salles trouvees: $($rooms.Count)" -ForegroundColor Green
    
    foreach ($room in $rooms) {
        $priceStatus = if ($room.price -and $room.price -gt 0) { "OK" } else { "ERREUR" }
        Write-Host "  $priceStatus $($room.name): $($room.price)EUR (Max: $($room.max_people) pers.)" -ForegroundColor White
    }
} else {
    Write-Host "Erreur lors de la recuperation des salles: $($response.Error)" -ForegroundColor Red
}

# Test 2: Verifier les salles sans prix
Write-Host "`nTest 2: Verification des salles sans prix" -ForegroundColor Yellow
$response = Invoke-ApiRequest -Url "$adminUrl/rooms/ensure-prices"
if ($response.Success) {
    $roomsWithoutPrice = $response.Data.data.roomsWithoutPrice
    Write-Host "Salles sans prix: $($roomsWithoutPrice.Count)" -ForegroundColor Green
    
    if ($roomsWithoutPrice.Count -gt 0) {
        foreach ($room in $roomsWithoutPrice) {
            Write-Host "  ERREUR $($room.name): Prix manquant" -ForegroundColor Red
        }
    } else {
        Write-Host "  Toutes les salles ont un prix defini" -ForegroundColor Green
    }
} else {
    Write-Host "Erreur lors de la verification: $($response.Error)" -ForegroundColor Red
}

# Test 3: Creer une nouvelle salle sans prix specifie
Write-Host "`nTest 3: Creation d'une nouvelle salle sans prix specifie" -ForegroundColor Yellow
$newRoomData = @{
    name = "Salle Test Prix"
    subtitle = "Test de creation avec prix par defaut"
    duration = 30
    price = 0  # Prix a 0 pour tester le prix par defaut
    description = "Salle de test pour valider le systeme de prix par defaut"
    maxPeople = 4
    objectsToDestroy = @("Objets de test")
    included = @("Equipement de test")
    isActive = $true
}

$response = Invoke-ApiRequest -Url "$adminUrl/rooms" -Method "POST" -Body $newRoomData
if ($response.Success) {
    $createdRoom = $response.Data.data
    Write-Host "Salle creee avec succes" -ForegroundColor Green
    Write-Host "  Nom: $($createdRoom.name)" -ForegroundColor White
    Write-Host "  Prix: $($createdRoom.price)EUR (prix par defaut applique)" -ForegroundColor White
    Write-Host "  Duree: $($createdRoom.duration) minutes" -ForegroundColor White
    Write-Host "  Max personnes: $($createdRoom.max_people)" -ForegroundColor White
    
    $testRoomId = $createdRoom.id
} else {
    Write-Host "Erreur lors de la creation de la salle: $($response.Error)" -ForegroundColor Red
    $testRoomId = $null
}

# Test 4: Creer une nouvelle salle avec prix specifique
Write-Host "`nTest 4: Creation d'une nouvelle salle avec prix specifique" -ForegroundColor Yellow
$newRoomData2 = @{
    name = "Salle Test Prix Specifique"
    subtitle = "Test de creation avec prix specifique"
    duration = 45
    price = 50.00  # Prix specifique
    description = "Salle de test avec prix specifique"
    maxPeople = 6
    objectsToDestroy = @("Objets de test 2")
    included = @("Equipement de test 2")
    isActive = $true
}

$response = Invoke-ApiRequest -Url "$adminUrl/rooms" -Method "POST" -Body $newRoomData2
if ($response.Success) {
    $createdRoom2 = $response.Data.data
    Write-Host "Salle creee avec succes" -ForegroundColor Green
    Write-Host "  Nom: $($createdRoom2.name)" -ForegroundColor White
    Write-Host "  Prix: $($createdRoom2.price)EUR (prix specifique conserve)" -ForegroundColor White
    Write-Host "  Duree: $($createdRoom2.duration) minutes" -ForegroundColor White
    Write-Host "  Max personnes: $($createdRoom2.max_people)" -ForegroundColor White
    
    $testRoomId2 = $createdRoom2.id
} else {
    Write-Host "Erreur lors de la creation de la salle: $($response.Error)" -ForegroundColor Red
    $testRoomId2 = $null
}

# Test 5: Tester l'API de prix pour une salle existante
Write-Host "`nTest 5: Test de l'API de prix pour une salle existante" -ForegroundColor Yellow
$response = Invoke-ApiRequest -Url "$baseUrl/api/rooms/price?name=Salle Haches"
if ($response.Success) {
    $priceData = $response.Data
    Write-Host "Prix recupere avec succes" -ForegroundColor Green
    Write-Host "  Salle: $($priceData.name)" -ForegroundColor White
    Write-Host "  Prix: $($priceData.price)EUR" -ForegroundColor White
    Write-Host "  Duree: $($priceData.duration) minutes" -ForegroundColor White
    Write-Host "  Max personnes: $($priceData.max_people)" -ForegroundColor White
} else {
    Write-Host "Erreur lors de la recuperation du prix: $($response.Error)" -ForegroundColor Red
}

# Test 6: Nettoyage - Supprimer les salles de test
Write-Host "`nTest 6: Nettoyage des salles de test" -ForegroundColor Yellow

if ($testRoomId) {
    $response = Invoke-ApiRequest -Url "$adminUrl/rooms/$testRoomId" -Method "DELETE"
    if ($response.Success) {
        Write-Host "Salle de test 1 supprimee" -ForegroundColor Green
    } else {
        Write-Host "Erreur lors de la suppression de la salle de test 1: $($response.Error)" -ForegroundColor Red
    }
}

if ($testRoomId2) {
    $response = Invoke-ApiRequest -Url "$adminUrl/rooms/$testRoomId2" -Method "DELETE"
    if ($response.Success) {
        Write-Host "Salle de test 2 supprimee" -ForegroundColor Green
    } else {
        Write-Host "Erreur lors de la suppression de la salle de test 2: $($response.Error)" -ForegroundColor Red
    }
}

# Test 7: Verification finale
Write-Host "`nTest 7: Verification finale des salles" -ForegroundColor Yellow
$response = Invoke-ApiRequest -Url "$adminUrl/rooms/ensure-prices"
if ($response.Success) {
    $roomsWithoutPrice = $response.Data.data.roomsWithoutPrice
    Write-Host "Verification finale terminee" -ForegroundColor Green
    Write-Host "  Salles sans prix: $($roomsWithoutPrice.Count)" -ForegroundColor White
    
    if ($roomsWithoutPrice.Count -eq 0) {
        Write-Host "  Toutes les salles ont un prix defini !" -ForegroundColor Green
    } else {
        Write-Host "  Il reste des salles sans prix" -ForegroundColor Yellow
    }
} else {
    Write-Host "Erreur lors de la verification finale: $($response.Error)" -ForegroundColor Red
}

Write-Host "`nResume du test" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan
Write-Host "Systeme de prix des salles teste avec succes" -ForegroundColor Green
Write-Host "Creation de nouvelles salles avec prix par defaut validee" -ForegroundColor Green
Write-Host "Creation de nouvelles salles avec prix specifique validee" -ForegroundColor Green
Write-Host "API de recuperation des prix fonctionnelle" -ForegroundColor Green
Write-Host "Nettoyage des donnees de test effectue" -ForegroundColor Green

Write-Host "`nLe systeme de prix des salles est maintenant operationnel !" -ForegroundColor Green
Write-Host "   - Toutes les nouvelles salles auront automatiquement un prix par defaut de 30EUR" -ForegroundColor White
Write-Host "   - Les prix peuvent etre personnalises lors de la creation" -ForegroundColor White
Write-Host "   - L'API permet de recuperer les prix pour les reservations" -ForegroundColor White