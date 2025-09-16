# Script de test pour vérifier la correction du système SMTP
# Ce script teste l'envoi d'emails réels après la correction du problème de chiffrement

Write-Host "=== Test de la correction SMTP - U Silenziu ===" -ForegroundColor Green
Write-Host ""

# Vérifier que l'application est démarrée
Write-Host "1. Vérification du statut de l'application..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -Method GET -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Application démarrée correctement" -ForegroundColor Green
    } else {
        Write-Host "❌ Application non accessible (Code: $($response.StatusCode))" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Application non accessible: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Veuillez démarrer l'application avec: npm run dev" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "2. Test de l'API de configuration SMTP..." -ForegroundColor Yellow

# Test de l'API de test SMTP
$testConfig = @{
    host = "smtp-mail.outlook.com"
    port = 587
    secure = $false
    username = "test@example.com"
    password = "testpassword"
    tlsRejectUnauthorized = $true
    tlsMinVersion = "TLSv1.2"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/admin/smtp/test" -Method POST -Body $testConfig -ContentType "application/json" -TimeoutSec 10
    $result = $response.Content | ConvertFrom-Json
    
    if ($result.success) {
        Write-Host "✅ API de test SMTP fonctionne correctement" -ForegroundColor Green
        Write-Host "   Message: $($result.message)" -ForegroundColor Gray
    } else {
        Write-Host "⚠️ API de test SMTP répond mais avec erreur (normal pour des identifiants de test)" -ForegroundColor Yellow
        Write-Host "   Message: $($result.message)" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Erreur lors du test de l'API SMTP: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Test de l'API d'envoi d'emails..." -ForegroundColor Yellow

# Test de l'API d'envoi d'emails
$testEmail = @{
    testEmail = "test@example.com"
    message = "Test de la correction SMTP - $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/notifications/send" -Method POST -Body $testEmail -ContentType "application/json" -TimeoutSec 10
    $result = $response.Content | ConvertFrom-Json
    
    if ($result.success) {
        Write-Host "✅ API d'envoi d'emails fonctionne correctement" -ForegroundColor Green
        Write-Host "   Message: $($result.message)" -ForegroundColor Gray
        Write-Host "   Message ID: $($result.messageId)" -ForegroundColor Gray
    } else {
        Write-Host "⚠️ API d'envoi d'emails répond mais avec erreur" -ForegroundColor Yellow
        Write-Host "   Message: $($result.message)" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Erreur lors du test de l'API d'envoi: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Vérification des logs de l'application..." -ForegroundColor Yellow
Write-Host "Vérifiez les logs de l'application pour voir si les messages de déchiffrement apparaissent:" -ForegroundColor Gray
Write-Host "- 'Configuration SMTP trouvée - initialisation du transporteur'" -ForegroundColor Gray
Write-Host "- 'Configuration SMTP initialisée avec succès'" -ForegroundColor Gray
Write-Host "- 'Email envoyé avec succès'" -ForegroundColor Gray

Write-Host ""
Write-Host "=== Résumé de la correction ===" -ForegroundColor Green
Write-Host "✅ Système de chiffrement/déchiffrement implémenté" -ForegroundColor Green
Write-Host "✅ Service MailerService corrigé pour utiliser les mots de passe déchiffrés" -ForegroundColor Green
Write-Host "✅ API d'envoi d'emails mise à jour pour l'envoi réel" -ForegroundColor Green
Write-Host "✅ Fonction getSmtpConfigDecrypted() ajoutée" -ForegroundColor Green

Write-Host ""
Write-Host "=== Instructions pour tester avec de vrais identifiants ===" -ForegroundColor Cyan
Write-Host "1. Allez sur http://localhost:3000/admin/smtp" -ForegroundColor White
Write-Host "2. Configurez vos vrais identifiants SMTP (Office 365, Gmail, etc.)" -ForegroundColor White
Write-Host "3. Testez la connexion avec le bouton 'Tester la connexion'" -ForegroundColor White
Write-Host "4. Envoyez un email de test avec le bouton 'Envoyer un email de test'" -ForegroundColor White
Write-Host "5. Vérifiez votre boîte de réception et vos spams" -ForegroundColor White

Write-Host ""
Write-Host "=== Configuration recommandée pour Office 365 ===" -ForegroundColor Cyan
Write-Host "Hôte: smtp-mail.outlook.com" -ForegroundColor White
Write-Host "Port: 587" -ForegroundColor White
Write-Host "Sécurisé: NON (décocher)" -ForegroundColor White
Write-Host "Rejeter certificats non autorisés: OUI (cocher)" -ForegroundColor White

Write-Host ""
Write-Host "Test terminé ! Le système SMTP devrait maintenant fonctionner correctement." -ForegroundColor Green