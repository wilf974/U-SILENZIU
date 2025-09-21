#!/bin/bash

# Script de correction rapide pour le déploiement Payplug
echo "🔧 Correction du déploiement Payplug"
echo "===================================="

# 1. Arrêter les services
echo "Arrêt des services..."
docker compose -f docker-compose.prod.yml down

# 2. Corriger les variables d'environnement
echo "Correction des variables d'environnement..."

# Sauvegarder l'ancien fichier
cp env.prod env.prod.backup.$(date +%Y%m%d-%H%M%S)

# Corriger les clés Payplug (en mode test)
cat > env.prod << 'EOF'
# Configuration de base
NODE_ENV=production
NEXT_PUBLIC_SITE_URL=https://rageroom.usilenziu.com
NEXT_PUBLIC_SITE_NAME=U Silenziu

# Base de données PostgreSQL
DATABASE_URL=postgresql://usilenzio_user:usilenzio_password_2024@postgres:5432/usilenzio
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=usilenzio
POSTGRES_USER=usilenzio_user
POSTGRES_PASSWORD=usilenzio_password_2024

# Configuration SMTP (à remplir avec vos données)
SMTP_HOST=smtp-mail.outlook.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=contact@votre-domaine.com
SMTP_PASS=votre_mot_de_passe_smtp
SMTP_FROM=contact@votre-domaine.com

# Clé de chiffrement pour les mots de passe SMTP
ENCRYPTION_KEY=votre_cle_de_chiffrement_32_caracteres

# Configuration des notifications
NOTIFICATION_EMAIL=contact@votre-domaine.com
NOTIFICATION_PHONE=+33123456789

# Configuration des uploads
UPLOAD_DIR=./public/uploads
MAX_FILE_SIZE=5242880

# Configuration du cron
CRON_ENABLED=true
CRON_INTERVAL=*/15 * * * * # Toutes les 15 minutes

# Configuration de sécurité
JWT_SECRET=votre_jwt_secret_tres_long_et_complexe
JWT_EXPIRES_IN=1h
SESSION_SECRET=votre_session_secret_tres_long_et_complexe

# Configuration des logs
LOG_LEVEL=info
LOG_FILE=./logs/app.log

# Configuration du cache
CACHE_TTL=3600
CACHE_MAX_SIZE=100

# Configuration des performances
NEXT_PUBLIC_IMAGE_OPTIMIZATION=true
NEXT_PUBLIC_COMPRESSION=true

# Configuration Payplug (MODE TEST)
PAYPLUG_SECRET_KEY=sk_test_4qzp5fowqEGBG93PjzZOlF
PAYPLUG_PUBLIC_KEY=pk_test_votre_cle_publique_ici
PAYPLUG_WEBHOOK_SECRET=whsec_votre_secret_webhook_ici
PAYPLUG_MODE=test
EOF

echo "✅ Variables d'environnement corrigées"

# 3. Récupérer les corrections de code
echo "Récupération des corrections de code..."
git add .
git commit -m "Fix: Correction erreur useSearchParams dans page de retour paiement"
git push origin main

# 4. Redémarrer les services
echo "Redémarrage des services..."
docker compose -f docker-compose.prod.yml up -d --build

if [ $? -eq 0 ]; then
    echo "✅ Services redémarrés avec succès"
    
    # Attendre le démarrage
    echo "⏳ Attente du démarrage (30 secondes)..."
    sleep 30
    
    # Vérifier les logs
    echo "📊 Vérification des logs..."
    docker compose -f docker-compose.prod.yml logs --tail 20
    
    echo ""
    echo "🎉 Correction terminée !"
    echo "========================="
    echo ""
    echo "📋 Prochaines étapes:"
    echo "1. Obtenez vos vraies clés Payplug depuis votre compte"
    echo "2. Mettez à jour env.prod avec les bonnes clés:"
    echo "   - PAYPLUG_PUBLIC_KEY (pk_test_...)"
    echo "   - PAYPLUG_WEBHOOK_SECRET (whsec_...)"
    echo "3. Redémarrez: docker compose -f docker-compose.prod.yml restart"
    echo ""
    echo "🔗 URL de test: https://rageroom.usilenziu.com/reservation"
    
else
    echo "❌ Erreur lors du redémarrage"
    echo "Vérifiez les logs: docker compose -f docker-compose.prod.yml logs"
fi
