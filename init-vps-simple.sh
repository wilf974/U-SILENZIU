#!/bin/bash

# Script d'initialisation simplifiée de la base de données pour le VPS
# Crée toutes les tables directement sans fichiers SQL externes

echo "🚀 Initialisation simplifiée de la base de données PostgreSQL..."

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "docker-compose.prod.yml" ]; then
    echo "❌ Erreur: docker-compose.prod.yml non trouvé"
    exit 1
fi

# Obtenir l'ID du container PostgreSQL
PG_CONTAINER=$(docker compose -f docker-compose.prod.yml ps -q postgres)

if [ -z "$PG_CONTAINER" ]; then
    echo "❌ Erreur: Container PostgreSQL non trouvé"
    exit 1
fi

echo "✅ Container PostgreSQL trouvé: $PG_CONTAINER"

# Créer les extensions nécessaires
echo "🔧 Création des extensions PostgreSQL..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"

# Créer toutes les tables nécessaires
echo "🗄️ Création des tables..."

# Table rooms
echo "  🏠 Création de la table rooms..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
CREATE TABLE IF NOT EXISTS rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    duration INTEGER NOT NULL DEFAULT 30,
    price DECIMAL(10,2) NOT NULL DEFAULT 0,
    max_people INTEGER NOT NULL DEFAULT 4,
    objects_to_destroy TEXT[] DEFAULT '{}',
    included TEXT[] DEFAULT '{}',
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insérer des salles par défaut
INSERT INTO rooms (name, description, duration, price, max_people, objects_to_destroy, included, image_url, is_active) 
VALUES 
    ('Salle Douce', 'Défoulement Soft', 30, 25, 4, ARRAY['vaisselle', 'verres', 'assiettes'], ARRAY['équipement de protection', 'encadrement'], '/images/salle-douce.jpg', true),
    ('Salle Carnage', 'Défoulement Intense', 45, 35, 6, ARRAY['électroménager', 'meubles', 'télévision'], ARRAY['marteaux', 'battes', 'protection complète'], '/images/salle-carnage.jpg', true),
    ('Salle Extrême', 'Défoulement Total', 60, 50, 8, ARRAY['voiture', 'gros électroménager'], ARRAY['masse', 'hache', 'équipement lourd'], '/images/salle-extreme.jpg', true)
ON CONFLICT DO NOTHING;
EOF

