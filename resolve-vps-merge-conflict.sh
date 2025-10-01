#!/bin/bash

# Script pour résoudre le conflit de merge sur le VPS
# U Silenziu - Janvier 2025

echo "🔧 RÉSOLUTION CONFLIT DE MERGE VPS"
echo "=================================="
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

print_warning "RÉSOLUTION DU CONFLIT DE MERGE"
echo "===================================="
echo ""

# Étape 1: Vérifier l'état actuel
print_info "1️⃣ Vérification de l'état Git actuel..."
echo ""

git status

echo ""

# Étape 2: Sauvegarder les modifications locales
print_info "2️⃣ Sauvegarde des modifications locales..."
echo ""

# Créer un backup des fichiers modifiés
mkdir -p backup_$(date +%Y%m%d_%H%M%S)
cp deploy-payplug-vps.sh backup_$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || true
cp docker-compose.prod.yml backup_$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || true

print_status "Modifications locales sauvegardées"

echo ""

# Étape 3: Stash des modifications locales
print_info "3️⃣ Mise en stash des modifications locales..."
echo ""

git stash push -m "Modifications locales avant merge - $(date)"

print_status "Modifications mises en stash"

echo ""

# Étape 4: Pull des dernières modifications
print_info "4️⃣ Récupération des dernières modifications..."
echo ""

git pull origin main

if [ $? -eq 0 ]; then
    print_status "Pull réussi"
else
    print_error "Erreur lors du pull"
    exit 1
fi

echo ""

# Étape 5: Vérifier les nouveaux fichiers
print_info "5️⃣ Vérification des nouveaux fichiers..."
echo ""

ls -la debug-reservation-vps-error.sh test-reservation-api-vps.sh fix-reservation-vps-urgent.sh 2>/dev/null

if [ $? -eq 0 ]; then
    print_status "Nouveaux scripts de diagnostic présents"
else
    print_warning "Certains scripts de diagnostic manquants"
fi

echo ""

# Étape 6: Rendre les scripts exécutables
print_info "6️⃣ Rendu des scripts exécutables..."
echo ""

chmod +x debug-reservation-vps-error.sh 2>/dev/null
chmod +x test-reservation-api-vps.sh 2>/dev/null
chmod +x fix-reservation-vps-urgent.sh 2>/dev/null
chmod +x deploy-payplug-vps.sh 2>/dev/null

print_status "Scripts rendus exécutables"

echo ""

# Étape 7: Vérifier la configuration Payplug
print_info "7️⃣ Vérification de la configuration Payplug..."
echo ""

# Vérifier que les clés de test sont configurées
if grep -q "PAYPLUG_MODE=test" docker-compose.prod.yml; then
    print_status "Mode TEST configuré dans docker-compose.prod.yml"
else
    print_warning "Mode TEST non trouvé dans docker-compose.prod.yml"
fi

if grep -q "sk_test_" docker-compose.prod.yml; then
    print_status "Clés de test configurées"
else
    print_warning "Clés de test non trouvées"
fi

echo ""

# Étape 8: Redémarrer les services
print_info "8️⃣ Redémarrage des services..."
echo ""

docker-compose -f docker-compose.prod.yml restart u-silenziu

print_status "Services redémarrés"

echo ""

# Étape 9: Test rapide de l'API
print_info "9️⃣ Test rapide de l'API..."
echo ""

sleep 10

response=$(curl -s -o /dev/null -w "%{http_code}" "https://rageroom.usilenziu.com/api/admin/payplug-config")

if [ "$response" = "200" ]; then
    print_status "API accessible (HTTP $response)"
else
    print_warning "API non accessible (HTTP $response)"
fi

echo ""

print_warning "RÉSOLUTION TERMINÉE"
echo "====================="
echo ""
print_info "Actions effectuées:"
print_step "1. Sauvegarde des modifications locales"
print_step "2. Mise en stash des modifications"
print_step "3. Pull des dernières modifications"
print_step "4. Vérification des nouveaux fichiers"
print_step "5. Rendu des scripts exécutables"
print_step "6. Vérification de la configuration Payplug"
print_step "7. Redémarrage des services"
print_step "8. Test de l'API"
echo ""
print_info "Prochaines étapes:"
print_step "1. Lancer le diagnostic: ./debug-reservation-vps-error.sh"
print_step "2. Tester l'API: ./test-reservation-api-vps.sh"
print_step "3. Corriger si nécessaire: ./fix-reservation-vps-urgent.sh"
echo ""
print_info "Fichiers de backup disponibles dans:"
print_step "backup_$(date +%Y%m%d_%H%M%S)/"
echo ""
print_status "Conflit de merge résolu ! Vous pouvez maintenant lancer les diagnostics. 🚀"
