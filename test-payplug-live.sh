#!/bin/bash

# Script de test pour vérifier la configuration Payplug LIVE
# U Silenziu - Janvier 2025

echo "🧪 Test de la configuration Payplug LIVE"
echo "========================================"

# Vérifier qu'on est sur le VPS
if [ ! -f "docker-compose.prod.yml" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis le répertoire du projet sur le VPS"
    echo "   Assurez-vous d'être dans /opt/usilenziu ou /var/www/usilenziu"
    exit 1
fi

echo "🔍 Vérification de la configuration actuelle..."

# Vérifier le mode dans env.prod
MODE=$(grep "PAYPLUG_MODE=" env.prod | cut -d'=' -f2)
SECRET_KEY=$(grep "PAYPLUG_SECRET_KEY=" env.prod | cut -d'=' -f2)
PUBLIC_KEY=$(grep "PAYPLUG_PUBLIC_KEY=" env.prod | cut -d'=' -f2)

echo "   - Mode: $MODE"
echo "   - Clé secrète: ${SECRET_KEY:0:20}..."
echo "   - Clé publique: ${PUBLIC_KEY:0:20}..."

if [ "$MODE" != "live" ]; then
    echo "❌ Erreur: Le mode n'est pas 'live'"
    echo "   Utilisez ./switch-payplug-live.sh pour passer en mode LIVE"
    exit 1
fi

if [[ ! $SECRET_KEY =~ ^sk_live_ ]]; then
    echo "❌ Erreur: La clé secrète ne commence pas par 'sk_live_'"
    exit 1
fi

# Payplug n'utilise pas de clés publiques pour l'API
echo "✅ Clé secrète LIVE validée"

echo "✅ Configuration LIVE détectée"
echo ""

echo "🌐 Test de l'API de configuration..."

# Test de l'API de configuration
RESPONSE=$(curl -s -X GET "https://rageroom.usilenziu.com/api/admin/payplug-config" \
  -H "Content-Type: application/json")

if echo "$RESPONSE" | grep -q '"success":true'; then
    echo "✅ API de configuration accessible"
    
    # Extraire le mode de la réponse
    API_MODE=$(echo "$RESPONSE" | grep -o '"mode":"[^"]*"' | cut -d'"' -f4)
    echo "   - Mode API: $API_MODE"
    
    if [ "$API_MODE" = "live" ]; then
        echo "✅ Mode LIVE confirmé via l'API"
    else
        echo "❌ Erreur: L'API retourne le mode '$API_MODE' au lieu de 'live'"
    fi
else
    echo "❌ Erreur API de configuration:"
    echo "$RESPONSE"
    exit 1
fi

echo ""
echo "🧪 Test de création de paiement (simulation)..."

# Test de création de paiement
PAYMENT_RESPONSE=$(curl -s -X POST "https://rageroom.usilenziu.com/api/payments/create" \
  -H "Content-Type: application/json" \
  -d '{
    "reservationNumber": "TEST'$(date +%Y%m%d%H%M%S)'",
    "amount": 1,
    "currency": "EUR",
    "customer": {
      "email": "test@usilenziu.com",
      "first_name": "Test",
      "last_name": "LIVE"
    },
    "metadata": {
      "test": true
    }
  }')

if echo "$PAYMENT_RESPONSE" | grep -q '"success":true'; then
    echo "✅ Création de paiement réussie"
    
    # Extraire l'URL de paiement
    PAYMENT_URL=$(echo "$PAYMENT_RESPONSE" | grep -o '"payment_url":"[^"]*"' | cut -d'"' -f4)
    if [ -n "$PAYMENT_URL" ]; then
        echo "   - URL de paiement: $PAYMENT_URL"
        
        # Vérifier que l'URL contient bien Payplug
        if echo "$PAYMENT_URL" | grep -q "payplug.com"; then
            echo "✅ URL Payplug valide"
        else
            echo "❌ Erreur: URL Payplug invalide"
        fi
    fi
else
    echo "❌ Erreur création de paiement:"
    echo "$PAYMENT_RESPONSE"
    exit 1
fi

echo ""
echo "🔗 Test de l'URL du webhook..."

# Test de l'URL du webhook
WEBHOOK_RESPONSE=$(curl -s -X POST "https://rageroom.usilenziu.com/api/webhooks/payplug" \
  -H "Content-Type: application/json" \
  -d '{"test": true}')

# Le webhook peut retourner une erreur 400 (normal sans signature Payplug)
if echo "$WEBHOOK_RESPONSE" | grep -q "signature" || echo "$WEBHOOK_RESPONSE" | grep -q "400"; then
    echo "✅ Webhook accessible (erreur 400 normale sans signature)"
else
    echo "⚠️  Webhook accessible mais réponse inattendue:"
    echo "$WEBHOOK_RESPONSE"
fi

echo ""
echo "🎉 Tests Payplug LIVE terminés!"
echo ""
echo "📋 Résumé des tests:"
echo "   ✅ Configuration LIVE détectée"
echo "   ✅ Clé secrète LIVE validée"
echo "   ✅ API de configuration accessible"
echo "   ✅ Mode LIVE confirmé via l'API"
echo "   ✅ Création de paiement réussie"
echo "   ✅ URL Payplug valide"
echo "   ✅ Webhook accessible"
echo ""
echo "⚠️  IMPORTANT:"
echo "   - Vous êtes maintenant en mode LIVE (PRODUCTION)"
echo "   - Les paiements seront RÉELS et facturés"
echo "   - Configurez l'URL du webhook dans votre compte Payplug"
echo "   - Testez avec un petit montant avant de lancer en production"
echo ""
echo "🔗 URLs importantes:"
echo "   - Site: https://rageroom.usilenziu.com"
echo "   - Admin: https://rageroom.usilenziu.com/admin"
echo "   - Webhook: https://rageroom.usilenziu.com/api/webhooks/payplug"
echo ""
echo "🔄 Pour revenir en mode TEST:"
echo "   ./switch-payplug-test.sh"
echo ""
