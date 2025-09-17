#!/bin/bash

echo "🚀 DÉPLOIEMENT EN PRODUCTION - U SILENZIU"
echo "========================================="

# Vérifier qu'on est dans le bon répertoire
if [ ! -f "package.json" ]; then
    echo "❌ Erreur: Ce script doit être exécuté dans le répertoire du projet"
    exit 1
fi

# Vérifier que le fichier de production existe
if [ ! -f "docker-compose.prod.yml" ]; then
    echo "❌ Erreur: docker-compose.prod.yml non trouvé"
    exit 1
fi

echo "📥 Étape 1: Récupération du code depuis Git..."
git fetch origin
git reset --hard origin/main
git clean -fd

echo "🛑 Étape 2: Arrêt des conteneurs existants..."
docker compose -f docker-compose.prod.yml down --volumes --remove-orphans

echo "🧹 Étape 3: Nettoyage des images inutilisées..."
docker system prune -f

echo "🔨 Étape 4: Construction et démarrage des conteneurs de production..."
docker compose -f docker-compose.prod.yml up -d --build

echo "⏳ Étape 5: Attente du démarrage des services..."
sleep 30

echo "📊 Étape 6: Vérification du statut des conteneurs..."
docker compose -f docker-compose.prod.yml ps

echo "🗄️ Étape 7: Initialisation de la base de données..."

# Attendre que PostgreSQL soit prêt
echo "⏳ Attente de PostgreSQL..."
until docker exec u-silenziu-postgres-prod pg_isready -U usilenzio_user -d usilenzio; do
    echo "⏳ PostgreSQL n'est pas encore prêt..."
    sleep 5
done

