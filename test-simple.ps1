Write-Host "Test de synchronisation des salles" -ForegroundColor Cyan

# Test API /api/rooms
Write-Host "`nTest de l'API /api/rooms" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/rooms" -Method GET
    Write-Host "OK: API /api/rooms accessible" -ForegroundColor Green
    Write-Host "Nombre de salles: $($response.Count)" -ForegroundColor Green
    
    foreach ($room in $response) {
        Write-Host "  - $($room.name) ($($room.price) EUR, $($room.duration) min)" -ForegroundColor White
    }
} catch {
    Write-Host "ERREUR: API /api/rooms: $($_.Exception.Message)" -ForegroundColor Red
}

# Test page d'accueil
Write-Host "`nTest de la page d'accueil" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing
    Write-Host "OK: Page d'accueil accessible (Status: $($response.StatusCode))" -ForegroundColor Green
    
    if ($response.Content -match "Nos Salles") {
        Write-Host "OK: Section 'Nos Salles' trouvee" -ForegroundColor Green
    }
    
    if ($response.Content -match "Pas Content!") {
        Write-Host "OK: Salle 'Pas Content!' trouvee" -ForegroundColor Green
    }
    if ($response.Content -match "Vraiment pas Content!") {
        Write-Host "OK: Salle 'Vraiment pas Content!' trouvee" -ForegroundColor Green
    }
    if ($response.Content -match "Grosse colere") {
        Write-Host "OK: Salle 'Grosse colere' trouvee" -ForegroundColor Green
    }
    
} catch {
    Write-Host "ERREUR: Page d'accueil: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTest termine" -ForegroundColor Cyan
