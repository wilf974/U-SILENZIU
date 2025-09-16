# Script de test pour le système de gestion des salles
# Test complet du CRUD des salles

Write-Host "🧪 Test du système de gestion des salles U Silenziu" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

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

# Test 1: Vérifier que l'API publique fonctionne
Write-Host "`n📋 Test 1: API publique des salles" -ForegroundColor Yellow
$publicRooms = Invoke-TestRequest -Method "GET" -Url "$baseUrl/api/rooms"

if ($publicRooms.Success) {
    Write-Host "✅ API publique fonctionnelle" -ForegroundColor Green
    Write-Host "   Salles actives: $($publicRooms.Data.count)" -ForegroundColor Gray
} else {
    Write-Host "❌ Erreur API publique: $($publicRooms.Error)" -ForegroundColor Red
}

# Test 2: Vérifier que l'API admin fonctionne
Write-Host "`n📋 Test 2: API admin des salles" -ForegroundColor Yellow
$adminRooms = Invoke-TestRequest -Method "GET" -Url "$baseUrl/api/admin/rooms"

if ($adminRooms.Success) {
    Write-Host "✅ API admin fonctionnelle" -ForegroundColor Green
    Write-Host "   Total salles: $($adminRooms.Data.count)" -ForegroundColor Gray
} else {
    Write-Host "❌ Erreur API admin: $($adminRooms.Error)" -ForegroundColor Red
}

# Test 3: Créer une nouvelle salle
Write-Host "`n📋 Test 3: Création d'une nouvelle salle" -ForegroundColor Yellow
$newRoom = @{
    name = "Salle Test"
    subtitle = "Test de création"
    duration = 45
    price = 60
    description = "Salle de test pour validation du système"
    maxPeople = 6
    objectsToDestroy = @("verres", "assiettes", "bouteilles")
    included = @("équipement", "protection", "encadrement")
    imageUrl = ""
    isActive = $true
}

$createResult = Invoke-TestRequest -Method "POST" -Url "$baseUrl/api/admin/rooms" -Body $newRoom

if ($createResult.Success) {
    Write-Host "✅ Salle créée avec succès" -ForegroundColor Green
    $roomId = $createResult.Data.data.id
    Write-Host "   ID de la salle: $roomId" -ForegroundColor Gray
} else {
    Write-Host "❌ Erreur création: $($createResult.Error)" -ForegroundColor Red
    $roomId = $null
}

# Test 4: Récupérer la salle créée
if ($roomId) {
    Write-Host "`n📋 Test 4: Récupération de la salle créée" -ForegroundColor Yellow
    $getRoom = Invoke-TestRequest -Method "GET" -Url "$baseUrl/api/admin/rooms/$roomId"
    
    if ($getRoom.Success) {
        Write-Host "✅ Salle récupérée avec succès" -ForegroundColor Green
        Write-Host "   Nom: $($getRoom.Data.data.name)" -ForegroundColor Gray
        Write-Host "   Prix: $($getRoom.Data.data.price)€" -ForegroundColor Gray
    } else {
        Write-Host "❌ Erreur récupération: $($getRoom.Error)" -ForegroundColor Red
    }
}

# Test 5: Modifier la salle
if ($roomId) {
    Write-Host "`n📋 Test 5: Modification de la salle" -ForegroundColor Yellow
    $updateData = @{
        price = 75
        description = "Salle de test modifiée"
    }
    
    $updateResult = Invoke-TestRequest -Method "PUT" -Url "$baseUrl/api/admin/rooms/$roomId" -Body $updateData
    
    if ($updateResult.Success) {
        Write-Host "✅ Salle modifiée avec succès" -ForegroundColor Green
        Write-Host "   Nouveau prix: $($updateResult.Data.data.price)€" -ForegroundColor Gray
    } else {
        Write-Host "❌ Erreur modification: $($updateResult.Error)" -ForegroundColor Red
    }
}

# Test 6: Basculer le statut de la salle
if ($roomId) {
    Write-Host "`n📋 Test 6: Basculement du statut" -ForegroundColor Yellow
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
    }
}

