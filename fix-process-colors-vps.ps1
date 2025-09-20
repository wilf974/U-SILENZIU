# Script pour corriger les couleurs bleues dans la section process sur le VPS
# U Silenziu - Septembre 2025

Write-Host "🔧 Correction des couleurs bleues dans la section process..." -ForegroundColor Yellow

# Commande SQL à exécuter
$sqlCommand = @"
UPDATE homepage_sections 
SET content = REPLACE(
  REPLACE(
    REPLACE(
      REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(
              REPLACE(
                REPLACE(
                  REPLACE(
                    content,
                    'from-blue-400 to-blue-600', 'from-kaki-400 to-kaki-600'
                  ),
                  'from-blue-500 to-blue-700', 'from-kaki-500 to-blue-700'
                ),
                'from-blue-600 to-blue-800', 'from-kaki-600 to-kaki-800'
              ),
              'from-blue-700 to-blue-900', 'from-kaki-700 to-kaki-900'
            ),
            'bg-blue-600', 'bg-kaki-600'
          ),
          'bg-blue-500', 'bg-kaki-500'
        ),
        'text-blue-400', 'text-kaki-400'
      ),
      'text-blue-500', 'text-kaki-500'
    ),
    'hover:bg-blue-700', 'hover:bg-kaki-700'
  ),
  'hover:bg-blue-600', 'hover:bg-kaki-600'
)
WHERE section_key = 'process' 
AND content LIKE '%blue%';
"@

Write-Host "📝 Exécution de la correction SQL..." -ForegroundColor Cyan

# Exécuter la commande SQL
$result = docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c $sqlCommand

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Correction SQL exécutée avec succès !" -ForegroundColor Green
    
    # Vérifier les résultats
    Write-Host "🔍 Vérification des résultats..." -ForegroundColor Cyan
    docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "SELECT id, section_key, LEFT(content, 200) as content_preview FROM homepage_sections WHERE section_key = 'process';"
    
    Write-Host "🎉 Correction terminée ! Les couleurs bleues ont été remplacées par kaki." -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors de l'exécution de la correction SQL" -ForegroundColor Red
    Write-Host $result -ForegroundColor Red
}

Write-Host "`n📋 Commandes à exécuter sur le VPS :" -ForegroundColor Yellow
Write-Host "1. cd ~/U-SILENZIU" -ForegroundColor White
Write-Host "2. docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -f fix-process-colors.sql" -ForegroundColor White
Write-Host "3. docker compose -f docker-compose.prod.yml restart u-silenziu" -ForegroundColor White
