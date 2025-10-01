#!/bin/bash

# Script de test Payplug en production
# U Silenziu - Janvier 2025
# Usage: ./test-payplug-production.sh

echo "🧪 TEST PAYPLUG EN PRODUCTION"
echo "============================="
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

# Configuration
PROD_URL="https://rageroom.usilenziu.com"
TEST_RESERVATION_NUMBER="PRODTEST$(date +%Y%m%d%H%M%S)"

echo -e "${CYAN}URL de production: $PROD_URL${NC}"
echo -e "${CYAN}Numéro de test: $TEST_RESERVATION_NUMBER${NC}"
echo ""

# Test 1: Vérification de l'accessibilité du site
print_info "Test 1: Vérification de l'accessibilité du site"
print_step "Test de la page d'accueil..."

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$PROD_URL")
if [ "$HTTP_CODE" = "200" ]; then
    print_status "Site accessible (HTTP $HTTP_CODE)"
else
    print_error "Site non accessible (HTTP $HTTP_CODE)"
    exit 1
fi

# Test 2: Vérification de la page de réservation
print_info "Test 2: Vérification de la page de réservation"
print_step "Test de la page de réservation..."

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$PROD_URL/reservation")
if [ "$HTTP_CODE" = "200" ]; then
    print_status "Page de réservation accessible (HTTP $HTTP_CODE)"
else
    print_error "Page de réservation non accessible (HTTP $HTTP_CODE)"
fi

# Test 3: Vérification de l'interface d'administration
print_info "Test 3: Vérification de l'interface d'administration"
print_step "Test de l'interface d'administration..."

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$PROD_URL/admin")
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
    print_status "Interface d'administration accessible (HTTP $HTTP_CODE)"
else
    print_error "Interface d'administration non accessible (HTTP $HTTP_CODE)"
fi

# Test 4: Test de l'API de paiement
print_info "Test 4: Test de l'API de paiement"
print_step "Création d'un paiement test..."

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

PAYMENT_RESPONSE=$(curl -s -X POST "$PROD_URL/api/payments/create" \
    -H "Content-Type: application/json" \
    -d "$PAYMENT_DATA")

if echo "$PAYMENT_RESPONSE" | grep -q "success.*true"; then
    print_status "Paiement créé avec succès"
    PAYMENT_URL=$(echo "$PAYMENT_RESPONSE" | grep -o '"payment_url":"[^"]*"' | cut -d'"' -f4)
    echo -e "${GRAY}   URL Payplug: $PAYMENT_URL${NC}"
    echo -e "${GRAY}   Numéro de réservation: $TEST_RESERVATION_NUMBER${NC}"
else
    print_error "Échec de création du paiement"
    echo -e "${GRAY}   Réponse: $PAYMENT_RESPONSE${NC}"
fi

# Test 5: Test de la page de retour
print_info "Test 5: Test de la page de retour"
print_step "Test de la page de retour (succès)..."

RETURN_URL="$PROD_URL/reservation/payment/return?reservation=$TEST_RESERVATION_NUMBER&status=success"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$RETURN_URL")
if [ "$HTTP_CODE" = "200" ]; then
    print_status "Page de retour accessible (HTTP $HTTP_CODE)"
else
    print_error "Page de retour non accessible (HTTP $HTTP_CODE)"
fi

print_step "Test de la page de retour (annulation)..."

CANCEL_URL="$PROD_URL/reservation/payment/return?reservation=$TEST_RESERVATION_NUMBER&status=cancelled"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$CANCEL_URL")
if [ "$HTTP_CODE" = "200" ]; then
    print_status "Page de retour (annulation) accessible (HTTP $HTTP_CODE)"
else
    print_error "Page de retour (annulation) non accessible (HTTP $HTTP_CODE)"
fi

# Test 6: Test du webhook
print_info "Test 6: Test du webhook"
print_step "Test du webhook Payplug..."

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

WEBHOOK_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$PROD_URL/api/webhooks/payplug" \
    -H "Content-Type: application/json" \
    -d "$WEBHOOK_DATA")

if [ "$WEBHOOK_RESPONSE" = "400" ]; then
    print_status "Webhook accessible (erreur 400 normale sans signature Payplug)"
elif [ "$WEBHOOK_RESPONSE" = "200" ]; then
    print_status "Webhook accessible en production (HTTP $WEBHOOK_RESPONSE)"
else
    print_error "Erreur webhook (HTTP $WEBHOOK_RESPONSE)"
fi

# Test 7: Test des APIs publiques
print_info "Test 7: Test des APIs publiques"
print_step "Test de l'API des salles..."

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$PROD_URL/api/rooms")
if [ "$HTTP_CODE" = "200" ]; then
    print_status "API des salles accessible (HTTP $HTTP_CODE)"
else
    print_error "API des salles non accessible (HTTP $HTTP_CODE)"
fi

print_step "Test de l'API des sections homepage..."

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$PROD_URL/api/homepage-sections")
if [ "$HTTP_CODE" = "200" ]; then
    print_status "API des sections homepage accessible (HTTP $HTTP_CODE)"
else
    print_error "API des sections homepage non accessible (HTTP $HTTP_CODE)"
fi

# Test 8: Test de la configuration HTTPS
print_info "Test 8: Test de la configuration HTTPS"
print_step "Vérification du certificat SSL..."

SSL_INFO=$(echo | openssl s_client -connect rageroom.usilenziu.com:443 -servername rageroom.usilenziu.com 2>/dev/null | openssl x509 -noout -dates 2>/dev/null)

if [ $? -eq 0 ]; then
    print_status "Certificat SSL valide"
    echo -e "${GRAY}   $SSL_INFO${NC}"
else
    print_error "Problème avec le certificat SSL"
fi

# Résumé des tests
echo ""
print_status "RÉSUMÉ DES TESTS"
echo "=================="
echo ""
print_info "URLs testées :"
echo -e "${GRAY}   Site principal: $PROD_URL${NC}"
echo -e "${GRAY}   Réservation: $PROD_URL/reservation${NC}"
echo -e "${GRAY}   Administration: $PROD_URL/admin${NC}"
echo -e "${GRAY}   Page de retour: $PROD_URL/reservation/payment/return${NC}"
echo -e "${GRAY}   Webhook: $PROD_URL/api/webhooks/payplug${NC}"
echo ""
print_info "APIs testées :"
echo -e "${GRAY}   /api/payments/create${NC}"
echo -e "${GRAY}   /api/rooms${NC}"
echo -e "${GRAY}   /api/homepage-sections${NC}"
echo ""
print_warning "Prochaines étapes :"
print_step "1. Tester le flux complet via l'interface utilisateur"
print_step "2. Vérifier les webhooks Payplug en production"
print_step "3. Tester les emails de confirmation"
print_step "4. Surveiller les logs pour détecter d'éventuels problèmes"
echo ""
print_status "Tests de production terminés !"
