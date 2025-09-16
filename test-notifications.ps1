# Script de test pour les notifications SMTP
# Utilisation: .\test-notifications.ps1

Write-Host "=== Test des Notifications SMTP U Silenziu ===" -ForegroundColor Green
Write-Host ""

# URL de base
$baseUrl = "http://localhost:3000"

# Test 1: Verifier le statut SMTP
Write-Host "1. Verification du statut SMTP..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/admin/smtp/status" -Method GET
    if ($response.success) {
        Write-Host "   [OK] SMTP connecte: $($response.message)" -ForegroundColor Green
    } else {
        Write-Host "   [ERREUR] Erreur SMTP: $($response.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "   [ERREUR] Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 2: Recuperer les reservations prevues
Write-Host "2. Recuperation des reservations prevues..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/notifications/send" -Method GET
    if ($response.success) {
        Write-Host "   [OK] Reservations trouvees: $($response.reservations.Count)" -ForegroundColor Green
        if ($response.reservations.Count -gt 0) {
            Write-Host "   [INFO] Details des reservations:" -ForegroundColor Cyan
            foreach ($reservation in $response.reservations) {
                Write-Host "      - $($reservation.reservationNumber): $($reservation.firstName) $($reservation.lastName) ($($reservation.roomName)) - $($reservation.date) $($reservation.timeSlot)" -ForegroundColor White
            }
        }
    } else {
        Write-Host "   [ERREUR] Erreur: $($response.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "   [ERREUR] Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Envoyer les notifications (optionnel)
Write-Host "3. Test d'envoi des notifications..." -ForegroundColor Yellow
$sendNotifications = Read-Host "   Voulez-vous envoyer les notifications de test ? (y/N)"
if ($sendNotifications -eq "y" -or $sendNotifications -eq "Y") {
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/api/notifications/send" -Method POST
        if ($response.success) {
            Write-Host "   [OK] Notifications envoyees: $($response.sentCount)/$($response.totalReservations)" -ForegroundColor Green
            if ($response.errors) {
                Write-Host "   [ATTENTION] Erreurs:" -ForegroundColor Yellow
                foreach ($err in $response.errors) {
                    Write-Host "      - $err" -ForegroundColor Red
                }
            }
        } else {
            Write-Host "   [ERREUR] Erreur: $($response.message)" -ForegroundColor Red
        }
    } catch {
        Write-Host "   [ERREUR] Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "   [IGNORE] Test d'envoi ignore" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=== Test termine ===" -ForegroundColor Green
