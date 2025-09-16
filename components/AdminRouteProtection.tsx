'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { useAuth, AdminRole } from '@/hooks/useAuth'
import { Shield, Crown, AlertTriangle } from 'lucide-react'

interface AdminRouteProtectionProps {
  children: React.ReactNode
  requiredRole?: AdminRole
  fallbackComponent?: React.ReactNode
}

/**
 * Composant de protection des routes d'administration
 * Vérifie les droits d'accès selon le rôle requis
 * @param children - Contenu à afficher si l'utilisateur a les droits
 * @param requiredRole - Rôle minimum requis (par défaut: 'admin')
 * @param fallbackComponent - Composant à afficher si l'utilisateur n'a pas les droits
 */
export default function AdminRouteProtection({ 
  children, 
  requiredRole = 'admin',
  fallbackComponent 
}: AdminRouteProtectionProps) {
  const { isAuthenticated, user, loading, hasRole, requireAuth } = useAuth()
  const router = useRouter()

  useEffect(() => {
    // Vérifier l'authentification de base
    if (!loading && !isAuthenticated) {
      requireAuth()
      return
    }

    // Vérifier les droits spécifiques
    if (!loading && isAuthenticated && user && !hasRole(requiredRole)) {
      // L'utilisateur est connecté mais n'a pas les droits requis
      console.warn(`Accès refusé: ${user.username} (${user.role}) n'a pas les droits ${requiredRole}`)
    }
  }, [isAuthenticated, user, loading, requiredRole, hasRole, requireAuth])

  // Affichage pendant le chargement
  if (loading) {
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-kaki-500 mx-auto mb-4"></div>
          <p className="text-gray-400">Vérification des droits d'accès...</p>
        </div>
      </div>
    )
  }

  // Utilisateur non authentifié
  if (!isAuthenticated) {
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-kaki-500 mx-auto mb-4"></div>
          <p className="text-gray-400">Redirection vers la page de connexion...</p>
        </div>
      </div>
    )
  }

  // Utilisateur authentifié mais sans les droits requis
  if (!hasRole(requiredRole)) {
    // Utiliser le composant de fallback personnalisé si fourni
    if (fallbackComponent) {
      return <>{fallbackComponent}</>
    }

    // Composant de fallback par défaut
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center p-4">
        <div className="max-w-md w-full bg-gray-800 rounded-lg p-8 border border-gray-700">
          <div className="text-center">
            {/* Icône selon le rôle requis */}
            <div className="mx-auto w-16 h-16 bg-red-600 rounded-full flex items-center justify-center mb-6">
              {requiredRole === 'super-admin' ? (
                <Crown className="w-8 h-8 text-white" />
              ) : (
                <Shield className="w-8 h-8 text-white" />
              )}
            </div>

            {/* Titre */}
            <h1 className="text-2xl font-bold text-white mb-4">
              Accès Refusé
            </h1>

            {/* Message d'erreur */}
            <div className="bg-red-900 border border-red-700 text-red-200 px-4 py-3 rounded-lg mb-6">
              <div className="flex items-center">
                <AlertTriangle className="w-5 h-5 mr-2" />
                <div>
                  <p className="font-medium">Droits insuffisants</p>
                  <p className="text-sm mt-1">
                    Cette fonctionnalité nécessite les droits de{' '}
                    <span className="font-semibold">
                      {requiredRole === 'super-admin' ? 'Super Administrateur' : 'Administrateur'}
                    </span>
                  </p>
                </div>
              </div>
            </div>

            {/* Informations utilisateur */}
            <div className="bg-gray-700 rounded-lg p-4 mb-6">
              <p className="text-sm text-gray-300">
                <strong>Utilisateur connecté :</strong> {user?.username}
              </p>
              <p className="text-sm text-gray-300">
                <strong>Rôle actuel :</strong> {user?.role === 'super-admin' ? 'Super Administrateur' : 'Administrateur'}
              </p>
            </div>

            {/* Actions */}
            <div className="space-y-3">
              <button
                onClick={() => router.push('/admin')}
                className="w-full bg-kaki-600 hover:bg-kaki-700 text-white font-medium py-2 px-4 rounded-lg transition-colors duration-200"
              >
                Retour au Dashboard
              </button>
              
              <button
                onClick={() => router.push('/admin/login')}
                className="w-full bg-gray-600 hover:bg-gray-700 text-white font-medium py-2 px-4 rounded-lg transition-colors duration-200"
              >
                Se reconnecter
              </button>
            </div>
          </div>
        </div>
      </div>
    )
  }

  // Utilisateur a les droits requis, afficher le contenu
  return <>{children}</>
}

/**
 * Hook pour vérifier les droits d'accès dans un composant
 * @param requiredRole - Rôle minimum requis
 * @returns objet avec les informations d'accès
 */
export function useAdminAccess(requiredRole: AdminRole = 'admin') {
  const { user, hasRole, isAuthenticated } = useAuth()

  return {
    hasAccess: hasRole(requiredRole),
    isAuthenticated,
    user,
    role: user?.role,
    isSuperAdmin: user?.role === 'super-admin',
    isAdmin: user?.role === 'admin' || user?.role === 'super-admin'
  }
}
