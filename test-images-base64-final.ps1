# Test final de l'affichage des images base64 avec Context7
# U Silenziu - Decembre 2024

Write-Host "Test final de l'affichage des images base64 avec Context7" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

# Configuration
$baseUrl = "http://localhost:3000"
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
        
        $base64Count = 0
        $urlCount = 0
        $noImageCount = 0
        
        foreach ($room in $rooms) {
            if ($room.image_url) {
                if ($room.image_url.StartsWith("data:")) {
                    Write-Host "   ✅ $($room.name) - Image base64 presente" -ForegroundColor Green
                    $base64Count++
                } else {
                    Write-Host "   ✅ $($room.name) - Image URL externe" -ForegroundColor Blue
                    $urlCount++
                }
            } else {
                Write-Host "   ❌ $($room.name) - Pas d'image" -ForegroundColor Yellow
                $noImageCount++
            }
        }
        
        Write-Host "`nStatistiques des images:" -ForegroundColor Magenta
        Write-Host "   • Images base64: $base64Count" -ForegroundColor Green
        Write-Host "   • Images URL externes: $urlCount" -ForegroundColor Blue
        Write-Host "   • Salles sans image: $noImageCount" -ForegroundColor Yellow
        
    } else {
        Write-Host "❌ Erreur API - Status: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur API: $($_.Exception.Message)" -ForegroundColor Red
}

# Test de la page d'accueil
Write-Host "`nTest de la page d'accueil..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $baseUrl -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Page d'accueil accessible" -ForegroundColor Green
        
        # Vérifier si les images base64 sont présentes dans le HTML
        if ($response.Content -match "data:image") {
            Write-Host "✅ Images base64 detectees dans le HTML" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Aucune image base64 detectee dans le HTML" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "❌ Page d'accueil - Status: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Page d'accueil - Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

# Instructions pour tester manuellement
Write-Host "`nTests manuels recommandes:" -ForegroundColor Yellow
Write-Host "1. Ouvrir http://localhost:3000" -ForegroundColor White
Write-Host "2. Verifier que les images des salles s'affichent correctement" -ForegroundColor White
Write-Host "3. Verifier que les images base64 se chargent sans erreur" -ForegroundColor White
Write-Host "4. Tester la responsivite sur differentes tailles d'ecran" -ForegroundColor White
Write-Host "5. Verifier l'accessibilite avec les alt text" -ForegroundColor White
Write-Host "6. Tester le lazy loading des images" -ForegroundColor White

Write-Host "`nTest final termine !" -ForegroundColor Green
Write-Host "Solution Context7: Images base64 affichees avec img standard, URLs externes avec Next.js Image" -ForegroundColor Cyan
