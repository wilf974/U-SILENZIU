# Script de correction affichage des salles - PowerShell
# U Silenziu - Septembre 2025

Write-Host "🔧 CORRECTION AFFICHAGE DES SALLES" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

# 1. Vérifier l'état actuel
Write-Host "1. Vérification des données actuelles..." -ForegroundColor Yellow
Write-Host "   - homepage_sections:"
$homepage_count = docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "SELECT COUNT(*) FROM homepage_sections;" 2>$null
Write-Host "   Résultat: $homepage_count"

Write-Host "   - rooms:"
$rooms_count = docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "SELECT COUNT(*) FROM rooms;" 2>$null
Write-Host "   Résultat: $rooms_count"

Write-Host ""
Write-Host "2. Insertion des données homepage_sections..." -ForegroundColor Yellow

# Insérer les sections de la page d'accueil
$homepage_sql = @"
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
"@

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c $homepage_sql

Write-Host ""
Write-Host "3. Vérification des salles dans la table rooms..." -ForegroundColor Yellow

# Vérifier et ajouter les salles si nécessaire
$room_count = docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -t -c "SELECT COUNT(*) FROM rooms;" 2>$null | ForEach-Object { $_.Trim() }

if ($room_count -eq "0") {
    Write-Host "   Ajout des salles..."
    $rooms_sql = @"
INSERT INTO rooms (name, description, price, duration, max_people, objects_to_destroy, included, is_active) 
VALUES 
('Salle Douce', 'Pour un défoulement en douceur', 50.00, 60, 4, ARRAY['Assiettes', 'Verres', 'Objets légers'], ARRAY['Équipements de protection', 'Nettoyage'], true),
('Salle Carnage', 'Pour un défoulement intense', 75.00, 60, 6, ARRAY['Électroménager', 'Meubles', 'Gros objets'], ARRAY['Équipements de protection', 'Nettoyage', 'Marteau'], true),
('Salle Privatisée', 'Salle privatisée pour groupes', 120.00, 90, 10, ARRAY['Choix personnalisé'], ARRAY['Équipements de protection', 'Nettoyage', 'Animation'], true)
ON CONFLICT DO NOTHING;
"@
    docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c $rooms_sql
} else {
    Write-Host "   Salles déjà présentes: $room_count"
}

Write-Host ""
Write-Host "4. Vérification finale des données..." -ForegroundColor Yellow
Write-Host "   - homepage_sections:"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "SELECT id, section_type, title FROM homepage_sections ORDER BY order_index;"

Write-Host "   - rooms:"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "SELECT name, description, price FROM rooms WHERE is_active = true;"

Write-Host ""
Write-Host "5. Redémarrage de l'application..." -ForegroundColor Yellow
docker compose -f docker-compose.prod.yml restart u-silenziu

Write-Host ""
Write-Host "6. Attente du démarrage (15 secondes)..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Write-Host ""
Write-Host "7. Test de l'API homepage-sections..." -ForegroundColor Yellow
$homepage_response = Invoke-WebRequest -Uri "https://rageroom.usilenziu.com/api/homepage-sections" -UseBasicParsing
Write-Host "   Code: $($homepage_response.StatusCode)"
Write-Host "   Contenu: $($homepage_response.Content.Substring(0, [Math]::Min(200, $homepage_response.Content.Length)))"

Write-Host ""
Write-Host "8. Test de l'API rooms..." -ForegroundColor Yellow
$rooms_response = Invoke-WebRequest -Uri "https://rageroom.usilenziu.com/api/rooms" -UseBasicParsing
Write-Host "   Code: $($rooms_response.StatusCode)"
Write-Host "   Contenu: $($rooms_response.Content.Substring(0, [Math]::Min(200, $rooms_response.Content.Length)))"

Write-Host ""
Write-Host "✅ CORRECTION TERMINÉE !" -ForegroundColor Green
Write-Host "🌐 Vérifiez maintenant : https://rageroom.usilenziu.com" -ForegroundColor Cyan
Write-Host "   Les salles devraient maintenant s'afficher dans la section 'Nos Salles'" -ForegroundColor White
