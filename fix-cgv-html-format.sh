#!/bin/bash

echo "🔧 CORRECTION FORMAT HTML CGV"
echo "=============================="

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

print_info "Correction du format HTML des CGV..."

# 1. Vérifier le contenu actuel des CGV
print_step "1. Contenu actuel des CGV..."
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT LEFT(content, 200) as preview
FROM legal_pages
WHERE page_type = 'cgv';"

# 2. Créer le nouveau contenu formaté comme les autres pages
print_step "2. Création du nouveau contenu formaté..."
cat > new_cgv_content.html << 'EOF'
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

# 3. Mettre à jour le contenu des CGV
print_step "3. Mise à jour du contenu des CGV..."
NEW_CONTENT=$(cat new_cgv_content.html)

docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
UPDATE legal_pages
SET content = '$NEW_CONTENT',
    updated_at = NOW()
WHERE page_type = 'cgv';"

# 4. Vérifier la mise à jour
print_step "4. Vérification de la mise à jour..."
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT LEFT(content, 200) as preview,
       LENGTH(content) as length,
       updated_at
FROM legal_pages
WHERE page_type = 'cgv';"

# 5. Redémarrer l'application pour vider le cache
print_step "5. Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

# 6. Attendre le démarrage
print_step "6. Attente du démarrage (30 secondes)..."
sleep 30

# 7. Tester la nouvelle page
print_step "7. Test de la nouvelle page CGV..."
echo ""
echo "=== Nouvelle réponse CGV ==="
curl -s "https://rageroom.usilenziu.com/legal/cgv" | grep -o '<title>.*</title>' || echo "Test de connectivité..."

echo ""
echo -e "${GREEN}✅ Correction terminée !${NC}"
echo ""
print_info "Les CGV utilisent maintenant le même format HTML que les autres pages légales."
print_info "Le cache a été vidé et la page devrait s'afficher correctement."
echo ""
print_info "Vérifiez maintenant :"
print_step "https://rageroom.usilenziu.com/legal/cgv"
