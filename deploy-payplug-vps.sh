#!/bin/bash

# Script de déploiement Payplug complet pour VPS
# Ce script configure Payplug et redémarre l'application

echo "🚀 Déploiement Payplug pour U Silenziu (VPS)"
echo "============================================="

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "docker-compose.prod.yml" ]; then
    echo "❌ Fichier docker-compose.prod.yml non trouvé !"
    echo "Assurez-vous d'être dans le répertoire du projet U Silenziu"
    exit 1
fi

echo "✅ Répertoire du projet détecté"

# 1. Récupérer les dernières modifications
echo ""
echo "📥 Récupération des modifications Git..."
git pull origin main

if [ $? -eq 0 ]; then
    echo "✅ Modifications récupérées avec succès"
else
    echo "❌ Erreur lors de la récupération Git"
    exit 1
fi

# 2. Vérifier si les colonnes de paiement existent déjà
echo ""
echo "🔍 Vérification de la base de données..."

# Vérifier si les colonnes de paiement existent
COLUMN_CHECK=$(docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -t -c "
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'reservations' 
AND column_name = 'payment_id';
" 2>/dev/null | tr -d ' \n')

if [ "$COLUMN_CHECK" = "payment_id" ]; then
    echo "✅ Colonnes de paiement déjà présentes"
else
    echo "📝 Ajout des colonnes de paiement..."
    
    # Ajouter les colonnes de paiement
    docker exec -i u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
    ALTER TABLE reservations 
    ADD COLUMN IF NOT EXISTS payment_id VARCHAR(255),
    ADD COLUMN IF NOT EXISTS payment_status VARCHAR(50) DEFAULT 'pending',
    ADD COLUMN IF NOT EXISTS payment_amount DECIMAL(10,2),
    ADD COLUMN IF NOT EXISTS payment_date TIMESTAMP,
    ADD COLUMN IF NOT EXISTS refund_amount DECIMAL(10,2),
    ADD COLUMN IF NOT EXISTS refund_date TIMESTAMP,
    ADD COLUMN IF NOT EXISTS payment_error TEXT;
    "
    
    if [ $? -eq 0 ]; then
        echo "✅ Colonnes de paiement ajoutées"
        
        # Créer les index
        docker exec -i u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
        CREATE INDEX IF NOT EXISTS idx_reservations_payment_id ON reservations(payment_id);
        CREATE INDEX IF NOT EXISTS idx_reservations_payment_status ON reservations(payment_status);
        "
        
        # Mettre à jour les réservations existantes
        docker exec -i u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
        UPDATE reservations 
        SET payment_status = 'pending' 
        WHERE payment_status IS NULL;
        "
        
        echo "✅ Index créés et données mises à jour"
    else
        echo "❌ Erreur lors de l'ajout des colonnes"
        exit 1
    fi
fi

# 3. Configurer Payplug
echo ""
echo "🔧 Configuration Payplug..."

# Vérifier si le fichier env.prod existe
if [ ! -f "env.prod" ]; then
    if [ -f "env.prod.example" ]; then
        cp env.prod.example env.prod
        echo "✅ Fichier env.prod créé à partir de env.prod.example"
    else
        echo "❌ Fichier env.prod.example non trouvé !"
        exit 1
    fi
fi

# Demander les clés Payplug
echo ""
echo "🔑 Configuration des clés Payplug"
echo "================================="

read -p "Entrez votre PAYPLUG_SECRET_KEY (sk_test_...): " SECRET_KEY
read -p "Entrez votre PAYPLUG_PUBLIC_KEY (pk_test_...): " PUBLIC_KEY
read -p "Entrez votre PAYPLUG_WEBHOOK_SECRET (whsec_...): " WEBHOOK_SECRET

# Demander le mode
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

# Vérifier que les clés ne sont pas vides
if [ -z "$SECRET_KEY" ] || [ -z "$PUBLIC_KEY" ] || [ -z "$WEBHOOK_SECRET" ]; then
    echo "❌ Toutes les clés Payplug sont requises !"
    exit 1
fi

# Sauvegarder l'ancien fichier
BACKUP_FILE="env.prod.backup.$(date +%Y%m%d-%H%M%S)"
cp env.prod "$BACKUP_FILE"
echo "✅ Sauvegarde créée: $BACKUP_FILE"

# Mettre à jour les variables
update_env_variable() {
    local var_name="$1"
    local var_value="$2"
    
    if grep -q "^$var_name=" env.prod; then
        sed -i "s|^$var_name=.*|$var_name=$var_value|" env.prod
    else
        echo "$var_name=$var_value" >> env.prod
    fi
}

update_env_variable "PAYPLUG_SECRET_KEY" "$SECRET_KEY"
update_env_variable "PAYPLUG_PUBLIC_KEY" "$PUBLIC_KEY"
update_env_variable "PAYPLUG_WEBHOOK_SECRET" "$WEBHOOK_SECRET"
update_env_variable "PAYPLUG_MODE" "$PAYPLUG_MODE"

echo "✅ Variables Payplug configurées"

# 4. Redémarrer l'application
echo ""
echo "🔄 Redémarrage de l'application..."

# Arrêter les services
echo "Arrêt des services..."
docker compose -f docker-compose.prod.yml down

# Redémarrer les services
echo "Démarrage des services..."
docker compose -f docker-compose.prod.yml up -d --build

if [ $? -eq 0 ]; then
    echo "✅ Services redémarrés avec succès"
    
    # Attendre que l'application soit prête
    echo ""
    echo "⏳ Attente du démarrage de l'application (30 secondes)..."
    sleep 30
    
    # Vérifier les logs
    echo ""
    echo "📊 Vérification des logs..."
    echo "========================="
    docker compose -f docker-compose.prod.yml logs --tail 20
    
    # Vérifier le statut des conteneurs
    echo ""
    echo "🔍 Statut des conteneurs..."
    docker compose -f docker-compose.prod.yml ps
    
else
    echo "❌ Erreur lors du redémarrage des services"
    exit 1
fi

# 5. Test de l'application
echo ""
echo "🧪 Test de l'application..."

# Vérifier que l'application répond
APP_URL="https://rageroom.usilenziu.com"
echo "Test de l'URL: $APP_URL"

if curl -s --head "$APP_URL" | head -n 1 | grep -q "200 OK"; then
    echo "✅ Application accessible"
else
    echo "⚠️  Application non accessible ou erreur"
    echo "Vérifiez les logs: docker compose -f docker-compose.prod.yml logs"
fi

# 6. Instructions finales
echo ""
echo "🎉 Déploiement Payplug terminé !"
echo "==============================="
echo ""
echo "📋 Configuration:"
echo "- Mode: $PAYPLUG_MODE"
echo "- Secret Key: ${SECRET_KEY:0:10}..."
echo "- Public Key: ${PUBLIC_KEY:0:10}..."
echo "- Webhook Secret: ${WEBHOOK_SECRET:0:10}..."

echo ""
echo "🔗 URLs importantes:"
echo "- Application: $APP_URL"
echo "- Réservation: $APP_URL/reservation"
echo "- Webhook Payplug: $APP_URL/api/webhooks/payplug"

echo ""
echo "📋 Prochaines étapes:"
echo "1. Testez une réservation sur $APP_URL/reservation"
echo "2. Vérifiez que l'étape de paiement apparaît"
echo "3. Configurez les webhooks dans votre compte Payplug:"
echo "   URL: $APP_URL/api/webhooks/payplug"
echo "   Événements: payment.paid, payment.failed, payment.refunded"

echo ""
echo "📁 Fichiers créés/modifiés:"
echo "- env.prod (variables d'environnement)"
echo "- $BACKUP_FILE (sauvegarde)"

echo ""
echo "✨ Payplug est maintenant déployé et configuré !"
