'use client'

import VideoPlayer from './VideoPlayer'
import { Play, Zap, Shield } from 'lucide-react'
import { useRouter } from 'next/navigation'

const VideoSection = () => {
  const router = useRouter()

  const handleReservation = () => {
    try {
      router.push('/reservation')
    } catch (error) {
      console.error('Erreur lors de la navigation:', error)
      // Fallback vers une navigation simple
      window.location.href = '/reservation'
    }
  }

  // Données statiques pour éviter les problèmes de sérialisation
  const features = [
    {
      icon: Shield,
      title: "Sécurité maximale",
      description: "Équipement de protection complet, salles isolées et protocoles stricts pour votre sécurité absolue."
    },
    {
      icon: Zap,
      title: "Libération totale",
      description: "Laissez-vous aller dans un environnement conçu pour évacuer le stress et retrouver votre énergie."
    }
  ]

  const stats = [
    { value: "30", label: "Minutes de défoulement", description: "Sessions optimisées pour un maximum d'efficacité" },
    { value: "100%", label: "Sécurisé", description: "Équipement et protocoles de sécurité complets" },
    { value: "24/7", label: "Support", description: "Accompagnement professionnel disponible" }
  ]

  return (
    <section className="py-20 bg-dark-surface" aria-labelledby="video-section-title">
      <div className="section-container">
        <div className="text-center mb-16">
          <h2 id="video-section-title" className="text-4xl lg:text-5xl font-bold text-white mb-6">
            Découvrez <span className="text-gradient-kaki">l'expérience</span>
          </h2>
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            Plongez dans l'univers de U Silenziu et découvrez l'ambiance unique de nos salles de défoulement. 
            Une expérience immersive qui vous donnera envie de nous rejoindre.
          </p>
        </div>

        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Video */}
          <div className="relative">
            <VideoPlayer
              src="/video/hero-video.mp4"
              title="U Silenziu - Expérience Défoulement"
              className="rounded-2xl overflow-hidden shadow-2xl"
              autoPlay={false}
              loop={false}
              muted={true}
              controls={true}
              poster="/images/hero-poster.jpg"
            />
          </div>

          {/* Content */}
          <div className="space-y-8">
            <div className="space-y-6">
              <h3 className="text-3xl font-bold text-white">
                Une expérience <span className="text-gradient-kaki">unique</span> et sécurisée
              </h3>
              <p className="text-lg text-gray-300 leading-relaxed">
                Nos salles de défoulement sont conçues pour vous offrir une expérience libératrice 
                dans un environnement parfaitement sécurisé. Équipement professionnel, ambiance 
                personnalisée et accompagnement expert garantissent une session inoubliable.
              </p>
            </div>

            {/* Features */}
            <div className="space-y-4">
              {features.map((feature, index) => {
                const IconComponent = feature.icon
                return (
                  <div key={index} className="flex items-start space-x-4">
                    <div className="w-12 h-12 bg-kaki-600 rounded-lg flex items-center justify-center flex-shrink-0" aria-hidden="true">
                      <IconComponent className="text-white" size={24} />
                    </div>
                    <div>
                      <h4 className="text-xl font-semibold text-white mb-2">{feature.title}</h4>
                      <p className="text-gray-300">{feature.description}</p>
                    </div>
                  </div>
                )
              })}
            </div>

            {/* CTA */}
            <div className="pt-6">
              <button 
                onClick={handleReservation}
                className="btn-kaki text-lg px-8 py-4 hover:scale-105 transition-transform duration-200"
                aria-label="Réserver une session de défoulement chez U Silenziu"
              >
                Réserver maintenant
              </button>
            </div>
          </div>
        </div>

        {/* Additional info */}
        <div className="mt-16 grid md:grid-cols-3 gap-8">
          {stats.map((stat, index) => (
            <div key={index} className="text-center">
              <div className="w-16 h-16 bg-kaki-600 rounded-full flex items-center justify-center mx-auto mb-4" aria-hidden="true">
                <span className="text-white font-bold text-xl">{stat.value}</span>
              </div>
              <h4 className="text-xl font-semibold text-white mb-2">{stat.label}</h4>
              <p className="text-gray-300">{stat.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}

export default VideoSection
