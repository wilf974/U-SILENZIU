import { ReactNode } from 'react'
import { cookies } from 'next/headers'
import { ADMIN_TOKEN_COOKIE, verifyAdminToken } from '@/lib/auth'

export default function AdminAuthLayout({ children }: { children: ReactNode }) {
  const token = cookies().get(ADMIN_TOKEN_COOKIE)?.value

  // Vérifier si le token est valide, mais NE PAS rediriger côté serveur
  // Laisser le client gérer la navigation avec router.push()
  // Cela évite les conflits avec les redirections client
  if (token) {
    try {
      verifyAdminToken(token)
      // Token valide - laisser le composant client gérer la redirection
      // via useEffect et router.push()
    } catch (error) {
      console.warn('Token admin invalide sur /admin/login:', error)
    }
  }

  return <>{children}</>
}

