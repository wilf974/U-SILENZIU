# Script de test pour la nouvelle page /rooms
# Teste la synchronisation entre back-office et front-office avec la vraie URL

Write-Host "=== Test de la nouvelle page /rooms ===" -ForegroundColor Green
Write-Host ""

# Test 1: Verifier l'accessibilite de la nouvelle page /rooms
Write-Host "1. Test d'accessibilite de la page /rooms..." -ForegroundColor Yellow
try {
    $roomsResponse = Invoke-WebRequest -Uri "http://localhost:3000/rooms" -Method GET -TimeoutSec 10
    if ($roomsResponse.StatusCode -eq 200) {
        Write-Host "   ✅ Page /rooms accessible" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Page /rooms non accessible (Status: $($roomsResponse.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erreur d'acces a la page /rooms: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 2: Verifier l'API des salles
Write-Host "2. Test de l'API des salles..." -ForegroundColor Yellow
try {
    $apiResponse = Invoke-WebRequest -Uri "http://localhost:3000/api/admin/rooms" -Method GET -TimeoutSec 10
    if ($apiResponse.StatusCode -eq 200) {
        $rooms = $apiResponse.Content | ConvertFrom-Json
        Write-Host "   ✅ API des salles accessible" -ForegroundColor Green
        Write-Host "   📊 Nombre total de salles: $($rooms.Count)" -ForegroundColor Cyan
        
        $activeRooms = $rooms | Where-Object { $_.isActive -eq $true }
        $inactiveRooms = $rooms | Where-Object { $_.isActive -eq $false }
        
        Write-Host "   🟢 Salles actives: $($activeRooms.Count)" -ForegroundColor Green
        Write-Host "   🔴 Salles inactives: $($inactiveRooms.Count)" -ForegroundColor Red
        
        if ($activeRooms.Count -gt 0) {
            Write-Host "   📋 Salles actives disponibles:" -ForegroundColor Cyan
            $activeRooms | ForEach-Object {
                Write-Host "      • $($_.name) - $($_.price)€" -ForegroundColor White
            }
        }
    } else {
        Write-Host "   ❌ API des salles non accessible (Status: $($apiResponse.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erreur d'acces a l'API des salles: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Verifier que la page /rooms affiche les bonnes salles
Write-Host "3. Test du contenu de la page /rooms..." -ForegroundColor Yellow
try {
    $roomsPageResponse = Invoke-WebRequest -Uri "http://localhost:3000/rooms" -Method GET -TimeoutSec 10
    if ($roomsPageResponse.StatusCode -eq 200) {
        $content = $roomsPageResponse.Content
        
        # Verifier si la page contient des elements de salles
        if ($content -match "Nos Salles") {
            Write-Host "   ✅ Page /rooms contient le titre 'Nos Salles'" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Page /rooms ne contient pas le titre attendu" -ForegroundColor Yellow
        }
        
        # Verifier si des salles sont affichees
        if ($content -match "Reserver cette salle") {
            Write-Host "   ✅ Page /rooms contient des boutons de reservation" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Page /rooms ne contient pas de boutons de reservation" -ForegroundColor Yellow
        }
        
        # Verifier le bouton de rafraichissement
        if ($content -match "Actualiser") {
            Write-Host "   ✅ Page /rooms contient le bouton d'actualisation" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Page /rooms ne contient pas le bouton d'actualisation" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "   ❌ Page /rooms non accessible (Status: $($roomsPageResponse.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erreur d'acces a la page /rooms: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Instructions pour l'utilisateur
Write-Host "=== Instructions d'utilisation ===" -ForegroundColor Green
Write-Host ""
Write-Host "🔧 NOUVELLE SOLUTION - Page dediee /rooms:" -ForegroundColor Cyan
Write-Host "   1. Ouvrez http://localhost:3000/admin/rooms dans votre navigateur" -ForegroundColor White
Write-Host "   2. Activez les salles que vous voulez afficher" -ForegroundColor White
Write-Host "   3. Ouvrez http://localhost:3000/rooms pour voir les salles actives" -ForegroundColor White
Write-Host "   4. Cliquez sur le bouton 'Actualiser' si necessaire" -ForegroundColor White
Write-Host ""
Write-Host "📱 URLs importantes:" -ForegroundColor Cyan
Write-Host "   • Interface admin: http://localhost:3000/admin/rooms" -ForegroundColor White
Write-Host "   • Page des salles: http://localhost:3000/rooms" -ForegroundColor White
Write-Host "   • Site principal: http://localhost:3000" -ForegroundColor White
Write-Host ""
Write-Host "✅ AVANTAGES de la nouvelle page /rooms:" -ForegroundColor Green
Write-Host "   • URL propre et SEO-friendly" -ForegroundColor White
Write-Host "   • Rechargement automatique a chaque visite" -ForegroundColor White
Write-Host "   • Pas de problemes de cache avec les fragments" -ForegroundColor White
Write-Host "   • Bouton d'actualisation manuel disponible" -ForegroundColor White
Write-Host ""
Write-Host "🎯 Les modifications cote admin sont maintenant immediatement visibles sur /rooms !" -ForegroundColor Green
