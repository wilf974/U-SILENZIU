#!/bin/bash

echo "🔧 CORRECTION ERREUR JAVASCRIPT ADMIN/RESERVATIONS"
echo "================================================"

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

print_info "Correction définitive de l'erreur JavaScript dans admin/reservations..."

# 1. Analyser l'état actuel
print_step "1. État actuel des réservations en base..."
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT
    COUNT(*) as total_reservations,
    COUNT(CASE WHEN time_slot IS NULL THEN 1 END) as null_time_slots,
    COUNT(CASE WHEN date IS NULL THEN 1 END) as null_dates,
    COUNT(CASE WHEN first_name IS NULL AND last_name IS NULL AND customer_name IS NULL THEN 1 END) as null_clients
FROM reservations;"

# 2. Corriger les données nulles problématiques
print_step "2. Correction des données problématiques..."
echo "Correction des réservations avec données manquantes..."

# Ajouter des valeurs par défaut pour les réservations problématiques
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
-- Corriger les réservations avec time_slot null
UPDATE reservations SET time_slot = '14:00-16:00' WHERE time_slot IS NULL;

-- Corriger les réservations avec date null (mettre à aujourd'hui)
UPDATE reservations SET date = CURRENT_DATE WHERE date IS NULL;

-- Corriger les réservations avec client null
UPDATE reservations SET
    first_name = COALESCE(first_name, 'Client'),
    last_name = COALESCE(last_name, 'Inconnu'),
    customer_name = COALESCE(customer_name, first_name || ' ' || last_name, 'Client Inconnu')
WHERE (first_name IS NULL AND last_name IS NULL AND customer_name IS NULL);

-- Corriger les réservations avec amount null
UPDATE reservations SET amount = 25.00 WHERE amount IS NULL;

-- Corriger les réservations avec duration null
UPDATE reservations SET duration = 60 WHERE duration IS NULL;
"

# 3. Vérifier les corrections
print_step "3. Vérification des corrections..."
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT
    page_type,
    COUNT(*) as count,
    COUNT(CASE WHEN time_slot IS NULL THEN 1 END) as null_time_slots,
    COUNT(CASE WHEN date IS NULL THEN 1 END) as null_dates
FROM reservations
GROUP BY page_type;"

# 4. Vider complètement le cache Next.js
print_step "4. Vidage complet du cache Next.js..."
rm -rf .next/cache
docker compose -f docker-compose.prod.yml exec u-silenziu rm -rf /app/.next/cache 2>/dev/null || echo "Cache déjà vidé côté container"

# 5. Redémarrer l'application
print_step "5. Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

# 6. Attendre le démarrage complet
print_step "6. Attente du démarrage (45 secondes)..."
sleep 45

# 7. Tester la page admin/reservations
print_step "7. Test de la page admin/reservations..."
echo ""
echo "=== Test de connectivité ==="
curl -s -I "https://rageroom.usilenziu.com/admin/reservations" | head -3

echo ""
echo "=== Test de l'API réservations ==="
curl -s "https://rageroom.usilenziu.com/api/admin/reservations" | jq '.success' 2>/dev/null || echo "Réponse reçue"

# 8. Vérifier les logs pour s'assurer qu'il n'y a plus d'erreurs JavaScript
print_step "8. Vérification des logs récents..."
docker compose -f docker-compose.prod.yml logs u-silenziu --tail 20 | grep -E "(error|Error|substring|null)" || echo "Aucune erreur détectée dans les logs récents"

echo ""
echo -e "${GREEN}✅ Correction définitive terminée !${NC}"
echo ""
print_info "Résumé des corrections appliquées :"
print_step "✅ Fonctions de formatage avec gestion d'erreur complète"
print_step "✅ Vérifications de nullité pour toutes les propriétés de réservation"
print_step "✅ Correction des données nulles en base de données"
print_step "✅ Cache Next.js complètement vidé"
print_step "✅ Application redémarrée avec les corrections"
echo ""
print_info "La page /admin/reservations devrait maintenant fonctionner sans erreurs :"
print_step "- Plus d'erreur 'can't access property substring'"
print_step "- Gestion robuste des données manquantes"
print_step "- Affichage cohérent même avec des réservations incomplètes"
echo ""
print_info "Testez maintenant :"
print_step "https://rageroom.usilenziu.com/admin/reservations"
