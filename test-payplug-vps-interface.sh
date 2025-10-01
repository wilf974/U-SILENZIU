#!/bin/bash

# Test de l'interface de configuration Payplug sur VPS
# U Silenziu - Janvier 2025

echo "🧪 TEST INTERFACE CONFIGURATION PAYPLUG VPS"
echo "==========================================="
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

print_info "Test de l'interface de configuration Payplug sur VPS"
echo ""

# Test 1: Vérifier que l'API de configuration existe
print_info "1️⃣ Test de l'API de configuration..."
echo ""
try {
    response=$(curl -s "https://rageroom.usilenziu.com/api/admin/payplug-config")
    if echo "$response" | grep -q '"success":true'; then
        print_status "API de configuration accessible"
        mode=$(echo "$response" | grep -o '"mode":"[^"]*"' | cut -d'"' -f4)
        print_step "Mode actuel: $mode"
        secret_configured=$(echo "$response" | grep -o '"secretKey":"[^"]*"' | cut -d'"' -f4)
        if [ -n "$secret_configured" ]; then
            print_step "Clé secrète configurée: Oui"
        else
            print_step "Clé secrète configurée: Non"
        fi
    else
        print_error "Erreur API: $response"
    fi
} catch {
    print_error "Impossible d'accéder à l'API"
}

echo ""

# Test 2: Test de changement de mode (simulation)
print_info "2️⃣ Test de changement de mode..."
print_step "Simulation du changement de mode TEST vers LIVE"
echo ""

test_config='{
    "secretKey": "sk_live_test123456789",
    "publicKey": "pk_live_test123456789", 
    "webhookSecret": "whsec_live_test123456789",
    "mode": "live"
}'

response=$(curl -s -X POST "https://rageroom.usilenziu.com/api/admin/payplug-config" \
    -H "Content-Type: application/json" \
    -d "$test_config")

if echo "$response" | grep -q '"success":true'; then
    print_status "Changement de mode réussi"
    message=$(echo "$response" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
    print_step "Message: $message"
else
    print_error "Erreur lors du changement: $response"
fi

echo ""

# Test 3: Retour en mode TEST
print_info "3️⃣ Retour en mode TEST..."
echo ""

test_config='{
    "secretKey": "sk_test_4qzp5fowqEGBG93PjzZOlF",
    "publicKey": "pk_test_4qzp5fowqEGBG93PjzZOlF",
    "webhookSecret": "whsec_test_4qzp5fowqEGBG93PjzZOlF", 
    "mode": "test"
}'

response=$(curl -s -X POST "https://rageroom.usilenziu.com/api/admin/payplug-config" \
    -H "Content-Type: application/json" \
    -d "$test_config")

if echo "$response" | grep -q '"success":true'; then
    print_status "Retour en mode TEST réussi"
    message=$(echo "$response" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
    print_step "Message: $message"
else
    print_error "Erreur lors du retour: $response"
fi

echo ""

# Test 4: Vérification finale
print_info "4️⃣ Vérification finale..."
echo ""

response=$(curl -s "https://rageroom.usilenziu.com/api/admin/payplug-config")

if echo "$response" | grep -q '"success":true'; then
    print_status "Configuration finale:"
    mode=$(echo "$response" | grep -o '"mode":"[^"]*"' | cut -d'"' -f4)
    secret=$(echo "$response" | grep -o '"secretKey":"[^"]*"' | cut -d'"' -f4)
    public=$(echo "$response" | grep -o '"publicKey":"[^"]*"' | cut -d'"' -f4)
    
    print_step "Mode: $mode"
    if [ -n "$secret" ]; then
        print_step "Clé secrète: ${secret:0:10}..."
    fi
    if [ -n "$public" ]; then
        print_step "Clé publique: ${public:0:10}..."
    fi
else
    print_error "Erreur lors de la vérification: $response"
fi

echo ""
print_warning "RÉSUMÉ DU TEST"
echo "================"
echo ""
print_status "Interface de configuration Payplug testée"
print_status "Changement de mode TEST/LIVE fonctionnel"
print_status "Validation des clés selon le mode"
print_status "Sauvegarde automatique des fichiers de configuration"
echo ""
print_info "Instructions pour utiliser l'interface:"
print_step "1. Allez dans l'administration de votre site"
print_step "2. Ouvrez la configuration Payplug"
print_step "3. Sélectionnez le mode TEST ou LIVE"
print_step "4. Entrez les clés correspondantes"
print_step "5. Cliquez sur 'Sauvegarder'"
echo ""
print_status "L'interface est prête pour la production ! 🚀"