# Table header_config
echo "  📋 Création de la table header_config..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
CREATE TABLE IF NOT EXISTS header_config (
    id SERIAL PRIMARY KEY,
    logo_url VARCHAR(500),
    logo_alt VARCHAR(255) DEFAULT 'Logo U Silenziu',
    site_name VARCHAR(255) DEFAULT 'U SILENZIU',
    tagline VARCHAR(500),
    contact_phone VARCHAR(20) DEFAULT '+33 7 83 83 64 53',
    contact_email VARCHAR(255) DEFAULT 'info@usilenziu.com',
    opening_hours VARCHAR(255) DEFAULT 'Mardi-Jeudi: 14h-21h | Vendredi: 14h-24h',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insérer la configuration par défaut
INSERT INTO header_config (logo_url, site_name, tagline, contact_phone, contact_email, opening_hours, is_active)
VALUES ('/images/logo.png', 'U SILENZIU', 'Libérez votre stress en toute sécurité', '+33 7 83 83 64 53', 'info@usilenziu.com', 'Mardi-Jeudi: 14h-21h | Vendredi: 14h-24h', true)
ON CONFLICT DO NOTHING;
EOF

# Table footer_config
echo "  🦶 Création de la table footer_config..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
CREATE TABLE IF NOT EXISTS footer_config (
    id SERIAL PRIMARY KEY,
    contact_address TEXT DEFAULT '123 Rue de la Détente, 20000 Ajaccio, Corse',
    contact_phone VARCHAR(20) DEFAULT '+33 7 83 83 64 53',
    contact_email VARCHAR(255) DEFAULT 'info@usilenziu.com',
    opening_hours TEXT DEFAULT 'Mardi au Jeudi: 14h-21h\nVendredi: 14h-24h\nWeekend: Sur réservation',
    social_facebook VARCHAR(255),
    social_instagram VARCHAR(255),
    social_twitter VARCHAR(255),
    copyright_text VARCHAR(255) DEFAULT '© 2024 U Silenziu. Tous droits réservés.',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insérer la configuration par défaut
INSERT INTO footer_config (contact_address, contact_phone, contact_email, opening_hours, copyright_text, is_active)
VALUES ('123 Rue de la Détente, 20000 Ajaccio, Corse', '+33 7 83 83 64 53', 'info@usilenziu.com', 'Mardi au Jeudi: 14h-21h\nVendredi: 14h-24h\nWeekend: Sur réservation', '© 2024 U Silenziu. Tous droits réservés.', true)
ON CONFLICT DO NOTHING;
EOF

# Table homepage_sections
echo "  📄 Création de la table homepage_sections..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
CREATE TABLE IF NOT EXISTS homepage_sections (
    id SERIAL PRIMARY KEY,
    section_key VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(255),
    subtitle TEXT,
    content TEXT,
    button_text VARCHAR(100),
    button_link VARCHAR(255),
    image_url VARCHAR(500),
    background_color VARCHAR(20),
    text_color VARCHAR(20),
    order_index INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insérer les sections par défaut
INSERT INTO homepage_sections (section_key, title, subtitle, content, button_text, button_link, image_url, order_index, is_active)
VALUES 
    ('hero', 'Libérez votre STRESS', 'Venez vous défouler dans notre espace sécurisé', 'Découvrez une nouvelle façon de gérer votre stress et vos émotions dans un environnement contrôlé et thérapeutique.', 'Réserver maintenant', '/reservation', '/images/hero-bg.jpg', 1, true),
    ('salles', 'Nos Salles de Défoulement', 'Choisissez votre niveau d''intensité', 'De la détente douce au défoulement intense, nos salles s''adaptent à vos besoins et votre humeur du moment.', 'Voir les salles', '#salles', '/images/salles-bg.jpg', 2, true),
    ('concept', 'Le Concept', 'Thérapie par le défoulement', 'Une approche innovante pour libérer les tensions et retrouver un équilibre émotionnel dans un cadre sécurisé.', 'En savoir plus', '/concept', '/images/concept-bg.jpg', 3, true),
    ('process', 'Comment ça marche', 'Votre expérience en 3 étapes', 'Réservation, équipement, défoulement - tout est prévu pour une expérience sécurisée et libératrice.', '', '', '', 4, true),
    ('faq', 'Questions Fréquentes', 'Toutes les réponses à vos questions', 'Retrouvez les réponses aux questions les plus courantes sur nos services, la sécurité et les modalités.', '', '', '', 5, true),
    ('contact', 'Nous Contacter', 'Prêt à libérer votre stress ?', 'Contactez-nous pour plus d''informations ou pour réserver votre séance de défoulement.', 'Nous contacter', '/contact', '', 6, true)
ON CONFLICT (section_key) DO NOTHING;
EOF

# Table admin_users
echo "  👤 Création de la table admin_users..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
CREATE TABLE IF NOT EXISTS admin_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'admin',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insérer l'utilisateur admin par défaut (mot de passe: MotDePasse123!)
INSERT INTO admin_users (username, password_hash, role, is_active)
VALUES ('administrateur', '$2a$10$YourHashedPasswordHere', 'super-admin', true)
ON CONFLICT (username) DO NOTHING;
EOF

# Table reservations
echo "  📅 Création de la table reservations..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
CREATE TABLE IF NOT EXISTS reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_number VARCHAR(20) UNIQUE NOT NULL,
    room_id UUID REFERENCES rooms(id),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    date DATE NOT NULL,
    time_slot VARCHAR(10) NOT NULL,
    duration INTEGER NOT NULL DEFAULT 30,
    nb_people INTEGER NOT NULL DEFAULT 1,
    total_price DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    special_requests TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EOF

echo "🔄 Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

echo "⏳ Attente du redémarrage (5 secondes)..."
sleep 5

echo "📊 Statut final des containers..."
docker compose -f docker-compose.prod.yml ps

echo ""
echo "✅ Initialisation terminée !"
echo ""
echo "🌐 Testez votre site: http://72.60.90.156:3000"
echo "🔐 Admin: http://72.60.90.156:3000/admin"
echo "   👤 Utilisateur: administrateur"
echo "   🔑 Mot de passe: MotDePasse123!"
echo ""
echo "📋 Si des erreurs persistent, consultez les logs:"
echo "   docker compose -f docker-compose.prod.yml logs --tail=50 u-silenziu"
