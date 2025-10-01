#!/bin/bash

# Script de déploiement Payplug sur VPS
# U Silenziu - Janvier 2025
# Usage: ./deploy-payplug-vps.sh

echo "🚀 DÉPLOIEMENT PAYPLUG SUR VPS"
echo "=============================="
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

# Vérification des prérequis
print_info "Vérification des prérequis..."

# Vérifier que Docker est installé
if command -v docker &> /dev/null; then
    print_status "Docker installé"
else
    print_error "Docker n'est pas installé"
    echo "Installation de Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
fi

# Vérifier que Docker Compose est installé
if command -v docker-compose &> /dev/null; then
    print_status "Docker Compose installé"
else
    print_error "Docker Compose n'est pas installé"
    echo "Installation de Docker Compose..."
    apt update
    apt install docker-compose-plugin -y
fi

# Vérifier que Git est installé
if command -v git &> /dev/null; then
    print_status "Git installé"
else
    print_error "Git n'est pas installé"
    echo "Installation de Git..."
    apt update
    apt install git -y
fi

echo ""
print_warning "CONFIGURATION PAYPLUG PRODUCTION"
echo "===================================="
echo ""
echo -e "${WHITE}🔑 Vous devez configurer les clés Payplug de production :${NC}"
echo ""
echo -e "${GRAY}   1. Connectez-vous à votre compte Payplug${NC}"
echo -e "${GRAY}   2. Activez votre clé LIVE (Clé LIVE)${NC}"
echo -e "${GRAY}   3. Récupérez vos clés de production :${NC}"
echo -e "${GRAY}      - PAYPLUG_SECRET_KEY (sk_live_...)${NC}"
echo -e "${GRAY}      - PAYPLUG_PUBLIC_KEY (pk_live_...)${NC}"
echo -e "${GRAY}      - PAYPLUG_WEBHOOK_SECRET (whsec_live_...)${NC}"
echo ""
echo -e "${GRAY}   4. Modifiez le fichier docker-compose.prod.yml${NC}"
echo -e "${GRAY}   5. Remplacez les valeurs CHANGE_ME_* par vos vraies clés${NC}"
echo ""

read -p "Avez-vous configuré vos clés Payplug de production ? (o/n): " configure
if [ "$configure" != "o" ] && [ "$configure" != "O" ]; then
    print_error "Veuillez d'abord configurer vos clés Payplug de production"
    echo ""
    print_info "Instructions détaillées :"
    print_step "1. Ouvrez docker-compose.prod.yml"
    print_step "2. Remplacez CHANGE_ME_PAYPLUG_SECRET_KEY_PRODUCTION par votre clé secrète"
    print_step "3. Remplacez CHANGE_ME_PAYPLUG_PUBLIC_KEY_PRODUCTION par votre clé publique"
    print_step "4. Remplacez CHANGE_ME_PAYPLUG_WEBHOOK_SECRET_PRODUCTION par votre secret webhook"
    print_step "5. Relancez ce script"
    exit 1
fi

echo ""
print_info "Déploiement Docker en production..."

# Arrêter les conteneurs existants
print_step "Arrêt des conteneurs existants..."
docker-compose -f docker-compose.prod.yml down

# Construire et démarrer les conteneurs
print_step "Construction et démarrage des conteneurs..."
docker-compose -f docker-compose.prod.yml up -d --build

# Attendre que les services soient prêts
print_step "Attente du démarrage des services..."
sleep 30

# Vérifier le statut des conteneurs
echo ""
print_info "Statut des conteneurs :"
docker-compose -f docker-compose.prod.yml ps

echo ""
print_info "Test du système de paiement..."

# Test de l'API de paiement
TEST_URL="https://rageroom.usilenziu.com"
TEST_RESERVATION_NUMBER="PRODTEST$(date +%Y%m%d%H%M%S)"

print_step "Test de création de paiement..."
PAYMENT_DATA='{
    "reservationNumber": "'$TEST_RESERVATION_NUMBER'",
    "amount": 50,
    "currency": "EUR",
    "customer": {
        "email": "test@usilenziu.com",
        "first_name": "Test",
        "last_name": "Production"
    },
    "metadata": {
        "test": true
    }
}'

# Test de création de paiement
if curl -s -X POST "$TEST_URL/api/payments/create" \
    -H "Content-Type: application/json" \
    -d "$PAYMENT_DATA" | grep -q "success"; then
    print_status "Paiement créé avec succès en production"
    echo -e "${GRAY}   Numéro de réservation: $TEST_RESERVATION_NUMBER${NC}"
else
    print_error "Échec de création du paiement en production"
fi

# Test de la page de retour
print_step "Test de la page de retour..."
RETURN_URL="$TEST_URL/reservation/payment/return?reservation=$TEST_RESERVATION_NUMBER&status=success"
if curl -s -o /dev/null -w "%{http_code}" "$RETURN_URL" | grep -q "200"; then
    print_status "Page de retour accessible en production"
else
    print_error "Page de retour non accessible"
fi

# Test du webhook
print_step "Test du webhook..."
WEBHOOK_DATA='{
    "type": "payment.paid",
    "data": {
        "id": "test_payment_'$TEST_RESERVATION_NUMBER'",
        "amount": 5000,
        "currency": "EUR",
        "metadata": {
            "reservation_number": "'$TEST_RESERVATION_NUMBER'"
        }
    }
}'

WEBHOOK_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$TEST_URL/api/webhooks/payplug" \
    -H "Content-Type: application/json" \
    -d "$WEBHOOK_DATA")

if [ "$WEBHOOK_RESPONSE" = "400" ]; then
    print_status "Webhook accessible (erreur 400 normale sans signature Payplug)"
elif [ "$WEBHOOK_RESPONSE" = "200" ]; then
    print_status "Webhook accessible en production"
else
    print_error "Erreur webhook: HTTP $WEBHOOK_RESPONSE"
fi

echo ""
print_status "DÉPLOIEMENT TERMINÉ"
echo "====================="
echo ""
print_status "Système Payplug déployé en production"
print_status "Tests de base effectués"
echo ""
print_info "URLs importantes :"
echo -e "${GRAY}   Site principal: $TEST_URL${NC}"
echo -e "${GRAY}   Réservation: $TEST_URL/reservation${NC}"
echo -e "${GRAY}   Administration: $TEST_URL/admin${NC}"
echo -e "${GRAY}   Page de retour: $TEST_URL/reservation/payment/return${NC}"
echo -e "${GRAY}   Webhook: $TEST_URL/api/webhooks/payplug${NC}"
echo ""
print_warning "Prochaines étapes :"
print_step "1. Tester le flux complet via l'interface utilisateur"
print_step "2. Vérifier les webhooks Payplug en production"
print_step "3. Tester les emails de confirmation"
print_step "4. Surveiller les logs pour détecter d'éventuels problèmes"
echo ""
print_info "Surveillance des logs :"
echo -e "${GRAY}   docker-compose -f docker-compose.prod.yml logs -f u-silenziu${NC}"
echo ""
print_status "Déploiement Payplug en production terminé avec succès !"