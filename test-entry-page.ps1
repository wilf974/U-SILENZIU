# Script de test de la page d'entrée pour U Silenziu
# Ce script teste toutes les fonctionnalités de la page d'entrée

Write-Host "🧪 Test de la page d'entrée U Silenziu" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""

# Configuration
$baseUrl = "http://localhost:3000"
$apiUrl = "$baseUrl/api"

# Fonction de test d'URL
function Test-Url {
    param(
        [string]$Url,
        [string]$Description,
        [string]$ExpectedContent = $null
    )
    
    Write-Host "🔍 Test: $Description" -ForegroundColor Yellow
    Write-Host "   URL: $Url" -ForegroundColor Gray
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method GET -UseBasicParsing -TimeoutSec 10
        
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✅ Statut: $($response.StatusCode) OK" -ForegroundColor Green
            
            if ($ExpectedContent -and $response.Content -like "*$ExpectedContent*") {
                Write-Host "   ✅ Contenu attendu trouvé" -ForegroundColor Green
            } elseif ($ExpectedContent) {
                Write-Host "   ⚠️  Contenu attendu non trouvé: $ExpectedContent" -ForegroundColor Yellow
            }
            
            return $true
        } else {
            Write-Host "   ❌ Statut: $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "   ❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Fonction de test d'API
function Test-Api {
    param(
        [string]$Url,
        [string]$Description,
        [string]$Method = "GET",
        [hashtable]$Body = $null
    )
    
    Write-Host "🔍 Test API: $Description" -ForegroundColor Yellow
    Write-Host "   URL: $Url" -ForegroundColor Gray
    Write-Host "   Méthode: $Method" -ForegroundColor Gray
    
    try {
        $headers = @{
            "Content-Type" = "application/json"
            "Accept" = "application/json"
        }
        
        if ($Method -eq "GET") {
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Headers $headers -TimeoutSec 10
        } else {
            $jsonBody = $Body | ConvertTo-Json -Depth 3
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Headers $headers -Body $jsonBody -TimeoutSec 10
        }
        
        Write-Host "   ✅ Réponse reçue" -ForegroundColor Green
        
        if ($response) {
            Write-Host "   📄 Données: $(($response | ConvertTo-Json -Compress).Substring(0, [Math]::Min(100, ($response | ConvertTo-Json -Compress).Length)))..." -ForegroundColor Gray
        }
        
        return $response
    }
    catch {
        Write-Host "   ❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

Write-Host "🏁 Début des tests..." -ForegroundColor White
Write-Host ""

# Test 1: Vérification du serveur
Write-Host "1️⃣ Test de base du serveur" -ForegroundColor Cyan
$serverOk = Test-Url -Url "$baseUrl/" -Description "Page d'accueil du site"
Write-Host ""

if (-not $serverOk) {
    Write-Host "❌ Le serveur n'est pas accessible. Veuillez démarrer l'application." -ForegroundColor Red
    Read-Host "Appuyez sur Entrée pour continuer..."
    exit 1
}

# Test 2: API de configuration de la page d'entrée
Write-Host "2️⃣ Test de l'API de configuration" -ForegroundColor Cyan
$configData = Test-Api -Url "$apiUrl/entry-page-config" -Description "API publique de configuration"

if ($configData) {
    Write-Host "   📋 Configuration récupérée:" -ForegroundColor White
    Write-Host "      • Titre: $($configData.title)" -ForegroundColor Gray
    Write-Host "      • Sous-titre: $($configData.subtitle)" -ForegroundColor Gray
    Write-Host "      • Type d'arrière-plan: $($configData.background_type)" -ForegroundColor Gray
    Write-Host "      • Statut: $(if($configData.is_active) { 'Actif' } else { 'Inactif' })" -ForegroundColor Gray
}
Write-Host ""

# Test 3: Page d'entrée
Write-Host "3️⃣ Test de la page d'entrée" -ForegroundColor Cyan
$entryPageOk = Test-Url -Url "$baseUrl/entry" -Description "Page d'entrée du site" -ExpectedContent "U SILENZIU"
Write-Host ""

# Test 4: Interface d'administration
Write-Host "4️⃣ Test de l'interface d'administration" -ForegroundColor Cyan
$adminOk = Test-Url -Url "$baseUrl/admin/entry-page" -Description "Interface d'administration de la page d'entrée"
Write-Host ""

# Test 5: API d'administration
Write-Host "5️⃣ Test de l'API d'administration" -ForegroundColor Cyan
$adminConfigData = Test-Api -Url "$apiUrl/admin/entry-page-config" -Description "API d'administration"

if ($adminConfigData) {
    Write-Host "   📋 Configuration administrative récupérée:" -ForegroundColor White
    Write-Host "      • ID: $($adminConfigData.id)" -ForegroundColor Gray
    Write-Host "      • Date de création: $($adminConfigData.created_at)" -ForegroundColor Gray
    Write-Host "      • Dernière modification: $($adminConfigData.updated_at)" -ForegroundColor Gray
}
Write-Host ""

# Test 6: Vérification des répertoires de médias
Write-Host "6️⃣ Test des répertoires de médias" -ForegroundColor Cyan
$imageDir = "public/media/entry/image"
$videoDir = "public/media/entry/video"

if (Test-Path $imageDir) {
    Write-Host "   ✅ Répertoire images: $imageDir" -ForegroundColor Green
} else {
    Write-Host "   ❌ Répertoire images manquant: $imageDir" -ForegroundColor Red
}

if (Test-Path $videoDir) {
    Write-Host "   ✅ Répertoire vidéos: $videoDir" -ForegroundColor Green
} else {
    Write-Host "   ❌ Répertoire vidéos manquant: $videoDir" -ForegroundColor Red
}
Write-Host ""

# Test 7: API d'upload (sans fichier)
Write-Host "7️⃣ Test de l'API d'upload (informations)" -ForegroundColor Cyan
$uploadInfo = Test-Api -Url "$apiUrl/media/upload" -Description "API d'upload - informations"

if ($uploadInfo) {
    Write-Host "   📋 Informations d'upload:" -ForegroundColor White
    Write-Host "      • Types supportés: $($uploadInfo.endpoints.supported_types -join ', ')" -ForegroundColor Gray
    Write-Host "      • Taille max images: $($uploadInfo.endpoints.max_sizes.image)" -ForegroundColor Gray
    Write-Host "      • Taille max vidéos: $($uploadInfo.endpoints.max_sizes.video)" -ForegroundColor Gray
}
Write-Host ""

# Résumé des tests
Write-Host "📊 Résumé des tests" -ForegroundColor White
Write-Host "==================" -ForegroundColor White

$results = @(
    @{ Test = "Serveur principal"; Status = $serverOk },
    @{ Test = "API configuration publique"; Status = ($configData -ne $null) },
    @{ Test = "Page d'entrée"; Status = $entryPageOk },
    @{ Test = "Interface d'administration"; Status = $adminOk },
    @{ Test = "API d'administration"; Status = ($adminConfigData -ne $null) },
    @{ Test = "Répertoires de médias"; Status = ((Test-Path $imageDir) -and (Test-Path $videoDir)) },
    @{ Test = "API d'upload"; Status = ($uploadInfo -ne $null) }
)

$successCount = 0
foreach ($result in $results) {
    $status = if ($result.Status) { "✅ OK"; $successCount++ } else { "❌ ÉCHEC" }
    $color = if ($result.Status) { "Green" } else { "Red" }
    Write-Host "$($result.Test): $status" -ForegroundColor $color
}

Write-Host ""
$percentage = [math]::Round(($successCount / $results.Count) * 100, 1)
Write-Host "🎯 Résultat global: $successCount/$($results.Count) tests réussis ($percentage%)" -ForegroundColor $(if ($percentage -eq 100) { "Green" } elseif ($percentage -ge 80) { "Yellow" } else { "Red" })

if ($percentage -eq 100) {
    Write-Host ""
    Write-Host "🎉 Tous les tests sont passés ! La page d'entrée est prête à être utilisée." -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 URLs de test :" -ForegroundColor White
    Write-Host "   • Page d'entrée : $baseUrl/entry" -ForegroundColor Gray
    Write-Host "   • Administration : $baseUrl/admin/entry-page" -ForegroundColor Gray
    Write-Host "   • Dashboard admin : $baseUrl/admin" -ForegroundColor Gray
} elseif ($percentage -ge 80) {
    Write-Host ""
    Write-Host "⚠️  La plupart des tests sont passés, mais il y a quelques problèmes à résoudre." -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "❌ Plusieurs tests ont échoué. Vérifiez la configuration et les services." -ForegroundColor Red
}

Write-Host ""
Read-Host "Appuyez sur Entrée pour continuer..."
