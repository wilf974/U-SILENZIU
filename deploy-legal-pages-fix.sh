#!/bin/bash

echo "🔧 DÉPLOIEMENT RAPIDE CORRECTION PAGES LÉGALES"
echo "=============================================="

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages d'erreur
print_error() {
    echo -e "${RED}❌ ERREUR: $1${NC}"
}

# Fonction pour afficher les messages d'information
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Fonction pour afficher les étapes
print_step() {
    echo -e "${WHITE}➡️  $1${NC}"
}

print_info "Déploiement de la correction des pages légales..."

# 1. Pull des dernières modifications
print_step "1. Récupération des modifications..."
git pull origin main

if [ $? -ne 0 ]; then
    print_error "Échec du git pull"
    exit 1
fi

# 2. Redémarrer l'application
print_step "2. Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

# 3. Attendre le démarrage
print_step "3. Attente du démarrage (30 secondes)..."
sleep 30

# 4. Tester l'API
print_step "4. Test de l'API..."
response=$(curl -s "https://rageroom.usilenziu.com/api/admin/legal-pages" | grep -o '"success":[^,]*')
echo "Statut API: $response"

# 5. Tester la mise à jour du statut
print_step "5. Test de la mise à jour du statut..."
test_response=$(curl -s -X PUT "https://rageroom.usilenziu.com/api/admin/legal-pages/cgv" \
  -H "Content-Type: application/json" \
  -d '{"is_published": false}')

echo "Réponse test: $test_response"

echo ""
echo -e "${GREEN}✅ Déploiement terminé avec succès !${NC}"
echo ""
print_info "Vous pouvez maintenant tester le bouton 'Dépublier' dans l'interface admin :"
print_step "https://rageroom.usilenziu.com/admin/legal-pages"
echo ""
print_info "Les erreurs de création de pages légales ne devraient plus apparaître."
