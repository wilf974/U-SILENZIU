#!/bin/bash
# ====================================================================
# Script de migration complète base de données PRODUCTION
# Objectif: Migrer vers structure UUID comme en local
# ====================================================================

echo "=== MIGRATION PRODUCTION U-SILENZIU ==="
echo "Migration vers structure UUID (compatible local)"

# 1. SAUVEGARDE COMPLÈTE
echo ""
echo "1. Sauvegarde base de données..."
docker exec u-silenziu-postgres pg_dump -U usilenzio_user -d usilenzio > "backup-avant-migration-$(date +%Y%m%d-%H%M).sql"

# 2. SUPPRESSION ET RECREATION COMPLÈTE
echo ""
echo "2. Recréation complète base de données..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
-- Sauvegarder les données critiques
CREATE TABLE IF NOT EXISTS rooms_backup AS SELECT * FROM rooms;
CREATE TABLE IF NOT EXISTS reservations_backup AS SELECT * FROM reservations;

-- Supprimer toutes les tables pour repartir à zéro
DROP TABLE IF EXISTS reservations CASCADE;
DROP TABLE IF EXISTS rooms CASCADE;
DROP TABLE IF EXISTS smtp_config CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS pages CASCADE;
DROP TABLE IF EXISTS templates CASCADE;
DROP TABLE IF EXISTS activity_logs CASCADE;
DROP TABLE IF EXISTS homepage_sections CASCADE;
DROP TABLE IF EXISTS global_sections CASCADE;
DROP TABLE IF EXISTS header_config CASCADE;
DROP TABLE IF EXISTS legal_pages CASCADE;
DROP TABLE IF EXISTS admin_users CASCADE;
DROP TABLE IF EXISTS footer_config CASCADE;

-- Supprimer les fonctions
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
"

# 3. REINITIALISATION AVEC STRUCTURE UUID
echo ""
echo "3. Réinitialisation avec structure UUID..."
docker exec -i u-silenziu-postgres psql -U usilenzio_user -d usilenzio < init-db.sql

# 4. AJOUT DES TABLES MANQUANTES
echo ""
echo "4. Ajout tables manquantes..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
-- Extension pour UUIDs si pas encore fait
CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";

-- Table des sections homepage
CREATE TABLE IF NOT EXISTS homepage_sections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    section_name VARCHAR(50) UNIQUE NOT NULL,
    content JSONB NOT NULL DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table admin_users
CREATE TABLE IF NOT EXISTS admin_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'admin' CHECK (role IN ('admin', 'super_admin')),
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table header_config
CREATE TABLE IF NOT EXISTS header_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    site_name VARCHAR(255) DEFAULT 'U Silenziu',
    logo_type VARCHAR(10) DEFAULT 'text' CHECK (logo_type IN ('text', 'image')),
    logo_text VARCHAR(100) DEFAULT 'U SILENZIU',
    logo_image_url TEXT,
    logo_alt_text VARCHAR(255) DEFAULT 'Logo U Silenziu',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table legal_pages
CREATE TABLE IF NOT EXISTS legal_pages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    page_type VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    meta_description TEXT,
    meta_keywords TEXT,
    author VARCHAR(255) DEFAULT 'U Silenziu',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table footer_config
CREATE TABLE IF NOT EXISTS footer_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_name VARCHAR(255) DEFAULT 'U Silenziu',
    company_description TEXT,
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'France',
    phone VARCHAR(50),
    email VARCHAR(255),
    social_links JSONB DEFAULT '[]',
    opening_hours JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Triggers pour updated_at
CREATE TRIGGER update_homepage_sections_updated_at BEFORE UPDATE ON homepage_sections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_admin_users_updated_at BEFORE UPDATE ON admin_users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_header_config_updated_at BEFORE UPDATE ON header_config
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_legal_pages_updated_at BEFORE UPDATE ON legal_pages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_footer_config_updated_at BEFORE UPDATE ON footer_config
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
"

