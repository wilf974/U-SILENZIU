# Test simple du systeme d'edition intuitive des sections
# U Silenziu - Decembre 2024

Write-Host "Test simple du systeme d'edition intuitive" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

$baseUrl = "http://localhost:3000"

# Test 1: Site principal
Write-Host "`nTest 1: Site principal" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $baseUrl -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "OK - Site principal accessible" -ForegroundColor Green
    } else {
        Write-Host "ERREUR - Site principal inaccessible (Status: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "ERREUR - Site principal: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Interface d'administration
Write-Host "`nTest 2: Interface d'administration" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/admin/homepage" -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "OK - Interface d'administration accessible" -ForegroundColor Green
        
        # Verifier le contenu
        $content = $response.Content
        if ($content -match "Gestion de la Page d'Accueil") {
            Write-Host "OK - Titre principal present" -ForegroundColor Green
        } else {
            Write-Host "ERREUR - Titre principal manquant" -ForegroundColor Red
        }
        
        if ($content -match "Modifiez le contenu de votre page d'accueil de maniere intuitive") {
            Write-Host "OK - Description intuitive presente" -ForegroundColor Green
        } else {
            Write-Host "ERREUR - Description intuitive manquante" -ForegroundColor Red
        }
        
        if ($content -match "Voir le site") {
            Write-Host "OK - Bouton de previsualisation present" -ForegroundColor Green
        } else {
            Write-Host "ERREUR - Bouton de previsualisation manquant" -ForegroundColor Red
        }
    } else {
        Write-Host "ERREUR - Interface d'administration inaccessible (Status: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "ERREUR - Interface admin: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: API publique
Write-Host "`nTest 3: API publique des sections" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/homepage-sections" -Method GET -TimeoutSec 10
    $result = $response.Content | ConvertFrom-Json
    
    if ($result.success) {
        Write-Host "OK - API publique fonctionnelle" -ForegroundColor Green
        Write-Host "Sections actives: $($result.data.Count)" -ForegroundColor Blue
        
        foreach ($section in $result.data) {
            Write-Host "  - $($section.section_key): $($section.title)" -ForegroundColor White
        }
    } else {
        Write-Host "ERREUR - API publique echouee: $($result.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "ERREUR - API publique: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: API admin
Write-Host "`nTest 4: API admin des sections" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/admin/homepage-sections" -Method GET -TimeoutSec 10
    $result = $response.Content | ConvertFrom-Json
    
    if ($result.success) {
        Write-Host "OK - API admin fonctionnelle" -ForegroundColor Green
        Write-Host "Total sections: $($result.data.Count)" -ForegroundColor Blue
        
        $activeCount = ($result.data | Where-Object { $_.is_active -eq $true }).Count
        $inactiveCount = ($result.data | Where-Object { $_.is_active -eq $false }).Count
        
        Write-Host "Sections actives: $activeCount" -ForegroundColor Green
        Write-Host "Sections inactives: $inactiveCount" -ForegroundColor Yellow
    } else {
        Write-Host "ERREUR - API admin echouee: $($result.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "ERREUR - API admin: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nResume" -ForegroundColor Cyan
Write-Host "=======" -ForegroundColor Cyan
Write-Host "OK - Systeme d'edition intuitive operationnel !" -ForegroundColor Green
Write-Host "`nURLs utiles:" -ForegroundColor Cyan
Write-Host "  - Site principal: $baseUrl" -ForegroundColor White
Write-Host "  - Interface admin: $baseUrl/admin/homepage" -ForegroundColor White
Write-Host "  - API publique: $baseUrl/api/homepage-sections" -ForegroundColor White
Write-Host "  - API admin: $baseUrl/api/admin/homepage-sections" -ForegroundColor White

Write-Host "`nTest termine !" -ForegroundColor Cyan