# Test 7: Vérifier que la salle inactive n'apparaît plus dans l'API publique
if ($roomId) {
    Write-Host "`n📋 Test 7: Vérification API publique après désactivation" -ForegroundColor Yellow
    $publicRoomsAfter = Invoke-TestRequest -Method "GET" -Url "$baseUrl/api/rooms"
    
    if ($publicRoomsAfter.Success) {
        $testRoomInPublic = $publicRoomsAfter.Data.data | Where-Object { $_.id -eq $roomId }
        if ($testRoomInPublic) {
            Write-Host "❌ La salle inactive apparaît encore dans l'API publique" -ForegroundColor Red
        } else {
            Write-Host "✅ La salle inactive ne apparaît plus dans l'API publique" -ForegroundColor Green
        }
    } else {
        Write-Host "❌ Erreur vérification API publique: $($publicRoomsAfter.Error)" -ForegroundColor Red
    }
}

# Test 8: Réactiver la salle
if ($roomId) {
    Write-Host "`n📋 Test 8: Réactivation de la salle" -ForegroundColor Yellow
    $toggleData = @{
        action = "toggle"
    }
    
    $toggleResult = Invoke-TestRequest -Method "PATCH" -Url "$baseUrl/api/admin/rooms/$roomId" -Body $toggleData
    
    if ($toggleResult.Success) {
        Write-Host "✅ Salle réactivée avec succès" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur réactivation: $($toggleResult.Error)" -ForegroundColor Red
    }
}

# Test 9: Supprimer la salle de test
if ($roomId) {
    Write-Host "`n📋 Test 9: Suppression de la salle de test" -ForegroundColor Yellow
    $deleteResult = Invoke-TestRequest -Method "DELETE" -Url "$baseUrl/api/admin/rooms/$roomId"
    
    if ($deleteResult.Success) {
        Write-Host "✅ Salle supprimée avec succès" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur suppression: $($deleteResult.Error)" -ForegroundColor Red
    }
}

# Test 10: Vérifier que la salle supprimée n'existe plus
if ($roomId) {
    Write-Host "`n📋 Test 10: Vérification de la suppression" -ForegroundColor Yellow
    $getDeletedRoom = Invoke-TestRequest -Method "GET" -Url "$baseUrl/api/admin/rooms/$roomId"
    
    if ($getDeletedRoom.Success) {
        Write-Host "❌ La salle supprimée existe encore" -ForegroundColor Red
    } else {
        Write-Host "✅ La salle supprimée n'existe plus (404 attendu)" -ForegroundColor Green
    }
}

# Test 11: Vérifier les pages web
Write-Host "`n📋 Test 11: Vérification des pages web" -ForegroundColor Yellow

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
Write-Host "`n🎯 Résumé des tests" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan

$totalTests = 11
$successfulTests = 0

# Compter les tests réussis (simplifié)
if ($publicRooms.Success) { $successfulTests++ }
if ($adminRooms.Success) { $successfulTests++ }
if ($createResult.Success) { $successfulTests++ }
if ($roomId -and $getRoom.Success) { $successfulTests++ }
if ($roomId -and $updateResult.Success) { $successfulTests++ }
if ($roomId -and $toggleResult.Success) { $successfulTests++ }
if ($roomId -and $publicRoomsAfter.Success) { $successfulTests++ }
if ($roomId -and $toggleResult.Success) { $successfulTests++ }
if ($roomId -and $deleteResult.Success) { $successfulTests++ }
if ($roomId -and -not $getDeletedRoom.Success) { $successfulTests++ }

Write-Host "Tests réussis: $successfulTests/$totalTests" -ForegroundColor $(if ($successfulTests -eq $totalTests) { "Green" } else { "Yellow" })

if ($successfulTests -eq $totalTests) {
    Write-Host "`n🎉 Tous les tests sont passés avec succès !" -ForegroundColor Green
    Write-Host "Le système de gestion des salles est entièrement fonctionnel." -ForegroundColor Green
} else {
    Write-Host "`n⚠️  Certains tests ont échoué. Vérifiez les erreurs ci-dessus." -ForegroundColor Yellow
}

Write-Host "`n📝 URLs de test:" -ForegroundColor Cyan
Write-Host "   Site principal: $baseUrl" -ForegroundColor Gray
Write-Host "   Back-office: $baseUrl/admin/rooms" -ForegroundColor Gray
Write-Host "   API publique: $baseUrl/api/rooms" -ForegroundColor Gray
Write-Host "   API admin: $baseUrl/api/admin/rooms" -ForegroundColor Gray

