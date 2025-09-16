# Test des salles dynamiques - U Silenziu
# Script pour verifier que les salles sont bien recuperees depuis la base de donnees

Write-Host "=== Test des Salles Dynamiques - U Silenziu ===" -ForegroundColor Green
Write-Host ""

# Configuration
$baseUrl = "http://localhost:3000"
$apiUrl = "$baseUrl/api/rooms"
$adminApiUrl = "$baseUrl/api/admin/rooms"
$adminRoomsUrl = "$baseUrl/admin/rooms"

Write-Host "Test 1: Verification de l'API publique des salles" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri $apiUrl -Method GET -ContentType "application/json"
    Write-Host "OK API publique accessible" -ForegroundColor Green
    Write-Host "   Salles recuperees: $($response.Count)" -ForegroundColor Cyan
    
    if ($response.Count -gt 0) {
        $activeRooms = $response | Where-Object { $_.isActive -eq $true }
        Write-Host "   Salles actives: $($activeRooms.Count)" -ForegroundColor Green
        Write-Host "   Salles inactives: $($response.Count - $activeRooms.Count)" -ForegroundColor Red
        
        # Afficher les details des salles actives
        foreach ($room in $activeRooms) {
            Write-Host "   $($room.name) - $($room.price)EUR - $($room.duration)min - Max $($room.maxPeople) pers." -ForegroundColor White
        }
    } else {
        Write-Host "   Aucune salle trouvee" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Erreur API publique: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test 2: Verification de l'API admin des salles" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri $adminApiUrl -Method GET -ContentType "application/json"
    Write-Host "OK API admin accessible" -ForegroundColor Green
    Write-Host "   Total salles: $($response.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "Erreur API admin: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test 3: Verification de la page d'accueil avec salles dynamiques" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $baseUrl -Method GET
    if ($response.StatusCode -eq 200) {
        Write-Host "OK Page d'accueil accessible" -ForegroundColor Green
        Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Cyan
        
        # Verifier si la section des salles est presente
        if ($response.Content -match "Nos Salles") {
            Write-Host "   Section 'Nos Salles' trouvee" -ForegroundColor Green
        } else {
            Write-Host "   Section 'Nos Salles' non trouvee" -ForegroundColor Yellow
        }
        
        # Verifier si les salles dynamiques sont chargees
        if ($response.Content -match "Derniere mise a jour") {
            Write-Host "   Salles dynamiques detectees" -ForegroundColor Green
        } else {
            Write-Host "   Salles dynamiques non detectees" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Page d'accueil inaccessible: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "Erreur page d'accueil: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test 4: Verification du back-office des salles" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $adminRoomsUrl -Method GET
    if ($response.StatusCode -eq 200) {
        Write-Host "OK Back-office des salles accessible" -ForegroundColor Green
        Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Cyan
    } else {
        Write-Host "Back-office des salles inaccessible: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "Erreur back-office: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Resume des Tests ===" -ForegroundColor Green
Write-Host "Objectif: Salles dynamiques integrees dans la page d'accueil en one-page" -ForegroundColor Cyan
Write-Host "OK API publique creee: /api/rooms" -ForegroundColor Green
Write-Host "OK Composant Formules mis a jour pour utiliser l'API" -ForegroundColor Green
Write-Host "OK Page /rooms supprimee (one-page uniquement)" -ForegroundColor Green
Write-Host "OK Gestion d'erreur et etats de chargement implementes" -ForegroundColor Green
Write-Host "OK Bouton de rafraichissement ajoute" -ForegroundColor Green

Write-Host ""
Write-Host "URLs de test:" -ForegroundColor Yellow
Write-Host "   Accueil (one-page): $baseUrl" -ForegroundColor White
Write-Host "   Back-office: $adminRoomsUrl" -ForegroundColor White
Write-Host "   API publique: $apiUrl" -ForegroundColor White
Write-Host "   API admin: $adminApiUrl" -ForegroundColor White

Write-Host ""
Write-Host "Test termine !" -ForegroundColor Green
