#!/bin/bash

# Script pour passer Payplug en mode LIVE sur le VPS
# U Silenziu - Janvier 2025

echo "🚀 Passage de Payplug en mode LIVE sur le VPS"
echo "=============================================="

# Vérifier qu'on est sur le VPS
if [ ! -f "docker-compose.prod.yml" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis le répertoire du projet sur le VPS"
    echo "   Assurez-vous d'être dans /opt/usilenziu ou /var/www/usilenziu"
    exit 1
fi

echo "📋 Configuration actuelle:"
echo "   - Mode: TEST"
echo "   - Clé secrète: sk_test_4qzp5fowqEGBG93PjzZOlF"
echo "   - Clé publique: pk_test_4qzp5fowqEGBG93PjzZOlF"
echo ""

# Demander la clé secrète LIVE (Payplug n'utilise que les clés secrètes)
echo "🔑 Veuillez entrer votre clé secrète Payplug LIVE:"
echo ""

read -p "Clé secrète LIVE (sk_live_...): " PAYPLUG_SECRET_KEY_LIVE

# Validation de la clé secrète
if [[ ! $PAYPLUG_SECRET_KEY_LIVE =~ ^sk_live_ ]]; then
    echo "❌ Erreur: La clé secrète doit commencer par 'sk_live_'"
    exit 1
fi

# Payplug n'utilise pas de clés publiques pour l'API
# On garde les anciennes valeurs pour la compatibilité
PAYPLUG_PUBLIC_KEY_LIVE=""
PAYPLUG_WEBHOOK_SECRET_LIVE=""

echo ""
echo "✅ Clés validées!"
echo ""

# Confirmation
echo "⚠️  ATTENTION: Vous allez passer en mode LIVE (PRODUCTION)"
echo "   - Les paiements seront RÉELS"
echo "   - Les transactions seront facturées"
echo "   - Assurez-vous que vos clés sont correctes"
echo ""

read -p "Êtes-vous sûr de vouloir continuer? (oui/non): " CONFIRM

if [ "$CONFIRM" != "oui" ]; then
    echo "❌ Opération annulée"
    exit 0
fi

echo ""
echo "🔄 Mise à jour de la configuration..."

# Sauvegarder l'ancienne configuration
cp env.prod env.prod.backup.$(date +%Y%m%d_%H%M%S)
cp docker-compose.prod.yml docker-compose.prod.yml.backup.$(date +%Y%m%d_%H%M%S)

echo "✅ Sauvegarde créée"

# Mettre à jour env.prod
sed -i "s/PAYPLUG_SECRET_KEY=.*/PAYPLUG_SECRET_KEY=$PAYPLUG_SECRET_KEY_LIVE/" env.prod
sed -i "s/PAYPLUG_PUBLIC_KEY=.*/PAYPLUG_PUBLIC_KEY=/" env.prod
sed -i "s/PAYPLUG_WEBHOOK_SECRET=.*/PAYPLUG_WEBHOOK_SECRET=/" env.prod
sed -i "s/PAYPLUG_MODE=.*/PAYPLUG_MODE=live/" env.prod

echo "✅ env.prod mis à jour"

# Mettre à jour docker-compose.prod.yml
sed -i "s/- PAYPLUG_SECRET_KEY=.*/- PAYPLUG_SECRET_KEY=$PAYPLUG_SECRET_KEY_LIVE/" docker-compose.prod.yml
sed -i "s/- PAYPLUG_PUBLIC_KEY=.*/- PAYPLUG_PUBLIC_KEY=/" docker-compose.prod.yml
sed -i "s/- PAYPLUG_WEBHOOK_SECRET=.*/- PAYPLUG_WEBHOOK_SECRET=/" docker-compose.prod.yml
sed -i "s/- PAYPLUG_MODE=.*/- PAYPLUG_MODE=live/" docker-compose.prod.yml

echo "✅ docker-compose.prod.yml mis à jour"

echo ""
echo "🔄 Redémarrage des services..."

# Redémarrer les services
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d --build

echo "✅ Services redémarrés"

echo ""
echo "🧪 Test de la configuration..."

# Attendre que les services soient prêts
sleep 10

# Test de l'API de configuration
echo "   - Test de l'API de configuration Payplug..."
RESPONSE=$(curl -s -X GET "https://rageroom.usilenziu.com/api/admin/payplug-config" \
  -H "Content-Type: application/json" \
  -w "%{http_code}")

if [[ $RESPONSE == *"200"* ]]; then
    echo "   ✅ API de configuration accessible"
else
    echo "   ❌ Erreur API de configuration: $RESPONSE"
fi

echo ""
echo "🎉 Configuration Payplug LIVE terminée!"
echo ""
echo "📋 Résumé:"
echo "   - Mode: LIVE (PRODUCTION)"
echo "   - Clé secrète: $PAYPLUG_SECRET_KEY_LIVE"
echo "   - Note: Payplug n'utilise que les clés secrètes pour l'API"
echo ""
echo "🔗 URLs importantes:"
echo "   - Site: https://rageroom.usilenziu.com"
echo "   - Admin: https://rageroom.usilenziu.com/admin"
echo "   - Webhook: https://rageroom.usilenziu.com/api/webhooks/payplug"
echo ""
echo "⚠️  IMPORTANT:"
echo "   - Configurez l'URL du webhook dans votre compte Payplug"
echo "   - Testez un paiement avec un petit montant"
echo "   - Vérifiez que les notifications arrivent bien"
echo ""
echo "🔄 Pour revenir en mode TEST:"
echo "   ./switch-payplug-test.sh"
echo ""
