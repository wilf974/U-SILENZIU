# Test simple de la page d'entree
Write-Host "Test de la page d'entree U Silenziu" -ForegroundColor Green

# Test de la page d'entree
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/entry" -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Page d'entree accessible" -ForegroundColor Green
    } else {
        Write-Host "❌ Page d'entree non accessible (Code: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

# Test de la redirection
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/" -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Redirection fonctionne" -ForegroundColor Green
    } else {
        Write-Host "❌ Redirection non fonctionnelle (Code: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur redirection: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Test termine" -ForegroundColor Cyan
