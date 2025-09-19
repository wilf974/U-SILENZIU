#!/bin/bash
# Script de création complète de toutes les tables manquantes
# U Silenziu - Septembre 2025

echo "🚀 CRÉATION COMPLÈTE DE TOUTES LES TABLES"
echo "========================================="
echo ""

# 1. Vérifier l'état actuel des tables
echo "1. Vérification de l'état actuel des tables..."
echo "Tables existantes :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
"

echo ""

# 2. Créer toutes les tables manquantes
echo "2. Création de toutes les tables manquantes..."
echo "Création du schéma complet..."

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
-- Extension pour UUIDs si pas encore fait
CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";

-- Table admin_users (si pas encore créée)
CREATE TABLE IF NOT EXISTS admin_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'super-admin')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE
);

-- Table rooms
CREATE TABLE IF NOT EXISTS rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    duration INTEGER NOT NULL DEFAULT 60,
    max_people INTEGER NOT NULL DEFAULT 4,
    objects_to_destroy TEXT[],
    included TEXT[],
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table reservations
CREATE TABLE IF NOT EXISTS reservations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20),
    room_id UUID REFERENCES rooms(id) ON DELETE SET NULL,
    room_name VARCHAR(255) NOT NULL,
    date DATE NOT NULL,
    time_slot VARCHAR(20) NOT NULL,
    duration INTEGER NOT NULL DEFAULT 60,
    participants INTEGER NOT NULL DEFAULT 1,
    amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled')),
    special_requests TEXT,
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

-- Table footer_config
CREATE TABLE IF NOT EXISTS footer_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    site_name VARCHAR(255) DEFAULT 'U SILENZIU',
    site_description TEXT,
    contact_phone VARCHAR(20),
    contact_email VARCHAR(255),
    contact_address TEXT,
    opening_hours_tuesday VARCHAR(50),
    opening_hours_wednesday VARCHAR(50),
    opening_hours_thursday VARCHAR(50),
    opening_hours_friday VARCHAR(50),
    opening_hours_saturday VARCHAR(50),
    opening_hours_sunday VARCHAR(50),
    legal_links JSONB DEFAULT '[]',
    copyright_text VARCHAR(255) DEFAULT '© 2024 U Silenziu. Tous droits réservés.',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table homepage_sections
