'use client'

import { useState, useEffect } from 'react'
import Hero from './Hero'
import Concept from './Concept'
import Salles from './Salles'
import Process from './Process'
import FAQ from './FAQ'
import Contact from './Contact'
import VideoSection from './VideoSection'
import DynamicSection from './DynamicSection'
import CommentCaMarche from './CommentCaMarche'

interface HomepageSection {
  id: string
  section_key: string
  section_type?: string
  title?: string
  subtitle?: string
  content?: string
  image_url?: string
  video_url?: string
  background_color?: string
  text_color?: string
  order_index: number
  is_active: boolean
  created_at: string
  updated_at: string
}

/**
 * Composant qui affiche toutes les sections de la page d'accueil
 * dans l'ordre configuré dans le back-office
 */
export default function HomepageSections() {
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
      
      // Récupérer toutes les sections depuis l'API publique
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

      // Filtrer les sections actives et les trier par ordre
      const activeSections = result.data
        .filter((section: HomepageSection) => section.is_active)
        .sort((a: HomepageSection, b: HomepageSection) => (a.order_index || 0) - (b.order_index || 0))

      setSections(activeSections)
    } catch (err) {
      console.error('Erreur lors du chargement des sections:', err)
      setError(err instanceof Error ? err.message : 'Erreur inconnue')
    } finally {
      setLoading(false)
    }
  }

  /**
   * Rendu d'une section selon sa clé
   */
  const renderSection = (section: HomepageSection) => {
    const sectionType = section.section_key || section.section_type
    
    switch (sectionType) {
      case 'hero':
        return <Hero key={section.id} />
      case 'concept':
        return <Concept key={section.id} />
      case 'salles':
        return <Salles key={section.id} />
      case 'process':
        return <Process key={section.id} />
      case 'faq':
        return <FAQ key={section.id} />
      case 'comment-ca-marche':
        return <CommentCaMarche key={section.id} />
      case 'contact':
        return <Contact key={section.id} />
      case 'video':
        return <VideoSection key={section.id} />
      default:
        // Section dynamique créée via le back-office
        return <DynamicSection key={section.id} section={section} />
    }
  }

  // Affichage de chargement
  if (loading) {
    return (
      <div className="min-h-screen bg-dark-bg flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-kaki-500 mx-auto mb-4"></div>
          <p className="text-gray-400">Chargement des sections...</p>
        </div>
      </div>
    )
  }

  // Affichage d'erreur
  if (error) {
    return (
      <div className="min-h-screen bg-dark-bg flex items-center justify-center">
        <div className="text-center">
          <div className="text-red-500 text-6xl mb-4">⚠️</div>
          <h2 className="text-2xl font-bold text-white mb-2">Erreur de chargement</h2>
          <p className="text-gray-400 mb-4">{error}</p>
          <button 
            onClick={fetchSections}
            className="bg-kaki-500 hover:bg-kaki-600 text-white px-6 py-2 rounded-md transition-colors"
          >
            Réessayer
          </button>
        </div>
      </div>
    )
  }

  // Affichage des sections dans l'ordre configuré
  return (
    <>
      {sections.map((section) => renderSection(section))}
    </>
  )
}
