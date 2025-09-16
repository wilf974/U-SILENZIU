# Script PowerShell pour créer la table footer_config
Write-Host "🔧 Création de la table footer_config..." -ForegroundColor Cyan

# Lire le contenu du fichier SQL
$sqlContent = Get-Content -Path "create-footer-config-table.sql" -Raw

# Exécuter le script SQL via Docker
Write-Host "📡 Exécution du script SQL..." -ForegroundColor Yellow
$result = docker exec u-silenziu-postgres psql -U postgres -d usilenziu -c $sqlContent

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Table footer_config créée avec succès !" -ForegroundColor Green
    Write-Host "📊 Résultat:" -ForegroundColor Gray
    Write-Host $result -ForegroundColor Gray
} else {
    Write-Host "❌ Erreur lors de la création de la table" -ForegroundColor Red
    Write-Host "Code de sortie: $LASTEXITCODE" -ForegroundColor Red
}

Write-Host "`n🧪 Test de l'API footer-config..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/footer-config" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ API footer-config fonctionne correctement !" -ForegroundColor Green
        $data = $response.Content | ConvertFrom-Json
        Write-Host "📋 Configuration chargée:" -ForegroundColor Gray
        Write-Host "   - Nom du site: $($data.data.site_name)" -ForegroundColor Gray
        Write-Host "   - Email: $($data.data.contact_email)" -ForegroundColor Gray
        Write-Host "   - Téléphone: $($data.data.contact_phone)" -ForegroundColor Gray
    } else {
        Write-Host "❌ Erreur API: Code $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors du test de l'API: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n✨ Script terminé !" -ForegroundColor Cyan
