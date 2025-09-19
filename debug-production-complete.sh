#!/bin/bash
# Script de diagnostic complet pour production VPS
# U Silenziu - Septembre 2025
# Diagnostique en profondeur les erreurs HTTP 500

echo "🔍 DIAGNOSTIC COMPLET PRODUCTION VPS"
echo "===================================="
echo ""

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les sections
function print_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_section "1. ÉTAT DES CONTENEURS"
echo "Conteneurs en cours d'exécution :"
docker compose -f docker-compose.prod.yml ps

echo -e "\nÉtat détaillé des conteneurs :"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

print_section "2. SANTÉ DE LA BASE DE DONNÉES"
echo "Test de connexion PostgreSQL :"
if docker exec u-silenziu-postgres pg_isready -U usilenzio_user -d usilenzio 2>/dev/null; then
    echo -e "${GREEN}✅ PostgreSQL est accessible${NC}"
    
    echo -e "\nTest de connexion avec les credentials :"
    if docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "SELECT version();" 2>/dev/null | grep -q "PostgreSQL"; then
        echo -e "${GREEN}✅ Connexion avec credentials réussie${NC}"
        
        echo -e "\nVérification des tables critiques :"
        TABLES=("header_config" "footer_config" "homepage_sections" "legal_pages")
        for table in "${TABLES[@]}"; do
            if docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\dt $table" 2>/dev/null | grep -q "$table"; then
                echo -e "${GREEN}✅ Table $table existe${NC}"
                # Compter les enregistrements
                count=$(docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -t -c "SELECT COUNT(*) FROM $table;" 2>/dev/null | tr -d ' ')
                echo "   → $count enregistrement(s)"
            else
                echo -e "${RED}❌ Table $table manquante${NC}"
            fi
        done
    else
        echo -e "${RED}❌ Échec de connexion avec credentials${NC}"
    fi
else
    echo -e "${RED}❌ PostgreSQL non accessible${NC}"
fi

print_section "3. VARIABLES D'ENVIRONNEMENT DE L'APPLICATION"
echo "Variables critiques dans le conteneur u-silenziu :"
docker exec u-silenziu-app env | grep -E "(NODE_ENV|DATABASE_URL|NEXT_PUBLIC|POSTGRES)" | sort

print_section "4. LOGS DE L'APPLICATION (20 dernières lignes)"
docker compose -f docker-compose.prod.yml logs --tail=20 u-silenziu

print_section "5. LOGS DE LA BASE DE DONNÉES (10 dernières lignes)"
docker compose -f docker-compose.prod.yml logs --tail=10 postgres

print_section "6. TEST DES APIS DEPUIS LE CONTENEUR"
echo "Test des APIs depuis l'intérieur du conteneur :"
APIS=("header-config" "footer-config" "homepage-sections" "legal-pages")
for api in "${APIS[@]}"; do
    echo -n "API $api : "
    if docker exec u-silenziu-app curl -s -f "http://localhost:3000/api/$api" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ OK${NC}"
    else
        echo -e "${RED}❌ ERREUR${NC}"
        # Récupérer le détail de l'erreur
        error_detail=$(docker exec u-silenziu-app curl -s "http://localhost:3000/api/$api" 2>/dev/null)
        echo "   Détail : $error_detail"
    fi
done

print_section "7. TEST DE CONNEXION RÉSEAU"
echo "Résolution DNS postgres depuis l'application :"
if docker exec u-silenziu-app nslookup postgres 2>/dev/null | grep -q "Address"; then
    echo -e "${GREEN}✅ DNS postgres résolu${NC}"
    docker exec u-silenziu-app nslookup postgres 2>/dev/null | grep "Address"
else
    echo -e "${RED}❌ DNS postgres non résolu${NC}"
fi

echo -e "\nConnectivité réseau postgres:5432 :"
if docker exec u-silenziu-app nc -z postgres 5432 2>/dev/null; then
    echo -e "${GREEN}✅ Port 5432 accessible${NC}"
else
    echo -e "${RED}❌ Port 5432 non accessible${NC}"
fi

print_section "8. FICHIERS DE CONFIGURATION"
echo "Vérification de la configuration Next.js :"
if docker exec u-silenziu-app cat /app/next.config.js 2>/dev/null | grep -q "rageroom.usilenziu.com"; then
    echo -e "${GREEN}✅ Domaine production configuré${NC}"
else
    echo -e "${RED}❌ Domaine production manquant${NC}"
fi

echo -e "\nVérification lib/database.ts :"
if docker exec u-silenziu-app grep -q "postgres:5432" /app/lib/database.ts 2>/dev/null; then
    echo -e "${GREEN}✅ Connexion Docker configurée${NC}"
else
    echo -e "${RED}❌ Connexion Docker mal configurée${NC}"
    echo "Configuration actuelle :"
    docker exec u-silenziu-app grep "connectionString" /app/lib/database.ts 2>/dev/null || echo "Fichier non trouvé"
fi

print_section "9. DIAGNOSTIC RAPIDE"
echo "Espace disque :"
df -h

echo -e "\nMémoire :"
free -h

echo -e "\nProcessus Docker :"
docker stats --no-stream

print_section "10. RECOMMANDATIONS"
echo -e "${YELLOW}📋 Problèmes détectés et solutions :${NC}"

# Analyse automatique des problèmes
problems_found=0

# Test si PostgreSQL est accessible
if ! docker exec u-silenziu-postgres pg_isready -U usilenzio_user -d usilenzio >/dev/null 2>&1; then
    echo -e "${RED}❌ PostgreSQL non accessible${NC}"
    echo "   Solution : docker compose -f docker-compose.prod.yml restart postgres"
    problems_found=$((problems_found + 1))
fi

# Test si l'application peut se connecter à la DB
if ! docker exec u-silenziu-app nc -z postgres 5432 >/dev/null 2>&1; then
    echo -e "${RED}❌ Application ne peut pas joindre PostgreSQL${NC}"
    echo "   Solution : Vérifier la configuration réseau Docker"
    problems_found=$((problems_found + 1))
fi

# Test si les tables existent
if ! docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\dt header_config" 2>/dev/null | grep -q "header_config"; then
    echo -e "${RED}❌ Tables manquantes${NC}"
    echo "   Solution : Recréer la base de données avec les scripts d'init"
    problems_found=$((problems_found + 1))
fi

if [ $problems_found -eq 0 ]; then
    echo -e "${GREEN}✅ Aucun problème majeur détecté${NC}"
    echo "   Les erreurs 500 peuvent venir d'un problème de timing ou de build"
    echo "   Solution recommandée : Rebuild complet"
fi

echo -e "\n${BLUE}🚀 COMMANDES DE RÉPARATION RECOMMANDÉES :${NC}"
echo "1. Redémarrage complet :"
echo "   docker compose -f docker-compose.prod.yml down"
echo "   docker compose -f docker-compose.prod.yml up -d --build"
echo ""
echo "2. Si les tables manquent :"
echo "   docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -f /docker-entrypoint-initdb.d/00-init-db.sql"
echo ""
echo "3. Logs en temps réel :"
echo "   docker compose -f docker-compose.prod.yml logs -f u-silenziu"

echo -e "\n${GREEN}✅ DIAGNOSTIC TERMINÉ${NC}"
