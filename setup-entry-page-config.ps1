# Script PowerShell pour configurer la table de configuration de la page d'entree
# Execute le script SQL de creation de la table entry_page_config

Write-Host "=== Configuration de la Page d'Entree U Silenziu ===" -ForegroundColor Green
Write-Host ""

# Configuration de la base de donnees
$dbHost = "localhost"
$dbPort = "5432"
$dbName = "usilenzio"
$dbUser = "usilenzio_user"
$dbPassword = "usilenzio_password_2024"

# Chemin vers le script SQL
$sqlScript = "create-entry-page-config-table.sql"

Write-Host "Configuration de la base de donnees:" -ForegroundColor Cyan
Write-Host "   Host: $dbHost" -ForegroundColor Gray
Write-Host "   Port: $dbPort" -ForegroundColor Gray
Write-Host "   Base: $dbName" -ForegroundColor Gray
Write-Host "   Utilisateur: $dbUser" -ForegroundColor Gray
Write-Host ""

# Verifier si le script SQL existe
if (-not (Test-Path $sqlScript)) {
    Write-Host "Erreur: Le script SQL '$sqlScript' n'existe pas" -ForegroundColor Red
    Write-Host "   Assurez-vous que le fichier est dans le repertoire courant" -ForegroundColor Yellow
    exit 1
}

Write-Host "Script SQL trouve: $sqlScript" -ForegroundColor Green
Write-Host ""

# Verifier si psql est disponible
try {
    $psqlVersion = & psql --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "PostgreSQL client (psql) disponible" -ForegroundColor Green
        Write-Host "   Version: $psqlVersion" -ForegroundColor Gray
    } else {
        throw "psql non trouve"
    }
} catch {
    Write-Host "Erreur: PostgreSQL client (psql) non trouve" -ForegroundColor Red
    Write-Host "   Veuillez installer PostgreSQL ou ajouter psql au PATH" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Solutions alternatives:" -ForegroundColor Cyan
    Write-Host "   1. Installer PostgreSQL: https://www.postgresql.org/download/" -ForegroundColor White
    Write-Host "   2. Utiliser pgAdmin pour executer le script manuellement" -ForegroundColor White
    Write-Host "   3. Copier le contenu de '$sqlScript' dans votre outil de gestion de base de donnees" -ForegroundColor White
    exit 1
}

Write-Host ""

# Construire la commande psql
$psqlCommand = "psql -h $dbHost -p $dbPort -d $dbName -U $dbUser -f $sqlScript"

Write-Host "Execution du script SQL..." -ForegroundColor Cyan
Write-Host "   Commande: $psqlCommand" -ForegroundColor Gray
Write-Host ""

try {
    # Executer le script SQL
    $env:PGPASSWORD = $dbPassword
    & psql -h $dbHost -p $dbPort -d $dbName -U $dbUser -f $sqlScript
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "Script SQL execute avec succes !" -ForegroundColor Green
        Write-Host "   La table 'entry_page_config' a ete creee" -ForegroundColor Green
        Write-Host "   La configuration par defaut a ete inseree" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Erreur lors de l'execution du script SQL" -ForegroundColor Red
        Write-Host "   Code de sortie: $LASTEXITCODE" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host ""
    Write-Host "Erreur lors de l'execution du script SQL:" -ForegroundColor Red
    Write-Host "   $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    # Nettoyer la variable d'environnement
    Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Configuration terminee avec succes !" -ForegroundColor Green
Write-Host ""
Write-Host "=== Prochaines etapes ===" -ForegroundColor Cyan
Write-Host "1. Demarrer l'application: docker-compose up" -ForegroundColor White
Write-Host "2. Acceder a la page d'entree: http://localhost:3000" -ForegroundColor White
Write-Host "3. Configurer la page d'entree: http://localhost:3000/admin/entry-page" -ForegroundColor White
Write-Host "4. Tester le systeme: .\test-page-entree.ps1" -ForegroundColor White
Write-Host ""
Write-Host "=== Fichiers de medias ===" -ForegroundColor Cyan
Write-Host "• Ajoutez vos images dans: public/images/" -ForegroundColor White
Write-Host "• Ajoutez vos videos dans: public/videos/" -ForegroundColor White
Write-Host "• Exemples d'URLs:" -ForegroundColor White
Write-Host "  - Image: /images/entry-bg.jpg" -ForegroundColor Gray
Write-Host "  - Video: /videos/entry-bg.mp4" -ForegroundColor Gray
Write-Host ""