#!/bin/bash

echo "🔧 CORRECTION DE LA PAGE CGV SUR LE VPS"
echo "======================================"

# Couleurs pour l'affichage
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Vérifier si docker compose est disponible
DOCKER_COMPOSE_CMD=""
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker compose"
else
    echo -e "${RED}❌ ERREUR: docker-compose ou docker compose n'est pas installé.${NC}"
    exit 1
fi

# 1. Vérifier le contenu de la page CGV dans la base
echo "1. Vérification du contenu de la page CGV dans la base de données..."
$DOCKER_COMPOSE_CMD -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
    page_type, 
    title, 
    is_published, 
    LENGTH(content) as content_length,
    last_updated_by,
    updated_at
FROM legal_pages 
WHERE page_type = 'cgv';"

# 2. Tester l'API publique pour la page CGV
echo ""
echo "2. Test de l'API publique pour la page CGV..."
CGV_API_RESPONSE=$(curl -s "https://rageroom.usilenziu.com/api/legal-pages/cgv")
echo "Réponse API CGV:"
echo "$CGV_API_RESPONSE" | head -5

# 3. Vérifier si la page CGV utilise le contenu de la base
echo ""
echo "3. Vérification du contenu affiché sur la page CGV..."
CGV_PAGE_CONTENT=$(curl -s "https://rageroom.usilenziu.com/legal/cgv")
if echo "$CGV_PAGE_CONTENT" | grep -q "dangerouslySetInnerHTML"; then
    echo -e "${GREEN}✅ La page CGV utilise le contenu de la base de données${NC}"
else
    echo -e "${RED}❌ La page CGV n'utilise pas le contenu de la base de données${NC}"
fi

# 4. Vérifier les logs de l'application pour des erreurs
echo ""
echo "4. Vérification des logs de l'application..."
$DOCKER_COMPOSE_CMD -f docker-compose.prod.yml logs u-silenziu | grep -i "legal\|cgv\|error" | tail -5

# 5. Forcer le redémarrage de l'application
echo ""
echo "5. Redémarrage de l'application pour vider le cache..."
$DOCKER_COMPOSE_CMD -f docker-compose.prod.yml restart u-silenziu
sleep 30

# 6. Test final
echo ""
echo "6. Test final de la page CGV..."
FINAL_CGV_CONTENT=$(curl -s "https://rageroom.usilenziu.com/legal/cgv")
if echo "$FINAL_CGV_CONTENT" | grep -q "dangerouslySetInnerHTML"; then
    echo -e "${GREEN}✅ SUCCÈS: La page CGV utilise maintenant le contenu de la base de données${NC}"
else
    echo -e "${RED}❌ ÉCHEC: La page CGV n'utilise toujours pas le contenu de la base de données${NC}"
    echo "Contenu actuel de la page:"
    echo "$FINAL_CGV_CONTENT" | grep -A 5 -B 5 "1. Objet"
fi

echo ""
echo -e "${YELLOW}📋 Résumé:${NC}"
echo -e "${YELLOW}   • Vérifiez que la page CGV affiche le contenu de la base de données${NC}"
echo -e "${YELLOW}   • Si le problème persiste, vérifiez les logs de l'application${NC}"
echo -e "${YELLOW}   • L'interface d'administration est disponible sur /admin/legal-pages${NC}"
