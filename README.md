# U Silenziu - Zone de Défoulement

Site web pour U Silenziu, votre zone de défoulement à Buros. Libérez votre stress et vos tensions dans un environnement sécurisé et amusant.

## 🎯 Fonctionnalités

- **Site moderne et responsive** construit avec Next.js 14 et Tailwind CSS
- **Thème sombre** avec couleurs vert kaki personnalisées
- **Sections complètes** : Hero, Concept, Activités, Formules, FAQ, Contact
- **Interface intuitive** avec navigation fluide
- **Formulaire de contact** pour les réservations
- **Full Docker** pour un déploiement facile

## 🎨 Design

- **Couleurs principales** :
  - Vert kaki pour les boutons et encadrements
  - Noir (#0a0a0a) pour le fond
  - Blanc pour le texte
  - Dégradés subtils pour les accents

## 🚀 Installation et Démarrage

### Avec Docker (Recommandé)

```bash
# Cloner le projet
git clone <repository-url>
cd u-silenziu

# Construire et démarrer avec Docker Compose
docker-compose up --build -d

# L'application sera disponible sur http://localhost:3000
```

### Développement local

```bash
# Installer les dépendances
npm install

# Démarrer le serveur de développement
npm run dev

# Construire pour la production
npm run build

# Démarrer en mode production
npm start
```

## 🐳 Docker

L'application est entièrement containerisée avec :

- **Dockerfile multi-stage** pour optimiser la taille de l'image
- **Docker Compose** pour orchestrer les services
- **Healthcheck** pour surveiller l'état de l'application
- **Utilisateur non-root** pour la sécurité

### Commandes Docker utiles

```bash
# Construire l'image
docker build -t u-silenziu .

# Démarrer les services
docker-compose up -d

# Voir les logs
docker-compose logs -f

# Arrêter les services
docker-compose down

# Reconstruire et redémarrer
docker-compose up --build -d
```

## 📱 Sections du Site

1. **Header** - Navigation avec informations de contact
2. **Hero** - Section d'accueil avec CTA
3. **Concept** - Explication du concept de défoulement
4. **Activités** - Présentation des 6 activités proposées
5. **Formules** - 3 formules de défoulement détaillées
6. **Process** - Déroulement d'une séance
7. **FAQ** - Réponses aux questions fréquentes
8. **Contact** - Informations et formulaire de réservation
9. **Footer** - Liens rapides et informations

## 🛠️ Technologies Utilisées

- **Next.js 14** - Framework React avec App Router
- **TypeScript** - Typage statique
- **Tailwind CSS** - Framework CSS utilitaire
- **Lucide React** - Icônes modernes
- **Docker** - Containerisation

## 📞 Contact

- **Téléphone** : +33 7 83 83 64 53
- **Email** : info@usilenziu.com
- **Adresse** : 18 Rue du Pont Long, 64160 Buros, Zone Berlanne

## 📅 Horaires

- **Mardi au Jeudi** : 14:00 – 21:00
- **Vendredi au Samedi** : 14:00 – 00:00
- **Dimanche** : Sur réservation uniquement (minimum 5 personnes)

## 📝 Licence

© 2024 U Silenziu. Tous droits réservés.