# Créer toutes les tables
echo "🏗️ Création des tables..."
docker exec u-silenziu-postgres-prod psql -U usilenzio_user -d usilenzio -c "
-- Table admin_users
CREATE TABLE IF NOT EXISTS admin_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'admin',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- Table homepage_sections
CREATE TABLE IF NOT EXISTS homepage_sections (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    section_type VARCHAR(50) NOT NULL,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table footer_config
CREATE TABLE IF NOT EXISTS footer_config (
    id SERIAL PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table header_config
CREATE TABLE IF NOT EXISTS header_config (
    id SERIAL PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table entry_page_config
CREATE TABLE IF NOT EXISTS entry_page_config (
    id SERIAL PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table legal_pages
CREATE TABLE IF NOT EXISTS legal_pages (
    id SERIAL PRIMARY KEY,
    slug VARCHAR(100) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table rooms
CREATE TABLE IF NOT EXISTS rooms (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    capacity INTEGER,
    price_per_hour DECIMAL(10,2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table reservations
CREATE TABLE IF NOT EXISTS reservations (
    id SERIAL PRIMARY KEY,
    room_id INTEGER REFERENCES rooms(id),
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    total_price DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"

# Insérer les données par défaut
echo "📝 Insertion des données par défaut..."

# Utilisateur administrateur
docker exec u-silenziu-postgres-prod psql -U usilenzio_user -d usilenzio -c "
INSERT INTO admin_users (username, password_hash, role) 
VALUES ('administrateur', '\$2a\$10\$I2QGTSQhxlwflsXseiUbH.E2wXgj2T20Y.LKqj0MDSDtuDJCUrO56', 'super-admin')
ON CONFLICT (username) DO UPDATE SET 
    password_hash = EXCLUDED.password_hash,
    role = EXCLUDED.role,
    updated_at = CURRENT_TIMESTAMP;
"

# Configuration du footer
docker exec u-silenziu-postgres-prod psql -U usilenzio_user -d usilenzio -c "
INSERT INTO footer_config (config_key, config_value) VALUES
('site_name', 'U SILENZIU'),
('contact_email', 'info@usilenziu.com'),
('contact_phone', '+33 7 83 83 64 53'),
('opening_hours', 'Mardi-Jeudi: 14h-21h | Vendredi-Samedi: 14h-00h'),
('address', 'Buros, France'),
('social_links', '{\"facebook\": \"\", \"instagram\": \"\", \"twitter\": \"\"}')
ON CONFLICT (config_key) DO UPDATE SET config_value = EXCLUDED.config_value;
"

# Configuration de l'en-tête
docker exec u-silenziu-postgres-prod psql -U usilenzio_user -d usilenzio -c "
INSERT INTO header_config (config_key, config_value) VALUES
('logo_url', '/logo.png'),
('site_title', 'U SILENZIU'),
('navigation_links', '[{\"label\": \"Accueil\", \"href\": \"/\"}, {\"label\": \"Le concept\", \"href\": \"/concept\"}, {\"label\": \"Contact\", \"href\": \"/contact\"}, {\"label\": \"Nos salles\", \"href\": \"/rooms\"}, {\"label\": \"Réservation\", \"href\": \"/reservation\"}]')
ON CONFLICT (config_key) DO UPDATE SET config_value = EXCLUDED.config_value;
"

# Sections de la page d'accueil
docker exec u-silenziu-postgres-prod psql -U usilenzio_user -d usilenzio -c "
INSERT INTO homepage_sections (title, content, section_type, display_order, is_active) VALUES
('Hero', '{\"title\": \"Libérez votre STRESS\", \"subtitle\": \"Zone de défoulement à Buros\", \"description\": \"Venez vous défouler dans notre espace sécurisé et amusant\", \"cta_primary\": {\"text\": \"Réserver\", \"href\": \"/reservation\"}, \"cta_secondary\": {\"text\": \"Découvrir\", \"href\": \"/concept\"}, \"features\": [\"Sécurité garantie\", \"Matériel fourni\", \"Ambiance décontractée\"]}', 'hero', 1, true),
('Concept', '{\"title\": \"Le Concept\", \"subtitle\": \"Une expérience unique de défoulement\", \"description\": \"U Silenziu vous propose une expérience de défoulement sécurisée et encadrée\", \"features\": [{\"title\": \"Sécurité\", \"description\": \"Équipement de protection fourni\"}, {\"title\": \"Fun\", \"description\": \"Ambiance décontractée et amusante\"}, {\"title\": \"Thérapie\", \"description\": \"Libérez votre stress en toute sécurité\"}]}', 'concept', 2, true),
('Salles', '{\"title\": \"Nos Salles\", \"subtitle\": \"Choisissez votre espace de défoulement\", \"description\": \"Plusieurs salles disponibles pour votre session de défoulement\"}', 'rooms', 3, true),
('Process', '{\"title\": \"Comment ça marche ?\", \"subtitle\": \"3 étapes simples\", \"description\": \"Un processus simple pour votre session de défoulement\", \"steps\": [{\"title\": \"Réservez\", \"description\": \"Choisissez votre créneau\"}, {\"title\": \"Équipez-vous\", \"description\": \"Nous vous fournissons tout le matériel\"}, {\"title\": \"Défoulez-vous\", \"description\": \"Libérez votre stress en toute sécurité\"}]}', 'process', 4, true),
('FAQ', '{\"title\": \"Questions Fréquentes\", \"subtitle\": \"Tout ce que vous devez savoir\", \"questions\": [{\"question\": \"C''est quoi une salle de défoulement ?\", \"answer\": \"Une salle de défoulement est un endroit où vous pouvez vous défouler en toute liberté dans un environnement sûr et contrôlé.\"}, {\"question\": \"Comment m''habiller ?\", \"answer\": \"Nous vous recommandons une tenue ample et confortable. Des chaussures fermées sont obligatoires.\"}, {\"question\": \"Quels objets puis-je casser ?\", \"answer\": \"Selon la formule choisie, vous pourrez casser des bouteilles, verres, objets multimédia, petit électroménager...\"}]}', 'faq', 5, true),
('Contact', '{\"title\": \"Contactez-nous\", \"subtitle\": \"Nous sommes là pour vous\", \"description\": \"N''hésitez pas à nous contacter pour toute question\", \"contact_info\": {\"phone\": \"+33 7 83 83 64 53\", \"email\": \"info@usilenziu.com\", \"address\": \"Buros, France\"}}', 'contact', 6, true)
ON CONFLICT DO NOTHING;
"

# Pages légales
docker exec u-silenziu-postgres-prod psql -U usilenzio_user -d usilenzio -c "
INSERT INTO legal_pages (slug, title, content, is_active) VALUES
('mentions-legales', 'Mentions Légales', 'Contenu des mentions légales...', true),
('politique-confidentialite', 'Politique de Confidentialité', 'Contenu de la politique de confidentialité...', true),
('cgv', 'Conditions Générales de Vente', 'Contenu des CGV...', true),
('parametres-cookies', 'Paramètres des Cookies', 'Contenu des paramètres de cookies...', true)
ON CONFLICT (slug) DO UPDATE SET 
    title = EXCLUDED.title,
    content = EXCLUDED.content,
    is_active = EXCLUDED.is_active;
"

# Salles par défaut
docker exec u-silenziu-postgres-prod psql -U usilenzio_user -d usilenzio -c "
INSERT INTO rooms (name, description, capacity, price_per_hour, is_active) VALUES
('Salle Défoulement Standard', 'Salle de défoulement standard avec objets variés', 4, 25.00, true),
('Salle Défoulement Premium', 'Salle de défoulement premium avec plus d''objets', 6, 35.00, true),
('Salle Multimédia', 'Salle spécialisée pour le défoulement d''objets multimédia', 3, 30.00, true)
ON CONFLICT DO NOTHING;
"

echo "✅ Étape 8: Vérification finale..."
docker exec u-silenziu-postgres-prod psql -U usilenzio_user -d usilenzio -c "\dt"

echo "🔄 Étape 9: Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

echo "⏳ Attente du redémarrage..."
sleep 15

echo "📊 Étape 10: Vérification finale du statut..."
docker compose -f docker-compose.prod.yml ps

echo ""
echo "🎉 DÉPLOIEMENT EN PRODUCTION TERMINÉ !"
echo "====================================="
echo ""
echo "✅ Tous les conteneurs sont démarrés"
echo "✅ Base de données initialisée avec les données par défaut"
echo "✅ Utilisateur administrateur créé"
echo "✅ Configuration par défaut appliquée"
echo ""
echo "🌐 Application accessible sur: http://$(curl -s ifconfig.me):3000"
echo "🔐 Admin: http://$(curl -s ifconfig.me):3000/admin/login"
echo "   Utilisateur: administrateur"
echo "   Mot de passe: @dm1n1str@t3uR!)"
echo ""
echo "🧪 Test de l'application..."
curl -s -o /dev/null -w "Status: %{http_code}\n" http://localhost:3000 || echo "Application en cours de démarrage..."
echo ""
echo "📋 Commandes utiles:"
echo "  - Voir les logs: docker compose -f docker-compose.prod.yml logs -f"
echo "  - Redémarrer: docker compose -f docker-compose.prod.yml restart"
echo "  - Arrêter: docker compose -f docker-compose.prod.yml down"
echo "  - Statut: docker compose -f docker-compose.prod.yml ps"
