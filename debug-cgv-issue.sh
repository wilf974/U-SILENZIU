#!/bin/bash

echo "🔍 DIAGNOSTIC PROBLÈME CGV"
echo "=========================="

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

print_info "Diagnostic du problème avec les CGV..."

# 1. Vérifier l'état des services
print_step "1. Vérification des services Docker..."
docker compose -f docker-compose.prod.yml ps

# 2. Vérifier les données en base
print_step "2. État actuel des pages légales..."
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT page_type, title, is_published, updated_at
FROM legal_pages
ORDER BY page_type;"

# 3. Tester l'API GET
print_step "3. Test de l'API GET..."
curl -s "https://rageroom.usilenziu.com/api/admin/legal-pages" | jq '.'

# 4. Tester la mise à jour des CGV spécifiquement
print_step "4. Test de la mise à jour des CGV..."
response=$(curl -s -X PUT "https://rageroom.usilenziu.com/api/admin/legal-pages/cgv" \
  -H "Content-Type: application/json" \
  -d '{"is_published": false}')

echo "Réponse API CGV: $response"

# 5. Vérifier le statut après la mise à jour
print_step "5. Vérification du statut après mise à jour..."
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT page_type, title, is_published, updated_at
FROM legal_pages
WHERE page_type = 'cgv';"

# 6. Tester les autres pages pour comparaison
print_step "6. Test des autres pages..."
echo "Test mentions légales:"
curl -s -X PUT "https://rageroom.usilenziu.com/api/admin/legal-pages/legal" \
  -H "Content-Type: application/json" \
  -d '{"is_published": false}' | jq '.success'

echo "Test politique de confidentialité:"
curl -s -X PUT "https://rageroom.usilenziu.com/api/admin/legal-pages/privacy" \
  -H "Content-Type: application/json" \
  -d '{"is_published": true}' | jq '.success'

# 7. Vérifier les logs d'erreur
print_step "7. Vérification des erreurs récentes..."
docker compose -f docker-compose.prod.yml logs u-silenziu | grep -i "cgv\|error" | tail -10

echo ""
echo -e "${GREEN}✅ Diagnostic terminé !${NC}"
echo ""
print_info "D'après les résultats, analysez :"
print_step "- Le statut en base change-t-il ?"
print_step "- L'API retourne-t-elle une réponse de succès ?"
print_step "- Y a-t-il des erreurs spécifiques aux CGV ?"
