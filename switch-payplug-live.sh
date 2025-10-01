#!/bin/bash

# Script pour passer Payplug en mode LIVE
# U Silenziu - Janvier 2025
# Usage: ./switch-payplug-live.sh

echo "🔄 PASSAGE PAYPLUG EN MODE LIVE"
echo "==============================="
echo ""

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages colorés
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${CYAN}📋 $1${NC}"
}

print_step() {
    echo -e "${WHITE}   $1${NC}"
}

print_warning "ATTENTION : Passage en mode LIVE"
echo "===================================="
echo ""
echo -e "${WHITE}🔑 Vous devez avoir vos clés Payplug LIVE :${NC}"
echo ""
echo -e "${GRAY}   1. Clé secrète LIVE : sk_live_...${NC}"
echo -e "${GRAY}   2. Clé publique LIVE : pk_live_...${NC}"
echo -e "${GRAY}   3. Secret webhook LIVE : whsec_live_...${NC}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT :${NC}"
echo -e "${GRAY}   - Les paiements seront réels en mode LIVE${NC}"
echo -e "${GRAY}   - Assurez-vous que tout fonctionne en mode TEST d'abord${NC}"
echo -e "${GRAY}   - Sauvegardez votre configuration actuelle${NC}"
echo ""

read -p "Avez-vous vos clés Payplug LIVE et voulez-vous continuer ? (o/n): " confirm
if [ "$confirm" != "o" ] && [ "$confirm" != "O" ]; then
    print_error "Passage en mode LIVE annulé"
    exit 1
fi

echo ""
print_info "Sauvegarde de la configuration actuelle..."

# Sauvegarder la configuration actuelle
cp docker-compose.prod.yml docker-compose.prod.yml.backup.$(date +%Y%m%d_%H%M%S)
print_status "Configuration sauvegardée"

echo ""
print_info "Configuration des clés LIVE..."

# Demander les clés LIVE
read -p "Entrez votre clé secrète LIVE (sk_live_...): " LIVE_SECRET_KEY
read -p "Entrez votre clé publique LIVE (pk_live_...): " LIVE_PUBLIC_KEY
read -p "Entrez votre secret webhook LIVE (whsec_live_...): " LIVE_WEBHOOK_SECRET

# Vérifier que les clés commencent par les bons préfixes
if [[ ! $LIVE_SECRET_KEY == sk_live_* ]]; then
    print_error "Clé secrète invalide (doit commencer par sk_live_)"
    exit 1
fi

if [[ ! $LIVE_PUBLIC_KEY == pk_live_* ]]; then
    print_error "Clé publique invalide (doit commencer par pk_live_)"
    exit 1
fi

if [[ ! $LIVE_WEBHOOK_SECRET == whsec_live_* ]]; then
    print_error "Secret webhook invalide (doit commencer par whsec_live_)"
    exit 1
fi

print_status "Clés LIVE validées"

echo ""
print_info "Mise à jour de la configuration..."

# Mettre à jour docker-compose.prod.yml
sed -i "s/PAYPLUG_SECRET_KEY=sk_test_.*/PAYPLUG_SECRET_KEY=$LIVE_SECRET_KEY/" docker-compose.prod.yml
sed -i "s/PAYPLUG_PUBLIC_KEY=pk_test_.*/PAYPLUG_PUBLIC_KEY=$LIVE_PUBLIC_KEY/" docker-compose.prod.yml
sed -i "s/PAYPLUG_WEBHOOK_SECRET=whsec_test_.*/PAYPLUG_WEBHOOK_SECRET=$LIVE_WEBHOOK_SECRET/" docker-compose.prod.yml
sed -i "s/PAYPLUG_MODE=test/PAYPLUG_MODE=live/" docker-compose.prod.yml

# Mettre à jour env.prod
sed -i "s/PAYPLUG_SECRET_KEY=sk_test_.*/PAYPLUG_SECRET_KEY=$LIVE_SECRET_KEY/" env.prod
sed -i "s/PAYPLUG_PUBLIC_KEY=pk_test_.*/PAYPLUG_PUBLIC_KEY=$LIVE_PUBLIC_KEY/" env.prod
sed -i "s/PAYPLUG_WEBHOOK_SECRET=whsec_test_.*/PAYPLUG_WEBHOOK_SECRET=$LIVE_WEBHOOK_SECRET/" env.prod
sed -i "s/PAYPLUG_MODE=test/PAYPLUG_MODE=live/" env.prod

print_status "Configuration mise à jour"

echo ""
print_info "Redémarrage des services..."

# Redémarrer les services
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d --build

print_status "Services redémarrés"

echo ""
print_info "Test de la configuration LIVE..."

# Test rapide
sleep 10
TEST_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "https://rageroom.usilenziu.com/api/payments/create")

if [ "$TEST_RESPONSE" = "200" ] || [ "$TEST_RESPONSE" = "400" ]; then
    print_status "Configuration LIVE opérationnelle"
else
    print_error "Problème avec la configuration LIVE (HTTP $TEST_RESPONSE)"
fi

echo ""
print_status "PASSAGE EN MODE LIVE TERMINÉ"
echo "================================="
echo ""
print_warning "IMPORTANT :"
print_step "1. Testez un paiement réel avec un petit montant"
print_step "2. Vérifiez que les webhooks fonctionnent"
print_step "3. Surveillez les logs pour détecter d'éventuels problèmes"
print_step "4. La sauvegarde est disponible dans docker-compose.prod.yml.backup.*"
echo ""
print_info "URLs importantes :"
echo -e "${GRAY}   Site: https://rageroom.usilenziu.com${NC}"
echo -e "${GRAY}   Webhook: https://rageroom.usilenziu.com/api/webhooks/payplug${NC}"
echo ""
print_status "Payplug est maintenant en mode LIVE ! 🚀"
