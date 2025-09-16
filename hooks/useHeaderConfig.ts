'use client'

import { useState, useEffect } from 'react'
import { HeaderConfig } from '@/lib/database'

/**
 * Hook personnalisé pour récupérer la configuration de l'en-tête
 */
export function useHeaderConfig() {
  const [config, setConfig] = useState<HeaderConfig | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchConfig = async () => {
      try {
        setLoading(true)
        setError(null)
        
        const response = await fetch('/api/header-config')
        
        if (response.ok) {
          const data = await response.json()
          setConfig(data)
        } else {
          setError('Erreur lors du chargement de la configuration')
        }
      } catch (error) {
        console.error('Erreur lors du chargement de la configuration de l\'en-tête:', error)
        setError('Erreur lors du chargement de la configuration')
      } finally {
        setLoading(false)
      }
    }

    fetchConfig()
  }, [])

  return {
    config,
    loading,
    error,
    refetch: () => {
      setLoading(true)
      setError(null)
      fetch('/api/header-config')
        .then(response => response.json())
        .then(data => {
          setConfig(data)
          setLoading(false)
        })
        .catch(error => {
          console.error('Erreur:', error)
          setError('Erreur lors du chargement de la configuration')
          setLoading(false)
        })
    }
  }
}

