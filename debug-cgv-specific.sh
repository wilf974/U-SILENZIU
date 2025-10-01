#!/bin/bash

echo "🔍 DIAGNOSTIC SPÉCIFIQUE CGV"
echo "============================"

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

print_info "Diagnostic spécifique du problème CGV..."

# 1. Vérifier les données en base pour chaque type
print_step "1. Comparaison des données en base..."
echo "CGV:"
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT page_type, title, is_published, LENGTH(content) as content_length, updated_at
FROM legal_pages
WHERE page_type = 'cgv';"

echo ""
echo "Mentions légales:"
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT page_type, title, is_published, LENGTH(content) as content_length, updated_at
FROM legal_pages
WHERE page_type = 'legal';"

echo ""
echo "Politique de confidentialité:"
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT page_type, title, is_published, LENGTH(content) as content_length, updated_at
FROM legal_pages
WHERE page_type = 'privacy';"

# 2. Tester l'API pour chaque page
print_step "2. Test des API pour chaque page..."
echo ""
echo "API CGV:"
curl -s "https://rageroom.usilenziu.com/api/legal-pages/cgv" | jq '.'

echo ""
echo "API Mentions légales:"
curl -s "https://rageroom.usilenziu.com/api/legal-pages/legal" | jq '.'

echo ""
echo "API Politique de confidentialité:"
curl -s "https://rageroom.usilenziu.com/api/legal-pages/privacy" | jq '.'

# 3. Vérifier le contenu HTML brut
print_step "3. Vérification du contenu brut..."
echo ""
echo "Contenu CGV (premiers 200 caractères):"
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT LEFT(content, 200) as content_preview
FROM legal_pages
WHERE page_type = 'cgv';"

echo ""
echo "Contenu Mentions légales (premiers 200 caractères):"
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT LEFT(content, 200) as content_preview
FROM legal_pages
WHERE page_type = 'legal';"

# 4. Tester la mise à jour du statut
print_step "4. Test de la mise à jour du statut CGV..."
echo "Test dépublication CGV:"
curl -s -X PUT "https://rageroom.usilenziu.com/api/admin/legal-pages/cgv" \
  -H "Content-Type: application/json" \
  -d '{"is_published": false}' | jq '.'

echo ""
echo "Vérification statut après mise à jour:"
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT page_type, title, is_published, updated_at
FROM legal_pages
WHERE page_type = 'cgv';"

# 5. Remettre le statut à publié
print_step "5. Remise à publié..."
curl -s -X PUT "https://rageroom.usilenziu.com/api/admin/legal-pages/cgv" \
  -H "Content-Type: application/json" \
  -d '{"is_published": true}' | jq '.'

echo ""
echo -e "${GREEN}✅ Diagnostic terminé !${NC}"
echo ""
print_info "Comparez les résultats pour identifier les différences entre CGV et les autres pages."
print_info "Les différences peuvent être dans :"
print_step "- La longueur du contenu"
print_step "- La structure du HTML"
print_step "- Les métadonnées"
print_step "- Les données de mise à jour"
