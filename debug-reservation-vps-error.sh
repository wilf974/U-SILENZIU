#!/bin/bash

# Script de diagnostic pour l'erreur de réservation sur VPS
# U Silenziu - Janvier 2025

echo "🔍 DIAGNOSTIC ERREUR RÉSERVATION VPS"
echo "===================================="
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

print_info "Diagnostic de l'erreur de réservation sur VPS"
echo ""

# Test 1: Vérifier l'état des services Docker
print_info "1️⃣ Vérification des services Docker..."
echo ""

docker-compose -f docker-compose.prod.yml ps

echo ""

# Test 2: Vérifier les logs de l'application
print_info "2️⃣ Logs de l'application (dernières 50 lignes)..."
echo ""

docker-compose -f docker-compose.prod.yml logs --tail=50 u-silenziu

echo ""

# Test 3: Vérifier la connectivité à la base de données
print_info "3️⃣ Test de connectivité à la base de données..."
echo ""

# Test de connexion PostgreSQL
docker-compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenziu -c "SELECT version();" 2>/dev/null

if [ $? -eq 0 ]; then
    print_status "Base de données accessible"
else
    print_error "Problème de connexion à la base de données"
fi

echo ""

# Test 4: Vérifier la structure de la table reservations
print_info "4️⃣ Vérification de la structure de la table reservations..."
echo ""

docker-compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenziu -c "\d reservations" 2>/dev/null

echo ""

# Test 5: Tester l'API de réservation directement
print_info "5️⃣ Test de l'API de réservation..."
echo ""

# Données de test pour la réservation
test_reservation='{
    "room_id": 2,
    "date": "2025-01-15",
    "time_slot": "14:00-16:00",
    "number_of_people": 2,
    "first_name": "Test",
    "last_name": "User",
    "email": "test@example.com",
    "phone": "0123456789",
    "notes": "Test de diagnostic"
}'

echo "Envoi d'une requête de test à l'API de réservation..."
echo ""

response=$(curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
    -H "Content-Type: application/json" \
    -d "$test_reservation" \
    -w "HTTP_CODE:%{http_code}")

http_code=$(echo "$response" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)
response_body=$(echo "$response" | sed 's/HTTP_CODE:[0-9]*$//')

echo "Code de réponse HTTP: $http_code"
echo "Réponse: $response_body"

if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
    print_status "API de réservation fonctionnelle"
else
    print_error "Erreur API de réservation (HTTP $http_code)"
fi

echo ""

# Test 6: Vérifier les variables d'environnement
print_info "6️⃣ Vérification des variables d'environnement..."
echo ""

docker-compose -f docker-compose.prod.yml exec u-silenziu env | grep -E "(DATABASE_URL|POSTGRES_|PAYPLUG_)" | head -10

echo ""

# Test 7: Vérifier les permissions des fichiers
print_info "7️⃣ Vérification des permissions..."
echo ""

ls -la env.prod docker-compose.prod.yml 2>/dev/null

echo ""

# Test 8: Vérifier l'espace disque
print_info "8️⃣ Vérification de l'espace disque..."
echo ""

df -h

echo ""

# Test 9: Vérifier la mémoire disponible
print_info "9️⃣ Vérification de la mémoire..."
echo ""

free -h

echo ""

# Test 10: Vérifier les erreurs récentes dans les logs système
print_info "🔟 Vérification des erreurs système récentes..."
echo ""

journalctl --since "1 hour ago" --no-pager | grep -i error | tail -5

echo ""

print_warning "RÉSUMÉ DU DIAGNOSTIC"
echo "========================"
echo ""
print_info "Points à vérifier:"
print_step "1. Les services Docker sont-ils tous démarrés ?"
print_step "2. Y a-t-il des erreurs dans les logs de l'application ?"
print_step "3. La base de données est-elle accessible ?"
print_step "4. La structure de la table reservations est-elle correcte ?"
print_step "5. L'API de réservation répond-elle correctement ?"
print_step "6. Les variables d'environnement sont-elles correctes ?"
print_step "7. Y a-t-il des problèmes de permissions ?"
print_step "8. L'espace disque et la mémoire sont-ils suffisants ?"
echo ""
print_info "Actions recommandées:"
print_step "1. Redémarrer les services si nécessaire"
print_step "2. Vérifier la configuration de la base de données"
print_step "3. Tester l'API de réservation avec des données valides"
print_step "4. Vérifier les logs pour des erreurs spécifiques"
echo ""
print_status "Diagnostic terminé ! Consultez les résultats ci-dessus."