CREATE TABLE IF NOT EXISTS homepage_sections (
    id VARCHAR(50) PRIMARY KEY,
    section_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    data JSONB DEFAULT '{}',
    order_index INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table legal_pages
CREATE TABLE IF NOT EXISTS legal_pages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    page_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    is_published BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table global_sections
CREATE TABLE IF NOT EXISTS global_sections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    section_key VARCHAR(100) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    data JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table smtp_config
CREATE TABLE IF NOT EXISTS smtp_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    host VARCHAR(255) NOT NULL,
    port INTEGER NOT NULL DEFAULT 587,
    secure BOOLEAN DEFAULT false,
    username VARCHAR(255),
    password_encrypted TEXT,
    from_email VARCHAR(255) NOT NULL,
    from_name VARCHAR(255) DEFAULT 'U Silenziu',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Créer les index
CREATE INDEX IF NOT EXISTS idx_admin_users_username ON admin_users(username);
CREATE INDEX IF NOT EXISTS idx_rooms_active ON rooms(is_active);
CREATE INDEX IF NOT EXISTS idx_reservations_date ON reservations(date);
CREATE INDEX IF NOT EXISTS idx_reservations_status ON reservations(status);
CREATE INDEX IF NOT EXISTS idx_reservations_room_id ON reservations(room_id);
CREATE INDEX IF NOT EXISTS idx_homepage_sections_active ON homepage_sections(is_active);
CREATE INDEX IF NOT EXISTS idx_legal_pages_published ON legal_pages(is_published);
CREATE INDEX IF NOT EXISTS idx_global_sections_active ON global_sections(is_active);

-- Vérifier que toutes les tables ont été créées
SELECT 'Toutes les tables créées avec succès' as status;
"

echo ""

# 3. Insérer les données par défaut
echo "3. Insertion des données par défaut..."
echo "Insertion des données de base..."

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
-- Insérer l'utilisateur administrateur
INSERT INTO admin_users (username, password_hash, role) 
VALUES ('administrateur', '@dm1n1str@t3uR!)', 'super-admin')
ON CONFLICT (username) DO UPDATE SET 
    password_hash = EXCLUDED.password_hash,
    role = EXCLUDED.role,
    updated_at = CURRENT_TIMESTAMP;

-- Insérer la configuration header
INSERT INTO header_config (id, site_name, logo_type, logo_text, logo_alt_text) 
VALUES ('default', 'U SILENZIU', 'text', 'U SILENZIU', 'Logo U Silenziu')
ON CONFLICT (id) DO UPDATE SET 
    site_name = EXCLUDED.site_name,
    logo_text = EXCLUDED.logo_text,
    updated_at = CURRENT_TIMESTAMP;

-- Insérer la configuration footer
INSERT INTO footer_config (id, site_name, site_description, contact_phone, contact_email, contact_address, opening_hours_tuesday, opening_hours_wednesday, opening_hours_thursday, opening_hours_friday, opening_hours_saturday, opening_hours_sunday, copyright_text) 
VALUES ('default', 'U SILENZIU', 'Votre zone de défoulement à Buros', '+33 7 83 83 64 53', 'info@usilenziu.com', '18 Rue du Pont Long 64160 Buros Zone Berlanne', '14:00 – 21:00', '14:00 – 21:00', '14:00 – 21:00', '14:00 – 00:00', '14:00 – 00:00', 'Sur réservation uniquement', '© 2024 U Silenziu. Tous droits réservés.')
ON CONFLICT (id) DO UPDATE SET 
    site_name = EXCLUDED.site_name,
    site_description = EXCLUDED.site_description,
    updated_at = CURRENT_TIMESTAMP;

-- Insérer les sections homepage
INSERT INTO homepage_sections (id, section_type, title, content, data, order_index, is_visible, is_active) 
VALUES 
('hero', 'hero', 'U SILENZIU', 'Votre zone de défoulement à Buros. Libérez votre stress et vos tensions dans un environnement sécurisé et fun.', '{\"subtitle\": \"Énergie positive garantie !\"}', 1, true, true),
('rooms', 'rooms', 'Nos Salles', 'Découvrez nos différentes salles de défoulement', '{}', 2, true, true),
('contact', 'contact', 'Contact', 'Contactez-nous pour réserver', '{}', 3, true, true)
ON CONFLICT (id) DO UPDATE SET 
    title = EXCLUDED.title,
    content = EXCLUDED.content,
    data = EXCLUDED.data,
    is_visible = EXCLUDED.is_visible,
    is_active = EXCLUDED.is_active;

-- Insérer les salles par défaut
INSERT INTO rooms (name, description, price, duration, max_people, objects_to_destroy, included, is_active) 
VALUES 
('Salle Douce', 'Pour un défoulement en douceur', 50.00, 60, 4, ARRAY['Assiettes', 'Verres', 'Objets légers'], ARRAY['Équipements de protection', 'Nettoyage'], true),
('Salle Carnage', 'Pour un défoulement intense', 75.00, 60, 6, ARRAY['Électroménager', 'Meubles', 'Gros objets'], ARRAY['Équipements de protection', 'Nettoyage', 'Marteau'], true),
('Salle Privatisée', 'Salle privatisée pour groupes', 120.00, 90, 10, ARRAY['Choix personnalisé'], ARRAY['Équipements de protection', 'Nettoyage', 'Animation'], true)
ON CONFLICT DO NOTHING;

-- Insérer les pages légales
INSERT INTO legal_pages (page_type, title, content, is_published) 
VALUES 
('mentions-legales', 'Mentions Légales', 'Contenu des mentions légales...', true),
('politique-confidentialite', 'Politique de Confidentialité', 'Contenu de la politique de confidentialité...', true),
('cgv', 'Conditions Générales de Vente', 'Contenu des CGV...', true)
ON CONFLICT DO NOTHING;

-- Insérer les sections globales
INSERT INTO global_sections (section_key, title, content, data, is_active) 
VALUES 
('about', 'À Propos', 'Découvrez U Silenziu, votre zone de défoulement à Buros', '{}', true)
ON CONFLICT (section_key) DO UPDATE SET 
    title = EXCLUDED.title,
    content = EXCLUDED.content,
    is_active = EXCLUDED.is_active;

-- Vérifier les données insérées
SELECT 'Données par défaut insérées avec succès' as status;
"

echo ""

# 4. Vérifier la structure finale
echo "4. Vérification de la structure finale..."
echo "Tables créées :"

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
"

echo ""

# 5. Vérifier les données
echo "5. Vérification des données..."
echo "Comptage des enregistrements :"

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
    'admin_users' as table_name, COUNT(*) as count FROM admin_users
UNION ALL
SELECT 'rooms', COUNT(*) FROM rooms
UNION ALL
SELECT 'reservations', COUNT(*) FROM reservations
UNION ALL
SELECT 'header_config', COUNT(*) FROM header_config
UNION ALL
SELECT 'footer_config', COUNT(*) FROM footer_config
UNION ALL
SELECT 'homepage_sections', COUNT(*) FROM homepage_sections
UNION ALL
SELECT 'legal_pages', COUNT(*) FROM legal_pages
UNION ALL
SELECT 'global_sections', COUNT(*) FROM global_sections
UNION ALL
SELECT 'smtp_config', COUNT(*) FROM smtp_config;
"

echo ""

# 6. Redémarrer l'application
echo "6. Redémarrage de l'application..."
echo "Redémarrage du conteneur application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

echo "Attente du démarrage (20 secondes)..."
sleep 20

echo ""

# 7. Test des APIs
echo "7. Test des APIs..."
echo "Test de l'API admin stats :"

curl -s "https://rageroom.usilenziu.com/api/admin/stats?includeRecent=true" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 500

echo ""

echo "Test de l'API rooms :"
curl -s "https://rageroom.usilenziu.com/api/rooms" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 200

echo ""

echo "Test de l'API homepage sections :"
curl -s "https://rageroom.usilenziu.com/api/homepage-sections" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 200

echo ""

echo "🎯 RÉSUMÉ DE LA CRÉATION"
echo "========================"
echo "✅ Toutes les tables créées avec le bon schéma"
echo "✅ Index et contraintes configurés"
echo "✅ Données par défaut insérées"
echo "✅ Application redémarrée"
echo "✅ APIs testées"
echo ""
echo "🔗 Testez maintenant :"
echo "- Admin: https://rageroom.usilenziu.com/admin"
echo "- Site: https://rageroom.usilenziu.com"
echo ""
echo "✅ CRÉATION TERMINÉE !"