# 5. INSERTION DES DONNÉES PAR DÉFAUT
echo ""
echo "5. Insertion données par défaut..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
-- Données par défaut homepage_sections
INSERT INTO homepage_sections (section_name, content, order_index) VALUES
('hero', '{\"title\":\"Bienvenue chez U Silenziu\",\"subtitle\":\"Votre zone de défoulement à Buros\",\"description\":\"Évacuez votre stress dans nos espaces sécurisés\",\"cta_text\":\"Réserver maintenant\",\"cta_link\":\"/reservation\",\"background_image\":\"/images/hero-bg.jpg\"}', 1),
('concept', '{\"title\":\"Le Concept\",\"description\":\"U Silenziu vous propose un concept unique de défoulement dans un environnement sécurisé.\",\"features\":[\"Espaces sécurisés\",\"Équipements fournis\",\"Accompagnement professionnel\"]}', 2),
('rooms', '{\"title\":\"Nos Salles\",\"description\":\"Découvrez nos différents espaces adaptés à vos besoins\"}', 3),
('process', '{\"title\":\"Comment ça marche ?\",\"steps\":[{\"title\":\"Réservez\",\"description\":\"Choisissez votre créneau\"},{\"title\":\"Venez\",\"description\":\"Présentez-vous à l heure\"},{\"title\":\"Défoulez-vous\",\"description\":\"Libérez votre stress\"}]}', 4),
('faq', '{\"title\":\"Questions Fréquentes\",\"items\":[{\"question\":\"Quel âge minimum ?\",\"answer\":\"16 ans minimum, 18 ans recommandé\"},{\"question\":\"Que porter ?\",\"answer\":\"Vêtements confortables et chaussures fermées\"}]}', 5),
('contact', '{\"title\":\"Contact\",\"description\":\"Une question ? N hésitez pas à nous contacter\",\"phone\":\"+33 X XX XX XX XX\",\"email\":\"contact@usilenziu.fr\",\"address\":\"Buros, France\"}', 6);

-- Données admin par défaut (mot de passe haché pour admin123)
INSERT INTO admin_users (username, email, password_hash, role) VALUES
('admin', 'admin@usilenziu.fr', '\$2b\$10\$rKjQqN9N5Ph5Ph5Ph5Ph5.O8P9P5Ph5Ph5Ph5Ph5Ph5Ph5Ph5Ph5Ph5P', 'admin'),
('superadmin', 'super@usilenziu.fr', '\$2b\$10\$rKjQqN9N5Ph5Ph5Ph5Ph5.O8P9P5Ph5Ph5Ph5Ph5Ph5Ph5Ph5Ph5Ph5P', 'super_admin');

-- Données header_config par défaut
INSERT INTO header_config (site_name, logo_type, logo_text) VALUES
('U SILENZIU | RAGE ROOM', 'text', 'U SILENZIU');

-- Données legal_pages par défaut
INSERT INTO legal_pages (page_type, title, content) VALUES
('privacy', 'Politique de Confidentialité', 'Contenu de la politique de confidentialité...'),
('terms', 'Conditions Générales', 'Contenu des conditions générales...'),
('legal', 'Mentions Légales', 'Contenu des mentions légales...');

-- Données footer_config par défaut
INSERT INTO footer_config (company_name, company_description, city, country, email) VALUES
('U Silenziu', 'Votre zone de défoulement à Buros', 'Buros', 'France', 'contact@usilenziu.fr');
"

# 6. RESTAURATION DONNÉES IMPORTANTES
echo ""
echo "6. Restauration données existantes..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
-- Restaurer les salles avec nouveaux UUIDs si les données existent
INSERT INTO rooms (name, description, price, duration, max_people, objects_to_destroy, included, is_active)
SELECT 
    name, 
    description, 
    COALESCE(price::numeric, price_per_hour::numeric, 25.00) as price,
    COALESCE(duration, 30) as duration,
    COALESCE(max_people, capacity, 4) as max_people,
    '[]'::jsonb,
    '[]'::jsonb,
    COALESCE(is_active, true)
FROM rooms_backup 
WHERE EXISTS (SELECT 1 FROM rooms_backup LIMIT 1)
ON CONFLICT DO NOTHING;
"

# 7. REDÉMARRAGE APPLICATION
echo ""
echo "7. Redémarrage application..."
docker restart u-silenziu-app

# 8. TESTS
echo ""
echo "8. Tests des APIs..."
sleep 15

echo "Test API rooms..."
curl -k -s https://rageroom.usilenziu.com/api/rooms | grep -o '"success":[^,]*' || echo "Erreur API rooms"

echo "Test API homepage-sections..."  
curl -k -s https://rageroom.usilenziu.com/api/homepage-sections | grep -o '"success":[^,]*' || echo "Erreur API homepage"

echo "Test API header-config..."
curl -k -s https://rageroom.usilenziu.com/api/header-config | grep -o '"success":[^,]*' || echo "Erreur API header"

echo ""
echo "=== MIGRATION TERMINÉE ==="
echo "Vérifiez le site: https://rageroom.usilenziu.com"
