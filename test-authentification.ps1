# Test de l'Authentification Admin - U Silenziu
$baseUrl = "http://localhost:3000"

Write-Host "Test de l'Authentification Admin" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Test 1: Accès à la page de connexion
Write-Host "Test 1: Page de connexion admin" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/admin/login" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "SUCCESS: Page de connexion accessible" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Page de connexion non accessible" -ForegroundColor Red
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Accès au dashboard admin (sans authentification)
Write-Host "Test 2: Dashboard admin sans authentification" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/admin" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "SUCCESS: Dashboard accessible" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Dashboard non accessible" -ForegroundColor Red
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Accès à la gestion des salles (sans authentification)
Write-Host "Test 3: Gestion des salles sans authentification" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/admin/rooms" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "SUCCESS: Page de gestion des salles accessible" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Page de gestion des salles non accessible" -ForegroundColor Red
    }
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Instructions pour tester l'authentification :" -ForegroundColor Cyan
Write-Host "1. Ouvrez http://localhost:3000/admin/login" -ForegroundColor White
Write-Host "2. Utilisez les identifiants : admin / admin123" -ForegroundColor White
Write-Host "3. Vous serez redirigé vers le dashboard" -ForegroundColor White
Write-Host "4. Testez les boutons de navigation" -ForegroundColor White
Write-Host "5. Utilisez le bouton 'Déconnexion' pour vous déconnecter" -ForegroundColor White

Write-Host ""
Write-Host "Test termine!" -ForegroundColor Green
