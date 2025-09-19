'use client'

import { useState, useEffect } from 'react'

export interface HomepageSection {
  id: number
  section_type: string
  title?: string
  subtitle?: string
  content?: string
  image_url?: string
  video_url?: string
  background_color?: string
  text_color?: string
  display_order: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export function useHomepageSections() {
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
      
      const response = await fetch('/api/homepage-sections')
      const result = await response.json()
      
      if (result.success) {
        setSections(result.data)
      } else {
        setError(result.error || 'Erreur lors du chargement des sections')
      }
    } catch (err) {
      setError('Erreur de connexion')
      console.error('Erreur lors du chargement des sections:', err)
    } finally {
      setLoading(false)
    }
  }

  const getSectionByKey = (sectionKey: string): HomepageSection | null => {
    return sections.find(section => 
      section.section_type === sectionKey || 
      (section as any).section_key === sectionKey
    ) || null
  }

  const getSectionContent = (sectionKey: string): any => {
    const section = getSectionByKey(sectionKey)
    if (!section || section.content === undefined || section.content === null) return null

    // Si l'API retourne déjà un objet (content en JSONB côté DB), ne pas reparser
    if (typeof (section as any).content === 'object') {
      return (section as any).content
    }

    // Sinon tenter de parser si c'est une chaîne JSON
    if (typeof (section as any).content === 'string') {
      try {
        return JSON.parse((section as any).content as unknown as string)
      } catch (err) {
        console.error(`Erreur de parsing JSON pour la section ${sectionKey}:`, err)
        return null
      }
    }

    return null
  }

  return {
    sections,
    loading,
    error,
    getSectionByKey,
    getSectionContent,
    refetch: fetchSections
  }
}
