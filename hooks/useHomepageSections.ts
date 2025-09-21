import { useState, useEffect } from 'react'

export interface HomepageSection {
  id: string
  section_name?: string
  section_key?: string
  section_type?: string
  content: any
  is_active: boolean
  created_at: string
  updated_at: string
}

/**
 * Hook pour gérer les sections de la page d'accueil
 */
export const useHomepageSections = () => {
  const [sections, setSections] = useState<HomepageSection[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchSections()
  }, [])

  const fetchSections = async () => {
    try {
      setLoading(true)
      setError(null)
      
      const timestamp = Date.now()
      const response = await fetch(`/api/homepage-sections?t=${timestamp}`, {
        cache: 'no-store',
        headers: {
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache'
        }
      })
      
      if (!response.ok) {
        throw new Error(`Erreur HTTP: ${response.status}`)
      }

      const result = await response.json()
      
      if (!result.success || !result.data) {
        throw new Error('Données des sections invalides')
      }

      setSections(result.data)
    } catch (err) {
      console.error('Erreur lors du chargement des sections:', err)
      setError(err instanceof Error ? err.message : 'Erreur inconnue')
    } finally {
      setLoading(false)
    }
  }

  return {
    sections,
    loading,
    error,
    refetch: fetchSections
  }
}

/**
 * Récupère une section par sa clé
 */
export const getSectionByKey = (sections: HomepageSection[], key: string): HomepageSection | null => {
  return sections.find(section => 
    section.section_key?.toLowerCase() === key.toLowerCase() ||
    section.section_name?.toLowerCase() === key.toLowerCase()
  ) || null
}

/**
 * Récupère le contenu d'une section par sa clé
 */
export const getSectionContent = (sections: HomepageSection[], key: string): any => {
  const section = getSectionByKey(sections, key)
  return section?.content || null
}
