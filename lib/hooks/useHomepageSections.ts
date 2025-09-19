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

const isLikelyJsonString = (value: string) => {
  const trimmed = value.trim()
  return trimmed.startsWith('{') || trimmed.startsWith('[')
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

    const rawContent = (section as any).content

    // Si l'API retourne déjà un objet (content en JSONB côté DB), ne pas reparser
    if (typeof rawContent === 'object' && rawContent !== null) {
      return rawContent
    }

    if (typeof rawContent === 'string') {
      const trimmed = rawContent.trim()
      if (!isLikelyJsonString(trimmed)) {
        return null
      }

      try {
        return JSON.parse(trimmed)
      } catch (err) {
        console.warn(`Contenu JSON invalide pour la section ${sectionKey}:`, err)
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

