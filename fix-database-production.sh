#!/bin/bash
# Script de correction de la base de données PostgreSQL en production
# U Silenziu - Septembre 2025
# Résout les problèmes de connexion et de tables manquantes

echo "🔧 CORRECTION BASE DE DONNÉES PRODUCTION"
echo "========================================"
echo ""

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📋 Diagnostic et correction de la base de données PostgreSQL${NC}"
echo ""

# 1. Vérifier l'état des conteneurs
echo "1. Vérification de l'état des conteneurs..."
docker compose -f docker-compose.prod.yml ps

# 2. Arrêter l'application pour éviter les conflits
echo ""
echo "2. Arrêt temporaire de l'application..."
docker compose -f docker-compose.prod.yml stop u-silenziu

# 3. Vérifier PostgreSQL
echo ""
echo "3. Diagnostic PostgreSQL..."
if docker compose -f docker-compose.prod.yml ps postgres | grep -q "Up"; then
    echo -e "${GREEN}✅ Conteneur PostgreSQL en cours d'exécution${NC}"
    
    # Test de connexion
    if docker exec u-silenziu-postgres pg_isready -U usilenzio_user -d usilenzio >/dev/null 2>&1; then
        echo -e "${GREEN}✅ PostgreSQL répond aux connexions${NC}"
    else
        echo -e "${RED}❌ PostgreSQL ne répond pas${NC}"
        echo "Redémarrage de PostgreSQL..."
        docker compose -f docker-compose.prod.yml restart postgres
        sleep 10
    fi
else
    echo -e "${RED}❌ Conteneur PostgreSQL arrêté${NC}"
    echo "Démarrage de PostgreSQL..."
    docker compose -f docker-compose.prod.yml up -d postgres
    sleep 15
fi

# 4. Vérifier les tables critiques
echo ""
echo "4. Vérification des tables critiques..."
CRITICAL_TABLES=("header_config" "footer_config" "homepage_sections" "legal_pages" "global_sections")
MISSING_TABLES=()

for table in "${CRITICAL_TABLES[@]}"; do
    if docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\dt $table" 2>/dev/null | grep -q "$table"; then
        echo -e "${GREEN}✅ Table $table existe${NC}"
    else
        echo -e "${RED}❌ Table $table manquante${NC}"
        MISSING_TABLES+=($table)
    fi
done

