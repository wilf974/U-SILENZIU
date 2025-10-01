#!/bin/bash

echo "🔍 DIAGNOSTIC AFFICHAGE CGV"
echo "==========================="

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

print_info "Diagnostic de l'affichage des CGV..."

# 1. Comparer le contenu brut en base
print_step "1. Comparaison du contenu HTML brut..."
echo "=== CONTENU CGV ==="
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT LEFT(content, 500) as content_preview
FROM legal_pages
WHERE page_type = 'cgv';"

echo ""
echo "=== CONTENU MENTIONS LÉGALES ==="
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT LEFT(content, 500) as content_preview
FROM legal_pages
WHERE page_type = 'legal';"

echo ""
echo "=== CONTENU POLITIQUE ==="
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT LEFT(content, 500) as content_preview
FROM legal_pages
WHERE page_type = 'privacy';"

# 2. Vérifier les métadonnées
print_step "2. Comparaison des métadonnées..."
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT
    page_type,
    title,
    LENGTH(content) as content_length,
    meta_description,
    seo_title,
    updated_at
FROM legal_pages
ORDER BY page_type;"

# 3. Tester les réponses HTTP
print_step "3. Test des réponses HTTP..."
echo ""
echo "=== Réponse CGV ==="
curl -s "https://rageroom.usilenziu.com/legal/cgv" | head -20

echo ""
echo "=== Réponse Mentions Légales ==="
curl -s "https://rageroom.usilenziu.com/legal/legal" | head -20

echo ""
echo "=== Réponse Politique ==="
curl -s "https://rageroom.usilenziu.com/legal/privacy" | head -20

# 4. Vérifier les headers HTTP
print_step "4. Comparaison des headers HTTP..."
echo ""
echo "=== Headers CGV ==="
curl -s -I "https://rageroom.usilenziu.com/legal/cgv"

echo ""
echo "=== Headers Mentions Légales ==="
curl -s -I "https://rageroom.usilenziu.com/legal/legal"

# 5. Vérifier si les fichiers de page existent
print_step "5. Vérification des fichiers de page..."
echo ""
echo "=== Structure des fichiers ==="
find app/legal -name "page.tsx" -exec echo "Fichier: {}" \; -exec head -5 {} \;

# 6. Vérifier le cache Next.js
print_step "6. Vérification du cache Next.js..."
echo ""
echo "=== Cache des pages ==="
ls -la .next/server/pages/legal/ 2>/dev/null || echo "Dossier .next non trouvé"

echo ""
echo -e "${GREEN}✅ Diagnostic terminé !${NC}"
echo ""
print_info "Comparez les résultats pour identifier les différences :"
print_step "- Le contenu HTML est-il similaire ?"
print_step "- Les métadonnées sont-elles cohérentes ?"
print_step "- Les headers HTTP sont-ils identiques ?"
print_step "- Les fichiers de page sont-ils similaires ?"
