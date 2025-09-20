# Script de diagnostic complet pour le probleme de l'en-tete sur VPS
# U Silenziu - Decembre 2024

Write-Host "DIAGNOSTIC COMPLET DU PROBLEME DE L'EN-TETE SUR VPS" -ForegroundColor Yellow
Write-Host "=================================================" -ForegroundColor Yellow
Write-Host ""

Write-Host "Instructions pour le VPS :" -ForegroundColor Cyan
Write-Host "1. Se connecter au VPS via SSH" -ForegroundColor White
Write-Host "2. Aller dans le repertoire du projet" -ForegroundColor White
Write-Host "3. Executer les commandes suivantes dans l'ordre :" -ForegroundColor White
Write-Host ""

Write-Host "ETAPE 1: Mise a jour du code" -ForegroundColor Green
Write-Host "git pull origin main" -ForegroundColor Gray
Write-Host ""

Write-Host "ETAPE 2: Arret complet des conteneurs" -ForegroundColor Green
Write-Host "docker compose -f docker-compose.prod.yml down" -ForegroundColor Gray
Write-Host ""

Write-Host "ETAPE 3: Nettoyage complet du systeme Docker" -ForegroundColor Green
Write-Host "docker system prune -af" -ForegroundColor Gray
Write-Host "docker volume prune -f" -ForegroundColor Gray
Write-Host ""

Write-Host "ETAPE 4: Reconstruction complete" -ForegroundColor Green
Write-Host "docker compose -f docker-compose.prod.yml up -d --build --force-recreate" -ForegroundColor Gray
Write-Host ""

Write-Host "ETAPE 5: Attente du demarrage" -ForegroundColor Green
Write-Host "sleep 30" -ForegroundColor Gray
Write-Host ""

Write-Host "ETAPE 6: Verification des conteneurs" -ForegroundColor Green
Write-Host "docker compose -f docker-compose.prod.yml ps" -ForegroundColor Gray
Write-Host ""

Write-Host "ETAPE 7: Test de l'API header-config" -ForegroundColor Green
Write-Host "curl -v https://rageroom.usilenziu.com/api/admin/header-config" -ForegroundColor Gray
Write-Host ""

Write-Host "ETAPE 8: Verification des logs" -ForegroundColor Green
Write-Host "docker compose -f docker-compose.prod.yml logs u-silenziu --tail=50" -ForegroundColor Gray
Write-Host ""

Write-Host "ETAPE 9: Verification de la base de donnees" -ForegroundColor Green
Write-Host "docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c \"SELECT * FROM header_config;\"" -ForegroundColor Gray
Write-Host ""

Write-Host "ETAPE 10: Si la table n'existe pas, la creer" -ForegroundColor Yellow
Write-Host "docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c \"" -ForegroundColor Gray
Write-Host "CREATE TABLE IF NOT EXISTS header_config (" -ForegroundColor Gray
Write-Host "  id SERIAL PRIMARY KEY," -ForegroundColor Gray
Write-Host "  site_name VARCHAR(255) NOT NULL DEFAULT 'U SILENZIU'," -ForegroundColor Gray
Write-Host "  logo_type VARCHAR(20) NOT NULL DEFAULT 'text'," -ForegroundColor Gray
Write-Host "  logo_text VARCHAR(255) DEFAULT 'U SILENZIU'," -ForegroundColor Gray
Write-Host "  logo_image_url TEXT," -ForegroundColor Gray
Write-Host "  logo_alt_text VARCHAR(255) DEFAULT 'Logo U Silenziu'," -ForegroundColor Gray
Write-Host "  logo_uploaded_data BYTEA," -ForegroundColor Gray
Write-Host "  logo_uploaded_filename VARCHAR(255)," -ForegroundColor Gray
Write-Host "  logo_uploaded_mimetype VARCHAR(100)," -ForegroundColor Gray
Write-Host "  logo_uploaded_size INTEGER," -ForegroundColor Gray
Write-Host "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," -ForegroundColor Gray
Write-Host "  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" -ForegroundColor Gray
Write-Host ");" -ForegroundColor Gray
Write-Host "\"" -ForegroundColor Gray
Write-Host ""

Write-Host "ETAPE 11: Insertion d'une configuration par defaut" -ForegroundColor Yellow
Write-Host "docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c \"" -ForegroundColor Gray
Write-Host "INSERT INTO header_config (site_name, logo_type, logo_text, logo_alt_text) " -ForegroundColor Gray
Write-Host "VALUES ('U SILENZIU', 'text', 'U SILENZIU', 'Logo U Silenziu') " -ForegroundColor Gray
Write-Host "ON CONFLICT DO NOTHING;" -ForegroundColor Gray
Write-Host "\"" -ForegroundColor Gray
Write-Host ""

Write-Host "ETAPE 12: Redemarrage final" -ForegroundColor Green
Write-Host "docker compose -f docker-compose.prod.yml restart u-silenziu" -ForegroundColor Gray
Write-Host ""

Write-Host "ETAPE 13: Test final" -ForegroundColor Green
Write-Host "curl -I https://rageroom.usilenziu.com" -ForegroundColor Gray
Write-Host ""

Write-Host "Si le probleme persiste, envoyer les logs complets :" -ForegroundColor Red
Write-Host "docker compose -f docker-compose.prod.yml logs u-silenziu > logs.txt" -ForegroundColor Gray
Write-Host ""

Write-Host "DIAGNOSTIC TERMINE !" -ForegroundColor Green
