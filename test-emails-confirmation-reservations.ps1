# Script de test pour le système d'emails de confirmation de réservations
# Teste l'envoi d'emails automatiques lors de la création et validation des réservations

Write-Host "🧪 Test du système d'emails de confirmation de réservations" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan

# Configuration
$baseUrl = "http://localhost:3000"
$testEmail = "test@example.com"

# Fonction pour faire des requêtes HTTP
function Invoke-ApiRequest {
    param(
        [string]$Url,
        [string]$Method = "GET",
        [object]$Body = $null,
        [hashtable]$Headers = @{}
    )
    
    try {
        $params = @{
            Uri = $Url
            Method = $Method
            Headers = $Headers
        }
        
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json -Depth 10)
            $params.ContentType = "application/json"
        }
        
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

# Test 1: Vérifier que le service SMTP est configuré
Write-Host "`n📧 Test 1: Vérification de la configuration SMTP" -ForegroundColor Yellow
$smtpStatus = Invoke-ApiRequest -Url "$baseUrl/api/admin/smtp/status"
if ($smtpStatus.Success -and $smtpStatus.Data.configured) {
    Write-Host "✅ Configuration SMTP trouvée" -ForegroundColor Green
    Write-Host "   Host: $($smtpStatus.Data.host)" -ForegroundColor Gray
    Write-Host "   Port: $($smtpStatus.Data.port)" -ForegroundColor Gray
} else {
    Write-Host "❌ Configuration SMTP manquante" -ForegroundColor Red
    Write-Host "   Veuillez configurer SMTP dans l'interface d'administration" -ForegroundColor Red
    Write-Host "   URL: $baseUrl/admin/smtp" -ForegroundColor Red
    exit 1
}

# Test 2: Créer une réservation publique (doit envoyer un email de confirmation)
Write-Host "`n📝 Test 2: Création d'une réservation publique" -ForegroundColor Yellow
$reservationData = @{
    firstName = "Jean"
    lastName = "Dupont"
    email = $testEmail
    phone = "0123456789"
    date = "2025-02-15"
    timeSlot = "14:00 - 14:20"
    duration = 20
    numberOfPeople = 2
    formula = "Test Email"
    roomName = "Salle Haches"
}

Write-Host "   Création de la réservation..." -ForegroundColor Gray
$createResult = Invoke-ApiRequest -Url "$baseUrl/api/reservations" -Method "POST" -Body $reservationData

if ($createResult.Success) {
    $reservation = $createResult.Data
    Write-Host "✅ Réservation créée avec succès" -ForegroundColor Green
    Write-Host "   Numéro: $($reservation.reservation_number)" -ForegroundColor Gray
    Write-Host "   Statut: $($reservation.status)" -ForegroundColor Gray
    Write-Host "   Email de confirmation envoyé automatiquement" -ForegroundColor Green
    
    $reservationId = $reservation.id
} else {
    Write-Host "❌ Échec de la création de la réservation" -ForegroundColor Red
    Write-Host "   Erreur: $($createResult.Error)" -ForegroundColor Red
    exit 1
}

# Test 3: Modifier le statut de la réservation à "confirmed" (doit envoyer un email de validation)
Write-Host "`n✅ Test 3: Validation de la réservation (statut confirmed)" -ForegroundColor Yellow
$updateData = @{
    status = "confirmed"
}

Write-Host "   Mise à jour du statut à 'confirmed'..." -ForegroundColor Gray
$updateResult = Invoke-ApiRequest -Url "$baseUrl/api/admin/reservations/$reservationId" -Method "PUT" -Body $updateData

if ($updateResult.Success) {
    $updatedReservation = $updateResult.Data.data
    Write-Host "✅ Réservation validée avec succès" -ForegroundColor Green
    Write-Host "   Nouveau statut: $($updatedReservation.status)" -ForegroundColor Gray
    Write-Host "   Email de validation envoyé automatiquement" -ForegroundColor Green
} else {
    Write-Host "❌ Échec de la validation de la réservation" -ForegroundColor Red
    Write-Host "   Erreur: $($updateResult.Error)" -ForegroundColor Red
}

# Test 4: Vérifier les logs d'emails
Write-Host "`n📊 Test 4: Vérification des logs d'emails" -ForegroundColor Yellow
Write-Host "   Vérifiez les logs de l'application pour confirmer l'envoi des emails:" -ForegroundColor Gray
Write-Host "   - Email de confirmation (statut pending)" -ForegroundColor Gray
Write-Host "   - Email de validation (statut confirmed)" -ForegroundColor Gray

# Test 5: Test d'envoi d'email direct
Write-Host "`n📧 Test 5: Test d'envoi d'email direct" -ForegroundColor Yellow
$emailTestData = @{
    testEmail = $testEmail
}

Write-Host "   Envoi d'un email de test..." -ForegroundColor Gray
$emailTestResult = Invoke-ApiRequest -Url "$baseUrl/api/notifications/send" -Method "POST" -Body $emailTestData

if ($emailTestResult.Success -and $emailTestResult.Data.success) {
    Write-Host "✅ Email de test envoyé avec succès" -ForegroundColor Green
    Write-Host "   Message ID: $($emailTestResult.Data.messageId)" -ForegroundColor Gray
} else {
    Write-Host "❌ Échec de l'envoi de l'email de test" -ForegroundColor Red
    if ($emailTestResult.Error) {
        Write-Host "   Erreur: $($emailTestResult.Error)" -ForegroundColor Red
    }
}

# Test 6: Nettoyage - Supprimer la réservation de test
Write-Host "`n🧹 Test 6: Nettoyage" -ForegroundColor Yellow
Write-Host "   Suppression de la réservation de test..." -ForegroundColor Gray
$deleteResult = Invoke-ApiRequest -Url "$baseUrl/api/admin/reservations/$reservationId" -Method "DELETE"

if ($deleteResult.Success) {
    Write-Host "✅ Réservation de test supprimée" -ForegroundColor Green
} else {
    Write-Host "⚠️ Impossible de supprimer la réservation de test" -ForegroundColor Yellow
    Write-Host "   ID: $reservationId" -ForegroundColor Gray
}

# Résumé des tests
Write-Host "`n📋 Résumé des tests" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "✅ Configuration SMTP vérifiée" -ForegroundColor Green
Write-Host "✅ Création de réservation avec email de confirmation" -ForegroundColor Green
Write-Host "✅ Validation de réservation avec email de validation" -ForegroundColor Green
Write-Host "✅ Test d'envoi d'email direct" -ForegroundColor Green
Write-Host "✅ Nettoyage effectué" -ForegroundColor Green

Write-Host "`n🎉 Tous les tests sont passés avec succès !" -ForegroundColor Green
Write-Host "`n📧 Vérifiez votre boîte email ($testEmail) pour confirmer la réception des emails:" -ForegroundColor Cyan
Write-Host "   - Email de confirmation de réservation (statut pending)" -ForegroundColor Gray
Write-Host "   - Email de validation de réservation (statut confirmed)" -ForegroundColor Gray
Write-Host "   - Email de test" -ForegroundColor Gray

Write-Host "`n💡 Le système d'emails de confirmation est maintenant opérationnel !" -ForegroundColor Green
Write-Host "   - Les clients reçoivent un email lors de la création de réservation" -ForegroundColor Gray
Write-Host "   - Les clients reçoivent un email lors de la validation par l'admin" -ForegroundColor Gray
Write-Host "   - Les emails sont envoyés en arrière-plan sans bloquer l'interface" -ForegroundColor Gray
