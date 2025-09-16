# Test du composant RoomImage réutilisable
# U Silenziu - Decembre 2024

Write-Host "Test du composant RoomImage réutilisable" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Configuration
$baseUrl = "http://localhost:3000"
$adminUrl = "http://localhost:3000/admin/rooms"
$apiUrl = "http://localhost:3000/api/rooms"

# Test de l'API des salles
Write-Host "`nTest de l'API des salles..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $apiUrl -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        $data = $response.Content | ConvertFrom-Json
        if ($data.data) {
            $rooms = $data.data
        } else {
            $rooms = $data
        }
        
        Write-Host "✅ API des salles accessible" -ForegroundColor Green
        Write-Host "📊 Nombre de salles actives: $($rooms.Count)" -ForegroundColor Cyan
        
        # Vérifier que les images sont présentes
        $roomsWithImages = 0
        foreach ($room in $rooms) {
            if ($room.image_url) {
                $roomsWithImages++
            }
        }
        
        Write-Host "📸 Salles avec images: $roomsWithImages/$($rooms.Count)" -ForegroundColor Green
        
    } else {
        Write-Host "❌ Erreur API - Status: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur API: $($_.Exception.Message)" -ForegroundColor Red
}

# Test de la page d'accueil (site public)
Write-Host "`nTest de la page d'accueil (site public)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $baseUrl -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Page d'accueil accessible" -ForegroundColor Green
        
        # Vérifier la présence du composant RoomImage
        if ($response.Content -match "RoomImage") {
            Write-Host "✅ Composant RoomImage detecte dans le code" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Composant RoomImage non detecte dans le code" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "❌ Page d'accueil - Status: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Page d'accueil - Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

# Test de l'interface d'administration
Write-Host "`nTest de l'interface d'administration..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $adminUrl -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Interface d'administration accessible" -ForegroundColor Green
        
        # Vérifier la présence du composant RoomImage
        if ($response.Content -match "RoomImage") {
            Write-Host "✅ Composant RoomImage detecte dans l'admin" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Composant RoomImage non detecte dans l'admin" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "❌ Interface admin - Status: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Interface admin - Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

# Instructions pour tester manuellement
Write-Host "`nTests manuels recommandes:" -ForegroundColor Yellow
Write-Host "1. Ouvrir http://localhost:3000 (site public)" -ForegroundColor White
Write-Host "2. Verifier que les images des salles s'affichent correctement" -ForegroundColor White
Write-Host "3. Ouvrir http://localhost:3000/admin/rooms (back-office)" -ForegroundColor White
Write-Host "4. Verifier que les images s'affichent dans l'interface admin" -ForegroundColor White
Write-Host "5. Tester la previsualisation d'images dans le formulaire" -ForegroundColor White
Write-Host "6. Verifier la coherence entre site public et admin" -ForegroundColor White

Write-Host "`nAvantages du composant RoomImage:" -ForegroundColor Magenta
Write-Host "✅ Code reutilisable entre site public et admin" -ForegroundColor Green
Write-Host "✅ Gestion automatique des images base64 et URLs externes" -ForegroundColor Green
Write-Host "✅ Fallback automatique en cas d'erreur" -ForegroundColor Green
Write-Host "✅ Optimisations de performance automatiques" -ForegroundColor Green
Write-Host "✅ Interface TypeScript complete et type-safe" -ForegroundColor Green

Write-Host "`nTest du composant RoomImage termine !" -ForegroundColor Green
Write-Host "🎯 Architecture unifiee et maintenable avec Context7" -ForegroundColor Cyan
