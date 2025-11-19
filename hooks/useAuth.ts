'use client'

import { useState, useEffect, useCallback, useRef } from 'react'
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
  const mountedRef = useRef(true) // Tracker si le composant est monté

  const checkAuthStatus = useCallback(async (): Promise<boolean> => {
    if (!mountedRef.current) {
      console.log('[Auth] Component unmounted, ignoring checkAuthStatus')
      return false
    }

    setLoading(true)
    try {
      const response = await fetch('/api/admin/auth/status')
      if (response.ok) {
        const data = await response.json()
        if (data.isAuthenticated) {
          if (mountedRef.current) {
            setUser(data.user)
            setIsAuthenticated(true)
          }
          return true
        } else {
          if (mountedRef.current) {
            setIsAuthenticated(false)
            setUser(null)
          }
          return false
        }
      } else {
        if (mountedRef.current) {
          setIsAuthenticated(false)
          setUser(null)
        }
        return false
      }
    } catch (error) {
      console.error('Erreur lors de la vérification du statut d\'authentification:', error)
      if (mountedRef.current) {
        setIsAuthenticated(false)
        setUser(null)
      }
      return false
    } finally {
      if (mountedRef.current) {
        setLoading(false)
      }
    }
  }, [])

  useEffect(() => {
    // Réinitialiser le flag au montage
    mountedRef.current = true
    checkAuthStatus()

    // Nettoyer au démontage
    return () => {
      mountedRef.current = false
    }
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
        const isAuthValid = await checkAuthStatus()
        console.log('[Auth] checkAuthStatus() retourné:', isAuthValid)

        if (!isAuthValid) {
          console.error('[Auth] Premier check échoué, attente et retry...')
          // Attendre que le cookie soit propagé et retry
          await new Promise(resolve => setTimeout(resolve, 1000))
          const isAuthValidRetry = await checkAuthStatus()
          console.log('[Auth] Retry checkAuthStatus():', isAuthValidRetry)

          if (!isAuthValidRetry) {
            console.error('[Auth] Authentification échouée après retry')
            return { success: false, error: 'Authentification échouée - veuillez réessayer' }
          }
        }

        console.log('[Auth] Authentification réussie, prêt pour navigation')
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
