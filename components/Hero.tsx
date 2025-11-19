'use client'

import { ArrowRight, Zap, Shield, Clock } from 'lucide-react'
import Link from 'next/link'
import Image from 'next/image'
import { useHomepageSections } from '@/lib/hooks/useHomepageSections'
import { useState, useEffect } from 'react'

const Hero = () => {
  const { getSectionByKey, getSectionContent, loading } = useHomepageSections()
  const heroSection = getSectionByKey('hero')
  const heroContent = getSectionContent('hero')
  const [videoUrl, setVideoUrl] = useState<string>('/video/hero-video.mp4')

  // Charger la vidéo hero depuis la configuration
  useEffect(() => {
    const fetchVideoUrl = async () => {
      try {
        const response = await fetch('/api/homepage-config', {
          cache: 'no-store'
        })
        if (response.ok) {
          const data = await response.json()
          if (data.data?.video_url) {
            setVideoUrl(data.data.video_url)
          }
        }
      } catch (err) {
        console.error('Erreur lors du chargement de la vidéo hero:', err)
        // Utiliser la vidéo par défaut en cas d'erreur
      }
    }
    fetchVideoUrl()
  }, [])

  // Ne pas afficher si chargement ou si la section est inactive/absente
  // if (loading) return null
  // Toujours afficher la section Hero même si pas trouvée dans la base
  // if (!heroSection) return null

  // Données par défaut si certains sous-champs manquent
  const rawTitle = (heroSection as any)?.title;
  const rawSubtitle = (heroSection as any)?.subtitle;
  const title = typeof rawTitle === 'string' && rawTitle.trim().length > 0
    ? rawTitle
    : 'Libérez votre STRESS';
  const subtitle = typeof rawSubtitle === 'string' && rawSubtitle.trim().length > 0
    ? rawSubtitle
    : "Venez vous défouler en toute sécurité chez U Silenziu. Cassez, détruisez et libérez vos tensions dans nos salles spécialement conçues pour évacuer le stress.";
  const features = (heroContent?.features) || [
    { icon: 'Shield', title: '100% Sécurisé', description: 'Équipement complet fourni' },
    { icon: 'Zap', title: 'Décompression', description: 'Évacuez votre stress' },
    { icon: 'Clock', title: 'Flexibilité', description: 'Sessions de 20-30 min' }
  ]
  const ctaPrimary = heroContent?.cta_primary || 'Réserver maintenant'
  const ctaSecondary = heroContent?.cta_secondary || 'Découvrir nos salles'

  const getIconComponent = (iconName: string) => {
    switch (iconName) {
      case 'Shield': return Shield
      case 'Zap': return Zap
      case 'Clock': return Clock
      default: return Zap
    }
  }

  return (
    <section id="hero" className="relative min-h-screen flex items-center overflow-hidden">
      {/* Background Video - Optimisé pour mobile avec poster */}
      <video
        src={videoUrl}
        autoPlay
        loop
        muted
        playsInline
        preload="metadata"
        poster="/images/hero-poster.jpg"
        className="absolute inset-0 w-full h-full object-cover z-0"
        style={{
          width: '100vw',
          height: '100vh',
          objectFit: 'cover',
          objectPosition: 'center'
        }}
        title="Vidéo d'introduction U Silenziu - Zone de défoulement"
      />
      
      {/* Overlay gradient for better text readability */}
      <div className="absolute inset-0 bg-gradient-to-r from-black/40 via-black/30 to-black/40 z-10"></div>
      
      {/* Content */}
      <div className="relative z-20 section-container py-20 w-full">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Left content */}
          <div className="space-y-8">
            <div className="space-y-4">
              <h1 className="text-4xl sm:text-5xl lg:text-7xl font-bold leading-tight">
                <span className="text-white">{title.split(' ').slice(0, -1).join(' ')}</span>
                <br />
                <span className="text-gradient-kaki">{title.split(' ').slice(-1)[0]}</span>
              </h1>
              <p className="text-lg sm:text-xl text-gray-300 max-w-2xl">
                {subtitle}
              </p>
            </div>

            {/* Features */}
            <div className="grid sm:grid-cols-3 gap-6">
              {features.map((feature: any, index: number) => {
                const IconComponent = getIconComponent(feature.icon)
                return (
                  <div key={index} className="flex items-center space-x-3">
                    <div className="w-12 h-12 bg-kaki-600 rounded-lg flex items-center justify-center">
                      <IconComponent className="text-white" size={24} />
                    </div>
                    <div>
                      <h3 className="font-semibold text-white">{feature.title}</h3>
                      <p className="text-sm text-gray-400">{feature.description}</p>
                    </div>
                  </div>
                )
              })}
            </div>

            {/* CTA Buttons */}
            <div className="flex flex-col sm:flex-row gap-4">
              <Link 
                href="/reservation"
                className="btn-kaki flex items-center justify-center space-x-2"
              >
                <span>{ctaPrimary}</span>
                <ArrowRight size={20} />
              </Link>
              <Link 
                href="/#salles"
                className="btn-kaki-outline"
              >
                {ctaSecondary}
              </Link>
            </div>
          </div>

          {/* Right content - Visual element avec image optimisée */}
          <div className="relative">
            <div className="aspect-square bg-gradient-to-br from-kaki-600/20 to-kaki-800/20 rounded-3xl flex items-center justify-center backdrop-blur-sm border border-kaki-500/30 overflow-hidden">
              <Image
                src="/images/hero-zone.jpg"
                alt="Zone de défoulement U Silenziu - Salle équipée pour l'évacuation du stress"
                width={400}
                height={400}
                className="object-cover w-full h-full opacity-20"
                priority
              />
              <div className="absolute inset-0 flex items-center justify-center">
                <div className="text-center text-white">
                  <div className="w-24 h-24 bg-kaki-600/80 rounded-full flex items-center justify-center mx-auto mb-4 backdrop-blur-sm">
                    <Zap size={48} className="opacity-80" />
                  </div>
                  <h3 className="text-2xl font-bold mb-2">Zone de Défoulement</h3>
                  <p className="text-lg opacity-90">U Silenziu</p>
                </div>
              </div>
            </div>
            {/* Decorative elements */}
            <div className="absolute -top-4 -right-4 w-24 h-24 bg-kaki-500 rounded-full opacity-20"></div>
            <div className="absolute -bottom-4 -left-4 w-16 h-16 bg-kaki-400 rounded-full opacity-30"></div>
          </div>
        </div>
      </div>
    </section>
  )
}

export default Hero
