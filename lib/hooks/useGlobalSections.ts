'use client'

import { useState, useEffect } from 'react'

export interface GlobalSection {
  id: string
  section_key: string
  title: string
  content: string
  is_active: boolean
  page_identifier: string
  created_at: string
  updated_at: string
}

export function useGlobalSections(pageIdentifier: string) {
  const [sections, setSections] = useState<GlobalSection[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchSections()
  }, [pageIdentifier])

  const fetchSections = () => {
    setLoading(true)
    setError(null)
    
    fetch(`/api/global-sections?page=${pageIdentifier}`)
      .then(response => response.json())
      .then(result => {
        if (result.success) {
          setSections(result.data)
        } else {
          setError(result.error || 'Erreur lors du chargement des sections')
        }
      })
      .catch(err => {
        setError('Erreur de connexion')
        console.error('Erreur lors du chargement des sections globales:', err)
      })
      .finally(() => {
        setLoading(false)
      })
  }

  const getSectionByKey = (sectionKey: string): GlobalSection | null => {
    return sections.find(section => section.section_key === sectionKey) || null
  }

  const getSectionContent = (sectionKey: string): any => {
    const section = getSectionByKey(sectionKey)
    if (!section || !section.content) return null
    
    try {
      return JSON.parse(section.content)
    } catch (err) {
      console.error(`Erreur de parsing JSON pour la section ${sectionKey}:`, err)
      return null
    }
  }

  const getSectionsByPage = (): GlobalSection[] => {
    return sections.filter(section => section.page_identifier === pageIdentifier)
  }

  return {
    sections,
    loading,
    error,
    getSectionByKey,
    getSectionContent,
    getSectionsByPage,
    refetch: fetchSections
  }
}
