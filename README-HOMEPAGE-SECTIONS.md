# 🏠 Système de Gestion des Sections de la Page d'Accueil

## 📋 Vue d'ensemble

Ce système permet de rendre modifiables via le back-office toutes les sections de la page d'accueil d'U Silenziu, tout en conservant la structure one page existante.

## ✨ Fonctionnalités

### 🎯 Gestion du contenu
- **Titres et sous-titres** : Modifiables pour chaque section
- **Contenu JSON** : Données structurées (features, CTA, etc.)
- **Médias** : URLs d'images et vidéos personnalisables
- **Couleurs** : Classes CSS personnalisées pour le style

### 🔧 Administration
- **Interface dédiée** : `/admin/homepage`
- **Statistiques** : Nombre total, sections actives/inactives
- **Activation/désactivation** : Contrôle de la visibilité des sections
- **Éditeur complet** : Formulaire intuitif pour chaque section

### 📱 Sections disponibles
1. **Hero** : Titre principal, sous-titre, features, boutons CTA
2. **Concept** : Description, features, informations supplémentaires
3. **Salles** : Liste des salles avec prix et descriptions
4. **Process** : Étapes du processus de réservation
5. **FAQ** : Questions et réponses fréquentes
6. **Contact** : Informations de contact et formulaire

## 🚀 Installation et configuration

### 1. Prérequis
- Docker et Docker Compose en cours d'exécution
- Application Next.js accessible sur `http://localhost:3000`

### 2. Configuration de la base de données
```bash
# Exécuter le script de configuration
.\setup-database-homepage.ps1

# Ou exécuter manuellement le SQL
psql -d votre_base -f create-homepage-sections-table.sql
```

### 3. Test du système
```bash
# Lancer les tests complets
.\test-homepage-sections.ps1

# Ou tester la configuration
.\setup-homepage-sections.ps1
```

## 📖 Utilisation

### Interface d'administration
1. **Accéder à l'interface** : `http://localhost:3000/admin/homepage`
2. **Voir les sections** : Liste de toutes les sections avec leur statut
3. **Modifier une section** : Cliquer sur le bouton "Modifier" (icône crayon)
4. **Éditer le contenu** : Formulaire complet avec tous les champs
5. **Sauvegarder** : Cliquer sur "Sauvegarder" pour appliquer les changements

### Modification du contenu

#### Titre et sous-titre
- **Titre** : Texte principal de la section
- **Sous-titre** : Description détaillée

#### Contenu JSON
Format structuré pour les données dynamiques :

**Section Hero :**
```json
{
  "features": [
    {
      "icon": "Shield",
      "title": "100% Sécurisé",
      "description": "Équipement complet fourni"
    }
  ],
  "cta_primary": "Réserver maintenant",
  "cta_secondary": "Découvrir nos salles"
}
```

**Section Concept :**
```json
{
  "features": [
    {
      "icon": "Target",
      "title": "Environnement Sécurisé",
      "description": "Un espace contrôlé..."
    }
  ],
  "additional_info": {
    "title": "C'est quoi une salle de défoulement ?",
    "content": "Une salle de défoulement..."
  }
}
```

#### Médias et couleurs
- **URL de l'image** : Chemin vers l'image de la section
- **URL de la vidéo** : Chemin vers la vidéo de la section
- **Couleur de fond** : Classe CSS (ex: `bg-dark-surface`)
- **Couleur du texte** : Classe CSS (ex: `text-white`)

### Activation/désactivation
- **Bouton œil** : Activer/désactiver une section
- **Sections inactives** : Ne s'affichent pas sur la page d'accueil
- **Statut visible** : Indicateur de couleur (vert = actif, jaune = inactif)

## 🔧 Architecture technique

### Base de données
- **Table** : `homepage_sections`
- **Champs** : `id`, `section_key`, `title`, `subtitle`, `content`, `image_url`, `video_url`, `background_color`, `text_color`, `order_index`, `is_active`, `created_at`, `updated_at`

### API Routes
- **Admin** : `/api/admin/homepage-sections` (CRUD complet)
- **Public** : `/api/homepage-sections` (lecture seule des sections actives)

### Composants
- **Hook personnalisé** : `useHomepageSections` pour récupérer les données
- **Composants modifiés** : `Hero.tsx`, `Concept.tsx` utilisent les données dynamiques
- **Fallback** : Données par défaut si les sections ne sont pas trouvées

## 🧪 Tests

### Scripts de test disponibles
1. **`test-homepage-sections.ps1`** : Tests complets du système
2. **`setup-homepage-sections.ps1`** : Configuration et validation
3. **`setup-database-homepage.ps1`** : Configuration de la base de données

### Tests effectués
- ✅ Accessibilité de l'interface d'administration
- ✅ Fonctionnement des API routes
- ✅ Modification du contenu des sections
- ✅ Activation/désactivation des sections
- ✅ Performance des API
- ✅ Affichage de la page d'accueil

## 🐛 Dépannage

### Erreurs courantes

#### "API des sections non accessible"
- Vérifier que la table `homepage_sections` existe dans PostgreSQL
- Exécuter le script SQL de création
- Vérifier que l'application est démarrée

#### "Composant ne s'affiche pas"
- Vérifier que la section est active (`is_active = true`)
- Vérifier que le contenu JSON est valide
- Regarder la console du navigateur pour les erreurs

#### "Erreur de compilation TypeScript"
- Vérifier que tous les composants utilisant des hooks ont `'use client'`
- Redémarrer l'application avec `docker compose up -d --build`

### Logs utiles
- **Console du navigateur** : Erreurs JavaScript et requêtes API
- **Logs Docker** : `docker compose logs -f app`
- **Base de données** : Vérifier les tables et données

## 📚 Ressources

### Fichiers importants
- **`create-homepage-sections-table.sql`** : Script de création de la base
- **`lib/hooks/useHomepageSections.ts`** : Hook personnalisé
- **`app/admin/homepage/page.tsx`** : Interface d'administration
- **`components/Hero.tsx`** et **`components/Concept.tsx`** : Composants modifiés

### URLs utiles
- **Interface d'administration** : `http://localhost:3000/admin/homepage`
- **API des sections** : `http://localhost:3000/api/homepage-sections`
- **Page d'accueil** : `http://localhost:3000/`

## 🎯 Prochaines étapes

### Améliorations possibles
1. **Système de versions** : Historique des modifications
2. **Prévisualisation en temps réel** : Voir les changements avant sauvegarde
3. **Templates avancés** : Plus de variétés de mise en page
4. **Gestion des médias** : Upload direct d'images et vidéos
5. **Cache et performance** : Optimisation des requêtes API

### Intégration avec d'autres modules
- **Gestion des pages** : Système de pages dynamiques existant
- **Gestion des salles** : Intégration avec le module des salles
- **Réservations** : Lien avec le système de réservation

## 📞 Support

Pour toute question ou problème :
1. Vérifier les logs et la console du navigateur
2. Consulter ce README et la documentation
3. Exécuter les scripts de test pour diagnostiquer
4. Vérifier la configuration de la base de données

---

**U Silenziu** - Système de gestion des sections de la page d'accueil  
*Développé avec Next.js 14, PostgreSQL et TypeScript*
