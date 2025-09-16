# Script de test pour vérifier les corrections du système de gestion des salles
# Test des fonctions de modification et basculement de statut

Write-Host "🧪 Test des corrections du système de gestion des salles U Silenziu" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan

$baseUrl = "http://localhost:3000"

# Fonction pour faire une requête HTTP
function Invoke-TestRequest {
    param(
        [string]$Method,
        [string]$Url,
        [object]$Body = $null
    )
    
    $headers = @{
        "Content-Type" = "application/json"
    }
    
    $params = @{
        Method = $Method
        Uri = $Url
        Headers = $headers
    }
    
    if ($Body) {
        $params.Body = $Body | ConvertTo-Json -Depth 10
    }
    
    try {
        $response = Invoke-RestMethod @params
        return @{
            Success = $true
            Data = $response
        }
    }
    catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
            StatusCode = $_.Exception.Response.StatusCode.value__
        }
    }
}

# Test 1: Vérifier que l'API admin fonctionne
Write-Host "`n📋 Test 1: API admin des salles" -ForegroundColor Yellow
$adminRooms = Invoke-TestRequest -Method "GET" -Url "$baseUrl/api/admin/rooms"

if ($adminRooms.Success) {
    Write-Host "✅ API admin fonctionnelle" -ForegroundColor Green
    Write-Host "   Total salles: $($adminRooms.Data.count)" -ForegroundColor Gray
    
    # Récupérer la première salle pour les tests
    if ($adminRooms.Data.data.Count -gt 0) {
        $firstRoom = $adminRooms.Data.data[0]
        $roomId = $firstRoom.id
        Write-Host "   ID de la première salle: $roomId" -ForegroundColor Gray
    } else {
        Write-Host "❌ Aucune salle trouvée pour les tests" -ForegroundColor Red
        exit
    }
} else {
    Write-Host "❌ Erreur API admin: $($adminRooms.Error)" -ForegroundColor Red
    exit
}

# Test 2: Modifier une salle (correction principale)
if ($roomId) {
    Write-Host "`n📋 Test 2: Modification d'une salle" -ForegroundColor Yellow
    $updateData = @{
        description = "Description modifiée pour test - $(Get-Date -Format 'HH:mm:ss')"
        price = 50
    }
    
    $updateResult = Invoke-TestRequest -Method "PUT" -Url "$baseUrl/api/admin/rooms/$roomId" -Body $updateData
    
    if ($updateResult.Success) {
        Write-Host "✅ Salle modifiée avec succès" -ForegroundColor Green
        Write-Host "   Nouvelle description: $($updateResult.Data.data.description)" -ForegroundColor Gray
        Write-Host "   Nouveau prix: $($updateResult.Data.data.price)€" -ForegroundColor Gray
    } else {
        Write-Host "❌ Erreur modification: $($updateResult.Error)" -ForegroundColor Red
        Write-Host "   Status Code: $($updateResult.StatusCode)" -ForegroundColor Red
    }
}

# Test 3: Basculer le statut d'une salle
if ($roomId) {
    Write-Host "`n📋 Test 3: Basculement du statut" -ForegroundColor Yellow
    $toggleData = @{
        action = "toggle"
    }
    
    $toggleResult = Invoke-TestRequest -Method "PATCH" -Url "$baseUrl/api/admin/rooms/$roomId" -Body $toggleData
    
    if ($toggleResult.Success) {
        Write-Host "✅ Statut basculé avec succès" -ForegroundColor Green
        $status = if ($toggleResult.Data.data.isActive) { "Active" } else { "Inactive" }
        Write-Host "   Nouveau statut: $status" -ForegroundColor Gray
    } else {
        Write-Host "❌ Erreur basculement: $($toggleResult.Error)" -ForegroundColor Red
        Write-Host "   Status Code: $($toggleResult.StatusCode)" -ForegroundColor Red
    }
}

# Test 4: Réactiver la salle
if ($roomId) {
    Write-Host "`n📋 Test 4: Réactivation de la salle" -ForegroundColor Yellow
    $toggleData = @{
        action = "toggle"
    }
    
    $toggleResult = Invoke-TestRequest -Method "PATCH" -Url "$baseUrl/api/admin/rooms/$roomId" -Body $toggleData
    
    if ($toggleResult.Success) {
        Write-Host "✅ Salle réactivée avec succès" -ForegroundColor Green
        $status = if ($toggleResult.Data.data.isActive) { "Active" } else { "Inactive" }
        Write-Host "   Statut final: $status" -ForegroundColor Gray
    } else {
        Write-Host "❌ Erreur réactivation: $($toggleResult.Error)" -ForegroundColor Red
    }
}

# Test 5: Vérifier que l'API publique fonctionne toujours
Write-Host "`n📋 Test 5: Vérification API publique" -ForegroundColor Yellow
$publicRooms = Invoke-TestRequest -Method "GET" -Url "$baseUrl/api/rooms"

if ($publicRooms.Success) {
    Write-Host "✅ API publique fonctionnelle" -ForegroundColor Green
    Write-Host "   Salles actives: $($publicRooms.Data.count)" -ForegroundColor Gray
} else {
    Write-Host "❌ Erreur API publique: $($publicRooms.Error)" -ForegroundColor Red
}

# Test 6: Vérifier les pages web
Write-Host "`n📋 Test 6: Vérification des pages web" -ForegroundColor Yellow

try {
    $homePage = Invoke-WebRequest -Uri "$baseUrl" -Method GET
    if ($homePage.StatusCode -eq 200) {
        Write-Host "✅ Page d'accueil accessible" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur page d'accueil: $($homePage.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur page d'accueil: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    $adminPage = Invoke-WebRequest -Uri "$baseUrl/admin/rooms" -Method GET
    if ($adminPage.StatusCode -eq 200) {
        Write-Host "✅ Page admin accessible" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur page admin: $($adminPage.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur page admin: $($_.Exception.Message)" -ForegroundColor Red
}

# Résumé final
Write-Host "`n🎯 Résumé des tests de correction" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

$totalTests = 6
$successfulTests = 0

# Compter les tests réussis
if ($adminRooms.Success) { $successfulTests++ }
if ($roomId -and $updateResult.Success) { $successfulTests++ }
if ($roomId -and $toggleResult.Success) { $successfulTests++ }
if ($roomId -and $toggleResult.Success) { $successfulTests++ }
if ($publicRooms.Success) { $successfulTests++ }

Write-Host "Tests réussis: $successfulTests/$totalTests" -ForegroundColor $(if ($successfulTests -eq $totalTests) { "Green" } else { "Yellow" })

if ($successfulTests -eq $totalTests) {
    Write-Host "`n🎉 Toutes les corrections sont fonctionnelles !" -ForegroundColor Green
    Write-Host "Le système de gestion des salles est maintenant entièrement opérationnel." -ForegroundColor Green
} else {
    Write-Host "`n⚠️  Certains tests ont échoué. Vérifiez les erreurs ci-dessus." -ForegroundColor Yellow
}

Write-Host "`n📝 URLs de test:" -ForegroundColor Cyan
Write-Host "   Site principal: $baseUrl" -ForegroundColor Gray
Write-Host "   Back-office: $baseUrl/admin/rooms" -ForegroundColor Gray
Write-Host "   API publique: $baseUrl/api/rooms" -ForegroundColor Gray
Write-Host "   API admin: $baseUrl/api/admin/rooms" -ForegroundColor Gray

