#!/bin/bash

# Script pour revenir en mode TEST Payplug sur le VPS
# U Silenziu - Janvier 2025

echo "🧪 Retour de Payplug en mode TEST sur le VPS"
echo "============================================="

# Vérifier qu'on est sur le VPS
if [ ! -f "docker-compose.prod.yml" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis le répertoire du projet sur le VPS"
    echo "   Assurez-vous d'être dans /opt/usilenziu ou /var/www/usilenziu"
    exit 1
fi

echo "⚠️  ATTENTION: Vous allez revenir en mode TEST"
echo "   - Les paiements seront simulés"
echo "   - Aucune transaction réelle ne sera effectuée"
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

# Mettre à jour env.prod avec les clés de test
sed -i "s/PAYPLUG_SECRET_KEY=.*/PAYPLUG_SECRET_KEY=sk_test_4qzp5fowqEGBG93PjzZOlF/" env.prod
sed -i "s/PAYPLUG_PUBLIC_KEY=.*/PAYPLUG_PUBLIC_KEY=pk_test_4qzp5fowqEGBG93PjzZOlF/" env.prod
sed -i "s/PAYPLUG_WEBHOOK_SECRET=.*/PAYPLUG_WEBHOOK_SECRET=whsec_test_4qzp5fowqEGBG93PjzZOlF/" env.prod
sed -i "s/PAYPLUG_MODE=.*/PAYPLUG_MODE=test/" env.prod

echo "✅ env.prod mis à jour"

# Mettre à jour docker-compose.prod.yml avec les clés de test
sed -i "s/- PAYPLUG_SECRET_KEY=.*/- PAYPLUG_SECRET_KEY=sk_test_4qzp5fowqEGBG93PjzZOlF/" docker-compose.prod.yml
sed -i "s/- PAYPLUG_PUBLIC_KEY=.*/- PAYPLUG_PUBLIC_KEY=pk_test_4qzp5fowqEGBG93PjzZOlF/" docker-compose.prod.yml
sed -i "s/- PAYPLUG_WEBHOOK_SECRET=.*/- PAYPLUG_WEBHOOK_SECRET=whsec_test_4qzp5fowqEGBG93PjzZOlF/" docker-compose.prod.yml
sed -i "s/- PAYPLUG_MODE=.*/- PAYPLUG_MODE=test/" docker-compose.prod.yml

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
echo "🎉 Configuration Payplug TEST terminée!"
echo ""
echo "📋 Résumé:"
echo "   - Mode: TEST (SIMULATION)"
echo "   - Clé secrète: sk_test_4qzp5fowqEGBG93PjzZOlF"
echo "   - Clé publique: pk_test_4qzp5fowqEGBG93PjzZOlF"
echo "   - Secret webhook: whsec_test_4qzp5fowqEGBG93PjzZOlF"
echo ""
echo "🔗 URLs importantes:"
echo "   - Site: https://rageroom.usilenziu.com"
echo "   - Admin: https://rageroom.usilenziu.com/admin"
echo "   - Webhook: https://rageroom.usilenziu.com/api/webhooks/payplug"
echo ""
echo "✅ Mode TEST activé:"
echo "   - Les paiements sont simulés"
echo "   - Aucune transaction réelle ne sera effectuée"
echo "   - Parfait pour les tests et le développement"
echo ""
echo "🔄 Pour passer en mode LIVE:"
echo "   ./switch-payplug-live.sh"
echo ""
