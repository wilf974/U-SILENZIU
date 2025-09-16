# Test de verification des salles - U Silenziu
# Script pour verifier que les salles affichees correspondent exactement a celles de la base de donnees

Write-Host "=== Test de Verification des Salles - U Silenziu ===" -ForegroundColor Green
Write-Host ""

# Configuration
$baseUrl = "http://localhost:3000"
$apiUrl = "$baseUrl/api/rooms"
$adminApiUrl = "$baseUrl/api/admin/rooms"

Write-Host "Test 1: Recuperation des donnees de la base de donnees" -ForegroundColor Yellow
try {
    $apiResponse = Invoke-RestMethod -Uri $apiUrl -Method GET -ContentType "application/json"
    Write-Host "OK API publique accessible" -ForegroundColor Green
    Write-Host "   Salles recuperees: $($apiResponse.Count)" -ForegroundColor Cyan
    
    Write-Host ""
    Write-Host "   Details des salles de la base de donnees:" -ForegroundColor Yellow
    foreach ($room in $apiResponse) {
        Write-Host "     Salle: $($room.name)" -ForegroundColor White
        Write-Host "       - Prix: $($room.price)€" -ForegroundColor Cyan
        Write-Host "       - Duree: $($room.duration) min" -ForegroundColor Cyan
        Write-Host "       - Max personnes: $($room.maxPeople)" -ForegroundColor Cyan
        Write-Host "       - Image: $($room.imageUrl)" -ForegroundColor Cyan
        Write-Host "       - Active: $($room.isActive)" -ForegroundColor Cyan
        Write-Host ""
    }
} catch {
    Write-Host "Erreur API publique: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test 2: Verification de la page d'accueil" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $baseUrl -Method GET
    if ($response.StatusCode -eq 200) {
        Write-Host "OK Page d'accueil accessible" -ForegroundColor Green
        
        # Verifier si les salles de la base de donnees sont presentes sur la page
        foreach ($room in $apiResponse) {
            if ($response.Content -match [regex]::Escape($room.name)) {
                Write-Host "   Salle '$($room.name)' trouvee sur la page" -ForegroundColor Green
            } else {
                Write-Host "   Salle '$($room.name)' NON trouvee sur la page" -ForegroundColor Red
            }
            
            # Verifier le prix
            if ($response.Content -match "$($room.price)€") {
                Write-Host "     Prix $($room.price)€ trouve" -ForegroundColor Green
            } else {
                Write-Host "     Prix $($room.price)€ NON trouve" -ForegroundColor Red
            }
            
            # Verifier la duree
            if ($response.Content -match "$($room.duration) min") {
                Write-Host "     Duree $($room.duration) min trouvee" -ForegroundColor Green
            } else {
                Write-Host "     Duree $($room.duration) min NON trouvee" -ForegroundColor Red
            }
        }
        
        # Verifier les images
        Write-Host ""
        Write-Host "   Verification des images:" -ForegroundColor Yellow
        foreach ($room in $apiResponse) {
            $imagePath = $room.imageUrl
            if ($response.Content -match [regex]::Escape($imagePath)) {
                Write-Host "     Image '$imagePath' trouvee sur la page" -ForegroundColor Green
            } else {
                Write-Host "     Image '$imagePath' NON trouvee sur la page" -ForegroundColor Red
            }
        }
        
    } else {
        Write-Host "Page d'accueil inaccessible: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "Erreur page d'accueil: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test 3: Verification du cache et des headers" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $apiUrl -Method GET
    Write-Host "OK Headers de l'API:" -ForegroundColor Green
    Write-Host "   Cache-Control: $($response.Headers['Cache-Control'])" -ForegroundColor Cyan
    Write-Host "   Last-Modified: $($response.Headers['Last-Modified'])" -ForegroundColor Cyan
    Write-Host "   ETag: $($response.Headers['ETag'])" -ForegroundColor Cyan
} catch {
    Write-Host "Erreur verification headers: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test 4: Test de rafraichissement force" -ForegroundColor Yellow
try {
    # Test avec un header pour forcer le rafraichissement
    $headers = @{
        'Cache-Control' = 'no-cache'
        'Pragma' = 'no-cache'
    }
    $response = Invoke-RestMethod -Uri $apiUrl -Method GET -Headers $headers -ContentType "application/json"
    Write-Host "OK Rafraichissement force reussi" -ForegroundColor Green
    Write-Host "   Salles recuperees: $($response.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "Erreur rafraichissement force: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Resume de la Verification ===" -ForegroundColor Green
Write-Host "Objectif: Salles affichees = Salles de la base de donnees" -ForegroundColor Cyan

# Recuperer les donnees pour le resume
try {
    $apiResponse = Invoke-RestMethod -Uri $apiUrl -Method GET -ContentType "application/json"
    $pageResponse = Invoke-WebRequest -Uri $baseUrl -Method GET
    
    $matchingRooms = 0
    foreach ($room in $apiResponse) {
        if ($pageResponse.Content -match [regex]::Escape($room.name)) {
            $matchingRooms++
        }
    }
    
    Write-Host "OK $matchingRooms/$($apiResponse.Count) salles correspondent" -ForegroundColor Green
    
    if ($matchingRooms -eq $apiResponse.Count) {
        Write-Host "OK Toutes les salles correspondent!" -ForegroundColor Green
    } else {
        Write-Host "ATTENTION: Certaines salles ne correspondent pas!" -ForegroundColor Red
    }
} catch {
    Write-Host "Erreur lors du resume: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Instructions de test manuel:" -ForegroundColor Yellow
Write-Host "   1. Ouvrir $baseUrl dans un navigateur prive" -ForegroundColor White
Write-Host "   2. Aller a la section 'Nos Salles'" -ForegroundColor White
Write-Host "   3. Comparer avec les donnees de l'API: $apiUrl" -ForegroundColor White
Write-Host "   4. Utiliser le bouton de rafraichissement sur la page" -ForegroundColor White
Write-Host "   5. Vider le cache du navigateur si necessaire" -ForegroundColor White

Write-Host ""
Write-Host "Test termine !" -ForegroundColor Green
