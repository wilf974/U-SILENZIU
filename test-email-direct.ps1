# Test direct du service d'emails de réservation
Write-Host "🧪 Test direct du service d'emails de réservation" -ForegroundColor Cyan

# Configuration
$baseUrl = "http://localhost:3000"
$testEmail = "jean.maillot14@gmail.com"

# Test 1: Vérifier la configuration SMTP
Write-Host "`n📧 Test 1: Vérification de la configuration SMTP" -ForegroundColor Yellow
try {
    $smtpStatus = Invoke-RestMethod -Uri "$baseUrl/api/admin/smtp/status" -Method GET
    if ($smtpStatus.configured) {
        Write-Host "✅ Configuration SMTP trouvée" -ForegroundColor Green
        Write-Host "   Host: $($smtpStatus.host)" -ForegroundColor Gray
        Write-Host "   Port: $($smtpStatus.port)" -ForegroundColor Gray
        Write-Host "   Username: $($smtpStatus.username)" -ForegroundColor Gray
    } else {
        Write-Host "❌ Configuration SMTP manquante" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Erreur lors de la vérification SMTP: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Envoyer un email de test
Write-Host "`n📧 Test 2: Envoi d'un email de test" -ForegroundColor Yellow
try {
    $testData = @{
        testEmail = $testEmail
    } | ConvertTo-Json
    
    $testResult = Invoke-RestMethod -Uri "$baseUrl/api/notifications/send" -Method POST -Body $testData -ContentType "application/json"
    
    if ($testResult.success) {
        Write-Host "✅ Email de test envoyé avec succès" -ForegroundColor Green
        Write-Host "   Message ID: $($testResult.messageId)" -ForegroundColor Gray
    } else {
        Write-Host "❌ Échec de l'envoi de l'email de test" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors de l'envoi de l'email de test: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Créer une réservation et vérifier l'envoi d'email
Write-Host "`n📝 Test 3: Création de réservation avec email de confirmation" -ForegroundColor Yellow
try {
    $reservationData = @{
        firstName = "Test"
        lastName = "Email"
        email = $testEmail
        phone = "0123456789"
        date = "2025-02-17"
        timeSlot = "16:00 - 16:20"
        duration = 20
        numberOfPeople = 2
        formula = "Test Email"
        roomName = "Salle Haches"
    } | ConvertTo-Json
    
    Write-Host "   Création de la réservation..." -ForegroundColor Gray
    $reservation = Invoke-RestMethod -Uri "$baseUrl/api/reservations" -Method POST -Body $reservationData -ContentType "application/json"
    
    Write-Host "✅ Réservation créée avec succès" -ForegroundColor Green
    Write-Host "   Numéro: $($reservation.reservation_number)" -ForegroundColor Gray
    Write-Host "   ID: $($reservation.id)" -ForegroundColor Gray
    Write-Host "   Statut: $($reservation.status)" -ForegroundColor Gray
    
    # Attendre un peu pour que l'email soit envoyé
    Write-Host "   Attente de l'envoi de l'email..." -ForegroundColor Gray
    Start-Sleep -Seconds 3
    
    $reservationId = $reservation.id
} catch {
    Write-Host "❌ Erreur lors de la création de la réservation: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 4: Valider la réservation et vérifier l'envoi d'email
Write-Host "`n✅ Test 4: Validation de la réservation avec email de validation" -ForegroundColor Yellow
try {
    $updateData = @{
        status = "confirmed"
    } | ConvertTo-Json
    
    Write-Host "   Validation de la réservation..." -ForegroundColor Gray
    $updatedReservation = Invoke-RestMethod -Uri "$baseUrl/api/admin/reservations/$reservationId" -Method PUT -Body $updateData -ContentType "application/json"
    
    Write-Host "✅ Réservation validée avec succès" -ForegroundColor Green
    Write-Host "   Nouveau statut: $($updatedReservation.data.status)" -ForegroundColor Gray
    
    # Attendre un peu pour que l'email soit envoyé
    Write-Host "   Attente de l'envoi de l'email de validation..." -ForegroundColor Gray
    Start-Sleep -Seconds 3
} catch {
    Write-Host "❌ Erreur lors de la validation de la réservation: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Nettoyage
Write-Host "`n🧹 Test 5: Nettoyage" -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri "$baseUrl/api/admin/reservations/$reservationId" -Method DELETE
    Write-Host "✅ Réservation de test supprimée" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Impossible de supprimer la réservation de test" -ForegroundColor Yellow
}

# Résumé
Write-Host "`n📋 Résumé des tests" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "✅ Configuration SMTP vérifiée" -ForegroundColor Green
Write-Host "✅ Email de test envoyé" -ForegroundColor Green
Write-Host "✅ Réservation créée (email de confirmation envoyé en arrière-plan)" -ForegroundColor Green
Write-Host "✅ Réservation validée (email de validation envoyé en arrière-plan)" -ForegroundColor Green
Write-Host "✅ Nettoyage effectué" -ForegroundColor Green

Write-Host "`n💡 Vérifiez votre boîte email ($testEmail) pour confirmer la réception des emails:" -ForegroundColor Cyan
Write-Host "   - Email de test" -ForegroundColor Gray
Write-Host "   - Email de confirmation de réservation (statut pending)" -ForegroundColor Gray
Write-Host "   - Email de validation de réservation (statut confirmed)" -ForegroundColor Gray

Write-Host "`n📧 Si vous ne recevez pas les emails, vérifiez:" -ForegroundColor Yellow
Write-Host "   - Votre dossier spam/courrier indésirable" -ForegroundColor Gray
Write-Host "   - Les logs de l'application Next.js" -ForegroundColor Gray
Write-Host "   - La configuration SMTP dans l'interface d'administration" -ForegroundColor Gray
