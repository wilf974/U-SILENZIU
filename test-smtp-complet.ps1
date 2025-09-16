# Test complet de la configuration SMTP - U Silenziu
Write-Host "=== Test complet de la configuration SMTP U Silenziu ===" -ForegroundColor Cyan
Write-Host ""

# Configuration SMTP pour Office 365
$smtpConfig = @{
    host = "smtp-mail.outlook.com"
    port = 587
    secure = $false
    username = "imprimante@divabox.net"
    password = "divabox20090@"
    tlsRejectUnauthorized = $true
    tlsMinVersion = "TLSv1.2"
}

Write-Host "1. Test de sauvegarde de la configuration SMTP..." -ForegroundColor Yellow
try {
    $saveResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/admin/smtp/save" -Method POST -ContentType "application/json" -Body ($smtpConfig | ConvertTo-Json)
    if ($saveResponse.success) {
        Write-Host "   ✅ Configuration SMTP sauvegardée avec succès" -ForegroundColor Green
        Write-Host "   📧 Hôte: $($saveResponse.config.host)" -ForegroundColor Gray
        Write-Host "   🔌 Port: $($saveResponse.config.port)" -ForegroundColor Gray
        Write-Host "   👤 Utilisateur: $($saveResponse.config.username)" -ForegroundColor Gray
    } else {
        Write-Host "   ❌ Erreur lors de la sauvegarde: $($saveResponse.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erreur de connexion lors de la sauvegarde: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Test de connexion SMTP..." -ForegroundColor Yellow
try {
    $testResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/admin/smtp/test" -Method POST -ContentType "application/json" -Body ($smtpConfig | ConvertTo-Json)
    if ($testResponse.success) {
        Write-Host "   ✅ Connexion SMTP réussie" -ForegroundColor Green
        Write-Host "   📡 Message: $($testResponse.message)" -ForegroundColor Gray
    } else {
        Write-Host "   ❌ Erreur de connexion: $($testResponse.message)" -ForegroundColor Red
        if ($testResponse.error) {
            Write-Host "   🔍 Détails: $($testResponse.error)" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "   ❌ Erreur lors du test de connexion: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Vérification du statut SMTP..." -ForegroundColor Yellow
try {
    $statusResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/admin/smtp/status" -Method GET
    if ($statusResponse.configured) {
        Write-Host "   ✅ Configuration SMTP présente" -ForegroundColor Green
        Write-Host "   📧 Hôte: $($statusResponse.host)" -ForegroundColor Gray
        Write-Host "   🔌 Port: $($statusResponse.port)" -ForegroundColor Gray
        if ($statusResponse.success) {
            Write-Host "   🔗 Connexion active" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ Connexion échouée: $($statusResponse.error)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ❌ Aucune configuration SMTP trouvée" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erreur lors de la vérification du statut: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Test d'envoi d'email..." -ForegroundColor Yellow
try {
    $emailData = @{
        testEmail = "imprimante@divabox.net"
        message = "Test d'envoi d'email depuis U Silenziu - $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')"
    }
    
    $emailResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/notifications/send" -Method POST -ContentType "application/json" -Body ($emailData | ConvertTo-Json)
    if ($emailResponse.success) {
        Write-Host "   ✅ Email de test envoyé avec succès" -ForegroundColor Green
        Write-Host "   📧 Message ID: $($emailResponse.messageId)" -ForegroundColor Gray
        Write-Host "   ⏰ Timestamp: $($emailResponse.timestamp)" -ForegroundColor Gray
    } else {
        Write-Host "   ❌ Erreur lors de l'envoi: $($emailResponse.message)" -ForegroundColor Red
        if ($emailResponse.error) {
            Write-Host "   🔍 Détails: $($emailResponse.error)" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "   ❌ Erreur lors de l'envoi d'email: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "5. Test de la page de test complète..." -ForegroundColor Yellow
try {
    $testPageResponse = Invoke-WebRequest -Uri "http://localhost:3000/test" -Method GET
    if ($testPageResponse.StatusCode -eq 200) {
        Write-Host "   ✅ Page de test accessible" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Page de test non accessible (Status: $($testPageResponse.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erreur d'accès à la page de test: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Résumé des tests ===" -ForegroundColor Cyan
Write-Host "📧 Configuration SMTP: $($smtpConfig.host):$($smtpConfig.port)" -ForegroundColor White
Write-Host "👤 Utilisateur: $($smtpConfig.username)" -ForegroundColor White
Write-Host "🔐 Mot de passe: $($smtpConfig.password)" -ForegroundColor White
Write-Host ""
Write-Host "💡 Conseils de dépannage:" -ForegroundColor Yellow
Write-Host "   • Vérifiez que le mot de passe est correct" -ForegroundColor Gray
Write-Host "   • Pour Office 365, utilisez un mot de passe d'application si l'authentification à 2 facteurs est activée" -ForegroundColor Gray
Write-Host "   • Vérifiez que les ports SMTP ne sont pas bloqués par votre antivirus ou fournisseur d'accès" -ForegroundColor Gray
Write-Host "   • Consultez la page de test complète: http://localhost:3000/test" -ForegroundColor Gray
Write-Host ""
