# Script de test pour le système d'upload de médias
Write-Host "=== Test du Système d'Upload de Médias ===" -ForegroundColor Green
Write-Host ""

$baseUrl = "http://localhost:3000"

# Fonction pour tester une API
function Test-Api {
    param($url, $method = "GET", $body = $null, $description)
    try {
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        if ($body) {
            $response = Invoke-WebRequest -Uri $url -Method $method -Body ($body | ConvertTo-Json) -Headers $headers -TimeoutSec 10
        } else {
            $response = Invoke-WebRequest -Uri $url -Method $method -Headers $headers -TimeoutSec 10
        }
        
        if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 201) {
            Write-Host "✅ $description" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ $description (Code: $($response.StatusCode))" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ $description (Erreur: $($_.Exception.Message))" -ForegroundColor Red
        return $false
    }
}

Write-Host "1. Test des API de médias" -ForegroundColor Yellow
Write-Host ""

# Test de l'API de récupération des images
$imageApiTest = Test-Api "$baseUrl/api/media/entry/image" "GET" $null "API de récupération des images"

# Test de l'API de récupération des vidéos
$videoApiTest = Test-Api "$baseUrl/api/media/entry/video" "GET" $null "API de récupération des vidéos"

Write-Host ""
Write-Host "2. Test des interfaces" -ForegroundColor Yellow
Write-Host ""

# Test de la page d'administration
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/admin/entry-page" -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Interface d'administration accessible" -ForegroundColor Green
    } else {
        Write-Host "❌ Interface d'administration non accessible (Code: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Interface d'administration (Erreur: $($_.Exception.Message))" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Test de la page d'entrée" -ForegroundColor Yellow
Write-Host ""

# Test de la page d'entrée
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/entry" -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Page d'entrée accessible" -ForegroundColor Green
    } else {
        Write-Host "❌ Page d'entrée non accessible (Code: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Page d'entrée (Erreur: $($_.Exception.Message))" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Instructions d'utilisation ===" -ForegroundColor Cyan
Write-Host "1. Accédez à l'interface d'administration: $baseUrl/admin/entry-page" -ForegroundColor White
Write-Host "2. Cliquez sur 'Modifier' pour activer l'édition" -ForegroundColor White
Write-Host "3. Dans la section 'Médias d'Arrière-plan':" -ForegroundColor White
Write-Host "   • Cliquez sur 'Uploader un fichier image' pour ajouter une image" -ForegroundColor Gray
Write-Host "   • Cliquez sur 'Uploader un fichier vidéo' pour ajouter une vidéo" -ForegroundColor Gray
Write-Host "   • Sélectionnez un fichier depuis la liste des médias disponibles" -ForegroundColor Gray
Write-Host "4. Sauvegardez vos modifications" -ForegroundColor White
Write-Host "5. Prévisualisez la page d'entrée" -ForegroundColor White
Write-Host ""

Write-Host "=== Formats supportés ===" -ForegroundColor Cyan
Write-Host "• Images: JPG, PNG, GIF, WebP (max 10MB)" -ForegroundColor White
Write-Host "• Vidéos: MP4, WebM, MOV, AVI (max 10MB)" -ForegroundColor White
Write-Host ""

Write-Host "Test terminé !" -ForegroundColor Green
