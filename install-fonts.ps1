# Script d'installation automatique de polices d'écriture
# U Silenziu - Installation de toutes les polices disponibles
# Exécuter en tant qu'administrateur

param(
    [switch]$SkipConfirmation,
    [switch]$InstallGoogleFonts,
    [switch]$InstallAdobeFonts,
    [switch]$InstallCustomFonts
)

# Configuration
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Couleurs pour l'affichage
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Success { Write-ColorOutput Green $args }
function Write-Error { Write-ColorOutput Red $args }
function Write-Warning { Write-ColorOutput Yellow $args }
function Write-Info { Write-ColorOutput Cyan $args }

# Vérification des privilèges administrateur
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Création des dossiers temporaires
function Initialize-Directories {
    Write-Info "Création des dossiers temporaires..."
    
    $tempDir = "$env:TEMP\FontInstallation"
    $googleFontsDir = "$tempDir\GoogleFonts"
    $adobeFontsDir = "$tempDir\AdobeFonts"
    $customFontsDir = "$tempDir\CustomFonts"
    
    @($tempDir, $googleFontsDir, $adobeFontsDir, $customFontsDir) | ForEach-Object {
        if (!(Test-Path $_)) {
            New-Item -ItemType Directory -Path $_ -Force | Out-Null
        }
    }
    
    return @{
        Temp = $tempDir
        GoogleFonts = $googleFontsDir
        AdobeFonts = $adobeFontsDir
        CustomFonts = $customFontsDir
    }
}

# Téléchargement de fichiers
function Download-File {
    param($Url, $Destination)
    
    try {
        Write-Info "Téléchargement de $Url..."
        Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing
        return $true
    }
    catch {
        Write-Warning "Échec du téléchargement de $Url : $($_.Exception.Message)"
        return $false
    }
}

# Installation d'une police
function Install-Font {
    param($FontPath)
    
    try {
        $fontName = [System.IO.Path]::GetFileNameWithoutExtension($FontPath)
        Write-Info "Installation de $fontName..."
        
        # Copie vers le dossier des polices Windows
        $windowsFontsPath = "$env:SystemRoot\Fonts"
        $fontFileName = [System.IO.Path]::GetFileName($FontPath)
        $destinationPath = Join-Path $windowsFontsPath $fontFileName
        
        Copy-Item -Path $FontPath -Destination $destinationPath -Force
        
        # Enregistrement dans le registre Windows
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
        $regValue = $fontFileName
        $regData = $fontFileName
        
        if (!(Get-ItemProperty -Path $regPath -Name $regValue -ErrorAction SilentlyContinue)) {
            New-ItemProperty -Path $regPath -Name $regValue -Value $regData -PropertyType String -Force | Out-Null
        }
        
        Write-Success "✓ $fontName installée avec succès"
        return $true
    }
    catch {
        Write-Warning "Échec de l'installation de $fontName : $($_.Exception.Message)"
        return $false
    }
}

# Installation des polices Google Fonts
function Install-GoogleFonts {
    param($FontsDir)
    
    Write-Info "=== Installation des polices Google Fonts ==="
    
    # Liste des polices Google Fonts populaires
    $googleFonts = @(
        @{Name="Roboto"; Url="https://github.com/google/fonts/raw/main/apache/roboto/Roboto-Regular.ttf"},
        @{Name="Open Sans"; Url="https://github.com/google/fonts/raw/main/apache/opensans/OpenSans-Regular.ttf"},
        @{Name="Lato"; Url="https://github.com/google/fonts/raw/main/ofl/lato/Lato-Regular.ttf"},
        @{Name="Montserrat"; Url="https://github.com/google/fonts/raw/main/ofl/montserrat/Montserrat-Regular.ttf"},
        @{Name="Poppins"; Url="https://github.com/google/fonts/raw/main/ofl/poppins/Poppins-Regular.ttf"},
        @{Name="Inter"; Url="https://github.com/google/fonts/raw/main/ofl/inter/Inter-Regular.ttf"},
        @{Name="Source Sans Pro"; Url="https://github.com/google/fonts/raw/main/ofl/sourcesanspro/SourceSansPro-Regular.ttf"},
        @{Name="Ubuntu"; Url="https://github.com/google/fonts/raw/main/ufl/ubuntu/Ubuntu-Regular.ttf"},
        @{Name="Noto Sans"; Url="https://github.com/google/fonts/raw/main/ofl/notosans/NotoSans-Regular.ttf"},
        @{Name="Work Sans"; Url="https://github.com/google/fonts/raw/main/ofl/worksans/WorkSans-Regular.ttf"}
    )
    
    $installedCount = 0
    foreach ($font in $googleFonts) {
        $fontPath = Join-Path $FontsDir "$($font.Name).ttf"
        
        if (Download-File -Url $font.Url -Destination $fontPath) {
            if (Install-Font -FontPath $fontPath) {
                $installedCount++
            }
        }
        
        Start-Sleep -Milliseconds 500  # Pause pour éviter la surcharge
    }
    
    Write-Success "Installation terminée : $installedCount polices Google Fonts installées"
}