# 5. Recréer les tables manquantes si nécessaire
if [ ${#MISSING_TABLES[@]} -gt 0 ]; then
    echo ""
    echo "5. Recréation des tables manquantes..."
    
    # Exécuter les scripts d'initialisation
    echo "Exécution des scripts d'initialisation..."
    
    # Script principal
    echo "   - Script principal init-db.sql..."
    docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -f /docker-entrypoint-initdb.d/00-init-db.sql
    
    # Scripts spécifiques
    SCRIPTS=(
        "10-create-header-config.sql"
        "11-create-footer-config.sql" 
        "12-create-homepage-sections.sql"
        "13-create-global-sections.sql"
        "14-create-homepage-config.sql"
        "20-create-admin-users.sql"
    )
    
    for script in "${SCRIPTS[@]}"; do
        if [ -f "/docker-entrypoint-initdb.d/$script" ]; then
            echo "   - Exécution de $script..."
            docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -f "/docker-entrypoint-initdb.d/$script" 2>/dev/null || echo "     Script $script non trouvé ou erreur"
        fi
    done
    
    # Vérification après création
    echo ""
    echo "Vérification après recréation..."
    for table in "${MISSING_TABLES[@]}"; do
        if docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\dt $table" 2>/dev/null | grep -q "$table"; then
            echo -e "${GREEN}✅ Table $table créée avec succès${NC}"
        else
            echo -e "${RED}❌ Échec création table $table${NC}"
        fi
    done
else
    echo -e "${GREEN}✅ Toutes les tables critiques sont présentes${NC}"
fi

# 6. Insérer les données par défaut si les tables sont vides
echo ""
echo "6. Vérification et insertion des données par défaut..."

# Header config
header_count=$(docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -t -c "SELECT COUNT(*) FROM header_config;" 2>/dev/null | tr -d ' ')
if [ "$header_count" = "0" ]; then
    echo "   Insertion données par défaut header_config..."
    docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
    INSERT INTO header_config (id, site_name, logo_type, logo_text, logo_alt_text) 
    VALUES ('default', 'U SILENZIU', 'text', 'U SILENZIU', 'Logo U Silenziu')
    ON CONFLICT (id) DO UPDATE SET 
        site_name = EXCLUDED.site_name,
        logo_type = EXCLUDED.logo_type,
        logo_text = EXCLUDED.logo_text,
        logo_alt_text = EXCLUDED.logo_alt_text;
    " 2>/dev/null
fi

# Footer config
footer_count=$(docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -t -c "SELECT COUNT(*) FROM footer_config;" 2>/dev/null | tr -d ' ')
if [ "$footer_count" = "0" ]; then
    echo "   Insertion données par défaut footer_config..."
    docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
    INSERT INTO footer_config (id, site_name, site_description, contact_phone, contact_email, contact_address, copyright_text, legal_links) 
    VALUES ('default', 'U SILENZIU', 'Votre zone de défoulement à Buros', '+33 7 83 83 64 53', 'info@usilenziu.com', '18 Rue du Pont Long 64160 Buros Zone Berlanne', '© 2024 U Silenziu. Tous droits réservés.', '[]'::jsonb)
    ON CONFLICT (id) DO UPDATE SET 
        site_name = EXCLUDED.site_name,
        site_description = EXCLUDED.site_description,
        contact_phone = EXCLUDED.contact_phone,
        contact_email = EXCLUDED.contact_email,
        contact_address = EXCLUDED.contact_address,
        copyright_text = EXCLUDED.copyright_text;
    " 2>/dev/null
fi

# Homepage sections
homepage_count=$(docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -t -c "SELECT COUNT(*) FROM homepage_sections;" 2>/dev/null | tr -d ' ')
if [ "$homepage_count" = "0" ]; then
    echo "   Insertion données par défaut homepage_sections..."
    docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
    INSERT INTO homepage_sections (id, section_type, title, content, data, is_visible) 
    VALUES 
    ('hero', 'hero', 'U SILENZIU', 'Votre zone de défoulement à Buros', '{\"subtitle\": \"Libérez votre stress\"}', true),
    ('rooms', 'rooms', 'Nos Salles', 'Découvrez nos différentes salles', '{}', true),
    ('contact', 'contact', 'Contact', 'Contactez-nous', '{}', true)
    ON CONFLICT (id) DO NOTHING;
    " 2>/dev/null
fi

# 7. Test final de connexion depuis l'application
echo ""
echo "7. Test de connexion depuis l'application..."

# Redémarrer l'application avec la bonne configuration
echo "Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml up -d u-silenziu

# Attendre que l'application démarre
echo "Attente du démarrage de l'application (30 secondes)..."
sleep 30

# Test des APIs
echo ""
echo "8. Test des APIs après correction..."
APIS=("header-config" "footer-config" "homepage-sections" "legal-pages")
for api in "${APIS[@]}"; do
    echo -n "Test API $api : "
    if curl -s -f "https://rageroom.usilenziu.com/api/$api" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ OK${NC}"
    else
        echo -e "${RED}❌ ERREUR${NC}"
        # Test depuis l'intérieur du conteneur
        echo -n "   Test interne : "
        if docker exec u-silenziu-app curl -s -f "http://localhost:3000/api/$api" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ OK (problème Nginx?)${NC}"
        else
            echo -e "${RED}❌ ERREUR${NC}"
        fi
    fi
done

echo ""
echo "9. Résumé des tables et données..."
for table in "${CRITICAL_TABLES[@]}"; do
    count=$(docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -t -c "SELECT COUNT(*) FROM $table;" 2>/dev/null | tr -d ' ')
    echo "   $table: $count enregistrement(s)"
done

echo ""
echo -e "${GREEN}✅ CORRECTION BASE DE DONNÉES TERMINÉE${NC}"
echo ""
echo "🌐 Testez maintenant : https://rageroom.usilenziu.com"
echo "📊 Logs en temps réel : docker compose -f docker-compose.prod.yml logs -f u-silenziu"
echo ""
echo "💡 Si les erreurs persistent :"
echo "   1. Vérifiez les logs : docker compose -f docker-compose.prod.yml logs u-silenziu"
echo "   2. Redémarrez complet : docker compose -f docker-compose.prod.yml restart"
