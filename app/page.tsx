import { redirect } from 'next/navigation'

/**
 * Page d'accueil qui redirige vers la page d'entrée
 * La page d'entrée permet aux clients d'entrer dans le site
 */
export default function Home() {
  // Redirection vers la page d'entrée
  redirect('/entry')
}

