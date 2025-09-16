# Script de lancement simplifié pour l'installation de polices
# U Silenziu - Installation automatique de toutes les polices

Write-Host "=== Installation automatique de polices d'écriture ===" -ForegroundColor Cyan
Write-Host "U Silenziu - Toutes les polices disponibles" -ForegroundColor Cyan
Write-Host ""

# Vérification des privilèges administrateur
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)

if (!$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ Ce script nécessite des privilèges administrateur." -ForegroundColor Red
    Write-Host "💡 Veuillez faire un clic droit sur PowerShell et sélectionner 'Exécuter en tant qu'administrateur'" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Appuyez sur Entrée pour fermer"
    exit 1
}

Write-Host "✅ Privilèges administrateur vérifiés" -ForegroundColor Green
Write-Host ""

# Confirmation utilisateur
Write-Host "Ce script va installer les polices suivantes :" -ForegroundColor Yellow
Write-Host "• 10 polices Google Fonts (Roboto, Open Sans, Lato, etc.)" -ForegroundColor White
Write-Host "• 3 polices Adobe Fonts (Source Code Pro, Source Serif Pro, etc.)" -ForegroundColor White
Write-Host "• 4 polices de programmation (Fira Code, JetBrains Mono, etc.)" -ForegroundColor White
Write-Host ""

$confirmation = Read-Host "Voulez-vous continuer ? (O/N)"
if ($confirmation -notmatch "^[OoYy]") {
    Write-Host "Installation annulée." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "🚀 Démarrage de l'installation..." -ForegroundColor Green
Write-Host "⏱️  Cela peut prendre 5-10 minutes selon votre connexion internet." -ForegroundColor Cyan
Write-Host ""

# Exécution du script principal
try {
    & "$PSScriptRoot\install-fonts.ps1" -SkipConfirmation
    Write-Host ""
    Write-Host "🎉 Installation terminée avec succès !" -ForegroundColor Green
    Write-Host "📝 Redémarrez vos applications pour voir les nouvelles polices." -ForegroundColor Cyan
}
catch {
    Write-Host ""
    Write-Host "❌ Une erreur s'est produite : $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Vérifiez votre connexion internet et relancez le script." -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Appuyez sur Entrée pour fermer"
