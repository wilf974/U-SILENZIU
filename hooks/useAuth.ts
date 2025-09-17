'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'

// Types pour les rôles d'administration
export type AdminRole = 'admin' | 'super-admin'

export interface AdminUser {
  username: string
  role: AdminRole
  token: string
}

export function useAuth() {
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [user, setUser] = useState<AdminUser | null>(null)
  const [loading, setLoading] = useState(true)
  const router = useRouter()

  useEffect(() => {
    // Vérifier le token d'authentification et récupérer les infos utilisateur
    const token = sessionStorage.getItem('adminToken')
    const userData = sessionStorage.getItem('adminUser')
    
    if (token && userData) {
      try {
        const parsedUser = JSON.parse(userData)
        setUser(parsedUser)
        setIsAuthenticated(true)
      } catch (error) {
        // Données corrompues, nettoyer
        sessionStorage.removeItem('adminToken')
        sessionStorage.removeItem('adminUser')
        setIsAuthenticated(false)
        setUser(null)
      }
    } else {
      setIsAuthenticated(false)
      setUser(null)
    }
    setLoading(false)
  }, [])

  /**
   * Fonction de connexion avec gestion des rôles
   * @param userData - Données de l'utilisateur connecté
   */
  const login = (userData: AdminUser) => {
    sessionStorage.setItem('adminToken', userData.token)
    sessionStorage.setItem('adminUser', JSON.stringify(userData))
    setUser(userData)
    setIsAuthenticated(true)
  }

  /**
   * Fonction de déconnexion
   */
  const logout = async () => {
    try {
      await fetch('/api/admin/auth/logout', { method: 'POST' })
    } catch (error) {
      console.error('Erreur lors de la déconnexion admin:', error)
    } finally {
      sessionStorage.removeItem('adminToken')
      sessionStorage.removeItem('adminUser')
      setIsAuthenticated(false)
      setUser(null)
      router.push('/admin/login')
    }
  }

  /**
   * Vérification de l'authentification requise
   * @returns true si authentifié, false sinon
   */
  const requireAuth = () => {
    if (!loading && !isAuthenticated) {
      router.push('/admin/login')
      return false
    }
    return true
  }

  /**
   * Vérification des droits super admin
   * @returns true si l'utilisateur est super admin
   */
  const isSuperAdmin = () => {
    return user?.role === 'super-admin'
  }

  /**
   * Vérification des droits admin
   * @returns true si l'utilisateur est admin ou super admin
   */
  const isAdmin = () => {
    return user?.role === 'admin' || user?.role === 'super-admin'
  }

  /**
   * Vérification d'accès à une fonctionnalité
   * @param requiredRole - Rôle minimum requis
   * @returns true si l'utilisateur a les droits
   */
  const hasRole = (requiredRole: AdminRole) => {
    if (!user) return false
    
    const roleHierarchy = {
      'admin': 1,
      'super-admin': 2
    }
    
    return roleHierarchy[user.role] >= roleHierarchy[requiredRole]
  }

  return {
    isAuthenticated,
    user,
    loading,
    login,
    logout,
    requireAuth,
    isSuperAdmin,
    isAdmin,
    hasRole
  }
}
