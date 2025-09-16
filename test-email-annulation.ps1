# Script de test pour le système d'emails d'annulation
Write-Host "=== Test du système d'emails d'annulation ===" -ForegroundColor Green

# Test 1: Créer une réservation
Write-Host "`n1. Création d'une réservation de test..." -ForegroundColor Yellow
$testData = @{
    firstName = "Test"
    lastName = "Annulation"
    email = "jean.maillot14@gmail.com"
    phone = "0123456789"
    date = "2025-01-15"
    timeSlot = "14:00 - 14:30"
    duration = 30
    numberOfPeople = 2
    formula = "standard"
    roomName = "Salle Défoulement"
} | ConvertTo-Json

try {
    $reservation = Invoke-RestMethod -Uri "http://localhost:3000/api/reservations" -Method POST -Body $testData -ContentType "application/json"
    Write-Host "✅ Réservation créée avec succès !" -ForegroundColor Green
    Write-Host "   ID: $($reservation.id)"
    Write-Host "   Numéro: $($reservation.reservation_number)"
    Write-Host "   Statut initial: $($reservation.status)"
} catch {
    Write-Host "❌ Erreur lors de la création de la réservation:" -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit 1
}

# Test 2: Annuler la réservation (cela devrait déclencher l'email d'annulation)
Write-Host "`n2. Annulation de la réservation..." -ForegroundColor Yellow
$cancelData = @{ status = "cancelled" } | ConvertTo-Json

try {
    $cancelledReservation = Invoke-RestMethod -Uri "http://localhost:3000/api/admin/reservations/$($reservation.id)" -Method PUT -Body $cancelData -ContentType "application/json"
    Write-Host "✅ Réservation annulée avec succès !" -ForegroundColor Green
    Write-Host "   Nouveau statut: $($cancelledReservation.data.status)"
} catch {
    Write-Host "❌ Erreur lors de l'annulation de la réservation:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Test 3: Vérifier les logs pour voir si l'email d'annulation a été envoyé
Write-Host "`n3. Vérification des logs..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
Write-Host "Logs du conteneur (dernières 20 lignes):"
docker logs u-silenziu-app --tail 20

# Test 4: Nettoyer - supprimer la réservation de test
Write-Host "`n4. Nettoyage - suppression de la réservation de test..." -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri "http://localhost:3000/api/admin/reservations/$($reservation.id)" -Method DELETE
    Write-Host "✅ Réservation de test supprimée" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Impossible de supprimer la réservation de test: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "`n=== Fin du test ===" -ForegroundColor Green
