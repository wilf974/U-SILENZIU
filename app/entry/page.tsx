import type { Metadata } from 'next'
import EntryPage from '@/components/EntryPage'

export const metadata: Metadata = {
  title: 'U Silenziu - Zone de défoulement à Buros',
  description: 'Libérez votre stress dans nos salles sécurisées. Zone de défoulement U Silenziu à Buros.',
  robots: {
    index: true,
    follow: true,
  },
}

/**
 * Page d'entrée du site U Silenziu
 * Affiche une page d'accueil avec bouton pour entrer dans le site
 * Support photo/vidéo en arrière-plan
 */
export default function Entry() {
  return <EntryPage />
}
