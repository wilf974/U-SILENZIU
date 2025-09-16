# Test simple des emails de réservation
Write-Host "🧪 Test simple des emails de réservation" -ForegroundColor Cyan

$baseUrl = "http://localhost:3000"
$testEmail = "jean.maillot14@gmail.com"

# Test 1: Email de test SMTP
Write-Host "`n📧 Test 1: Email de test SMTP" -ForegroundColor Yellow
$testData = @{ testEmail = $testEmail } | ConvertTo-Json
try {
    $result = Invoke-RestMethod -Uri "$baseUrl/api/notifications/send" -Method POST -Body $testData -ContentType "application/json"
    if ($result.success) {
        Write-Host "✅ Email de test envoyé: $($result.messageId)" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Erreur email de test: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Création réservation
Write-Host "`n📝 Test 2: Création réservation" -ForegroundColor Yellow
$reservationData = @{
    firstName = "Test"
    lastName = "Email"
    email = $testEmail
    phone = "0123456789"
    date = "2025-02-19"
    timeSlot = "18:00 - 18:20"
    duration = 20
    numberOfPeople = 2
    formula = "Test Email"
    roomName = "Salle Haches"
} | ConvertTo-Json

try {
    $reservation = Invoke-RestMethod -Uri "$baseUrl/api/reservations" -Method POST -Body $reservationData -ContentType "application/json"
    Write-Host "✅ Réservation créée: $($reservation.reservation_number)" -ForegroundColor Green
    Write-Host "   ID: $($reservation.id)" -ForegroundColor Gray
    
    # Attendre un peu
    Start-Sleep -Seconds 2
    
    # Test 3: Validation réservation
    Write-Host "`n✅ Test 3: Validation réservation" -ForegroundColor Yellow
    $updateData = @{ status = "confirmed" } | ConvertTo-Json
    $updated = Invoke-RestMethod -Uri "$baseUrl/api/admin/reservations/$($reservation.id)" -Method PUT -Body $updateData -ContentType "application/json"
    Write-Host "✅ Réservation validée" -ForegroundColor Green
    
    # Attendre un peu
    Start-Sleep -Seconds 2
    
    # Nettoyage
    Write-Host "`n🧹 Nettoyage" -ForegroundColor Yellow
    Invoke-RestMethod -Uri "$baseUrl/api/admin/reservations/$($reservation.id)" -Method DELETE
    Write-Host "✅ Réservation supprimée" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n💡 Vérifiez les logs de l'application Next.js pour voir les messages d'envoi d'emails" -ForegroundColor Cyan
Write-Host "   Les logs devraient afficher:" -ForegroundColor Gray
Write-Host "   - 📧 Tentative d'envoi de l'email de confirmation" -ForegroundColor Gray
Write-Host "   - ✅ Email de confirmation envoyé avec succès" -ForegroundColor Gray
Write-Host "   - 📧 Tentative d'envoi de l'email de validation" -ForegroundColor Gray
Write-Host "   - ✅ Email de validation envoyé avec succès" -ForegroundColor Gray