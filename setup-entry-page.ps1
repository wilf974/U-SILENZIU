# Script de configuration de la page d'entrée pour U Silenziu
# Ce script configure la table entry_page_config et insert les données par défaut

Write-Host "🎭 Configuration de la page d'entrée U Silenziu" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""

# Vérifier si Docker est en cours d'exécution
Write-Host "🔍 Vérification de l'état de Docker..." -ForegroundColor Yellow
if (-not (Get-Process "Docker Desktop" -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker Desktop n'est pas en cours d'exécution" -ForegroundColor Red
    Write-Host "💡 Veuillez démarrer Docker Desktop et relancer ce script" -ForegroundColor Yellow
    Read-Host "Appuyez sur Entrée pour continuer..."
    exit 1
}

# Vérifier si le conteneur PostgreSQL est en cours d'exécution
Write-Host "📊 Vérification du conteneur PostgreSQL..." -ForegroundColor Yellow
$postgresRunning = docker ps --filter "name=u-silenziu-postgres" --format "{{.Names}}" 2>$null
if (-not $postgresRunning) {
    Write-Host "❌ Le conteneur PostgreSQL n'est pas en cours d'exécution" -ForegroundColor Red
    Write-Host "💡 Démarrez les conteneurs avec: docker-compose up -d" -ForegroundColor Yellow
    Read-Host "Appuyez sur Entrée pour continuer..."
    exit 1
}

Write-Host "✅ Conteneur PostgreSQL détecté: $postgresRunning" -ForegroundColor Green

# Test de connexion à la base de données
Write-Host "`n🔗 Test de connexion à la base de données..." -ForegroundColor Yellow
$connectionTest = docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "SELECT 1;" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur: Impossible de se connecter a la base de donnees" -ForegroundColor Red
    Write-Host "💡 Vérifiez que les conteneurs sont correctement démarrés" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Connexion à la base de données réussie" -ForegroundColor Green

# Créer la table entry_page_config
Write-Host "`n🏗️ Configuration de la table entry_page_config..." -ForegroundColor Yellow

$createTableSQL = @"
-- Supprimer l'ancienne table si elle existe
DROP TABLE IF EXISTS entry_page_config CASCADE;

-- Créer la nouvelle table avec la structure appropriée
CREATE TABLE IF NOT EXISTS entry_page_config (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL DEFAULT 'U SILENZIU',
    subtitle VARCHAR(255) NOT NULL DEFAULT 'Zone de défoulement',
    description TEXT NOT NULL DEFAULT 'Libérez votre stress dans nos salles sécurisées',
    button_text VARCHAR(100) NOT NULL DEFAULT 'ENTRER DANS LE SITE',
    background_type VARCHAR(10) NOT NULL DEFAULT 'image' CHECK (background_type IN ('image', 'video')),
    background_image_url TEXT,
    background_video_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Créer un trigger pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_entry_page_config_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
"@

CREATE TRIGGER trigger_update_entry_page_config_updated_at
    BEFORE UPDATE ON entry_page_config
    FOR EACH ROW
    EXECUTE FUNCTION update_entry_page_config_updated_at();
'@

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c $createTableSQL

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Table entry_page_config créée avec succès" -ForegroundColor Green
} else {
    Write-Host "Erreur lors de la creation de la table" -ForegroundColor Red
    exit 1
}

# Insérer la configuration par défaut
Write-Host "`n📋 Insertion de la configuration par défaut..." -ForegroundColor Yellow

$insertDataSQL = @"
-- Insérer la configuration par défaut
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
    'Zone de défoulement',
    'Libérez votre stress dans nos salles sécurisées',
    'ENTRER DANS LE SITE',
    'image',
    '/images/entry/entry-bg.jpg',
    true
) ON CONFLICT DO NOTHING;
"@

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c $insertDataSQL

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Configuration par défaut insérée" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors de l'insertion des données" -ForegroundColor Red
    exit 1
}

# Vérifier les données insérées
Write-Host "`n🔍 Vérification des données..." -ForegroundColor Yellow
$verifySQL = "SELECT id, title, subtitle, background_type, is_active FROM entry_page_config;"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c $verifySQL

Write-Host "`n🎯 Configuration terminée avec succès !" -ForegroundColor Green
Write-Host "📝 Résumé des actions effectuées :" -ForegroundColor White
Write-Host "   • Table entry_page_config créée" -ForegroundColor Gray
Write-Host "   • Trigger de mise à jour automatique configuré" -ForegroundColor Gray  
Write-Host "   • Configuration par défaut insérée" -ForegroundColor Gray
Write-Host ""
Write-Host "🌐 URLs disponibles :" -ForegroundColor White
Write-Host "   • Page d'administration : http://localhost:3000/admin/entry-page" -ForegroundColor Gray
Write-Host "   • Page d'entrée : http://localhost:3000/entry" -ForegroundColor Gray
Write-Host "   • API configuration : http://localhost:3000/api/entry-page-config" -ForegroundColor Gray
Write-Host ""
Write-Host "✨ La page d'entrée est maintenant configurée et prête à être utilisée !" -ForegroundColor Green

Read-Host "`nAppuyez sur Entree pour continuer..."
