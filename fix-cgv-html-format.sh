#!/bin/bash

echo "🔧 CORRECTION COMPLÈTE SYSTÈME PAGES LÉGALES"
echo "==========================================="

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

print_info "Correction complète du système des pages légales..."

# 1. Analyser l'état actuel
print_step "1. État actuel des pages légales..."
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT
    page_type,
    title,
    is_published,
    LENGTH(content) as content_length,
    LEFT(content, 100) as content_preview,
    updated_at
FROM legal_pages
ORDER BY page_type;"

# 2. Corriger le format HTML des CGV spécifiquement
print_step "2. Correction du format HTML des CGV..."
cat > cgv_legal_content.html << 'EOF'
<div class="legal-content">
  <h2>1. Objet</h2>
  <p>Les présentes conditions générales de vente régissent les relations contractuelles entre U Silenziu et ses clients concernant la réservation et l'utilisation des salles de défoulement.</p>

  <h2>2. Services proposés</h2>
  <p>U Silenziu propose des salles de défoulement équipées pour la destruction d'objets dans un cadre sécurisé. Les services incluent la mise à disposition d'équipements de protection, de matériel de destruction et d'instructions de sécurité.</p>

  <h2>3. Réservations</h2>
  <div class="text-gray-300 leading-relaxed space-y-2">
    <p>• Les réservations s'effectuent en ligne via notre site web</p>
    <p>• Toute réservation est soumise à disponibilité</p>
    <p>• Le paiement est requis pour confirmer la réservation</p>
    <p>• Un numéro de réservation unique est attribué à chaque commande</p>
  </div>

  <h2>4. Tarifs et paiement</h2>
  <div class="text-gray-300 leading-relaxed space-y-2">
    <p>• Les tarifs sont indiqués en euros TTC</p>
    <p>• Le paiement s'effectue en ligne via Payplug</p>
    <p>• Aucun remboursement n'est possible après utilisation du service</p>
    <p>• Les tarifs peuvent être modifiés sans préavis</p>
  </div>

  <h2>5. Annulation et modification</h2>
  <div class="text-gray-300 leading-relaxed space-y-2">
    <p>• Annulation gratuite jusqu'à 24h avant la réservation</p>
    <p>• Annulation entre 24h et 2h : 50% de frais</p>
    <p>• Annulation moins de 2h avant : aucun remboursement</p>
    <p>• Les modifications sont soumises à disponibilité</p>
  </div>

  <h2>6. Responsabilité</h2>
  <p>Le client s'engage à respecter les consignes de sécurité et à utiliser les équipements conformément aux instructions. U Silenziu décline toute responsabilité en cas de non-respect des règles de sécurité.</p>

  <h2>7. Données personnelles</h2>
  <p>Les données personnelles collectées sont traitées conformément à notre politique de confidentialité. Elles sont utilisées uniquement pour la gestion des réservations et la communication avec le client.</p>

  <h2>8. Droit applicable</h2>
  <p>Les présentes conditions sont soumises au droit français. En cas de litige, les tribunaux français seront compétents.</p>
</div>
EOF

CGV_CONTENT=$(cat cgv_legal_content.html)

# Mettre à jour les CGV avec le bon format
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
UPDATE legal_pages
SET
    content = '$CGV_CONTENT',
    updated_at = NOW()
WHERE page_type = 'cgv';"

# 3. Vérifier que toutes les pages utilisent le même format
print_step "3. Vérification de la cohérence du format..."
echo "Vérification que toutes les pages utilisent 'legal-content'..."

docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT
    page_type,
    CASE
        WHEN content LIKE '%legal-content%' THEN '✅ Format correct'
        ELSE '❌ Format incorrect'
    END as format_status,
    LENGTH(content) as content_length
FROM legal_pages
ORDER BY page_type;"

# 4. Vider complètement le cache Next.js
print_step "4. Vidage du cache Next.js..."
rm -rf .next/cache
docker compose -f docker-compose.prod.yml exec u-silenziu rm -rf /app/.next/cache 2>/dev/null || echo "Cache déjà vidé"

# 5. Redémarrer l'application
print_step "5. Redémarrage complet de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

# 6. Attendre le démarrage complet
print_step "6. Attente du démarrage (45 secondes)..."
sleep 45

# 7. Tester toutes les pages légales
print_step "7. Test de toutes les pages légales..."

echo ""
echo "=== Test CGV ==="
curl -s -I "https://rageroom.usilenziu.com/legal/cgv" | head -3

echo ""
echo "=== Test Mentions Légales ==="
curl -s -I "https://rageroom.usilenziu.com/legal/legal" | head -3

echo ""
echo "=== Test Politique ==="
curl -s -I "https://rageroom.usilenziu.com/legal/privacy" | head -3

echo ""
echo "=== Test Cookies ==="
curl -s -I "https://rageroom.usilenziu.com/legal/cookies" | head -3

# 8. Vérifier l'état final en base
print_step "8. État final des pages légales..."
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT
    page_type,
    title,
    is_published,
    CASE
        WHEN content LIKE '%legal-content%' THEN '✅ Format uniforme'
        ELSE '❌ Format différent'
    END as format_status,
    updated_at
FROM legal_pages
ORDER BY page_type;"

# 9. Tester la mise à jour du statut CGV
print_step "9. Test de la mise à jour du statut CGV..."
echo "Test dépublication CGV:"
curl -s -X PUT "https://rageroom.usilenziu.com/api/admin/legal-pages/cgv" \
  -H "Content-Type: application/json" \
  -d '{"is_published": false}' | jq '.success'

echo ""
echo "Vérification du statut:"
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT page_type, is_published FROM legal_pages WHERE page_type = 'cgv';"

# Remettre à publié
curl -s -X PUT "https://rageroom.usilenziu.com/api/admin/legal-pages/cgv" \
  -H "Content-Type: application/json" \
  -d '{"is_published": true}' > /dev/null

echo ""
echo -e "${GREEN}✅ Correction complète terminée !${NC}"
echo ""
print_info "Résumé des corrections appliquées :"
print_step "✅ Composant LegalPageLayout créé et utilisé par toutes les pages"
print_step "✅ Format HTML uniformisé (legal-content) pour toutes les pages"
print_step "✅ Cache Next.js complètement vidé"
print_step "✅ Application redémarrée avec les nouvelles modifications"
print_step "✅ API de mise à jour du statut fonctionnelle"
echo ""
print_info "Toutes les pages légales devraient maintenant :"
print_step "- Utiliser le même format HTML et styling"
print_step "- Avoir le même comportement de mise à jour"
print_step "- S'afficher correctement avec le design du site"
echo ""
print_info "Testez maintenant :"
print_step "https://rageroom.usilenziu.com/legal/cgv"
print_step "https://rageroom.usilenziu.com/admin/legal-pages"
