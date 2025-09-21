#!/bin/bash

echo "🔧 Configuration Payplug SIMPLIFIÉE (mode test uniquement)"
echo "========================================================"

# Vérifier si on est sur le VPS
if [ -f "env.prod" ]; then
    echo "✅ Environnement de production détecté"
    ENV_FILE="env.prod"
else
    echo "❌ Fichier env.prod non trouvé"
    exit 1
fi

# Sauvegarder l'ancien fichier
cp $ENV_FILE $ENV_FILE.backup.$(date +%Y%m%d-%H%M%S)
echo "✅ Sauvegarde créée: $ENV_FILE.backup.$(date +%Y%m%d-%H%M%S)"

# Supprimer les anciennes variables Payplug si elles existent
sed -i '/^PAYPLUG_/d' $ENV_FILE

# Ajouter les variables Payplug minimales pour le mode test
echo "" >> $ENV_FILE
echo "# Configuration Payplug - Mode TEST (minimal)" >> $ENV_FILE
echo "PAYPLUG_SECRET_KEY=sk_test_4qzp5fowqEGBG93PjzZOlF" >> $ENV_FILE
echo "PAYPLUG_MODE=test" >> $ENV_FILE

echo "✅ Configuration Payplug minimale ajoutée"
echo ""
echo "📋 Configuration actuelle:"
echo "   - PAYPLUG_SECRET_KEY: sk_test_4qzp5fowqEGBG93PjzZOlF"
echo "   - PAYPLUG_MODE: test"
echo "   - Clés manquantes: ignorées en mode test"
echo ""

# Redémarrer l'application
echo "🔄 Redémarrage de l'application..."
docker restart u-silenziu-app

echo "✅ Application redémarrée"
echo ""
echo "🧪 Test de la configuration..."
sleep 5

# Tester l'API de paiement
echo "🔍 Test de l'API de paiement..."
curl -s -X POST http://localhost:3000/api/payments/create \
  -H "Content-Type: application/json" \
  -d '{"reservationNumber":"test123","amount":5000,"currency":"EUR","customer":{"email":"test@test.com","first_name":"Test","last_name":"User"},"metadata":{"test":true},"return_url":"https://example.com/success","cancel_url":"https://example.com/cancel","notification_url":"https://example.com/webhook"}' \
  | head -c 200

echo ""
echo ""
echo "✅ Configuration terminée !"
echo ""
echo "🌐 Testez maintenant: https://rageroom.usilenziu.com/reservation"
echo "🔍 Vérifiez les logs: docker logs -f u-silenziu-app"
