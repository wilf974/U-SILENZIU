#!/bin/bash

echo "🔧 Configuration Payplug en mode TEST"
echo "====================================="

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

# Ajouter les variables Payplug en mode test
echo "" >> $ENV_FILE
echo "# Configuration Payplug - Mode TEST" >> $ENV_FILE
echo "PAYPLUG_SECRET_KEY=sk_test_4qzp5fowqEGBG93PjzZOlF" >> $ENV_FILE
echo "PAYPLUG_PUBLIC_KEY=pk_test_REMPLACEZ_PAR_VOTRE_CLE_PUBLIQUE" >> $ENV_FILE
echo "PAYPLUG_WEBHOOK_SECRET=whsec_REMPLACEZ_PAR_VOTRE_SECRET_WEBHOOK" >> $ENV_FILE
echo "PAYPLUG_MODE=test" >> $ENV_FILE

echo "✅ Variables Payplug ajoutées en mode TEST"
echo ""
echo "⚠️  ATTENTION: Vous devez remplacer:"
echo "   - pk_test_REMPLACEZ_PAR_VOTRE_CLE_PUBLIQUE"
echo "   - whsec_REMPLACEZ_PAR_VOTRE_SECRET_WEBHOOK"
echo ""
echo "   par vos vraies clés depuis votre compte Payplug"
echo ""

# Redémarrer l'application
echo "🔄 Redémarrage de l'application..."
docker restart u-silenziu-app

echo "✅ Application redémarrée"
echo ""
echo "📋 Prochaines étapes:"
echo "1. Récupérez vos clés depuis https://portal.payplug.com/"
echo "2. Éditez le fichier $ENV_FILE"
echo "3. Remplacez les clés temporaires par les vraies"
echo "4. Redémarrez: docker restart u-silenziu-app"
echo ""
echo "🔍 Vérifiez les logs: docker logs -f u-silenziu-app"
