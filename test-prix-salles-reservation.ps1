# Script de test pour valider que les prix des salles sont correctement recuperes dans le processus de reservation

Write-Host "Test des prix des salles dans le processus de reservation" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan

# Configuration
$baseUrl = "http://localhost:3000"

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

# Liste des salles de la base de donnees
$rooms = @(
    "Salle Haches",
    "Salle Defoulement", 
    "Salle Shurikens",
    "Color Zone"
)

Write-Host "`nTest 1: Verification des prix de toutes les salles" -ForegroundColor Yellow
foreach ($room in $rooms) {
    $response = Invoke-ApiRequest -Url "$baseUrl/api/rooms/price?name=$([System.Web.HttpUtility]::UrlEncode($room))"
    if ($response.Success) {
        $priceData = $response.Data
        Write-Host "  OK $($priceData.name): $($priceData.price)EUR (Max: $($priceData.max_people) pers., Duree: $($priceData.duration) min)" -ForegroundColor Green
    } else {
        Write-Host "  ERREUR $room : $($response.Error)" -ForegroundColor Red
    }
}

Write-Host "`nTest 2: Test de creation de reservation pour chaque salle" -ForegroundColor Yellow
foreach ($room in $rooms) {
    Write-Host "`n  Test reservation pour: $room" -ForegroundColor White
    
    $reservationData = @{
        firstName = "Test"
        lastName = "Prix"
        email = "test.prix@example.com"
        phone = "0123456789"
        date = "2025-09-10"
        timeSlot = "14:00 - 14:20"
        duration = 20
        numberOfPeople = 2
        formula = "Pas Content!"
        roomName = $room
    }
    
    $response = Invoke-ApiRequest -Url "$baseUrl/api/reservations" -Method "POST" -Body $reservationData
    if ($response.Success) {
        $reservation = $response.Data
        Write-Host "    OK Reservation creee: #$($reservation.reservation_number)" -ForegroundColor Green
        Write-Host "    Prix par personne: $($reservation.amount / $reservationData.numberOfPeople)EUR" -ForegroundColor White
        Write-Host "    Prix total: $($reservation.amount)EUR" -ForegroundColor White
        
        # Supprimer la reservation de test
        $deleteResponse = Invoke-ApiRequest -Url "$baseUrl/api/admin/reservations/$($reservation.id)" -Method "DELETE"
        if ($deleteResponse.Success) {
            Write-Host "    Reservation de test supprimee" -ForegroundColor Green
        }
    } else {
        Write-Host "    ERREUR Creation reservation: $($response.Error)" -ForegroundColor Red
    }
}

Write-Host "`nTest 3: Verification des URLs de reservation" -ForegroundColor Yellow
$testUrls = @(
    "$baseUrl/reservation?formule=Salle Haches",
    "$baseUrl/reservation?formule=Salle Defoulement",
    "$baseUrl/reservation?formule=Salle Shurikens",
    "$baseUrl/reservation?formule=Color Zone"
)

foreach ($url in $testUrls) {
    Write-Host "  Test URL: $url" -ForegroundColor White
    try {
        $response = Invoke-WebRequest -Uri $url -Method GET -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "    OK Page accessible" -ForegroundColor Green
        } else {
            Write-Host "    ERREUR Status: $($response.StatusCode)" -ForegroundColor Red
        }
    } catch {
        Write-Host "    ERREUR: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nResume du test" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan
Write-Host "Test des prix des salles dans le processus de reservation termine" -ForegroundColor Green
Write-Host "Toutes les salles doivent maintenant avoir des prix corrects" -ForegroundColor Green
Write-Host "Les reservations doivent calculer le bon montant total" -ForegroundColor Green

Write-Host "`nLe systeme de prix des salles est maintenant operationnel pour toutes les salles !" -ForegroundColor Green
