# Script simple pour initialiser la base de données locale
Write-Host "Initialisation de la base de données..." -ForegroundColor Cyan

# Démarrer PostgreSQL
Write-Host "Demarrage de PostgreSQL..." -ForegroundColor Yellow
docker compose -f docker-compose.dev.yml up -d postgres

# Attendre que PostgreSQL soit prêt
Write-Host "Attente de PostgreSQL..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Créer les tables
Write-Host "Creation des tables..." -ForegroundColor Yellow
docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c "CREATE TABLE IF NOT EXISTS admin_users (id SERIAL PRIMARY KEY, username VARCHAR(50) UNIQUE NOT NULL, password_hash VARCHAR(255) NOT NULL, role VARCHAR(20) NOT NULL DEFAULT 'admin', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, last_login TIMESTAMP);"

docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c "CREATE TABLE IF NOT EXISTS homepage_sections (id SERIAL PRIMARY KEY, title VARCHAR(255) NOT NULL, content TEXT, section_type VARCHAR(50) NOT NULL, display_order INTEGER DEFAULT 0, is_active BOOLEAN DEFAULT true, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"

docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c "CREATE TABLE IF NOT EXISTS footer_config (id SERIAL PRIMARY KEY, config_key VARCHAR(100) UNIQUE NOT NULL, config_value TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"

docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c "CREATE TABLE IF NOT EXISTS header_config (id SERIAL PRIMARY KEY, config_key VARCHAR(100) UNIQUE NOT NULL, config_value TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"

docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c "CREATE TABLE IF NOT EXISTS entry_page_config (id SERIAL PRIMARY KEY, config_key VARCHAR(100) UNIQUE NOT NULL, config_value TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"

docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c "CREATE TABLE IF NOT EXISTS legal_pages (id SERIAL PRIMARY KEY, slug VARCHAR(100) UNIQUE NOT NULL, title VARCHAR(255) NOT NULL, content TEXT, is_active BOOLEAN DEFAULT true, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"

docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c "CREATE TABLE IF NOT EXISTS rooms (id SERIAL PRIMARY KEY, name VARCHAR(255) NOT NULL, description TEXT, capacity INTEGER, price_per_hour DECIMAL(10,2), is_active BOOLEAN DEFAULT true, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"

docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c "CREATE TABLE IF NOT EXISTS reservations (id SERIAL PRIMARY KEY, room_id INTEGER REFERENCES rooms(id), customer_name VARCHAR(255) NOT NULL, customer_email VARCHAR(255) NOT NULL, customer_phone VARCHAR(20), start_time TIMESTAMP NOT NULL, end_time TIMESTAMP NOT NULL, total_price DECIMAL(10,2), status VARCHAR(20) DEFAULT 'pending', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"

# Insérer l'utilisateur admin
Write-Host "Creation de l'utilisateur admin..." -ForegroundColor Yellow
docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c "INSERT INTO admin_users (username, password_hash, role) VALUES ('administrateur', '\$2a\$10\$I2QGTSQhxlwflsXseiUbH.E2wXgj2T20Y.LKqj0MDSDtuDJCUrO56', 'super-admin') ON CONFLICT (username) DO UPDATE SET password_hash = EXCLUDED.password_hash, role = EXCLUDED.role, updated_at = CURRENT_TIMESTAMP;"

# Insérer les données par défaut
Write-Host "Insertion des donnees par defaut..." -ForegroundColor Yellow
docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c "INSERT INTO footer_config (config_key, config_value) VALUES ('site_name', 'U SILENZIU'), ('contact_email', 'info@usilenziu.com'), ('contact_phone', '+33 7 83 83 64 53') ON CONFLICT (config_key) DO UPDATE SET config_value = EXCLUDED.config_value;"

docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c "INSERT INTO header_config (config_key, config_value) VALUES ('site_title', 'U SILENZIU'), ('logo_url', '/logo.png') ON CONFLICT (config_key) DO UPDATE SET config_value = EXCLUDED.config_value;"

docker exec u-silenziu-postgres-dev psql -U usilenzio_user -d usilenzio_dev -c "INSERT INTO homepage_sections (title, content, section_type, display_order, is_active) VALUES ('Hero', '{\"title\": \"Libérez votre STRESS\", \"subtitle\": \"Zone de défoulement à Buros\"}', 'hero', 1, true) ON CONFLICT DO NOTHING;"

Write-Host "Base de donnees initialisee !" -ForegroundColor Green
Write-Host "Vous pouvez maintenant demarrer l'application avec: npm run dev" -ForegroundColor Cyan
