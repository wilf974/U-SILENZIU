# Configuration simple de la page d'entree pour U Silenziu

Write-Host "Configuration de la page d'entree U Silenziu" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

# Test de connexion
Write-Host "Test de connexion a la base de donnees..." -ForegroundColor Yellow
$connectionTest = docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "SELECT 1;" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur: Impossible de se connecter a la base de donnees" -ForegroundColor Red
    exit 1
}

Write-Host "Connexion reussie" -ForegroundColor Green

# Creer la table
Write-Host "`nCreation de la table entry_page_config..." -ForegroundColor Yellow

$sql = "
DROP TABLE IF EXISTS entry_page_config CASCADE;

CREATE TABLE IF NOT EXISTS entry_page_config (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL DEFAULT 'U SILENZIU',
    subtitle VARCHAR(255) NOT NULL DEFAULT 'Zone de defoulement',
    description TEXT NOT NULL DEFAULT 'Liberez votre stress dans nos salles securisees',
    button_text VARCHAR(100) NOT NULL DEFAULT 'ENTRER DANS LE SITE',
    background_type VARCHAR(10) NOT NULL DEFAULT 'image' CHECK (background_type IN ('image', 'video')),
    background_image_url TEXT,
    background_video_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO entry_page_config (
    title,
    subtitle,
    description,
    button_text,
    background_type,
    background_image_url,
    is_active
) VALUES (
    'U SILENZIU',
    'Zone de defoulement',
    'Liberez votre stress dans nos salles securisees',
    'ENTRER DANS LE SITE',
    'image',
    '/images/entry/entry-bg.jpg',
    true
) ON CONFLICT DO NOTHING;

SELECT * FROM entry_page_config;
"

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c $sql

if ($LASTEXITCODE -eq 0) {
    Write-Host "Configuration terminee avec succes !" -ForegroundColor Green
    Write-Host ""
    Write-Host "URLs disponibles :" -ForegroundColor White
    Write-Host "  Page d'entree : http://localhost:3000/entry" -ForegroundColor Gray
    Write-Host "  Administration : http://localhost:3000/admin/entry-page" -ForegroundColor Gray
    Write-Host "  API : http://localhost:3000/api/entry-page-config" -ForegroundColor Gray
} else {
    Write-Host "Erreur lors de la configuration" -ForegroundColor Red
    exit 1
}

Write-Host ""
Read-Host "Appuyez sur Entree pour continuer..."
