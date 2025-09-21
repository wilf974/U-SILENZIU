# Script de configuration Payplug pour U Silenziu
# Ce script configure les variables d'environnement Payplug et redémarre l'application

Write-Host "🔧 Configuration Payplug pour U Silenziu" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Vérifier si le fichier env.prod existe
$envFile = "env.prod"
if (-not (Test-Path $envFile)) {
    Write-Host "❌ Fichier $envFile non trouvé !" -ForegroundColor Red
    Write-Host "Création du fichier à partir de env.prod.example..." -ForegroundColor Yellow
    
    if (Test-Path "env.prod.example") {
        Copy-Item "env.prod.example" $envFile
        Write-Host "✅ Fichier $envFile créé" -ForegroundColor Green
    } else {
        Write-Host "❌ Fichier env.prod.example non trouvé !" -ForegroundColor Red
        exit 1
    }
}

# Demander les clés Payplug à l'utilisateur
Write-Host "`n🔑 Configuration des clés Payplug" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

$secretKey = Read-Host "Entrez votre PAYPLUG_SECRET_KEY (sk_test_...)"
$publicKey = Read-Host "Entrez votre PAYPLUG_PUBLIC_KEY (pk_test_...)"
$webhookSecret = Read-Host "Entrez votre PAYPLUG_WEBHOOK_SECRET (whsec_...)"

# Demander le mode (test ou live)
Write-Host "`n📋 Mode de fonctionnement" -ForegroundColor Cyan
Write-Host "=======================" -ForegroundColor Cyan
Write-Host "1. Test (recommandé pour commencer)"
Write-Host "2. Live (production)"
$modeChoice = Read-Host "Choisissez le mode (1 ou 2)"

$payplugMode = if ($modeChoice -eq "2") { "live" } else { "test" }

Write-Host "`nMode sélectionné: $payplugMode" -ForegroundColor Yellow

# Vérifier que les clés ne sont pas vides
if ([string]::IsNullOrWhiteSpace($secretKey) -or [string]::IsNullOrWhiteSpace($publicKey) -or [string]::IsNullOrWhiteSpace($webhookSecret)) {
    Write-Host "❌ Toutes les clés Payplug sont requises !" -ForegroundColor Red
    exit 1
}

# Sauvegarder l'ancien fichier
$backupFile = "env.prod.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Copy-Item $envFile $backupFile
Write-Host "✅ Sauvegarde créée: $backupFile" -ForegroundColor Green

# Lire le contenu actuel du fichier
$content = Get-Content $envFile -Raw

# Fonction pour ajouter ou mettre à jour une variable d'environnement
function Update-EnvVariable {
    param(
        [string]$Content,
        [string]$VariableName,
        [string]$Value
    )
    
    $pattern = "^$VariableName=.*$"
    $newLine = "$VariableName=$Value"
    
    if ($Content -match $pattern) {
        # Remplacer la variable existante
        return $Content -replace $pattern, $newLine
    } else {
        # Ajouter la variable à la fin
        return $Content + "`n$newLine"
    }
}

# Mettre à jour les variables Payplug
Write-Host "`n📝 Mise à jour des variables d'environnement..." -ForegroundColor Yellow

$content = Update-EnvVariable $content "PAYPLUG_SECRET_KEY" $secretKey
$content = Update-EnvVariable $content "PAYPLUG_PUBLIC_KEY" $publicKey
$content = Update-EnvVariable $content "PAYPLUG_WEBHOOK_SECRET" $webhookSecret
$content = Update-EnvVariable $content "PAYPLUG_MODE" $payplugMode

# Écrire le contenu mis à jour
Set-Content -Path $envFile -Value $content -Encoding UTF8

Write-Host "✅ Variables Payplug configurées dans $envFile" -ForegroundColor Green

# Afficher un résumé de la configuration
Write-Host "`n📋 Résumé de la configuration" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host "PAYPLUG_SECRET_KEY: $($secretKey.Substring(0, 10))..." -ForegroundColor Gray
Write-Host "PAYPLUG_PUBLIC_KEY: $($publicKey.Substring(0, 10))..." -ForegroundColor Gray
Write-Host "PAYPLUG_WEBHOOK_SECRET: $($webhookSecret.Substring(0, 10))..." -ForegroundColor Gray
Write-Host "PAYPLUG_MODE: $payplugMode" -ForegroundColor Gray

# Demander confirmation avant redémarrage
Write-Host "`n🔄 Redémarrage de l'application" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan

$restart = Read-Host "Voulez-vous redémarrer l'application maintenant ? (y/N)"
if ($restart -eq "y" -or $restart -eq "Y") {
    Write-Host "`n🔄 Redémarrage de l'application..." -ForegroundColor Yellow
    
    # Vérifier si Docker est disponible
    try {
        $dockerVersion = docker --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Docker détecté: $dockerVersion" -ForegroundColor Green
            
            # Redémarrer l'application
            Write-Host "Redémarrage du conteneur u-silenziu-app..." -ForegroundColor Yellow
            docker restart u-silenziu-app
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Application redémarrée avec succès !" -ForegroundColor Green
                
                # Attendre un peu et vérifier les logs
                Write-Host "`n⏳ Attente du démarrage (10 secondes)..." -ForegroundColor Yellow
                Start-Sleep -Seconds 10
                
                Write-Host "`n📊 Vérification des logs..." -ForegroundColor Cyan
                Write-Host "=========================" -ForegroundColor Cyan
                Write-Host "Dernières lignes des logs de l'application:" -ForegroundColor Gray
                docker logs --tail 20 u-silenziu-app
                
            } else {
                Write-Host "❌ Erreur lors du redémarrage de l'application" -ForegroundColor Red
            }
        } else {
            Write-Host "❌ Docker non disponible. Redémarrage manuel requis." -ForegroundColor Red
            Write-Host "Exécutez: docker restart u-silenziu-app" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ Erreur lors de la vérification de Docker" -ForegroundColor Red
        Write-Host "Redémarrage manuel requis: docker restart u-silenziu-app" -ForegroundColor Yellow
    }
} else {
    Write-Host "`n⏭️  Redémarrage ignoré" -ForegroundColor Yellow
    Write-Host "Pour redémarrer manuellement: docker restart u-silenziu-app" -ForegroundColor Gray
}

# Instructions finales
Write-Host "`n🎉 Configuration Payplug terminée !" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host "`n📋 Prochaines étapes:" -ForegroundColor Cyan
Write-Host "1. Vérifiez que l'application fonctionne: https://rageroom.usilenziu.com" -ForegroundColor White
Write-Host "2. Testez une réservation avec paiement" -ForegroundColor White
Write-Host "3. Configurez les webhooks Payplug:" -ForegroundColor White
Write-Host "   URL: https://rageroom.usilenziu.com/api/webhooks/payplug" -ForegroundColor Gray
Write-Host "   Événements: payment.paid, payment.failed, payment.refunded" -ForegroundColor Gray

Write-Host "`n📁 Fichiers modifiés:" -ForegroundColor Cyan
Write-Host "- $envFile (variables d'environnement)" -ForegroundColor White
Write-Host "- $backupFile (sauvegarde)" -ForegroundColor White

Write-Host "`n✨ Payplug est maintenant configuré et prêt à l'emploi !" -ForegroundColor Green
