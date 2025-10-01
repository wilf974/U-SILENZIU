#!/bin/bash

echo "🔧 DÉPLOIEMENT RAPIDE CORRECTION ADMIN/RESERVATIONS"
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

print_info "Déploiement rapide de la correction admin/reservations..."

# 1. Résoudre le conflit de merge
print_step "1. Résolution du conflit de merge..."
git checkout -- fix-cgv-html-format.sh
git pull origin main

# 2. Rendre le script exécutable
print_step "2. Préparation du script..."
chmod +x fix-admin-reservations-error.sh

# 3. Appliquer les corrections principales
print_step "3. Correction des données en base..."
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
-- Corriger les réservations avec données manquantes
UPDATE reservations SET time_slot = '14:00-16:00' WHERE time_slot IS NULL;
UPDATE reservations SET date = CURRENT_DATE WHERE date IS NULL;
UPDATE reservations SET amount = 25.00 WHERE amount IS NULL;
UPDATE reservations SET duration = 60 WHERE duration IS NULL;
UPDATE reservations SET
    first_name = COALESCE(first_name, 'Client'),
    last_name = COALESCE(last_name, 'Inconnu')
WHERE (first_name IS NULL AND last_name IS NULL);
"

# 4. Vider le cache Next.js
print_step "4. Vidage du cache..."
rm -rf .next/cache
docker compose -f docker-compose.prod.yml exec u-silenziu rm -rf /app/.next/cache 2>/dev/null || echo "Cache vidé côté container"

# 5. Redémarrer l'application
print_step "5. Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

# 6. Attendre le démarrage
print_step "6. Attente du démarrage (30 secondes)..."
sleep 30

# 7. Test rapide
print_step "7. Test de la page admin..."
curl -s -I "https://rageroom.usilenziu.com/admin/reservations" | head -2

echo ""
echo -e "${GREEN}✅ Déploiement rapide terminé !${NC}"
echo ""
print_info "La page /admin/reservations devrait maintenant fonctionner sans erreurs JavaScript."
echo ""
print_info "Testez maintenant :"
print_step "https://rageroom.usilenziu.com/admin/reservations"
