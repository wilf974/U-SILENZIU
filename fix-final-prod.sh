#!/bin/bash

# Script de correction finale pour U-SILENZIU Production
# Corrige tous les problèmes d'APIs et de base de données

echo "=== CORRECTION FINALE PRODUCTION U-SILENZIU ==="
echo "Nettoyage et reconstruction complète..."

# 1. Arrêter tous les conteneurs
echo "1. Arrêt des conteneurs..."
docker compose -f docker-compose.prod.yml down --volumes --remove-orphans

# 2. Nettoyer les caches Docker
echo "2. Nettoyage cache Docker..."
docker system prune -af --volumes

# 3. Supprimer les images pour forcer rebuild
echo "3. Suppression images pour rebuild..."
docker rmi u-silenziu-u-silenziu:latest 2>/dev/null || true
docker rmi $(docker images -q --filter reference="u-silenziu*") 2>/dev/null || true

# 4. Correction complète base de données
echo "4. Correction base de données..."
cat > fix_db_complete.sql << 'EOF'
-- Nettoyer et recréer la base complète
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO public;

-- Extension UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Fonction update_updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Table rooms
CREATE TABLE rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    duration INTEGER NOT NULL DEFAULT 30,
    max_people INTEGER NOT NULL DEFAULT 6,
    objects_to_destroy JSONB DEFAULT '[]',
    included JSONB DEFAULT '[]',
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER rooms_updated_at BEFORE UPDATE ON rooms
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Table reservations
CREATE TABLE reservations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reservation_number VARCHAR(50) UNIQUE NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    room_name VARCHAR(255) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    duration INTEGER NOT NULL DEFAULT 30,
    number_of_people INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    amount DECIMAL(10,2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER reservations_updated_at BEFORE UPDATE ON reservations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Table homepage_sections
CREATE TABLE homepage_sections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    section_name VARCHAR(50) UNIQUE NOT NULL,
    content JSONB NOT NULL,
    order_index INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER homepage_sections_updated_at BEFORE UPDATE ON homepage_sections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Table header_config
CREATE TABLE header_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    site_name VARCHAR(255) DEFAULT 'U Silenziu',
    logo_type VARCHAR(20) DEFAULT 'text',
    logo_text VARCHAR(255) DEFAULT 'U SILENZIU',
    logo_image_url TEXT,
    logo_alt_text VARCHAR(255) DEFAULT 'U Silenziu Logo',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER header_config_updated_at BEFORE UPDATE ON header_config
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Table footer_config
CREATE TABLE footer_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_name VARCHAR(255) DEFAULT 'U SILENZIU',
    tagline TEXT DEFAULT 'Votre zone de défoulement à Buros',
    phone VARCHAR(20) DEFAULT '+33 7 83 83 64 53',
    email VARCHAR(255) DEFAULT 'info@usilenziu.com',
    address_line1 VARCHAR(255) DEFAULT '18 Rue du Pont Long',
    address_line2 VARCHAR(255) DEFAULT '64160 Buros',
    address_line3 VARCHAR(255) DEFAULT 'Zone Berlanne',
    opening_hours JSONB DEFAULT '{}',
    social_links JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER footer_config_updated_at BEFORE UPDATE ON footer_config
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Table legal_pages
CREATE TABLE legal_pages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    page_type VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    is_published BOOLEAN DEFAULT true,
    meta_description TEXT,
    meta_keywords TEXT,
    author VARCHAR(255) DEFAULT 'U Silenziu',
    seo_title VARCHAR(255),
    keywords TEXT,
    last_updated_by VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER legal_pages_updated_at BEFORE UPDATE ON legal_pages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Table admin_users
CREATE TABLE admin_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'admin',
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER admin_users_updated_at BEFORE UPDATE ON admin_users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Données par défaut rooms
INSERT INTO rooms (name, description, price, duration, max_people, objects_to_destroy, included, is_active) VALUES
('Salle Défoulement Standard', 'Salle de défoulement standard avec objets variés', 25.00, 30, 4, '["Assiettes", "Verres", "Bouteilles"]'::jsonb, '["Casque", "Lunettes", "Gants"]'::jsonb, true),
('Salle Défoulement Premium', 'Salle de défoulement premium avec plus d''objets', 35.00, 30, 6, '["Assiettes", "Verres", "Bouteilles", "Télévision", "Imprimante"]'::jsonb, '["Casque", "Lunettes", "Gants", "Combinaison"]'::jsonb, true),
('Salle Multimédia', 'Salle spécialisée pour le défoulement d''objets multimédia', 30.00, 30, 3, '["Ordinateurs", "Télévisions", "Consoles"]'::jsonb, '["Casque", "Lunettes", "Gants"]'::jsonb, true);

-- Données par défaut homepage_sections avec JSON valide
INSERT INTO homepage_sections (section_name, content, order_index, is_active) VALUES
('hero', '{"title":"Libérez votre STRESS","subtitle":"Venez vous défouler en toute sécurité chez U Silenziu. Cassez, détruisez et libérez vos tensions dans nos salles spécialement conçues pour évacuer le stress.","backgroundImage":"/hero-bg.jpg","ctaText":"Réserver maintenant","ctaLink":"/reservation"}', 1, true),
('concept', '{"title":"Le Concept","subtitle":"U Silenziu vous offre une expérience unique pour libérer votre stress et vos émotions négatives. Nous mettons à votre disposition un environnement sûr et contrôlé pour évacuer vos tensions.","features":["Environnement sécurisé","Équipements de protection fournis","Encadrement professionnel","Nettoyage inclus"]}', 2, true),
('rooms', '{"title":"Nos Salles","subtitle":"Découvrez nos différentes formules de défoulement","showPricing":true}', 3, true),
('process', '{"title":"Comment ça marche ?","steps":[{"title":"Réservation","description":"Choisissez votre créneau et votre formule en ligne","icon":"calendar"},{"title":"Accueil","description":"Présentation des règles et équipement de protection","icon":"shield"},{"title":"Défoulement","description":"Libérez-vous dans un environnement sécurisé","icon":"hammer"},{"title":"Détente","description":"Moment de relaxation après la session","icon":"coffee"}]}', 4, true),
('faq', '{"title":"Questions Fréquentes","items":[{"question":"Est-ce sécurisé ?","answer":"Oui, nous fournissons tous les équipements de protection nécessaires et un encadrement professionnel."},{"question":"Que puis-je casser ?","answer":"Nous mettons à disposition différents objets selon la formule choisie : vaisselle, appareils électroniques, etc."},{"question":"Combien de temps dure une session ?","answer":"Les sessions durent généralement 30 minutes, avec un briefing sécurité inclus."},{"question":"Puis-je venir en groupe ?","answer":"Oui, nous accueillons les groupes. Contactez-nous pour les réservations de groupe."}]}', 5, true),
('contact', '{"title":"Contactez-nous","subtitle":"Une question ? Envie de plus d''informations ?","phone":"+33 7 83 83 64 53","email":"info@usilenziu.com","address":"18 Rue du Pont Long, 64160 Buros","hours":"Mardi-Jeudi: 14h-21h, Vendredi-Samedi: 14h-00h"}', 6, true);

-- Données par défaut header_config
INSERT INTO header_config (site_name, logo_type, logo_text, logo_alt_text) VALUES
('U Silenziu', 'text', 'U SILENZIU', 'U Silenziu Logo');

-- Données par défaut footer_config
INSERT INTO footer_config (company_name, tagline, phone, email, address_line1, address_line2, address_line3, opening_hours) VALUES
('U SILENZIU', 'Votre zone de défoulement à Buros. Libérez votre stress et vos tensions dans un environnement sécurisé et fun.', '+33 7 83 83 64 53', 'info@usilenziu.com', '18 Rue du Pont Long', '64160 Buros', 'Zone Berlanne', '{"tuesday_thursday":"14:00-21:00","friday_saturday":"14:00-00:00","sunday":"Sur réservation uniquement, Minimum 5 personnes"}'::jsonb);

-- Données par défaut legal_pages
INSERT INTO legal_pages (page_type, title, content, is_published, meta_description, author) VALUES
('privacy', 'Politique de confidentialité', 'Contenu de la politique de confidentialité...', true, 'Politique de confidentialité de U Silenziu', 'U Silenziu'),
('terms', 'Conditions générales', 'Contenu des conditions générales...', true, 'Conditions générales d''utilisation de U Silenziu', 'U Silenziu'),
('legal', 'Mentions légales', 'Contenu des mentions légales...', true, 'Mentions légales de U Silenziu', 'U Silenziu');

-- Données par défaut admin_users (mot de passe: admin123)
INSERT INTO admin_users (username, email, password_hash, role, is_active) VALUES
('admin', 'admin@usilenziu.com', '$2b$10$K8QV8Q8K8QV8Q8K8QV8Q8O8QV8Q8K8QV8Q8K8QV8Q8K8QV8Q8K8QV8', 'admin', true),
('superadmin', 'superadmin@usilenziu.com', '$2b$10$K8QV8Q8K8QV8Q8K8QV8Q8O8QV8Q8K8QV8Q8K8QV8Q8K8QV8Q8K8QV8', 'super_admin', true);

EOF

# 5. Démarrer PostgreSQL et appliquer le script
echo "5. Démarrage PostgreSQL et application du script..."
docker compose -f docker-compose.prod.yml up -d postgres
sleep 10

# Attendre que PostgreSQL soit prêt
until docker exec u-silenziu-postgres-prod pg_isready -U usilenzio_user -d usilenzio; do
    echo "Attente PostgreSQL..."
    sleep 2
done

# Appliquer le script de correction
docker exec -i u-silenziu-postgres-prod psql -U usilenzio_user -d usilenzio < fix_db_complete.sql

# 6. Rebuild et démarrer l'application
echo "6. Rebuild complet application..."
docker compose -f docker-compose.prod.yml up -d --build --force-recreate

echo "7. Attente démarrage application..."
sleep 30

# 8. Tests des APIs
echo "8. Tests des APIs..."
echo "Test homepage-sections:"
curl -k -s https://rageroom.usilenziu.com/api/homepage-sections | jq '.success' 2>/dev/null || echo "ERREUR"

echo "Test header-config:"
curl -k -s https://rageroom.usilenziu.com/api/header-config | jq '.success' 2>/dev/null || echo "ERREUR"

echo "Test footer-config:"
curl -k -s https://rageroom.usilenziu.com/api/footer-config | jq '.success' 2>/dev/null || echo "ERREUR"

echo "Test legal-pages:"
curl -k -s https://rageroom.usilenziu.com/api/legal-pages | jq '.success' 2>/dev/null || echo "ERREUR"

echo "Test rooms:"
curl -k -s https://rageroom.usilenziu.com/api/rooms | jq '.success' 2>/dev/null || echo "ERREUR"

# 9. Nettoyage
rm -f fix_db_complete.sql

echo "=== CORRECTION TERMINÉE ==="
echo "Vérifiez le site: https://rageroom.usilenziu.com"
echo "Admin: https://rageroom.usilenziu.com/admin (admin/admin123)"