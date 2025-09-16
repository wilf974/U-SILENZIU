# 📝 Installation Automatique de Polices d'Écriture

## 🎯 Objectif
Script PowerShell pour installer automatiquement toutes les polices d'écriture populaires et gratuites disponibles sur votre système Windows.

## 📦 Polices incluses

### 🟢 Google Fonts (10 polices)
- **Roboto** - Police moderne et lisible
- **Open Sans** - Police humaniste optimisée pour l'écran
- **Lato** - Police sans-serif équilibrée
- **Montserrat** - Police géométrique élégante
- **Poppins** - Police géométrique moderne
- **Inter** - Police optimisée pour les interfaces
- **Source Sans Pro** - Police Adobe optimisée pour l'écran
- **Ubuntu** - Police de la distribution Linux Ubuntu
- **Noto Sans** - Police universelle par Google
- **Work Sans** - Police géométrique contemporaine

### 🔵 Adobe Fonts (3 polices)
- **Source Code Pro** - Police monospace pour la programmation
- **Source Serif Pro** - Police serif pour la lecture
- **Source Han Sans** - Police pour les caractères asiatiques

### 🟣 Polices de Programmation (4 polices)
- **Fira Code** - Police monospace avec ligatures
- **JetBrains Mono** - Police optimisée pour les IDE
- **Cascadia Code** - Police Microsoft pour le développement
- **Victor Mono** - Police italique pour la programmation

## 🚀 Installation

### Méthode 1 : Script simplifié (Recommandé)

1. **Téléchargez les fichiers** :
   - `install-fonts-simple.ps1` (script de lancement)
   - `install-fonts.ps1` (script principal)

2. **Ouvrez PowerShell en tant qu'administrateur** :
   - Clic droit sur PowerShell
   - Sélectionnez "Exécuter en tant qu'administrateur"

3. **Naviguez vers le dossier** :
   ```powershell
   cd "C:\chemin\vers\le\dossier"
   ```

4. **Exécutez le script** :
   ```powershell
   .\install-fonts-simple.ps1
   ```

### Méthode 2 : Script principal avec options

```powershell
# Installation de toutes les polices (par défaut)
.\install-fonts.ps1

# Installation uniquement des Google Fonts
.\install-fonts.ps1 -InstallGoogleFonts

# Installation uniquement des Adobe Fonts
.\install-fonts.ps1 -InstallAdobeFonts

# Installation uniquement des polices de programmation
.\install-fonts.ps1 -InstallCustomFonts

# Installation sans confirmation
.\install-fonts.ps1 -SkipConfirmation
```

## ⚠️ Prérequis

- **Windows 10/11** (testé sur Windows 10)
- **PowerShell 5.1 ou supérieur**
- **Privilèges administrateur**
- **Connexion internet** (pour télécharger les polices)

## 🔧 Fonctionnalités

### ✅ Sécurité
- Vérification automatique des privilèges administrateur
- Téléchargement depuis des sources fiables (GitHub officiels)
- Validation des fichiers téléchargés

### ✅ Interface utilisateur
- Affichage coloré avec progression
- Messages d'information détaillés
- Gestion des erreurs robuste

### ✅ Installation automatique
- Téléchargement automatique depuis les sources officielles
- Installation dans le dossier système des polices
- Enregistrement dans le registre Windows
- Nettoyage automatique des fichiers temporaires

### ✅ Gestion d'erreurs
- Gestion des échecs de téléchargement
- Gestion des erreurs d'installation
- Messages d'erreur explicites
- Nettoyage en cas d'échec

## 📊 Statistiques

- **Total** : 17 polices installées
- **Temps estimé** : 5-10 minutes
- **Taille totale** : ~50 MB
- **Sources** : Google Fonts, Adobe Fonts, GitHub officiels

## 🔍 Vérification de l'installation

### Méthode 1 : Explorateur Windows
1. Ouvrez l'Explorateur Windows
2. Naviguez vers `C:\Windows\Fonts`
3. Recherchez les nouvelles polices

### Méthode 2 : PowerShell
```powershell
# Lister les polices installées
Get-ChildItem "C:\Windows\Fonts" | Where-Object {$_.Name -like "*Roboto*" -or $_.Name -like "*Open Sans*" -or $_.Name -like "*Fira Code*"}
```

### Méthode 3 : Applications
1. Ouvrez Word, Photoshop, ou toute autre application
2. Allez dans les paramètres de police
3. Vérifiez que les nouvelles polices sont disponibles

## 🛠️ Dépannage

### Problème : "Privilèges administrateur requis"
**Solution** : Exécutez PowerShell en tant qu'administrateur

### Problème : "Échec du téléchargement"
**Solutions** :
- Vérifiez votre connexion internet
- Désactivez temporairement l'antivirus
- Relancez le script

### Problème : "Polices non visibles"
**Solutions** :
- Redémarrez vos applications
- Redémarrez l'explorateur Windows : `taskkill /f /im explorer.exe && start explorer.exe`
- Redémarrez le système si nécessaire

### Problème : "Erreur de registre"
**Solution** : Le script gère automatiquement les erreurs de registre

## 📝 Logs et débogage

Le script génère des logs détaillés dans la console :
- ✅ Succès (vert)
- ⚠️ Avertissements (jaune)
- ❌ Erreurs (rouge)
- ℹ️ Informations (cyan)

## 🔄 Désinstallation

Pour désinstaller une police :
1. Ouvrez `C:\Windows\Fonts`
2. Clic droit sur la police
3. Sélectionnez "Supprimer"

## 📞 Support

En cas de problème :
1. Vérifiez les prérequis
2. Consultez la section dépannage
3. Relancez le script avec les mêmes paramètres

## 📄 Licence

Ce script est fourni "tel quel" sans garantie. Utilisez à vos propres risques.

## 🎯 Utilisation dans U Silenziu

Ces polices peuvent être utilisées dans le projet U Silenziu pour :
- Améliorer la typographie du site web
- Créer des designs plus professionnels
- Optimiser la lisibilité sur différents appareils

---

**🎉 Profitez de vos nouvelles polices d'écriture !**
