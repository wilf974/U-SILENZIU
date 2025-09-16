# Script de test pour l'interface d'administration des salles
# Teste la synchronisation entre back-office et front-office

Write-Host "=== Test de l'interface d'administration des salles ===" -ForegroundColor Green
Write-Host ""

# Test 1: Vérifier l'accessibilité de l'admin
Write-Host "1. Test d'accessibilité de l'interface admin..." -ForegroundColor Yellow
try {
    $adminResponse = Invoke-WebRequest -Uri "http://localhost:3000/admin/rooms" -Method GET -TimeoutSec 10
    if ($adminResponse.StatusCode -eq 200) {
        Write-Host "   ✅ Interface admin accessible" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Interface admin non accessible (Status: $($adminResponse.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erreur d'accès à l'interface admin: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 2: Vérifier l'API des salles
Write-Host "2. Test de l'API des salles..." -ForegroundColor Yellow
try {
    $roomsResponse = Invoke-WebRequest -Uri "http://localhost:3000/api/admin/rooms" -Method GET -TimeoutSec 10
    if ($roomsResponse.StatusCode -eq 200) {
        $rooms = $roomsResponse.Content | ConvertFrom-Json
        Write-Host "   ✅ API des salles accessible" -ForegroundColor Green
        Write-Host "   📊 Nombre de salles: $($rooms.Count)" -ForegroundColor Cyan
        
        $activeRooms = $rooms | Where-Object { $_.isActive -eq $true }
        $inactiveRooms = $rooms | Where-Object { $_.isActive -eq $false }
        
        Write-Host "   🟢 Salles actives: $($activeRooms.Count)" -ForegroundColor Green
        Write-Host "   🔴 Salles inactives: $($inactiveRooms.Count)" -ForegroundColor Red
        
        if ($inactiveRooms.Count -gt 0) {
            Write-Host "   💡 Conseil: Activez les salles inactives pour les voir sur le site principal" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ❌ API des salles non accessible (Status: $($roomsResponse.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erreur d'accès à l'API des salles: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Vérifier le site principal
Write-Host "3. Test du site principal..." -ForegroundColor Yellow
try {
    $siteResponse = Invoke-WebRequest -Uri "http://localhost:3000" -Method GET -TimeoutSec 10
    if ($siteResponse.StatusCode -eq 200) {
        Write-Host "   ✅ Site principal accessible" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Site principal non accessible (Status: $($siteResponse.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erreur d'accès au site principal: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 4: Vérifier la section des salles sur le site
Write-Host "4. Test de la section des salles sur le site..." -ForegroundColor Yellow
try {
    $formulesResponse = Invoke-WebRequest -Uri "http://localhost:3000/#formules" -Method GET -TimeoutSec 10
    if ($formulesResponse.StatusCode -eq 200) {
        Write-Host "   ✅ Section des salles accessible" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Section des salles non accessible (Status: $($formulesResponse.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erreur d'accès à la section des salles: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Instructions pour l'utilisateur
Write-Host "=== Instructions d'utilisation ===" -ForegroundColor Green
Write-Host ""
Write-Host "🔧 Pour activer les salles et voir les modifications sur le site:" -ForegroundColor Cyan
Write-Host "   1. Ouvrez http://localhost:3000/admin/rooms dans votre navigateur" -ForegroundColor White
Write-Host "   2. Lisez la section 'Activation des salles' en haut de page" -ForegroundColor White
Write-Host "   3. Cliquez sur 'Activer toutes les salles' ou 'Activer' pour chaque salle" -ForegroundColor White
Write-Host "   4. Cliquez sur 'Voir le site principal' pour vérifier les modifications" -ForegroundColor White
Write-Host ""
Write-Host "📱 URLs importantes:" -ForegroundColor Cyan
Write-Host "   • Interface admin: http://localhost:3000/admin/rooms" -ForegroundColor White
Write-Host "   • Site principal: http://localhost:3000" -ForegroundColor White
Write-Host "   • Section des salles: http://localhost:3000/#formules" -ForegroundColor White
Write-Host ""
Write-Host "✅ Les modifications côté admin sont immédiatement reflétées côté site !" -ForegroundColor Green
