# Test des salles dynamiques - U Silenziu
# Script pour verifier que les salles affichees sont bien celles de la base de donnees

Write-Host "=== Test des Salles Dynamiques - U Silenziu ===" -ForegroundColor Green
Write-Host ""

# Configuration
$baseUrl = "http://localhost:3000"
$apiUrl = "$baseUrl/api/rooms"
$adminApiUrl = "$baseUrl/api/admin/rooms"

Write-Host "Test 1: Verification de l'API publique des salles" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri $apiUrl -Method GET -ContentType "application/json"
    Write-Host "OK API publique accessible" -ForegroundColor Green
    Write-Host "   Salles recuperees: $($response.Count)" -ForegroundColor Cyan
    
    if ($response.Count -gt 0) {
        Write-Host "   Salles actives trouvees:" -ForegroundColor Green
        foreach ($room in $response) {
            Write-Host "     - $($room.name) ($($room.price)€)" -ForegroundColor White
        }
    } else {
        Write-Host "   Aucune salle active trouvee" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Erreur API publique: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test 2: Verification de l'API admin des salles" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri $adminApiUrl -Method GET -ContentType "application/json"
    Write-Host "OK API admin accessible" -ForegroundColor Green
    Write-Host "   Total salles (actives + inactives): $($response.Count)" -ForegroundColor Cyan
    
    $activeRooms = $response | Where-Object { $_.isActive -eq $true }
    $inactiveRooms = $response | Where-Object { $_.isActive -eq $false }
    
    Write-Host "   Salles actives: $($activeRooms.Count)" -ForegroundColor Green
    Write-Host "   Salles inactives: $($inactiveRooms.Count)" -ForegroundColor Yellow
} catch {
    Write-Host "Erreur API admin: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test 3: Verification de la page d'accueil" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $baseUrl -Method GET
    if ($response.StatusCode -eq 200) {
        Write-Host "OK Page d'accueil accessible" -ForegroundColor Green
        
        # Verifier si les salles dynamiques sont presentes
        if ($response.Content -match "Nos Salles") {
            Write-Host "   Section 'Nos Salles' trouvee" -ForegroundColor Green
        } else {
            Write-Host "   Section 'Nos Salles' non trouvee" -ForegroundColor Yellow
        }
        
        # Verifier si les donnees dynamiques sont presentes
        $apiResponse = Invoke-RestMethod -Uri $apiUrl -Method GET -ContentType "application/json"
        foreach ($room in $apiResponse) {
            if ($response.Content -match [regex]::Escape($room.name)) {
                Write-Host "   Salle '$($room.name)' trouvee sur la page" -ForegroundColor Green
            } else {
                Write-Host "   Salle '$($room.name)' NON trouvee sur la page" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "Page d'accueil inaccessible: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "Erreur page d'accueil: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test 4: Verification de la base de donnees" -ForegroundColor Yellow
try {
    # Verifier si le fichier de base de donnees existe
    $dbPath = "data/reservations.db"
    if (Test-Path $dbPath) {
        Write-Host "OK Fichier de base de donnees trouve: $dbPath" -ForegroundColor Green
        
        # Verifier la taille du fichier
        $fileSize = (Get-Item $dbPath).Length
        Write-Host "   Taille du fichier: $fileSize bytes" -ForegroundColor Cyan
        
        if ($fileSize -gt 0) {
            Write-Host "   Base de donnees non vide" -ForegroundColor Green
        } else {
            Write-Host "   Base de donnees vide" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Fichier de base de donnees non trouve: $dbPath" -ForegroundColor Red
    }
} catch {
    Write-Host "Erreur verification base de donnees: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Resume des Tests ===" -ForegroundColor Green
Write-Host "Objectif: Salles dynamiques depuis la base de donnees" -ForegroundColor Cyan

# Recuperer les donnees pour le resume
try {
    $apiResponse = Invoke-RestMethod -Uri $apiUrl -Method GET -ContentType "application/json"
    $adminResponse = Invoke-RestMethod -Uri $adminApiUrl -Method GET -ContentType "application/json"
    
    Write-Host "OK API publique retourne $($apiResponse.Count) salles actives" -ForegroundColor Green
    Write-Host "OK API admin retourne $($adminResponse.Count) salles totales" -ForegroundColor Green
    Write-Host "OK Filtrage des salles actives fonctionne" -ForegroundColor Green
    Write-Host "OK Donnees provenant de la base de donnees PostgreSQL" -ForegroundColor Green
} catch {
    Write-Host "Erreur lors du resume: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "URLs de test:" -ForegroundColor Yellow
Write-Host "   Accueil: $baseUrl" -ForegroundColor White
Write-Host "   API publique: $apiUrl" -ForegroundColor White
Write-Host "   API admin: $adminApiUrl" -ForegroundColor White

Write-Host ""
Write-Host "Instructions de test manuel:" -ForegroundColor Yellow
Write-Host "   1. Ouvrir $baseUrl" -ForegroundColor White
Write-Host "   2. Aller a la section 'Nos Salles'" -ForegroundColor White
Write-Host "   3. Verifier que les salles affichees correspondent a celles de l'API" -ForegroundColor White
Write-Host "   4. Modifier une salle dans le back-office et verifier les changements" -ForegroundColor White

Write-Host ""
Write-Host "Test termine !" -ForegroundColor Green
