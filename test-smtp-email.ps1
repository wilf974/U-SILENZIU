# Script de test pour vérifier l'envoi d'email de test
Write-Host "=== Test d'envoi d'email de test ===" -ForegroundColor Green

# Configuration SMTP de test
Write-Host "`n1. Configuration SMTP de test..." -ForegroundColor Yellow
$config = @{
    host = "smtp-mail.outlook.com"
    port = 587
    secure = $false
    username = "imprimante@divabox.net"
    password = "votre_mot_de_passe_ici"
    tlsRejectUnauthorized = $true
    tlsMinVersion = "TLSv1.2"
}

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/admin/smtp/save" -Method POST -Body ($config | ConvertTo-Json) -ContentType "application/json"
    if ($response.success) {
        Write-Host "✅ Configuration SMTP sauvegardée" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur: $($response.message)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test de connexion SMTP
Write-Host "`n2. Test de connexion SMTP..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/admin/smtp/test" -Method POST -Body ($config | ConvertTo-Json) -ContentType "application/json"
    if ($response.success) {
        Write-Host "✅ Connexion SMTP réussie" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Test de connexion échoué: $($response.message)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
}

# Test d'envoi d'email de test
Write-Host "`n3. Test d'envoi d'email de test..." -ForegroundColor Yellow
$testEmail = @{
    testEmail = "test@example.com"  # Remplacez par votre email de test
    message = "Ceci est un email de test pour vérifier la configuration SMTP d'U Silenziu."
}

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/notifications/send" -Method POST -Body ($testEmail | ConvertTo-Json) -ContentType "application/json"
    if ($response.success) {
        Write-Host "✅ Email de test envoyé avec succès" -ForegroundColor Green
        Write-Host "   Message: $($response.message)" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Échec de l'envoi: $($response.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
}

# Vérification de la configuration sauvegardée
Write-Host "`n4. Vérification de la configuration sauvegardée..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/admin/smtp/config/edit" -Method GET
    if ($response.success -and $response.config) {
        Write-Host "✅ Configuration récupérée avec succès" -ForegroundColor Green
        Write-Host "   Host: $($response.config.host)" -ForegroundColor Cyan
        Write-Host "   Port: $($response.config.port)" -ForegroundColor Cyan
        Write-Host "   Secure: $($response.config.secure)" -ForegroundColor Cyan
        Write-Host "   Username: $($response.config.username)" -ForegroundColor Cyan
        Write-Host "   Password: $($response.config.password)" -ForegroundColor Cyan
    } else {
        Write-Host "⚠️ Aucune configuration trouvée" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Test terminé ===" -ForegroundColor Green
Write-Host "`nInstructions:" -ForegroundColor Yellow
Write-Host "1. Remplacez 'votre_mot_de_passe_ici' par le vrai mot de passe" -ForegroundColor White
Write-Host "2. Remplacez 'test@example.com' par votre email de test" -ForegroundColor White
Write-Host "3. Relancez le script pour tester l'envoi d'email" -ForegroundColor White
