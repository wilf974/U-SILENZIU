# Script de test de la configuration Payplug
# Vérifie que les variables d'environnement sont correctement configurées

Write-Host "🧪 Test de la configuration Payplug" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

# Vérifier si le fichier env.prod existe
$envFile = "env.prod"
if (-not (Test-Path $envFile)) {
    Write-Host "❌ Fichier $envFile non trouvé !" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Fichier $envFile trouvé" -ForegroundColor Green

# Lire le contenu du fichier
$content = Get-Content $envFile -Raw

# Variables Payplug requises
$requiredVars = @(
    "PAYPLUG_SECRET_KEY",
    "PAYPLUG_PUBLIC_KEY", 
    "PAYPLUG_WEBHOOK_SECRET",
    "PAYPLUG_MODE"
)

Write-Host "`n🔍 Vérification des variables d'environnement..." -ForegroundColor Yellow

$allConfigured = $true

foreach ($var in $requiredVars) {
    if ($content -match "^$var=(.+)$") {
        $value = $matches[1].Trim()
        if ($value -and $value -ne "") {
            # Masquer la valeur pour la sécurité
            $maskedValue = if ($value.Length -gt 10) { 
                $value.Substring(0, 10) + "..." 
            } else { 
                "***" 
            }
            Write-Host "✅ $var = $maskedValue" -ForegroundColor Green
        } else {
            Write-Host "❌ $var est vide" -ForegroundColor Red
            $allConfigured = $false
        }
    } else {
        Write-Host "❌ $var non trouvée" -ForegroundColor Red
        $allConfigured = $false
    }
}

# Vérifier les formats des clés
Write-Host "`n🔐 Vérification des formats des clés..." -ForegroundColor Yellow

if ($content -match "^PAYPLUG_SECRET_KEY=(.+)$") {
    $secretKey = $matches[1].Trim()
    if ($secretKey -match "^sk_(test|live)_") {
        Write-Host "✅ PAYPLUG_SECRET_KEY format correct" -ForegroundColor Green
    } else {
        Write-Host "⚠️  PAYPLUG_SECRET_KEY format suspect (devrait commencer par sk_test_ ou sk_live_)" -ForegroundColor Yellow
    }
}

if ($content -match "^PAYPLUG_PUBLIC_KEY=(.+)$") {
    $publicKey = $matches[1].Trim()
    if ($publicKey -match "^pk_(test|live)_") {
        Write-Host "✅ PAYPLUG_PUBLIC_KEY format correct" -ForegroundColor Green
    } else {
        Write-Host "⚠️  PAYPLUG_PUBLIC_KEY format suspect (devrait commencer par pk_test_ ou pk_live_)" -ForegroundColor Yellow
    }
}

if ($content -match "^PAYPLUG_WEBHOOK_SECRET=(.+)$") {
    $webhookSecret = $matches[1].Trim()
    if ($webhookSecret -match "^whsec_") {
        Write-Host "✅ PAYPLUG_WEBHOOK_SECRET format correct" -ForegroundColor Green
    } else {
        Write-Host "⚠️  PAYPLUG_WEBHOOK_SECRET format suspect (devrait commencer par whsec_)" -ForegroundColor Yellow
    }
}

# Vérifier le mode
if ($content -match "^PAYPLUG_MODE=(.+)$") {
    $mode = $matches[1].Trim()
    if ($mode -eq "test" -or $mode -eq "live") {
        Write-Host "✅ PAYPLUG_MODE = $mode" -ForegroundColor Green
    } else {
        Write-Host "⚠️  PAYPLUG_MODE = $mode (devrait être 'test' ou 'live')" -ForegroundColor Yellow
    }
}

# Résumé
Write-Host "`n📊 Résumé de la configuration" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan

if ($allConfigured) {
    Write-Host "✅ Configuration Payplug complète !" -ForegroundColor Green
    Write-Host "`n🚀 Prochaines étapes:" -ForegroundColor Yellow
    Write-Host "1. Redémarrez l'application: docker restart u-silenziu-app" -ForegroundColor White
    Write-Host "2. Testez une réservation sur https://rageroom.usilenziu.com" -ForegroundColor White
    Write-Host "3. Vérifiez que l'étape de paiement apparaît" -ForegroundColor White
} else {
    Write-Host "❌ Configuration Payplug incomplète !" -ForegroundColor Red
    Write-Host "`n🔧 Actions requises:" -ForegroundColor Yellow
    Write-Host "1. Exécutez le script configure-payplug.ps1" -ForegroundColor White
    Write-Host "2. Ou configurez manuellement les variables dans $envFile" -ForegroundColor White
}

# Vérifier si l'application est en cours d'exécution
Write-Host "`n🔍 Vérification de l'état de l'application..." -ForegroundColor Yellow

try {
    $dockerPs = docker ps --filter "name=u-silenziu-app" --format "table {{.Names}}\t{{.Status}}" 2>$null
    if ($LASTEXITCODE -eq 0 -and $dockerPs -match "u-silenziu-app") {
        Write-Host "✅ Application Docker en cours d'exécution" -ForegroundColor Green
        Write-Host $dockerPs -ForegroundColor Gray
    } else {
        Write-Host "⚠️  Application Docker non détectée" -ForegroundColor Yellow
        Write-Host "Vérifiez avec: docker ps" -ForegroundColor Gray
    }
} catch {
    Write-Host "⚠️  Impossible de vérifier l'état Docker" -ForegroundColor Yellow
}

Write-Host "`n✨ Test terminé !" -ForegroundColor Green
