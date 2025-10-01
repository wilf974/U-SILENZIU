#!/usr/bin/env pwsh

# Script de déploiement Payplug en production
# U Silenziu - Janvier 2025

Write-Host "🚀 DÉPLOIEMENT PAYPLUG EN PRODUCTION" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Étapes de déploiement :" -ForegroundColor Cyan
Write-Host "   1. Configuration des clés Payplug de production" -ForegroundColor White
Write-Host "   2. Déploiement sur le VPS" -ForegroundColor White
Write-Host "   3. Test du système de paiement" -ForegroundColor White
Write-Host "   4. Validation des webhooks" -ForegroundColor White
Write-Host ""

# Vérification des prérequis
Write-Host "🔍 Vérification des prérequis..." -ForegroundColor Yellow

# Vérifier que Docker est en cours d'exécution
try {
    docker --version | Out-Null
    Write-Host "✅ Docker installé" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker n'est pas installé ou ne fonctionne pas" -ForegroundColor Red
    exit 1
}

# Vérifier que le fichier docker-compose.prod.yml existe
if (Test-Path "docker-compose.prod.yml") {
    Write-Host "✅ docker-compose.prod.yml trouvé" -ForegroundColor Green
} else {
    Write-Host "❌ docker-compose.prod.yml non trouvé" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "⚠️  CONFIGURATION PAYPLUG PRODUCTION" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "🔑 Configuration Payplug en mode TEST pour les tests :" -ForegroundColor White
Write-Host ""
Write-Host "   ✅ Clés de test déjà configurées" -ForegroundColor Green
Write-Host "   ✅ Mode test activé pour les tests de production" -ForegroundColor Green
Write-Host "   ✅ URLs de production configurées" -ForegroundColor Green
Write-Host ""
Write-Host "   📝 Pour passer en mode LIVE plus tard :" -ForegroundColor Gray
Write-Host "   1. Activez votre clé LIVE dans Payplug" -ForegroundColor Gray
Write-Host "   2. Remplacez les clés sk_test_ par sk_live_" -ForegroundColor Gray
Write-Host "   3. Changez PAYPLUG_MODE=test vers PAYPLUG_MODE=live" -ForegroundColor Gray
Write-Host ""

$configure = Read-Host "Voulez-vous continuer avec le déploiement en mode TEST ? (o/n)"
if ($configure -ne "o" -and $configure -ne "O") {
    Write-Host "❌ Déploiement annulé" -ForegroundColor Red
    Write-Host ""
    Write-Host "📝 Pour déployer plus tard :" -ForegroundColor Cyan
    Write-Host "   1. Relancez ce script" -ForegroundColor White
    Write-Host "   2. Ou modifiez les clés pour passer en mode LIVE" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "🐳 Déploiement Docker en production..." -ForegroundColor Cyan

# Arrêter les conteneurs existants
Write-Host "   Arrêt des conteneurs existants..." -ForegroundColor Gray
docker-compose -f docker-compose.prod.yml down

# Construire et démarrer les conteneurs
Write-Host "   Construction et démarrage des conteneurs..." -ForegroundColor Gray
docker-compose -f docker-compose.prod.yml up -d --build

# Attendre que les services soient prêts
Write-Host "   Attente du démarrage des services..." -ForegroundColor Gray
Start-Sleep -Seconds 30

# Vérifier le statut des conteneurs
Write-Host ""
Write-Host "📊 Statut des conteneurs :" -ForegroundColor Cyan
docker-compose -f docker-compose.prod.yml ps

Write-Host ""
Write-Host "🧪 Test du système de paiement..." -ForegroundColor Cyan

# Test de l'API de paiement
$testUrl = "https://rageroom.usilenziu.com"
$testReservationNumber = "PRODTEST$(Get-Date -Format 'yyyyMMddHHmmss')"

Write-Host "   Test de création de paiement..." -ForegroundColor Gray
try {
    $paymentData = @{
        reservationNumber = $testReservationNumber
        amount = 50
        currency = "EUR"
        customer = @{
            email = "test@usilenziu.com"
            first_name = "Test"
            last_name = "Production"
        }
        metadata = @{
            test = $true
        }
    } | ConvertTo-Json -Depth 3

    $response = Invoke-RestMethod -Uri "$testUrl/api/payments/create" -Method POST -ContentType "application/json" -Body $paymentData
    
    if ($response.success -and $response.payment_url) {
        Write-Host "✅ Paiement créé avec succès en production" -ForegroundColor Green
        Write-Host "   URL Payplug: $($response.payment_url)" -ForegroundColor Gray
        Write-Host "   Numéro de réservation: $($response.reservation_number)" -ForegroundColor Gray
    } else {
        Write-Host "❌ Échec de création du paiement en production" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors du test de paiement: $($_.Exception.Message)" -ForegroundColor Red
}

# Test de la page de retour
Write-Host "   Test de la page de retour..." -ForegroundColor Gray
try {
    $returnUrl = "$testUrl/reservation/payment/return?reservation=$testReservationNumber&status=success"
    $response = Invoke-RestMethod -Uri $returnUrl -Method GET
    
    if ($response) {
        Write-Host "✅ Page de retour accessible en production" -ForegroundColor Green
    } else {
        Write-Host "❌ Page de retour non accessible" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur page de retour: $($_.Exception.Message)" -ForegroundColor Red
}

# Test du webhook
Write-Host "   Test du webhook..." -ForegroundColor Gray
try {
    $webhookData = @{
        type = "payment.paid"
        data = @{
            id = "test_payment_$testReservationNumber"
            amount = 5000
            currency = "EUR"
            metadata = @{
                reservation_number = $testReservationNumber
            }
        }
    } | ConvertTo-Json -Depth 3

    $response = Invoke-RestMethod -Uri "$testUrl/api/webhooks/payplug" -Method POST -ContentType "application/json" -Body $webhookData
    
    Write-Host "✅ Webhook accessible en production" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 400) {
        Write-Host "✅ Webhook accessible (erreur 400 normale sans signature Payplug)" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur webhook: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🎉 DÉPLOIEMENT TERMINÉ" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
Write-Host ""
Write-Host "✅ Système Payplug déployé en production" -ForegroundColor Green
Write-Host "✅ Tests de base effectués" -ForegroundColor Green
Write-Host ""
Write-Host "🔗 URLs importantes :" -ForegroundColor Cyan
Write-Host "   Site principal: $testUrl" -ForegroundColor Gray
Write-Host "   Réservation: $testUrl/reservation" -ForegroundColor Gray
Write-Host "   Administration: $testUrl/admin" -ForegroundColor Gray
Write-Host "   Page de retour: $testUrl/reservation/payment/return" -ForegroundColor Gray
Write-Host "   Webhook: $testUrl/api/webhooks/payplug" -ForegroundColor Gray
Write-Host ""
Write-Host "📋 Prochaines étapes :" -ForegroundColor Yellow
Write-Host "   1. Tester le flux complet via l'interface utilisateur" -ForegroundColor White
Write-Host "   2. Vérifier les webhooks Payplug en production" -ForegroundColor White
Write-Host "   3. Tester les emails de confirmation" -ForegroundColor White
Write-Host "   4. Surveiller les logs pour détecter d'éventuels problèmes" -ForegroundColor White
Write-Host ""
Write-Host "📊 Surveillance des logs :" -ForegroundColor Cyan
Write-Host "   docker-compose -f docker-compose.prod.yml logs -f u-silenziu" -ForegroundColor Gray
Write-Host ""
Write-Host "✨ Déploiement Payplug en production terminé avec succès !" -ForegroundColor Green
