#!/usr/bin/env pwsh

Write-Host "Test du systeme dynamique de salles" -ForegroundColor Yellow
Write-Host "===================================" -ForegroundColor Yellow

$baseUrl = "http://localhost:3000"

Write-Host ""
Write-Host "1. Test de l'API des salles" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/rooms" -Method GET
    Write-Host "Salles disponibles: $($response.count)" -ForegroundColor Green
    foreach ($room in $response.data) {
        Write-Host "  - $($room.name): $($room.price)€ (Max: $($room.max_people) personnes)" -ForegroundColor White
    }
} catch {
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Test des URLs de reservation dynamiques" -ForegroundColor Cyan

# Récupérer les salles pour tester dynamiquement
try {
    $roomsResponse = Invoke-RestMethod -Uri "$baseUrl/api/rooms" -Method GET
    $rooms = $roomsResponse.data
    
    foreach ($room in $rooms) {
        $encodedName = [System.Web.HttpUtility]::UrlEncode($room.name)
        $url = "$baseUrl/reservation?formule=$encodedName"
        
        Write-Host "  Test URL: $url" -ForegroundColor White
        try {
            $response = Invoke-WebRequest -Uri $url -Method GET -UseBasicParsing
            if ($response.StatusCode -eq 200) {
                Write-Host "    ✅ Page accessible pour $($room.name)" -ForegroundColor Green
            } else {
                Write-Host "    ❌ Erreur: $($response.StatusCode)" -ForegroundColor Red
            }
        } catch {
            Write-Host "    ❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "Erreur lors de la récupération des salles: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Test de l'API de prix pour chaque salle" -ForegroundColor Cyan

try {
    $roomsResponse = Invoke-RestMethod -Uri "$baseUrl/api/rooms" -Method GET
    $rooms = $roomsResponse.data
    
    foreach ($room in $rooms) {
        $encodedName = [System.Web.HttpUtility]::UrlEncode($room.name)
        try {
            $priceResponse = Invoke-RestMethod -Uri "$baseUrl/api/rooms/price?name=$encodedName" -Method GET
            Write-Host "  $($room.name) : $($priceResponse.price)€" -ForegroundColor Green
        } catch {
            Write-Host "  $($room.name) : ERREUR - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "Erreur lors de la récupération des salles: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Test de creation d'une nouvelle salle" -ForegroundColor Cyan

$newRoom = @{
    name = "Salle Test Dynamique"
    description = "Salle de test pour le systeme dynamique"
    price = 30.00
    duration = 25
    max_people = 5
    objects_to_destroy = @("Verres", "Assiettes")
    included = @("Protection", "Outils")
    is_active = $true
} | ConvertTo-Json

try {
    Write-Host "  Creation d'une nouvelle salle..." -ForegroundColor Green
    $response = Invoke-RestMethod -Uri "$baseUrl/api/admin/rooms" -Method POST -ContentType "application/json" -Body $newRoom
    
    if ($response.success) {
        Write-Host "  ✅ Salle creee avec succes: $($response.data.name)" -ForegroundColor Green
        
        # Tester l'URL de reservation pour la nouvelle salle
        $encodedName = [System.Web.HttpUtility]::UrlEncode($response.data.name)
        $url = "$baseUrl/reservation?formule=$encodedName"
        
        Write-Host "  Test URL pour la nouvelle salle: $url" -ForegroundColor White
        try {
            $urlResponse = Invoke-WebRequest -Uri $url -Method GET -UseBasicParsing
            if ($urlResponse.StatusCode -eq 200) {
                Write-Host "    ✅ URL de reservation fonctionne pour la nouvelle salle" -ForegroundColor Green
            } else {
                Write-Host "    ❌ Erreur URL: $($urlResponse.StatusCode)" -ForegroundColor Red
            }
        } catch {
            Write-Host "    ❌ Erreur URL: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Supprimer la salle de test
        Write-Host "  Suppression de la salle de test..." -ForegroundColor Yellow
        $deleteResponse = Invoke-RestMethod -Uri "$baseUrl/api/admin/rooms/$($response.data.id)" -Method DELETE
        if ($deleteResponse.success) {
            Write-Host "  ✅ Salle de test supprimee" -ForegroundColor Green
        } else {
            Write-Host "  ❌ Erreur lors de la suppression: $($deleteResponse.error)" -ForegroundColor Red
        }
    } else {
        Write-Host "  ❌ Erreur lors de la creation: $($response.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "  ❌ Erreur lors de la creation de la salle: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test du systeme dynamique termine" -ForegroundColor Yellow
