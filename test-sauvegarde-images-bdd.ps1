# Script de test pour valider le systeme de sauvegarde d images en base de donnees
# Test complet du systeme de gestion des medias avec stockage en base de donnees

Write-Host "🧪 Test du systeme de sauvegarde d images en base de donnees" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan

$baseUrl = "http://localhost:3000"
$testResults = @()

# Fonction pour tester une API
function Test-Api {
    param(
        [string]$Name,
        [string]$Url,
        [string]$Method = "GET",
        [hashtable]$Body = $null,
        [string]$ExpectedField = $null
    )
    
    Write-Host "`n📋 Test: $Name" -ForegroundColor Yellow
    Write-Host "URL: $Method $Url" -ForegroundColor Gray
    
    try {
        if ($Method -eq "GET") {
            $response = Invoke-RestMethod -Uri $Url -Method $Method -ContentType "application/json"
        } else {
            $jsonBody = if ($Body) { $Body | ConvertTo-Json } else { $null }
            $response = Invoke-RestMethod -Uri $Url -Method $Method -Body $jsonBody -ContentType "application/json"
        }
        
        if ($ExpectedField -and $response.$ExpectedField) {
            Write-Host "✅ Succes: $Name" -ForegroundColor Green
            Write-Host "   Reponse: $($response.$ExpectedField)" -ForegroundColor Gray
            return $true
        } elseif (-not $ExpectedField) {
            Write-Host "✅ Succes: $Name" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ Echec: $Name - Champ '$ExpectedField' manquant" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ Erreur: $Name" -ForegroundColor Red
        Write-Host "   Details: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Test 1: Verifier que la table media_files existe
Write-Host "`n🔍 Test 1: Verification de la table media_files" -ForegroundColor Magenta
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/admin/media?stats=true" -Method GET
    if ($response.success -and $response.data) {
        Write-Host "✅ Table media_files accessible" -ForegroundColor Green
        Write-Host "   Statistiques: $($response.data.total_files) fichiers, $($response.data.total_images) images, $($response.data.total_videos) videos" -ForegroundColor Gray
        $testResults += @{Test="Table media_files"; Result="✅ Succes"}
    } else {
        Write-Host "❌ Table media_files non accessible" -ForegroundColor Red
        $testResults += @{Test="Table media_files"; Result="❌ Echec"}
    }
} catch {
    Write-Host "❌ Erreur lors de l acces a la table media_files" -ForegroundColor Red
    $testResults += @{Test="Table media_files"; Result="❌ Erreur"}
}

# Test 2: Recuperer tous les fichiers medias
$testResults += @{Test="Recuperation fichiers medias"; Result=(Test-Api -Name "Recuperation de tous les fichiers medias" -Url "$baseUrl/api/admin/media" -ExpectedField "success")}

# Test 3: Recuperer les statistiques des medias
$testResults += @{Test="Statistiques medias"; Result=(Test-Api -Name "Statistiques des fichiers medias" -Url "$baseUrl/api/admin/media?stats=true" -ExpectedField "success")}

# Test 4: Tester l upload d une image (simulation)
Write-Host "`n🔍 Test 4: Test d upload d image" -ForegroundColor Magenta
Write-Host "Note: Ce test simule un upload. Pour un test reel, utilisez l interface d administration." -ForegroundColor Yellow

try {
    # Simuler la creation d un fichier media via l API
    $mediaData = @{
        filename = "test-$(Get-Date -Format 'yyyyMMdd-HHmmss').jpg"
        original_filename = "test-image.jpg"
        file_path = "/public/media/test/test-image.jpg"
        file_url = "/media/test/test-image.jpg"
        file_type = "image"
        mime_type = "image/jpeg"
        file_size = 1024
        is_active = $true
        uploaded_by = "test-script"
        context = "test"
        context_id = 1
    }
    
    $response = Invoke-RestMethod -Uri "$baseUrl/api/admin/media" -Method POST -Body ($mediaData | ConvertTo-Json) -ContentType "application/json"
    
    if ($response.success -and $response.data.id) {
        Write-Host "✅ Creation de fichier media reussie" -ForegroundColor Green
        Write-Host "   ID: $($response.data.id)" -ForegroundColor Gray
        Write-Host "   Nom: $($response.data.filename)" -ForegroundColor Gray
        
        $mediaId = $response.data.id
        $testResults += @{Test="Creation fichier media"; Result="✅ Succes"}
        
        # Test 5: Recuperer le fichier cree
        $testResults += @{Test="Recuperation fichier par ID"; Result=(Test-Api -Name "Recuperation du fichier cree" -Url "$baseUrl/api/admin/media/$mediaId" -ExpectedField "success")}
        
        # Test 6: Mettre a jour le fichier
        $updateData = @{
            is_active = $false
        }
        $testResults += @{Test="Mise a jour fichier"; Result=(Test-Api -Name "Mise a jour du fichier" -Url "$baseUrl/api/admin/media/$mediaId" -Method "PUT" -Body $updateData -ExpectedField "success")}
        
        # Test 7: Supprimer le fichier
        $testResults += @{Test="Suppression fichier"; Result=(Test-Api -Name "Suppression du fichier" -Url "$baseUrl/api/admin/media/$mediaId" -Method "DELETE" -ExpectedField "success")}
        
    } else {
        Write-Host "❌ Echec de la creation de fichier media" -ForegroundColor Red
        $testResults += @{Test="Creation fichier media"; Result="❌ Echec"}
    }
} catch {
    Write-Host "❌ Erreur lors du test d upload: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += @{Test="Creation fichier media"; Result="❌ Erreur"}
}

# Test 8: Verifier les filtres
Write-Host "`n🔍 Test 8: Test des filtres" -ForegroundColor Magenta
$testResults += @{Test="Filtre par type image"; Result=(Test-Api -Name "Filtre par type image" -Url "$baseUrl/api/admin/media?type=image" -ExpectedField "success")}
$testResults += @{Test="Filtre par type video"; Result=(Test-Api -Name "Filtre par type video" -Url "$baseUrl/api/admin/media?type=video" -ExpectedField "success")}
$testResults += @{Test="Filtre par contexte"; Result=(Test-Api -Name "Filtre par contexte" -Url "$baseUrl/api/admin/media?context=entry_page" -ExpectedField "success")}

# Test 9: Verifier l API d upload existante
Write-Host "`n🔍 Test 9: Verification de l API d upload existante" -ForegroundColor Magenta
Write-Host "Note: L API d upload necessite un fichier reel. Verifiez manuellement via l interface d administration." -ForegroundColor Yellow
Write-Host "URL de test: $baseUrl/admin/entry-page" -ForegroundColor Gray

# Resume des tests
Write-Host "`n📊 Resume des tests" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan

$successCount = 0
$totalCount = $testResults.Count

foreach ($result in $testResults) {
    Write-Host "$($result.Test): $($result.Result)" -ForegroundColor $(if ($result.Result -like "✅*") { "Green" } else { "Red" })
    if ($result.Result -like "✅*") { $successCount++ }
}

Write-Host "`n📈 Statistiques:" -ForegroundColor Cyan
Write-Host "Tests reussis: $successCount/$totalCount" -ForegroundColor $(if ($successCount -eq $totalCount) { "Green" } else { "Yellow" })
Write-Host "Taux de reussite: $([math]::Round(($successCount / $totalCount) * 100, 1))%" -ForegroundColor $(if ($successCount -eq $totalCount) { "Green" } else { "Yellow" })

if ($successCount -eq $totalCount) {
    Write-Host "`n🎉 Tous les tests sont passes avec succes !" -ForegroundColor Green
    Write-Host "Le systeme de sauvegarde d images en base de donnees fonctionne correctement." -ForegroundColor Green
} else {
    Write-Host "`n⚠️ Certains tests ont echoue. Verifiez les erreurs ci-dessus." -ForegroundColor Yellow
}

Write-Host "`n💡 Prochaines etapes:" -ForegroundColor Cyan
Write-Host "1. Testez l upload d images via l interface d administration" -ForegroundColor White
Write-Host "2. Verifiez que les metadonnees sont bien sauvegardees en base de donnees" -ForegroundColor White
Write-Host "3. Testez la recuperation des images depuis la base de donnees" -ForegroundColor White
Write-Host "4. Verifiez les statistiques des medias dans l interface d administration" -ForegroundColor White

Write-Host "`n🔗 URLs utiles:" -ForegroundColor Cyan
Write-Host "Interface d administration: $baseUrl/admin" -ForegroundColor White
Write-Host "Page d entree: $baseUrl/admin/entry-page" -ForegroundColor White
Write-Host "API des medias: $baseUrl/api/admin/media" -ForegroundColor White
Write-Host "Statistiques: $baseUrl/api/admin/media?stats=true" -ForegroundColor White