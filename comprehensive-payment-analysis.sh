#!/bin/bash

echo "🔍 ANALYSE COMPLÈTE DU PROBLÈME DE PAIEMENT"
echo "=========================================="

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

print_info "Analyse complète du problème de paiement causant l'erreur JavaScript..."

# 1. Analyser l'état actuel de la base de données
print_step "1. Analyse complète de la base de données..."
echo "=== ÉTAT DES RÉSERVATIONS ==="
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT
    COUNT(*) as total_reservations,
    COUNT(CASE WHEN time_slot IS NULL THEN 1 END) as null_time_slots,
    COUNT(CASE WHEN time IS NULL THEN 1 END) as null_time,
    COUNT(CASE WHEN date IS NULL THEN 1 END) as null_dates,
    COUNT(CASE WHEN first_name IS NULL THEN 1 END) as null_first_names,
    COUNT(CASE WHEN last_name IS NULL THEN 1 END) as null_last_names,
    COUNT(CASE WHEN email IS NULL THEN 1 END) as null_emails,
    COUNT(CASE WHEN phone IS NULL THEN 1 END) as null_phones,
    COUNT(CASE WHEN amount IS NULL THEN 1 END) as null_amounts,
    COUNT(CASE WHEN duration IS NULL THEN 1 END) as null_durations
FROM reservations;"

echo ""
echo "=== RÉSERVATIONS RÉCENTES (DERNIÈRES 5) ==="
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT
    id,
    reservation_number,
    time_slot,
    time,
    date,
    first_name,
    last_name,
    email,
    amount,
    duration,
    created_at
FROM reservations
ORDER BY created_at DESC
LIMIT 5;"

# 2. Analyser les logs d'erreur récents
print_step "2. Analyse des logs d'erreur récents..."
echo "=== ERREURS JAVASCRIPT RÉCENTES ==="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail 50 | grep -E "(error|Error|TypeError|substring|null)" | tail -10

echo ""
echo "=== ERREURS DE PAIEMENT RÉCENTES ==="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail 50 | grep -E "(payment|paiement|reservation)" | tail -10

# 3. Tester l'API de création de réservation
print_step "3. Test de l'API de création de réservation..."
echo "=== TEST AVEC DONNÉES COMPLÈTES ==="
curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "room_id": 1,
    "date": "2025-01-15",
    "timeSlot": "14:00-16:00",
    "duration": 60,
    "numberOfPeople": 2,
    "firstName": "Test",
    "lastName": "Client",
    "email": "test@client.com",
    "phone": "0123456789",
    "roomName": "Salle 1"
  }' | jq '.'

echo ""
echo "=== TEST AVEC DONNÉES MINIMALES ==="
curl -s -X POST "https://rageroom.usilenziu.com/api/reservations" \
  -H "Content-Type: application/json" \
  -d '{
    "room_id": 1,
    "date": "2025-01-15",
    "timeSlot": "14:00-16:00",
    "firstName": "Test",
    "email": "test@client.com"
  }' | jq '.'

# 4. Analyser les données problématiques potentielles
print_step "4. Recherche de données problématiques..."
echo "=== RÉSERVATIONS AVEC TIME_SLOT NULL ==="
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, reservation_number, time_slot, time, created_at
FROM reservations
WHERE time_slot IS NULL
ORDER BY created_at DESC
LIMIT 5;"

echo ""
echo "=== RÉSERVATIONS AVEC TIME NULL ==="
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, reservation_number, time_slot, time, created_at
FROM reservations
WHERE time IS NULL
ORDER BY created_at DESC
LIMIT 5;"

# 5. Analyser le problème côté serveur
print_step "5. Analyse du problème côté serveur..."
echo "=== VÉRIFICATION DU CODE SOURCE ==="
echo "Fichier admin/reservations/page.tsx - fonction formatTime:"
grep -A 10 -B 2 "formatTime" app/admin/\(protected\)/reservations/page.tsx

echo ""
echo "=== VÉRIFICATION DE L'API DE CRÉATION ==="
echo "Fichier api/reservations/route.ts - fonction sanitizeReservationData:"
grep -A 20 "sanitizeReservationData" app/api/reservations/route.ts

# 6. Créer un rapport de diagnostic
print_step "6. Rapport de diagnostic..."

cat > payment_issue_report.txt << 'EOF'
RAPPORT D'ANALYSE - PROBLÈME DE PAIEMENT CAUSANT ERREUR JAVASCRIPT
================================================================

PROBLÈME IDENTIFIÉ :
-------------------
L'erreur "can't access property 'substring', e is null" se produit dans la fonction formatTime()
lorsque timeString est null ou undefined.

SOURCE DE L'ERREUR :
-------------------
- Ligne 299 dans app/admin/(protected)/reservations/page.tsx
- Fonction : formatTime(timeString: string)
- Code : return timeString.substring(0, 5)

CAUSES POSSIBLES :
-----------------
1. Réservations créées avec time_slot = null
2. Réservations créées avec time = null
3. Données corrompues dans la base de données
4. API de création qui ne nettoie pas correctement les données

SOLUTIONS À IMPLÉMENTER :
------------------------
1. ✅ Fonction formatTime avec gestion d'erreur (DÉJÀ FAIT)
2. ✅ Fonction sanitizeReservationData côté serveur (DÉJÀ FAIT)
3. ✅ Nettoyage automatique des données (DÉJÀ FAIT)
4. ❓ Vérification que les corrections sont déployées sur le VPS

ACTIONS IMMÉDIATES :
-------------------
1. Vérifier que les corrections sont déployées sur le VPS
2. Nettoyer manuellement les données problématiques restantes
3. Tester avec un nouveau paiement
4. Surveiller les logs en temps réel

COMMANDE DE DÉPLOIEMENT :
-----------------------
./emergency-fix.sh

COMMANDE DE SURVEILLANCE :
------------------------
tail -f /var/log/docker/u-silenziu-app-prod.log | grep -E "(error|Error|substring|null)"
EOF

echo "=== RAPPORT DE DIAGNOSTIC CRÉÉ ==="
cat payment_issue_report.txt

echo ""
echo -e "${GREEN}✅ Analyse terminée !${NC}"
echo ""
print_info "Le rapport de diagnostic a été créé : payment_issue_report.txt"
echo ""
print_info "Prochaines étapes :"
print_step "1. Déployer les corrections avec : ./emergency-fix.sh"
print_step "2. Tester un paiement côté client"
print_step "3. Vérifier que l'erreur disparaît"
echo ""
print_info "Le problème devrait être résolu après le déploiement des corrections."
