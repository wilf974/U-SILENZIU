# Script de test pour vérifier le système de notifications automatiques CRON
Write-Host "=== Test du système de notifications automatiques CRON ===" -ForegroundColor Green

# Test 1: Vérifier le statut du service CRON
Write-Host "`n1. Vérification du statut du service CRON..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/admin/cron/status" -Method GET
    if ($response.success) {
        Write-Host "✅ Statut récupéré avec succès" -ForegroundColor Green
        Write-Host "   Initialisé: $($response.status.isInitialized)" -ForegroundColor Cyan
        Write-Host "   Actif: $($response.status.isActive)" -ForegroundColor Cyan
        if ($response.status.nextExecution) {
            Write-Host "   Prochaine exécution: $($response.status.nextExecution)" -ForegroundColor Cyan
        }
        if ($response.status.lastExecution) {
            Write-Host "   Dernière exécution: $($response.status.lastExecution)" -ForegroundColor Cyan
        }
    } else {
        Write-Host "❌ Erreur: $($response.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Démarrer le service CRON
Write-Host "`n2. Démarrage du service CRON..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/admin/cron/start" -Method POST
    if ($response.success) {
        Write-Host "✅ Service CRON démarré avec succès" -ForegroundColor Green
        Write-Host "   Message: $($response.message)" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Erreur: $($response.message)" -ForegroundColor Red
        Write-Host "   Vérifiez que la configuration SMTP est correcte" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Vérifier le statut après démarrage
Write-Host "`n3. Vérification du statut après démarrage..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/admin/cron/status" -Method GET
    if ($response.success) {
        Write-Host "✅ Statut mis à jour" -ForegroundColor Green
        Write-Host "   Initialisé: $($response.status.isInitialized)" -ForegroundColor Cyan
        Write-Host "   Actif: $($response.status.isActive)" -ForegroundColor Cyan
        if ($response.status.nextExecution) {
            Write-Host "   Prochaine exécution: $($response.status.nextExecution)" -ForegroundColor Cyan
        }
    } else {
        Write-Host "❌ Erreur: $($response.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Test d'exécution forcée des notifications
Write-Host "`n4. Test d'exécution forcée des notifications..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/admin/cron/test" -Method POST
    if ($response.success) {
        Write-Host "✅ Test d'exécution terminé" -ForegroundColor Green
        Write-Host "   Message: $($response.message)" -ForegroundColor Cyan
        Write-Host "   Vérifiez les logs de l'application pour les détails" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Erreur: $($response.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Vérifier les réservations disponibles
Write-Host "`n5. Vérification des réservations disponibles..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/reservations" -Method GET
    if ($response) {
        $confirmedReservations = $response | Where-Object { $_.status -eq "confirmed" }
        Write-Host "✅ Réservations récupérées" -ForegroundColor Green
        Write-Host "   Total: $($response.Count)" -ForegroundColor Cyan
        Write-Host "   Confirmées: $($confirmedReservations.Count)" -ForegroundColor Cyan
        
        if ($confirmedReservations.Count -gt 0) {
            Write-Host "   Réservations confirmées disponibles pour les notifications" -ForegroundColor Green
        } else {
            Write-Host "   Aucune réservation confirmée disponible" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ Aucune réservation trouvée" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Vérifier la configuration SMTP
Write-Host "`n6. Vérification de la configuration SMTP..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/admin/smtp/status" -Method GET
    if ($response.success) {
        Write-Host "✅ Configuration SMTP vérifiée" -ForegroundColor Green
        Write-Host "   Statut: $($response.status)" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Erreur: $($response.message)" -ForegroundColor Red
        Write-Host "   Configurez SMTP dans /admin/smtp avant d'utiliser les notifications" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Test terminé ===" -ForegroundColor Green
Write-Host "`nInstructions:" -ForegroundColor Yellow
Write-Host "1. Accédez à http://localhost:3000/admin/notifications pour gérer les notifications" -ForegroundColor White
Write-Host "2. Configurez SMTP dans http://localhost:3000/admin/smtp si nécessaire" -ForegroundColor White
Write-Host "3. Vérifiez les logs Docker avec 'docker-compose logs --tail=50'" -ForegroundColor White
Write-Host "4. Les notifications s'exécutent automatiquement tous les jours à 9h00" -ForegroundColor White
