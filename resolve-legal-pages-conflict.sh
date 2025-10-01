#!/bin/bash

echo "🔧 RÉSOLUTION CONFLIT PAGES LÉGALES VPS"
echo "======================================="

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

print_info "Résolution du conflit de merge pour les pages légales..."

# 1. Sauvegarder les modifications locales
print_step "1. Sauvegarde des modifications locales..."
cp fix-cgv-page-vps.sh fix-cgv-page-vps.sh.backup 2>/dev/null || echo "Fichier fix-cgv-page-vps.sh non trouvé"
cp init-legal-pages-vps.sh init-legal-pages-vps.sh.backup 2>/dev/null || echo "Fichier init-legal-pages-vps.sh non trouvé"

# 2. Supprimer les fichiers en conflit
print_step "2. Suppression des fichiers en conflit..."
rm -f fix-cgv-page-vps.sh
rm -f init-legal-pages-vps.sh

# 3. Effectuer le pull
print_step "3. Récupération des dernières modifications..."
git pull origin main

if [ $? -eq 0 ]; then
    print_info "✅ Pull réussi !"
else
    print_error "Échec du pull"
    exit 1
fi

# 4. Redémarrer l'application
print_step "4. Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

# 5. Attendre le démarrage
print_step "5. Attente du démarrage (30 secondes)..."
sleep 30

# 6. Vérifier le statut
print_step "6. Vérification du statut des services..."
docker compose -f docker-compose.prod.yml ps

echo ""
echo -e "${GREEN}✅ Résolution du conflit terminée avec succès !${NC}"
echo ""
print_info "Les pages légales sont maintenant à jour :"
print_step "- https://rageroom.usilenziu.com/legal/cgv"
print_step "- https://rageroom.usilenziu.com/legal/legal"
print_step "- https://rageroom.usilenziu.com/legal/privacy"
echo ""
print_info "Pour corriger l'erreur admin/reservations, exécutez :"
print_step "./fix-admin-reservations-urgent.sh"
