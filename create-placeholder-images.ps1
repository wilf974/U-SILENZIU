# Script pour créer des images placeholder

Write-Host "Création des images placeholder manquantes..." -ForegroundColor Yellow

# Créer les répertoires nécessaires
$imageDir = "public\images"
if (-not (Test-Path $imageDir)) {
    New-Item -ItemType Directory -Path $imageDir -Force
}

# Copier l'image existante entry-bg.jpg comme placeholder pour hero-poster.jpg
$entryImage = "public\images\entry\entry-bg.jpg"
$heroPosterImage = "public\images\hero-poster.jpg"

if (Test-Path $entryImage) {
    Copy-Item $entryImage $heroPosterImage -Force
    Write-Host "✅ Créé hero-poster.jpg depuis entry-bg.jpg" -ForegroundColor Green
} else {
    Write-Host "❌ Image source entry-bg.jpg non trouvée" -ForegroundColor Red
}

# Copier une image de salle comme placeholder pour hero-zone.jpg
$salleImage = "public\images\salle-douce.jpg"
$heroZoneImage = "public\images\hero-zone.jpg"

if (Test-Path $salleImage) {
    Copy-Item $salleImage $heroZoneImage -Force
    Write-Host "✅ Créé hero-zone.jpg depuis salle-douce.jpg" -ForegroundColor Green
} else {
    Write-Host "❌ Image source salle-douce.jpg non trouvée" -ForegroundColor Red
}

Write-Host ""
Write-Host "Images placeholder créées avec succès !" -ForegroundColor Green
