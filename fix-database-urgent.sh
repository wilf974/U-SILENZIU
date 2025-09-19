#!/bin/bash
# Correction urgente base de données - Tables manquantes
# U Silenziu - Septembre 2025

echo "🚨 CORRECTION URGENTE - TABLES MANQUANTES"
echo "=========================================="
echo ""

# Arrêter l'application
echo "1. Arrêt de l'application..."
docker compose -f docker-compose.prod.yml stop u-silenziu

echo ""
echo "2. Création manuelle des tables critiques..."

# Créer les tables directement
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio << 'EOF'

-- Table header_config
CREATE TABLE IF NOT EXISTS header_config (
    id VARCHAR(50) PRIMARY KEY,
    site_name VARCHAR(255) NOT NULL,
    logo_type VARCHAR(20) NOT NULL DEFAULT 'text',
    logo_text VARCHAR(255),
    logo_image_url TEXT,
    logo_alt_text VARCHAR(255),
    logo_uploaded_data BYTEA,
    logo_uploaded_filename VARCHAR(255),
    logo_uploaded_mimetype VARCHAR(100),
    logo_uploaded_size INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table footer_config
CREATE TABLE IF NOT EXISTS footer_config (
    id VARCHAR(50) PRIMARY KEY,
    site_name VARCHAR(255) NOT NULL,
    site_description TEXT,
    site_slogan VARCHAR(500),
    contact_phone VARCHAR(20),
    contact_email VARCHAR(255),
    contact_address TEXT,
    opening_hours_monday VARCHAR(100),
    opening_hours_tuesday VARCHAR(100),
    opening_hours_wednesday VARCHAR(100),
    opening_hours_thursday VARCHAR(100),
    opening_hours_friday VARCHAR(100),
    opening_hours_saturday VARCHAR(100),
    opening_hours_sunday VARCHAR(100),
    cta_title VARCHAR(255),
    cta_subtitle VARCHAR(500),
    cta_button_text VARCHAR(100),
    cta_button_url TEXT,
    legal_links JSONB DEFAULT '[]'::jsonb,
    copyright_text VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table homepage_sections
CREATE TABLE IF NOT EXISTS homepage_sections (
    id VARCHAR(50) PRIMARY KEY,
    section_type VARCHAR(50) NOT NULL,
    title VARCHAR(255),
    content TEXT,
    data JSONB DEFAULT '{}'::jsonb,
    order_index INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table legal_pages
CREATE TABLE IF NOT EXISTS legal_pages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    page_type VARCHAR(50) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    is_published BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table global_sections
CREATE TABLE IF NOT EXISTS global_sections (
    id VARCHAR(50) PRIMARY KEY,
    section_type VARCHAR(50) NOT NULL,
    title VARCHAR(255),
    content TEXT,
    data JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table rooms (si elle n'existe pas)
CREATE TABLE IF NOT EXISTS rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    duration INTEGER NOT NULL,
    max_people INTEGER NOT NULL,
    objects_to_destroy TEXT[] DEFAULT '{}',
    included TEXT[] DEFAULT '{}',
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Triggers pour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_header_config_updated_at BEFORE UPDATE ON header_config FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_footer_config_updated_at BEFORE UPDATE ON footer_config FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_homepage_sections_updated_at BEFORE UPDATE ON homepage_sections FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_legal_pages_updated_at BEFORE UPDATE ON legal_pages FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_global_sections_updated_at BEFORE UPDATE ON global_sections FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_rooms_updated_at BEFORE UPDATE ON rooms FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

EOF

echo ""
echo "3. Insertion des données par défaut..."

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio << 'EOF'

-- Données header_config
INSERT INTO header_config (id, site_name, logo_type, logo_text, logo_alt_text) 
VALUES ('default', 'U SILENZIU', 'text', 'U SILENZIU', 'Logo U Silenziu')
ON CONFLICT (id) DO UPDATE SET 
    site_name = EXCLUDED.site_name,
    logo_type = EXCLUDED.logo_type,
    logo_text = EXCLUDED.logo_text,
    logo_alt_text = EXCLUDED.logo_alt_text;

-- Données footer_config
INSERT INTO footer_config (id, site_name, site_description, contact_phone, contact_email, contact_address, opening_hours_tuesday, opening_hours_wednesday, opening_hours_thursday, opening_hours_friday, opening_hours_saturday, opening_hours_sunday, copyright_text, legal_links) 
VALUES ('default', 'U SILENZIU', 'Votre zone de défoulement à Buros. Libérez votre stress et vos tensions dans un environnement sécurisé et fun.', '+33 7 83 83 64 53', 'info@usilenziu.com', '18 Rue du Pont Long 64160 Buros Zone Berlanne', '14:00 – 21:00', '14:00 – 21:00', '14:00 – 21:00', '14:00 – 00:00', '14:00 – 00:00', 'Sur réservation uniquement, Minimum 5 personnes', '© 2024 U Silenziu. Tous droits réservés.', '[]'::jsonb)
ON CONFLICT (id) DO UPDATE SET 
    site_name = EXCLUDED.site_name,
    site_description = EXCLUDED.site_description,
    contact_phone = EXCLUDED.contact_phone,
    contact_email = EXCLUDED.contact_email,
    contact_address = EXCLUDED.contact_address,
    opening_hours_tuesday = EXCLUDED.opening_hours_tuesday,
    opening_hours_wednesday = EXCLUDED.opening_hours_wednesday,
    opening_hours_thursday = EXCLUDED.opening_hours_thursday,
    opening_hours_friday = EXCLUDED.opening_hours_friday,
    opening_hours_saturday = EXCLUDED.opening_hours_saturday,
    opening_hours_sunday = EXCLUDED.opening_hours_sunday,
    copyright_text = EXCLUDED.copyright_text;

-- Données homepage_sections
INSERT INTO homepage_sections (id, section_type, title, content, data, order_index, is_visible, is_active) 
VALUES 
('hero', 'hero', 'U SILENZIU', 'Votre zone de défoulement à Buros. Libérez votre stress et vos tensions dans un environnement sécurisé et fun.', '{"subtitle": "Énergie positive garantie !"}', 1, true, true),
('rooms', 'rooms', 'Nos Salles', 'Découvrez nos différentes salles de défoulement', '{}', 2, true, true),
('contact', 'contact', 'Contact', 'Contactez-nous pour réserver', '{}', 3, true, true)
ON CONFLICT (id) DO UPDATE SET 
    title = EXCLUDED.title,
    content = EXCLUDED.content,
    data = EXCLUDED.data,
    is_visible = EXCLUDED.is_visible,
    is_active = EXCLUDED.is_active;

-- Données global_sections
INSERT INTO global_sections (id, section_type, title, content, data, is_active) 
VALUES 
('cta', 'cta', 'Prêt à libérer votre stress ?', 'Réservez dès maintenant votre session de défoulement', '{"button_text": "Réserver maintenant", "button_url": "/reservation"}', true)
ON CONFLICT (id) DO UPDATE SET 
    title = EXCLUDED.title,
    content = EXCLUDED.content,
    data = EXCLUDED.data,
    is_active = EXCLUDED.is_active;

-- Données rooms
INSERT INTO rooms (name, description, price, duration, max_people, objects_to_destroy, included, is_active) 
VALUES 
('Salle Douce', 'Pour un défoulement en douceur', 50.00, 60, 4, ARRAY['Assiettes', 'Verres', 'Objets légers'], ARRAY['Équipements de protection', 'Nettoyage'], true),
('Salle Carnage', 'Pour un défoulement intense', 75.00, 60, 6, ARRAY['Électroménager', 'Meubles', 'Gros objets'], ARRAY['Équipements de protection', 'Nettoyage', 'Marteau'], true),
('Salle Privatisée', 'Salle privatisée pour groupes', 120.00, 90, 10, ARRAY['Choix personnalisé'], ARRAY['Équipements de protection', 'Nettoyage', 'Animation'], true)
ON CONFLICT DO NOTHING;

EOF

echo ""
echo "4. Vérification des tables créées..."
TABLES=("header_config" "footer_config" "homepage_sections" "legal_pages" "global_sections" "rooms")
for table in "${TABLES[@]}"; do
    count=$(docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -t -c "SELECT COUNT(*) FROM $table;" 2>/dev/null | tr -d ' ')
    if [ ! -z "$count" ]; then
        echo "✅ Table $table: $count enregistrement(s)"
    else
        echo "❌ Table $table: Erreur"
    fi
done

echo ""
echo "5. Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml up -d u-silenziu

echo ""
echo "6. Attente du démarrage (20 secondes)..."
sleep 20

echo ""
echo "7. Test final des APIs..."
APIS=("header-config" "footer-config" "homepage-sections" "legal-pages")
for api in "${APIS[@]}"; do
    echo -n "Test API $api : "
    if curl -s -f "https://rageroom.usilenziu.com/api/$api" >/dev/null 2>&1; then
        echo "✅ OK"
    else
        echo "❌ ERREUR"
    fi
done

echo ""
echo "✅ CORRECTION TERMINÉE !"
echo "🌐 Testez : https://rageroom.usilenziu.com"
