#!/bin/bash

echo "🚀 Redémarrage complet des services U Silenziu"
echo "=============================================="

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages colorés
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 1. Arrêter tous les conteneurs existants
echo "🛑 Arrêt des conteneurs existants..."
docker stop u-silenziu-app u-silenziu-nginx-prod u-silenziu-postgres 2>/dev/null || true
docker rm u-silenziu-app u-silenziu-nginx-prod 2>/dev/null || true

# 2. Démarrer PostgreSQL
echo "🐘 Démarrage de PostgreSQL..."
docker run -d --name u-silenziu-postgres \
  -e POSTGRES_DB=usilenzio \
  -e POSTGRES_USER=usilenzio_user \
  -e POSTGRES_PASSWORD=usilenzio_password_2024 \
  -p 5432:5432 \
  -v postgres_prod_data:/var/lib/postgresql/data \
  postgres:15-alpine

# Attendre que PostgreSQL soit prêt
echo "⏳ Attente que PostgreSQL soit prêt..."
sleep 10

# 3. Démarrer l'application avec les variables Payplug
echo "🚀 Démarrage de l'application avec Payplug..."
docker run -d --name u-silenziu-app \
  --env-file env.prod \
  -e PAYPLUG_SECRET_KEY=sk_test_4qzp5fowqEGBG93PjzZOlF \
  -e PAYPLUG_MODE=test \
  -e DATABASE_URL=postgresql://usilenzio_user:usilenzio_password_2024@u-silenziu-postgres:5432/usilenzio \
  -e POSTGRES_HOST=u-silenziu-postgres \
  -e POSTGRES_PORT=5432 \
  -e POSTGRES_DB=usilenzio \
  -e POSTGRES_USER=usilenzio_user \
  -e POSTGRES_PASSWORD=usilenzio_password_2024 \
  -e NODE_ENV=production \
  -e NEXT_PUBLIC_APP_URL=https://rageroom.usilenziu.com \
  -e NEXT_PUBLIC_API_URL=https://rageroom.usilenziu.com/api \
  -p 3000:3000 \
  u-silenziu-u-silenziu

# Attendre que l'application soit prête
echo "⏳ Attente que l'application soit prête..."
sleep 15

# 4. Démarrer nginx
echo "🌐 Démarrage de nginx..."
docker run -d --name u-silenziu-nginx-prod \
  -p 80:80 \
  -p 443:443 \
  -v /etc/letsencrypt:/etc/letsencrypt:ro \
  -v ./nginx.conf:/etc/nginx/nginx.conf:ro \
  nginx:alpine

# 5. Vérifier l'état des conteneurs
echo "🔍 Vérification de l'état des conteneurs..."
docker ps

# 6. Vérifier les variables Payplug
echo "🔑 Vérification des variables Payplug..."
docker exec u-silenziu-app env | grep PAYPLUG

# 7. Tester l'API de paiement
echo "🧪 Test de l'API de paiement..."
curl -s -X POST http://localhost:3000/api/payments/create \
  -H "Content-Type: application/json" \
  -d '{
    "reservationNumber": "test123",
    "amount": 5000,
    "currency": "EUR",
    "customer": {
      "email": "test@test.com",
      "first_name": "Test",
      "last_name": "User"
    },
    "metadata": {
      "test": true
    },
    "return_url": "https://rageroom.usilenziu.com/success",
    "cancel_url": "https://rageroom.usilenziu.com/cancel",
    "notification_url": "https://rageroom.usilenziu.com/api/webhooks/payplug"
  }' | head -c 200

echo ""
echo "🎉 Redémarrage terminé !"
echo ""
echo "📋 URLs d'accès :"
echo "   - Site principal : https://rageroom.usilenziu.com"
echo "   - Interface admin : https://rageroom.usilenziu.com/admin"
echo "   - Test direct : http://rageroom.usilenziu.com:3000"
echo ""
echo "🔧 Commandes utiles :"
echo "   - Voir les logs : docker logs u-silenziu-app"
echo "   - Vérifier les conteneurs : docker ps"
echo "   - Redémarrer : ./restart-all-services.sh"
