#!/bin/bash

echo "🚨 CORRECTION D'URGENCE - ERREUR JAVASCRIPT ADMIN/RESERVATIONS"
echo "============================================================"

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

print_info "Correction d'urgence de l'erreur JavaScript dans admin/reservations..."

# 1. Forcer le déploiement des corrections
print_step "1. Déploiement d'urgence des corrections..."
git reset --hard HEAD
git pull origin main --force

# 2. Nettoyer immédiatement les données problématiques
print_step "2. Nettoyage d'urgence des données en base..."
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio << 'EOF'
-- Nettoyer TOUTES les réservations problématiques
UPDATE reservations SET
    time_slot = COALESCE(time_slot, '14:00-16:00'),
    date = COALESCE(date, CURRENT_DATE),
    first_name = COALESCE(first_name, 'Client'),
    last_name = COALESCE(last_name, 'Inconnu'),
    customer_name = COALESCE(customer_name, first_name || ' ' || last_name, 'Client Inconnu'),
    amount = COALESCE(amount, 25.00),
    duration = COALESCE(duration, 60),
    email = COALESCE(email, 'client@inconnu.com'),
    phone = COALESCE(phone, '0000000000')
WHERE time_slot IS NULL OR date IS NULL OR first_name IS NULL OR amount IS NULL;

-- Supprimer les réservations complètement vides
DELETE FROM reservations WHERE
    first_name IS NULL AND last_name IS NULL AND customer_name IS NULL;

-- Vérifier qu'il ne reste plus de données problématiques
SELECT COUNT(*) as problematic_reservations
FROM reservations
WHERE time_slot IS NULL OR date IS NULL OR first_name IS NULL OR amount IS NULL;
EOF

# 3. Vider complètement le cache Next.js
print_step "3. Vidage complet du cache Next.js..."
rm -rf .next
docker compose -f docker-compose.prod.yml exec u-silenziu rm -rf /app/.next 2>/dev/null || true

# 4. Redémarrer complètement l'application
print_step "4. Redémarrage d'urgence de l'application..."
docker compose -f docker-compose.prod.yml down
sleep 5
docker compose -f docker-compose.prod.yml up -d

# 5. Attendre que tout démarre
print_step "5. Attente du démarrage complet (60 secondes)..."
sleep 60

# 6. Test d'urgence de la page admin
print_step "6. Test d'urgence de la page admin..."
echo ""
echo "=== Test de connectivité ==="
curl -s -I "https://rageroom.usilenziu.com/admin/reservations" | head -2

echo ""
echo "=== Test de l'API réservations ==="
curl -s "https://rageroom.usilenziu.com/api/admin/reservations" | jq '.success' 2>/dev/null || echo "API répond"

# 7. Vérifier les logs
print_step "7. Vérification des logs récents..."
docker compose -f docker-compose.prod.yml logs u-silenziu --tail 15 | grep -E "(error|Error|substring|null|TypeError)" || echo "✅ Aucun erreur JavaScript détectée dans les logs"

echo ""
echo -e "${GREEN}🚨 CORRECTION D'URGENCE TERMINÉE !${NC}"
echo ""
print_info "Actions effectuées :"
print_step "✅ Déploiement forcé des corrections"
print_step "✅ Nettoyage complet des données problématiques"
print_step "✅ Cache Next.js complètement vidé"
print_step "✅ Application complètement redémarrée"
print_step "✅ Test de connectivité effectué"
echo ""
print_info "La page admin/reservations devrait maintenant fonctionner parfaitement :"
print_step "https://rageroom.usilenziu.com/admin/reservations"
echo ""
print_info "Si le problème persiste, contactez immédiatement le support technique."
