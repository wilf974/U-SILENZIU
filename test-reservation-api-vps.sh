#!/bin/bash

# Test spécifique de l'API de réservation sur VPS
# U Silenziu - Janvier 2025

echo "🧪 TEST API RÉSERVATION VPS"
echo "==========================="
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

print_info "Test de l'API de réservation avec les données de l'interface"
echo ""

# Test 1: Vérifier que l'API est accessible
print_info "1️⃣ Test de connectivité API..."
echo ""

response=$(curl -s -o /dev/null -w "%{http_code}" "https://rageroom.usilenziu.com/api/reservations")

if [ "$response" = "405" ] || [ "$response" = "200" ]; then
    print_status "API de réservation accessible (HTTP $response)"
else
    print_error "API de réservation non accessible (HTTP $response)"
    exit 1
fi

echo ""

# Test 2: Test avec les données exactes de l'interface
print_info "2️⃣ Test avec les données de l'interface (Wilfred Maillot)..."
echo ""

# Données exactes de l'interface
reservation_data='{
    "room_id": 2,
    "date": "2025-01-15",
    "time_slot": "14:00-16:00",
    "number_of_people": 2,
    "first_name": "Wilfred",
    "last_name": "Maillot",
    "email": "jean.maillot14@gmail.com",
    "phone": "0782508406",
    "notes": "Test depuis l'interface"
}'

echo "Données envoyées:"
echo "$reservation_data" | jq '.' 2>/dev/null || echo "$reservation_data"
echo ""

echo "Envoi de la requête..."
response=$(curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
    -H "Content-Type: application/json" \
    -d "$reservation_data" \
    -w "HTTP_CODE:%{http_code}")

http_code=$(echo "$response" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
response_body=$(echo "$response" | sed 's/HTTP_CODE:[0-9]*$//')

echo "Code de réponse HTTP: $http_code"
echo "Réponse complète:"
echo "$response_body" | jq '.' 2>/dev/null || echo "$response_body"

if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
    print_status "Réservation créée avec succès !"
    
    # Extraire le numéro de réservation si disponible
    reservation_number=$(echo "$response_body" | jq -r '.reservation_number // .reservationNumber // .id // "N/A"' 2>/dev/null)
    if [ "$reservation_number" != "N/A" ] && [ "$reservation_number" != "null" ]; then
        print_step "Numéro de réservation: $reservation_number"
    fi
else
    print_error "Erreur lors de la création de la réservation (HTTP $http_code)"
    
    # Analyser l'erreur
    error_message=$(echo "$response_body" | jq -r '.error // .message // "Erreur inconnue"' 2>/dev/null)
    if [ "$error_message" != "Erreur inconnue" ] && [ "$error_message" != "null" ]; then
        print_step "Message d'erreur: $error_message"
    fi
fi

echo ""

# Test 3: Test avec des données minimales
print_info "3️⃣ Test avec des données minimales..."
echo ""

minimal_data='{
    "room_id": 2,
    "date": "2025-01-15",
    "time_slot": "16:00-18:00",
    "number_of_people": 1,
    "first_name": "Test",
    "last_name": "Minimal",
    "email": "test@example.com",
    "phone": "0123456789"
}'

echo "Données minimales envoyées:"
echo "$minimal_data" | jq '.' 2>/dev/null || echo "$minimal_data"
echo ""

response=$(curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
    -H "Content-Type: application/json" \
    -d "$minimal_data" \
    -w "HTTP_CODE:%{http_code}")

http_code=$(echo "$response" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
response_body=$(echo "$response" | sed 's/HTTP_CODE:[0-9]*$//')

echo "Code de réponse HTTP: $http_code"

if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
    print_status "Réservation minimale créée avec succès !"
else
    print_error "Erreur avec les données minimales (HTTP $http_code)"
    echo "Réponse: $response_body"
fi

echo ""

# Test 4: Vérifier les réservations existantes
print_info "4️⃣ Vérification des réservations existantes..."
echo ""

# Test de récupération des réservations (si l'endpoint existe)
response=$(curl -s "https://rageroom.usilenziu.com/api/reservations" \
    -w "HTTP_CODE:%{http_code}")

http_code=$(echo "$response" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
response_body=$(echo "$response" | sed 's/HTTP_CODE:[0-9]*$//')

if [ "$http_code" = "200" ]; then
    print_status "Réservations récupérées avec succès"
    echo "Nombre de réservations: $(echo "$response_body" | jq '. | length' 2>/dev/null || echo "N/A")"
else
    print_step "Endpoint de récupération non disponible (HTTP $http_code)"
fi

echo ""

# Test 5: Test de validation des données
print_info "5️⃣ Test de validation des données..."
echo ""

# Test avec des données invalides
invalid_data='{
    "room_id": "invalid",
    "date": "invalid-date",
    "time_slot": "invalid-time",
    "number_of_people": "invalid",
    "first_name": "",
    "last_name": "",
    "email": "invalid-email",
    "phone": ""
}'

echo "Test avec des données invalides..."
response=$(curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
    -H "Content-Type: application/json" \
    -d "$invalid_data" \
    -w "HTTP_CODE:%{http_code}")

http_code=$(echo "$response" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
response_body=$(echo "$response" | sed 's/HTTP_CODE:[0-9]*$//')

if [ "$http_code" = "400" ]; then
    print_status "Validation des données fonctionnelle (HTTP 400 attendu)"
else
    print_warning "Validation des données inattendue (HTTP $http_code)"
fi

echo ""

print_warning "RÉSUMÉ DES TESTS"
echo "==================="
echo ""
print_info "Tests effectués:"
print_step "1. Connectivité API de réservation"
print_step "2. Création avec données de l'interface"
print_step "3. Création avec données minimales"
print_step "4. Récupération des réservations existantes"
print_step "5. Validation des données invalides"
echo ""
print_info "Actions recommandées:"
print_step "1. Vérifier les logs de l'application pour des erreurs spécifiques"
print_step "2. Vérifier la structure de la base de données"
print_step "3. Tester avec des données différentes"
print_step "4. Vérifier les variables d'environnement"
echo ""
print_status "Tests terminés ! Consultez les résultats ci-dessus."
