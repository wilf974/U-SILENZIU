'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { ArrowRight } from 'lucide-react'

/**
 * Interface pour la configuration de la page d'entrée
 */
interface EntryPageConfig {
  title: string
  subtitle: string
  description: string
  button_text: string
  background_type: 'image' | 'video'
  background_image_url?: string | null
  background_video_url?: string | null
  is_active: boolean
}

/**
 * Composant de la page d'entrée avec arrière-plan média et bouton d'entrée
 * Cette page permet aux visiteurs d'accéder au site principal
 */
export default function EntryPage() {
  const [config, setConfig] = useState<EntryPageConfig | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const router = useRouter()

  useEffect(() => {
    fetchConfig()
  }, [])

  /**
   * Récupère la configuration de la page d'entrée depuis l'API
   */
  const fetchConfig = async () => {
    try {
      const response = await fetch('/api/entry-page-config', {
        cache: 'no-store',
        headers: {
          'Cache-Control': 'no-cache'
        }
      })

      if (response.ok) {
        const data = await response.json()
        setConfig(data)
      } else {
        setError('Erreur lors du chargement de la configuration')
      }
    } catch (err) {
      console.error('Erreur:', err)
      setError('Erreur de connexion')
    } finally {
      setLoading(false)
    }
  }

  /**
   * Gère le clic sur le bouton d'entrée
   */
  const handleEnterSite = () => {
    router.push('/')
  }

  // Configuration par défaut en cas d'erreur
  const defaultConfig: EntryPageConfig = {
    title: 'U SILENZIU',
    subtitle: 'Zone de défoulement',
    description: 'Libérez votre stress dans nos salles sécurisées',
    button_text: 'ENTRER DANS LE SITE',
    background_type: 'image',
    background_image_url: '/images/entry/entry-bg.jpg',
    background_video_url: undefined,
    is_active: true
  }

  const displayConfig = config || defaultConfig

  if (loading) {
    return (
      <div className="min-h-screen bg-dark-bg flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-kaki-400 mx-auto mb-4"></div>
          <p className="text-white text-lg">Chargement...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="relative min-h-screen overflow-hidden">
      {/* Arrière-plan média */}
      <div className="absolute inset-0 z-0">
        {displayConfig.background_type === 'video' && displayConfig.background_video_url ? (
          <video
            autoPlay
            muted
            loop
            playsInline
            className="w-full h-full object-cover"
            poster={displayConfig.background_image_url || undefined}
          >
            <source src={displayConfig.background_video_url} type="video/mp4" />
            {/* Fallback vers l'image si la vidéo ne se charge pas */}
            {displayConfig.background_image_url && (
              <img
                src={displayConfig.background_image_url}
                alt="Arrière-plan"
                className="w-full h-full object-cover"
              />
            )}
          </video>
        ) : (
          <div
            className="w-full h-full bg-cover bg-center bg-no-repeat"
            style={{
              backgroundImage: `url('${displayConfig.background_image_url || '/images/entry/entry-bg.jpg'}')`
            }}
          />
        )}
        
        {/* Overlay sombre pour améliorer la lisibilité */}
        <div className="absolute inset-0 bg-black/60" />
      </div>

      {/* Contenu principal */}
      <div className="relative z-10 min-h-screen flex items-center justify-center px-4">
        <div className="text-center max-w-4xl mx-auto">
          {/* Titre principal */}
          <h1 className="text-6xl md:text-8xl font-bold text-white mb-4 tracking-wider drop-shadow-2xl">
            {displayConfig.title}
          </h1>

          {/* Ligne séparatrice */}
          <div className="w-32 h-1 bg-kaki-400 mx-auto mb-6"></div>

          {/* Sous-titre */}
          <h2 className="text-2xl md:text-3xl font-light text-kaki-200 mb-8 tracking-wide">
            {displayConfig.subtitle}
          </h2>

          {/* Description */}
          <p className="text-lg md:text-xl text-gray-200 mb-12 max-w-2xl mx-auto leading-relaxed">
            {displayConfig.description}
          </p>

          {/* Bouton d'entrée */}
          <button
            onClick={handleEnterSite}
            className="group relative inline-flex items-center gap-3 bg-kaki-600 hover:bg-kaki-700 text-white text-lg font-semibold px-8 py-4 rounded-lg transition-all duration-300 transform hover:scale-105 hover:shadow-2xl focus:outline-none focus:ring-4 focus:ring-kaki-400/50"
          >
            <span className="relative z-10">{displayConfig.button_text}</span>
            <ArrowRight className="w-6 h-6 transition-transform duration-300 group-hover:translate-x-1" />
            
            {/* Effet de brillance au survol */}
            <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 rounded-lg transform -skew-x-12"></div>
          </button>

          {/* Indicateur de scroll optionnel */}
          <div className="absolute bottom-8 left-1/2 transform -translate-x-1/2 text-white/70 animate-bounce">
            <div className="flex flex-col items-center gap-2">
              <span className="text-sm uppercase tracking-wider">Défoulez-vous</span>
              <div className="w-0.5 h-8 bg-white/50"></div>
            </div>
          </div>
        </div>
      </div>

      {/* Message d'erreur si nécessaire */}
      {error && (
        <div className="absolute top-4 right-4 bg-red-900/80 border border-red-500 text-red-200 px-4 py-2 rounded-lg text-sm z-20">
          {error}
        </div>
      )}
    </div>
  )
}
