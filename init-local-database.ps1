# Script PowerShell pour initialiser la base de données locale
# U Silenziu - Janvier 2025

Write-Host "🗄️ Initialisation de la base de données locale..." -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Vérifier que Docker est en cours d'exécution
Write-Host "`n📋 Étape 1: Vérification de Docker" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow

try {
    $dockerStatus = docker ps --format "table {{.Names}}\t{{.Status}}" 2>$null
    if ($dockerStatus -and $dockerStatus -notmatch "Error") {
        Write-Host "✅ Docker est en cours d'exécution" -ForegroundColor Green
        Write-Host $dockerStatus
    } else {
        Write-Host "❌ Docker n'est pas en cours d'exécution" -ForegroundColor Red
        Write-Host "Démarrez Docker Desktop et relancez ce script" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "❌ Erreur lors de la vérification de Docker" -ForegroundColor Red
    exit 1
}

# Démarrer les conteneurs
Write-Host "`n📋 Étape 2: Démarrage des conteneurs" -ForegroundColor Yellow
Write-Host "------------------------------------" -ForegroundColor Yellow

Write-Host "🚀 Démarrage de PostgreSQL et Redis..." -ForegroundColor Blue
docker compose -f docker-compose.dev.yml up -d postgres redis

# Attendre que PostgreSQL soit prêt
Write-Host "`n📋 Étape 3: Attente de PostgreSQL" -ForegroundColor Yellow
Write-Host "----------------------------------" -ForegroundColor Yellow

Write-Host "⏳ Attente du démarrage de PostgreSQL..." -ForegroundColor Blue
$maxAttempts = 30
$attempt = 0

do {
    $attempt++
    try {
        $result = docker exec u-silenziu-postgres-dev pg_isready -U usilenzio_user -d usilenzio_dev 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ PostgreSQL est prêt" -ForegroundColor Green
            break
        }
    } catch {
        # Continue
    }
    
    if ($attempt -ge $maxAttempts) {
        Write-Host "❌ PostgreSQL n'est pas accessible après $maxAttempts tentatives" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "⏳ Tentative $attempt/$maxAttempts..." -ForegroundColor Blue
    Start-Sleep -Seconds 2
} while ($attempt -lt $maxAttempts)

# Créer les tables
Write-Host "`n📋 Étape 4: Création des tables" -ForegroundColor Yellow
Write-Host "--------------------------------" -ForegroundColor Yellow

Write-Host "🏗️ Création des tables de la base de données..." -ForegroundColor Blue

$createTablesSQL = @'
CREATE TABLE IF NOT EXISTS admin_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'admin',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

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

CREATE TABLE IF NOT EXISTS footer_config (
    id SERIAL PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS header_config (
    id SERIAL PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS entry_page_config (
    id SERIAL PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS legal_pages (
    id SERIAL PRIMARY KEY,
    slug VARCHAR(100) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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
'@

docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c $createTablesSQL

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Tables créées avec succès" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors de la création des tables" -ForegroundColor Red
    exit 1
}

# Insérer les données par défaut
Write-Host "`n📋 Étape 5: Insertion des données par défaut" -ForegroundColor Yellow
Write-Host "---------------------------------------------" -ForegroundColor Yellow

# Utilisateur administrateur
Write-Host "👤 Création de l'utilisateur administrateur..." -ForegroundColor Blue
docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c "
INSERT INTO admin_users (username, password_hash, role) 
VALUES ('administrateur', '\$2a\$10\$I2QGTSQhxlwflsXseiUbH.E2wXgj2T20Y.LKqj0MDSDtuDJCUrO56', 'super-admin')
ON CONFLICT (username) DO UPDATE SET 
    password_hash = EXCLUDED.password_hash,
    role = EXCLUDED.role,
    updated_at = CURRENT_TIMESTAMP;
"

# Configuration du footer
Write-Host "📝 Configuration du footer..." -ForegroundColor Blue
docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c "
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
Write-Host "📝 Configuration de l'en-tête..." -ForegroundColor Blue
docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c "
INSERT INTO header_config (config_key, config_value) VALUES
('logo_url', '/logo.png'),
('site_title', 'U SILENZIU'),
('navigation_links', '[{\"label\": \"Accueil\", \"href\": \"/\"}, {\"label\": \"Le concept\", \"href\": \"/concept\"}, {\"label\": \"Contact\", \"href\": \"/contact\"}, {\"label\": \"Nos salles\", \"href\": \"/rooms\"}, {\"label\": \"Réservation\", \"href\": \"/reservation\"}]')
ON CONFLICT (config_key) DO UPDATE SET config_value = EXCLUDED.config_value;
"

# Sections de la page d'accueil
Write-Host "📝 Configuration des sections de la page d'accueil..." -ForegroundColor Blue
docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c "
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
Write-Host "📝 Configuration des pages légales..." -ForegroundColor Blue
docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c "
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
Write-Host "📝 Configuration des salles..." -ForegroundColor Blue
docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c "
INSERT INTO rooms (name, description, capacity, price_per_hour, is_active) VALUES
('Salle Défoulement Standard', 'Salle de défoulement standard avec objets variés', 4, 25.00, true),
('Salle Défoulement Premium', 'Salle de défoulement premium avec plus d''objets', 6, 35.00, true),
('Salle Multimédia', 'Salle spécialisée pour le défoulement d''objets multimédia', 3, 30.00, true)
ON CONFLICT DO NOTHING;
"

# Vérification finale
Write-Host "`n📋 Étape 6: Vérification finale" -ForegroundColor Yellow
Write-Host "-------------------------------" -ForegroundColor Yellow

Write-Host "✅ Vérification des tables créées..." -ForegroundColor Blue
docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c "\dt"

Write-Host "`n✅ Initialisation de la base de données terminée !" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

Write-Host "`n📋 Résumé de la configuration:" -ForegroundColor Cyan
Write-Host "- ✅ PostgreSQL démarré sur le port 5432" -ForegroundColor White
Write-Host "- ✅ Redis démarré sur le port 6379" -ForegroundColor White
Write-Host "- ✅ Toutes les tables créées" -ForegroundColor White
Write-Host "- ✅ Données par défaut insérées" -ForegroundColor White
Write-Host "- ✅ Utilisateur administrateur créé" -ForegroundColor White

Write-Host "`n🚀 Prochaines étapes:" -ForegroundColor Cyan
Write-Host "1. Démarrer l'application Next.js:" -ForegroundColor White
Write-Host "   docker compose -f docker-compose.dev.yml up u-silenziu" -ForegroundColor Gray
Write-Host "2. Ou démarrer en mode développement local:" -ForegroundColor White
Write-Host "   npm run dev" -ForegroundColor Gray
Write-Host "3. Accéder à l'application sur http://localhost:3000" -ForegroundColor White
Write-Host "4. Admin sur http://localhost:3000/admin/login" -ForegroundColor White
Write-Host "   Utilisateur: administrateur" -ForegroundColor Gray
Write-Host "   Mot de passe: @dm1n1str@t3uR!)" -ForegroundColor Gray

Write-Host "`n🎉 La base de données est prête pour le développement !" -ForegroundColor Green
