'use client'

import { useState, useEffect, useCallback } from 'react'
import { useRouter } from 'next/navigation'

export type AdminRole = 'admin' | 'super-admin'

export interface AdminUser {
  username: string
  role: AdminRole
}

export function useAuth() {
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [user, setUser] = useState<AdminUser | null>(null)
  const [loading, setLoading] = useState(true)
  const router = useRouter()

  const checkAuthStatus = useCallback(async () => {
    setLoading(true)
    try {
      const response = await fetch('/api/admin/auth/status')
      if (response.ok) {
        const data = await response.json()
        if (data.isAuthenticated) {
          setUser(data.user)
          setIsAuthenticated(true)
        } else {
          setIsAuthenticated(false)
          setUser(null)
        }
      } else {
        setIsAuthenticated(false)
        setUser(null)
      }
    } catch (error) {
      console.error('Erreur lors de la vérification du statut d\'authentification:', error)
      setIsAuthenticated(false)
      setUser(null)
    } finally {
      setLoading(false)
    }
  }, [])

  useEffect(() => {
    checkAuthStatus()
  }, [checkAuthStatus])

  const login = async (credentials: {username: string, password: string}): Promise<{success: boolean, error?: string}> => {
    try {
      console.log('[Auth] Début login pour:', credentials.username)
      const response = await fetch('/api/admin/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(credentials),
      });

      const data = await response.json()
      console.log('[Auth] Réponse login:', data.success)

      if (data.success) {
        console.log('[Auth] Appel de checkAuthStatus()...')
        await checkAuthStatus()
        console.log('[Auth] checkAuthStatus() terminé, état actuel:', { isAuthenticated, user })

        // Attendre plus longtemps que React ait fini de mettre à jour l'état
        // et que les composants aient re-rendu
        console.log('[Auth] Attente de 500ms avant navigation...')
        await new Promise(resolve => setTimeout(resolve, 500))

        console.log('[Auth] Navigation vers /admin...')
        return { success: true }
      }
      return { success: false, error: data.error }
    } catch (error) {
      console.error('[Auth] Erreur login:', error)
      return { success: false, error: 'Erreur de connexion au serveur' }
    }
  }

  const logout = async () => {
    try {
      await fetch('/api/admin/auth/logout', { method: 'POST' })
    } finally {
      setIsAuthenticated(false)
      setUser(null)
      router.push('/admin/login')
    }
  }

  const requireAuth = useCallback(() => {
    if (!loading && !isAuthenticated) {
      router.push('/admin/login')
    }
  }, [loading, isAuthenticated, router])

  const isSuperAdmin = () => user?.role === 'super-admin'

  const isAdmin = () => user?.role === 'admin' || user?.role === 'super-admin'
  
  const hasRole = (requiredRole: AdminRole) => {
    if (!user) return false
    const roleHierarchy = { 'admin': 1, 'super-admin': 2 }
    return roleHierarchy[user.role] >= roleHierarchy[requiredRole]
  }

  return { isAuthenticated, user, loading, login, logout, requireAuth, isSuperAdmin, isAdmin, hasRole }
}
