#!/bin/bash
# Correction directe base de données - Version simplifiée
# U Silenziu - Septembre 2025

echo "🔧 CORRECTION DIRECTE BASE DE DONNÉES"
echo "====================================="
echo ""

# Vérifier la connexion PostgreSQL
echo "1. Test de connexion PostgreSQL..."
if ! docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "SELECT 1;" >/dev/null 2>&1; then
    echo "❌ Impossible de se connecter à PostgreSQL"
    exit 1
fi
echo "✅ Connexion PostgreSQL OK"

echo ""
echo "2. Création des tables une par une..."

# Table header_config
echo "   - Création table header_config..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
CREATE TABLE IF NOT EXISTS header_config (
    id VARCHAR(50) PRIMARY KEY,
    site_name VARCHAR(255) NOT NULL,
    logo_type VARCHAR(20) NOT NULL DEFAULT 'text',
    logo_text VARCHAR(255),
    logo_image_url TEXT,
    logo_alt_text VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);"

# Table footer_config
echo "   - Création table footer_config..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
CREATE TABLE IF NOT EXISTS footer_config (
    id VARCHAR(50) PRIMARY KEY,
    site_name VARCHAR(255) NOT NULL,
    site_description TEXT,
    contact_phone VARCHAR(20),
    contact_email VARCHAR(255),
    contact_address TEXT,
    opening_hours_tuesday VARCHAR(100),
    opening_hours_wednesday VARCHAR(100),
    opening_hours_thursday VARCHAR(100),
    opening_hours_friday VARCHAR(100),
    opening_hours_saturday VARCHAR(100),
    opening_hours_sunday VARCHAR(100),
    copyright_text VARCHAR(500),
    legal_links JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);"

# Table homepage_sections
echo "   - Création table homepage_sections..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
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
);"

# Table legal_pages
echo "   - Création table legal_pages..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
CREATE TABLE IF NOT EXISTS legal_pages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    page_type VARCHAR(50) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    is_published BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);"

# Table global_sections
echo "   - Création table global_sections..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
CREATE TABLE IF NOT EXISTS global_sections (
    id VARCHAR(50) PRIMARY KEY,
    section_type VARCHAR(50) NOT NULL,
    title VARCHAR(255),
    content TEXT,
    data JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);"

# Table rooms
echo "   - Création table rooms..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
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
);"

echo ""
echo "3. Vérification des tables créées..."
TABLES=("header_config" "footer_config" "homepage_sections" "legal_pages" "global_sections" "rooms")
for table in "${TABLES[@]}"; do
    if docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\dt $table" 2>/dev/null | grep -q "$table"; then
        echo "✅ Table $table créée"
    else
        echo "❌ Table $table manquante"
    fi
done

echo ""
echo "4. Insertion des données par défaut..."

# Header config
echo "   - Données header_config..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
INSERT INTO header_config (id, site_name, logo_type, logo_text, logo_alt_text) 
VALUES ('default', 'U SILENZIU', 'text', 'U SILENZIU', 'Logo U Silenziu')
ON CONFLICT (id) DO NOTHING;"

# Footer config
echo "   - Données footer_config..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
INSERT INTO footer_config (id, site_name, site_description, contact_phone, contact_email, contact_address, opening_hours_tuesday, opening_hours_wednesday, opening_hours_thursday, opening_hours_friday, opening_hours_saturday, opening_hours_sunday, copyright_text) 
VALUES ('default', 'U SILENZIU', 'Votre zone de défoulement à Buros', '+33 7 83 83 64 53', 'info@usilenziu.com', '18 Rue du Pont Long 64160 Buros Zone Berlanne', '14:00 – 21:00', '14:00 – 21:00', '14:00 – 21:00', '14:00 – 00:00', '14:00 – 00:00', 'Sur réservation uniquement', '© 2024 U Silenziu. Tous droits réservés.')
ON CONFLICT (id) DO NOTHING;"

# Homepage sections
echo "   - Données homepage_sections..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
INSERT INTO homepage_sections (id, section_type, title, content, data, order_index, is_visible, is_active) 
VALUES 
('hero', 'hero', 'U SILENZIU', 'Votre zone de défoulement à Buros', '{\"subtitle\": \"Énergie positive garantie !\"}', 1, true, true),
('rooms', 'rooms', 'Nos Salles', 'Découvrez nos différentes salles', '{}', 2, true, true),
('contact', 'contact', 'Contact', 'Contactez-nous', '{}', 3, true, true)
ON CONFLICT (id) DO NOTHING;"

# Global sections
echo "   - Données global_sections..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
INSERT INTO global_sections (id, section_type, title, content, data, is_active) 
VALUES ('cta', 'cta', 'Prêt à libérer votre stress ?', 'Réservez dès maintenant', '{\"button_text\": \"Réserver maintenant\"}', true)
ON CONFLICT (id) DO NOTHING;"

# Rooms
echo "   - Données rooms..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
INSERT INTO rooms (name, description, price, duration, max_people, objects_to_destroy, included, is_active) 
VALUES 
('Salle Douce', 'Pour un défoulement en douceur', 50.00, 60, 4, ARRAY['Assiettes', 'Verres'], ARRAY['Équipements de protection'], true),
('Salle Carnage', 'Pour un défoulement intense', 75.00, 60, 6, ARRAY['Électroménager', 'Meubles'], ARRAY['Équipements de protection'], true),
('Salle Privatisée', 'Salle privatisée pour groupes', 120.00, 90, 10, ARRAY['Choix personnalisé'], ARRAY['Équipements de protection'], true)
ON CONFLICT DO NOTHING;"

echo ""
echo "5. Vérification finale des données..."
for table in "${TABLES[@]}"; do
    count=$(docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -t -c "SELECT COUNT(*) FROM $table;" 2>/dev/null | tr -d ' ')
    echo "   $table: $count enregistrement(s)"
done

echo ""
echo "6. Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

echo ""
echo "7. Attente du démarrage (15 secondes)..."
sleep 15

echo ""
echo "8. Test des APIs..."
APIS=("header-config" "footer-config" "homepage-sections" "legal-pages")
for api in "${APIS[@]}"; do
    echo -n "   API $api : "
    if curl -s -f "https://rageroom.usilenziu.com/api/$api" >/dev/null 2>&1; then
        echo "✅ OK"
    else
        echo "❌ ERREUR"
    fi
done

echo ""
echo "✅ CORRECTION TERMINÉE !"
echo "🌐 Testez : https://rageroom.usilenziu.com"
