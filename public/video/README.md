# Dossier Vidéo - U Silenziu

Ce dossier contient les vidéos du site U Silenziu.

## Formats supportés
- MP4 (recommandé)
- WebM
- OGV

## Structure recommandée
```
video/
├── hero-video.mp4          # Vidéo d'accueil
├── activities-video.mp4    # Vidéo des activités
├── concept-video.mp4       # Vidéo du concept
└── README.md              # Ce fichier
```

## Utilisation dans Next.js
Les vidéos peuvent être référencées depuis les composants React avec le chemin `/video/nom-du-fichier.mp4`

### Exemple d'utilisation :
```jsx
<video 
  src="/video/hero-video.mp4" 
  controls 
  width="100%" 
  height="auto"
  preload="metadata"
>
  Votre navigateur ne supporte pas la lecture de vidéos.
</video>
```

## Optimisation
- Utilisez des formats compressés (H.264 pour MP4)
- Limitez la taille des fichiers pour un chargement rapide
- Considérez l'utilisation de plusieurs qualités pour l'adaptation