# Installation des polices Adobe Fonts (gratuites)
function Install-AdobeFonts {
    param($FontsDir)
    
    Write-Info "=== Installation des polices Adobe Fonts gratuites ==="
    
    # Polices Adobe gratuites
    $adobeFonts = @(
        @{Name="Source Code Pro"; Url="https://github.com/adobe-fonts/source-code-pro/raw/release/TTF/SourceCodePro-Regular.ttf"},
        @{Name="Source Serif Pro"; Url="https://github.com/adobe-fonts/source-serif-pro/raw/release/TTF/SourceSerifPro-Regular.ttf"},
        @{Name="Source Han Sans"; Url="https://github.com/adobe-fonts/source-han-sans/raw/release/OTF/SimplifiedChinese/SourceHanSansSC-Regular.otf"}
    )
    
    $installedCount = 0
    foreach ($font in $adobeFonts) {
        $fontPath = Join-Path $FontsDir "$($font.Name).ttf"
        
        if (Download-File -Url $font.Url -Destination $fontPath) {
            if (Install-Font -FontPath $fontPath) {
                $installedCount++
            }
        }
        
        Start-Sleep -Milliseconds 500
    }
    
    Write-Success "Installation terminée : $installedCount polices Adobe Fonts installées"
}

# Installation de polices personnalisées
function Install-CustomFonts {
    param($FontsDir)
    
    Write-Info "=== Installation de polices personnalisées ==="
    
    # Polices populaires depuis des sources fiables
    $customFonts = @(
        @{Name="Fira Code"; Url="https://github.com/tonsky/FiraCode/raw/master/distr/ttf/FiraCode-Regular.ttf"},
        @{Name="JetBrains Mono"; Url="https://github.com/JetBrains/JetBrainsMono/raw/master/fonts/ttf/JetBrainsMono-Regular.ttf"},
        @{Name="Cascadia Code"; Url="https://github.com/microsoft/cascadia-code/raw/main/ttf/CascadiaCode-Regular.ttf"},
        @{Name="Victor Mono"; Url="https://github.com/rubjo/victor-mono/raw/master/fonts/VictorMono-Regular.ttf"}
    )
    
    $installedCount = 0
    foreach ($font in $customFonts) {
        $fontPath = Join-Path $FontsDir "$($font.Name).ttf"
        
        if (Download-File -Url $font.Url -Destination $fontPath) {
            if (Install-Font -FontPath $fontPath) {
                $installedCount++
            }
        }
        
        Start-Sleep -Milliseconds 500
    }
    
    Write-Success "Installation terminée : $installedCount polices personnalisées installées"
}

# Nettoyage des fichiers temporaires
function Cleanup-TempFiles {
    param($TempDir)
    
    Write-Info "Nettoyage des fichiers temporaires..."
    try {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Success "Fichiers temporaires supprimés"
    }
    catch {
        Write-Warning "Impossible de supprimer les fichiers temporaires : $($_.Exception.Message)"
    }
}

# Fonction principale
function Main {
    Write-Info "=== Script d'installation de polices d'écriture ==="
    Write-Info "U Silenziu - Installation automatique de toutes les polices disponibles"
    Write-Info ""
    
    # Vérification des privilèges administrateur
    if (!(Test-Administrator)) {
        Write-Error "Ce script nécessite des privilèges administrateur."
        Write-Info "Veuillez exécuter PowerShell en tant qu'administrateur et relancer le script."
        exit 1
    }
    
    # Confirmation utilisateur
    if (!$SkipConfirmation) {
        Write-Warning "Ce script va installer plusieurs polices d'écriture sur votre système."
        Write-Info "Cela peut prendre plusieurs minutes selon votre connexion internet."
        Write-Info ""
        
        $confirmation = Read-Host "Voulez-vous continuer ? (O/N)"
        if ($confirmation -notmatch "^[OoYy]") {
            Write-Info "Installation annulée."
            exit 0
        }
    }
    
    # Initialisation
    $directories = Initialize-Directories
    
    $totalInstalled = 0
    
    try {
        # Installation des polices selon les paramètres
        if ($InstallGoogleFonts -or (!$InstallGoogleFonts -and !$InstallAdobeFonts -and !$InstallCustomFonts)) {
            Install-GoogleFonts -FontsDir $directories.GoogleFonts
            $totalInstalled += 10
        }
        
        if ($InstallAdobeFonts -or (!$InstallGoogleFonts -and !$InstallAdobeFonts -and !$InstallCustomFonts)) {
            Install-AdobeFonts -FontsDir $directories.AdobeFonts
            $totalInstalled += 3
        }
        
        if ($InstallCustomFonts -or (!$InstallGoogleFonts -and !$InstallAdobeFonts -and !$InstallCustomFonts)) {
            Install-CustomFonts -FontsDir $directories.CustomFonts
            $totalInstalled += 4
        }
        
        # Nettoyage
        Cleanup-TempFiles -TempDir $directories.Temp
        
        # Résumé final
        Write-Info ""
        Write-Success "=== Installation terminée avec succès ! ==="
        Write-Info "Nombre total de polices installées : $totalInstalled"
        Write-Info "Les polices sont maintenant disponibles dans toutes vos applications."
        Write-Info "Redémarrez vos applications pour voir les nouvelles polices."
        
    }
    catch {
        Write-Error "Une erreur s'est produite : $($_.Exception.Message)"
        Cleanup-TempFiles -TempDir $directories.Temp
        exit 1
    }
}

# Exécution du script
Main
