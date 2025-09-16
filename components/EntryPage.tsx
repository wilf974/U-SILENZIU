'use client'

import { useState, useEffect } from 'react'
import { ArrowRight, Zap } from 'lucide-react'
import Link from 'next/link'
import Image from 'next/image'

// Interface pour la configuration de la page d'entrée
interface EntryPageConfig {
  id: number
  title: string
  subtitle: string
  description: string
  button_text: string
  background_type: 'image' | 'video'
  background_url?: string
  background_image_url?: string
  background_video_url?: string
  is_active: boolean
  created_at: string
  updated_at: string
}

export default function EntryPage() {
  const [config, setConfig] = useState<EntryPageConfig | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // Configuration par défaut
  const defaultConfig: EntryPageConfig = {
    id: 0,
    title: 'U SILENZIU',
    subtitle: 'Zone de défoulement',
    description: 'Libérez votre stress dans nos salles sécurisées',
    button_text: 'ENTRER DANS LE SITE',
    background_type: 'video',
    background_image_url: '/images/entry/entry-bg.jpg',
    background_video_url: '/videos/entry/entry-bg.mp4',
    is_active: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  }

  // Charger la configuration depuis l'API
  useEffect(() => {
    const fetchConfig = async () => {
      try {
        const response = await fetch('/api/entry-page-config')
        if (response.ok) {
          const data = await response.json()
          setConfig(data)
        } else {
          console.warn('Configuration de la page d\'entrée non trouvée, utilisation des valeurs par défaut')
          setConfig(defaultConfig)
        }
      } catch (err) {
        console.error('Erreur lors du chargement de la configuration:', err)
        setError('Erreur de chargement')
        setConfig(defaultConfig)
      } finally {
        setLoading(false)
      }
    }

    fetchConfig()
  }, [])

  // Ne pas afficher si chargement
  if (loading) return null

  // Utiliser la configuration ou les valeurs par défaut
  const currentConfig = config || defaultConfig

  return (
    <section id="entry" className="relative h-screen flex items-center justify-center overflow-hidden">
      {/* Background Video - Exactement comme le Hero */}
      <video
        src="/videos/entry/entry-bg.mp4"
        autoPlay
        loop
        muted
        playsInline
        preload="metadata"
        poster="/images/entry/entry-bg.jpg"
        className="absolute inset-0 w-full h-full object-cover z-0"
        style={{
          width: '100vw',
          height: '100vh',
          objectFit: 'cover',
          objectPosition: 'center'
        }}
        title="Vidéo d'introduction U Silenziu - Zone de défoulement"
      />
      
      {/* Overlay gradient for better text readability - Exactement comme le Hero */}
      <div className="absolute inset-0 bg-gradient-to-r from-black/40 via-black/30 to-black/40 z-10"></div>
      
      {/* Content - Parfaitement centré au milieu de l'écran */}
      <div className="relative z-20 px-4">
        <div className="text-center space-y-6 w-full max-w-4xl bg-black/30 backdrop-blur-sm rounded-2xl p-8 border border-white/10 shadow-2xl">
          {/* Titre principal */}
          <h1 className="text-5xl sm:text-6xl lg:text-7xl font-bold text-white mb-4">
            {currentConfig.title}
          </h1>
          
          {/* Ligne verte */}
          <div className="w-24 h-1 bg-kaki-500 mx-auto mb-4"></div>
          
          {/* Sous-titre */}
          <h2 className="text-2xl sm:text-3xl lg:text-4xl text-kaki-300 font-light mb-6">
            {currentConfig.subtitle}
          </h2>

          {/* Description */}
          <p className="text-lg sm:text-xl lg:text-2xl text-gray-300 max-w-3xl mx-auto leading-relaxed mb-8">
            {currentConfig.description}
          </p>

          {/* Bouton d'entrée */}
          <Link 
            href="/home"
            className="inline-flex items-center justify-center space-x-3 bg-kaki-600 hover:bg-kaki-700 text-white text-lg sm:text-xl font-semibold px-12 py-4 rounded-lg transition-all duration-300 transform hover:scale-105 hover:shadow-2xl"
          >
            <span>{currentConfig.button_text}</span>
            <ArrowRight size={24} />
          </Link>
        </div>
      </div>
    </section>
  )
}
