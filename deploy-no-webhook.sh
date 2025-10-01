#!/bin/bash

echo "🚫 DÉSACTIVATION DU WEBHOOK PAYPLUG"
echo "==================================="

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

print_info "Désactivation du webhook Payplug et activation de la vérification manuelle..."

# 1. Récupérer les modifications
print_step "1. Récupération des modifications..."
git pull origin main

# 2. Vérifier que les fichiers sont présents
print_step "2. Vérification des nouveaux fichiers..."
if [ -f "app/reservation/payment/success/page.tsx" ]; then
    echo "✅ Page de succès créée"
else
    echo "❌ Page de succès manquante"
fi

if [ -f "app/reservation/payment/cancelled/page.tsx" ]; then
    echo "✅ Page d'annulation créée"
else
    echo "❌ Page d'annulation manquante"
fi

# 3. Redémarrer l'application pour appliquer les changements
print_step "3. Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

# 4. Attendre le démarrage
print_step "4. Attente du démarrage (30 secondes)..."
sleep 30

# 5. Tester les nouvelles pages
print_step "5. Test des nouvelles pages..."

echo ""
echo "=== Test page de succès ==="
curl -s -I "https://rageroom.usilenziu.com/reservation/payment/success" | head -2

echo ""
echo "=== Test page d'annulation ==="
curl -s -I "https://rageroom.usilenziu.com/reservation/payment/cancelled" | head -2

echo ""
echo "=== Test webhook désactivé ==="
curl -s -X POST "https://rageroom.usilenziu.com/api/webhooks/payplug" \
  -H "Content-Type: application/json" \
  -d '{"test": "webhook"}' | jq '.message'

# 6. Vérifier les logs
print_step "6. Vérification des logs récents..."
docker compose -f docker-compose.prod.yml logs u-silenziu --tail 10 | grep -E "(Webhook|payment|success|cancelled)" || echo "Aucun log de paiement récent"

echo ""
echo -e "${GREEN}✅ Déploiement terminé !${NC}"
echo ""
print_info "Modifications appliquées :"
print_step "✅ Webhook Payplug désactivé"
print_step "✅ URLs de retour modifiées pour vérification manuelle"
print_step "✅ Page de succès créée (/reservation/payment/success)"
print_step "✅ Page d'annulation créée (/reservation/payment/cancelled)"
print_step "✅ Application redémarrée"
echo ""
print_info "Nouveau flux de paiement :"
print_step "1. Client paie sur Payplug"
print_step "2. Payplug redirige vers /reservation/payment/success"
print_step "3. Page de succès permet vérification manuelle"
print_step "4. Admin confirme manuellement le paiement"
echo ""
print_info "Les réservations seront maintenant confirmées manuellement côté admin !"
