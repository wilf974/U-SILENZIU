#!/bin/bash

# Script de configuration Payplug pour U Silenziu (VPS)
# Ce script configure les variables d'environnement Payplug et redémarre l'application

echo "🔧 Configuration Payplug pour U Silenziu"
echo "========================================"

# Vérifier si le fichier env.prod existe
ENV_FILE="env.prod"
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Fichier $ENV_FILE non trouvé !"
    echo "Création du fichier à partir de env.prod.example..."
    
    if [ -f "env.prod.example" ]; then
        cp env.prod.example "$ENV_FILE"
        echo "✅ Fichier $ENV_FILE créé"
    else
        echo "❌ Fichier env.prod.example non trouvé !"
        exit 1
    fi
fi

# Demander les clés Payplug à l'utilisateur
echo ""
echo "🔑 Configuration des clés Payplug"
echo "================================="

read -p "Entrez votre PAYPLUG_SECRET_KEY (sk_test_...): " SECRET_KEY
read -p "Entrez votre PAYPLUG_PUBLIC_KEY (pk_test_...): " PUBLIC_KEY
read -p "Entrez votre PAYPLUG_WEBHOOK_SECRET (whsec_...): " WEBHOOK_SECRET

# Demander le mode (test ou live)
echo ""
echo "📋 Mode de fonctionnement"
echo "======================="
echo "1. Test (recommandé pour commencer)"
echo "2. Live (production)"
read -p "Choisissez le mode (1 ou 2): " MODE_CHOICE

if [ "$MODE_CHOICE" = "2" ]; then
    PAYPLUG_MODE="live"
else
    PAYPLUG_MODE="test"
fi

echo ""
echo "Mode sélectionné: $PAYPLUG_MODE"

# Vérifier que les clés ne sont pas vides
if [ -z "$SECRET_KEY" ] || [ -z "$PUBLIC_KEY" ] || [ -z "$WEBHOOK_SECRET" ]; then
    echo "❌ Toutes les clés Payplug sont requises !"
    exit 1
fi

# Sauvegarder l'ancien fichier
BACKUP_FILE="env.prod.backup.$(date +%Y%m%d-%H%M%S)"
cp "$ENV_FILE" "$BACKUP_FILE"
echo "✅ Sauvegarde créée: $BACKUP_FILE"

# Fonction pour ajouter ou mettre à jour une variable d'environnement
update_env_variable() {
    local var_name="$1"
    local var_value="$2"
    
    if grep -q "^$var_name=" "$ENV_FILE"; then
        # Remplacer la variable existante
        sed -i "s|^$var_name=.*|$var_name=$var_value|" "$ENV_FILE"
    else
        # Ajouter la variable à la fin
        echo "$var_name=$var_value" >> "$ENV_FILE"
    fi
}

# Mettre à jour les variables Payplug
echo ""
echo "📝 Mise à jour des variables d'environnement..."

update_env_variable "PAYPLUG_SECRET_KEY" "$SECRET_KEY"
update_env_variable "PAYPLUG_PUBLIC_KEY" "$PUBLIC_KEY"
update_env_variable "PAYPLUG_WEBHOOK_SECRET" "$WEBHOOK_SECRET"
update_env_variable "PAYPLUG_MODE" "$PAYPLUG_MODE"

echo "✅ Variables Payplug configurées dans $ENV_FILE"

# Afficher un résumé de la configuration
echo ""
echo "📋 Résumé de la configuration"
echo "============================="
echo "PAYPLUG_SECRET_KEY: ${SECRET_KEY:0:10}..."
echo "PAYPLUG_PUBLIC_KEY: ${PUBLIC_KEY:0:10}..."
echo "PAYPLUG_WEBHOOK_SECRET: ${WEBHOOK_SECRET:0:10}..."
echo "PAYPLUG_MODE: $PAYPLUG_MODE"

# Demander confirmation avant redémarrage
echo ""
echo "🔄 Redémarrage de l'application"
echo "=============================="

read -p "Voulez-vous redémarrer l'application maintenant ? (y/N): " RESTART

if [ "$RESTART" = "y" ] || [ "$RESTART" = "Y" ]; then
    echo ""
    echo "🔄 Redémarrage de l'application..."
    
    # Vérifier si Docker est disponible
    if command -v docker &> /dev/null; then
        echo "✅ Docker détecté: $(docker --version)"
        
        # Redémarrer l'application
        echo "Redémarrage du conteneur u-silenziu-app..."
        docker restart u-silenziu-app
        
        if [ $? -eq 0 ]; then
            echo "✅ Application redémarrée avec succès !"
            
            # Attendre un peu et vérifier les logs
            echo ""
            echo "⏳ Attente du démarrage (10 secondes)..."
            sleep 10
            
            echo ""
            echo "📊 Vérification des logs..."
            echo "========================="
            echo "Dernières lignes des logs de l'application:"
            docker logs --tail 20 u-silenziu-app
            
        else
            echo "❌ Erreur lors du redémarrage de l'application"
        fi
    else
        echo "❌ Docker non disponible. Redémarrage manuel requis."
        echo "Exécutez: docker restart u-silenziu-app"
    fi
else
    echo ""
    echo "⏭️  Redémarrage ignoré"
    echo "Pour redémarrer manuellement: docker restart u-silenziu-app"
fi

# Instructions finales
echo ""
echo "🎉 Configuration Payplug terminée !"
echo "==================================="
echo ""
echo "📋 Prochaines étapes:"
echo "1. Vérifiez que l'application fonctionne: https://rageroom.usilenziu.com"
echo "2. Testez une réservation avec paiement"
echo "3. Configurez les webhooks Payplug:"
echo "   URL: https://rageroom.usilenziu.com/api/webhooks/payplug"
echo "   Événements: payment.paid, payment.failed, payment.refunded"

echo ""
echo "📁 Fichiers modifiés:"
echo "- $ENV_FILE (variables d'environnement)"
echo "- $BACKUP_FILE (sauvegarde)"

echo ""
echo "✨ Payplug est maintenant configuré et prêt à l'emploi !"
