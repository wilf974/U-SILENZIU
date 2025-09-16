# Test de l'affichage des images optimisées avec Next.js Image
# U Silenziu - Décembre 2024

Write-Host "🧪 Test de l'affichage des images optimisées avec Next.js Image" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan

# Configuration
$baseUrl = "http://localhost:3000"
$adminUrl = "http://localhost:3000/admin/rooms"
$apiUrl = "http://localhost:3000/api/rooms"

# Test de la page d'accueil
Write-Host "`n📄 Test de la page d'accueil..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $baseUrl -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Page d'accueil accessible" -ForegroundColor Green
    } else {
        Write-Host "❌ Page d'accueil - Status: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Page d'accueil - Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

# Test de l'API des salles
Write-Host "`n📡 Test de l'API des salles..." -ForegroundColor Yellow
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
        
        foreach ($room in $rooms) {
            if ($room.image_url) {
                Write-Host "   ✅ $($room.name) - Image présente" -ForegroundColor Green
            } else {
                Write-Host "   ❌ $($room.name) - Pas d'image" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "❌ Erreur API - Status: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur API: $($_.Exception.Message)" -ForegroundColor Red
}

# Test de l'interface d'administration
Write-Host "`n🔧 Test de l'interface d'administration..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $adminUrl -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Interface d'administration accessible" -ForegroundColor Green
    } else {
        Write-Host "❌ Interface admin - Status: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Interface admin - Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

# Instructions pour tester manuellement
Write-Host "`nTests manuels recommandes:" -ForegroundColor Yellow
Write-Host "1. Ouvrir http://localhost:3000" -ForegroundColor White
Write-Host "2. Verifier que les images des salles s'affichent correctement" -ForegroundColor White
Write-Host "3. Verifier que les images se chargent avec un effet de blur" -ForegroundColor White
Write-Host "4. Tester la responsivite sur differentes tailles d'ecran" -ForegroundColor White
Write-Host "5. Verifier l'accessibilite avec les alt text" -ForegroundColor White

Write-Host "`n🎯 Test terminé !" -ForegroundColor Green
