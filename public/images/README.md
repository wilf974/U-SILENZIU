# Images U Silenziu

Ce dossier contient toutes les images optimisées pour le site U Silenziu.

## Structure des images

### Images principales
- `hero-poster.jpg` - Image de fallback pour la vidéo Hero (1920x1080)
- `hero-zone.jpg` - Image de la zone de défoulement dans le Hero (400x400)

### Images des salles
- `salle-douce.jpg` - Salle "Pas Content!" - Défoulement soft (600x400)
- `salle-carnage.jpg` - Salle "Vraiment pas Content!" - Défoulement carnage (600x400)
- `salle-privatisee.jpg` - Salle "Grosse colère" - Défoulement privatisé (600x400)

## Optimisation

### Formats recommandés
- **Format principal** : JPG pour les photos, PNG pour les logos/icônes
- **Compression** : Optimisée pour le web (< 200KB pour les images principales)
- **Dimensions** : Responsive avec plusieurs tailles si nécessaire

### Attributs SEO
Toutes les images incluent :
- `alt` descriptif et pertinent
- `title` informatif
- `loading="lazy"` pour les images non critiques
- `priority` pour les images above-the-fold

### Utilisation avec Next.js Image
```jsx
import Image from 'next/image'

<Image
  src="/images/salle-douce.jpg"
  alt="Salle de défoulement douce U Silenziu"
  width={600}
  height={400}
  className="object-cover"
  loading="lazy"
/>
```

## Remplacer les images

1. **Préparer l'image** : Optimiser pour le web (compression, dimensions)
2. **Nommer correctement** : Utiliser les noms existants
3. **Remplacer le fichier** : Copier dans ce dossier
4. **Vérifier l'affichage** : Tester sur le site

## Notes importantes

- Toutes les images doivent respecter le thème sombre (kaki/noir)
- Les images des salles doivent montrer l'équipement et l'ambiance
- Maintenir la cohérence visuelle avec le design existant
- Optimiser pour les performances (taille de fichier)
