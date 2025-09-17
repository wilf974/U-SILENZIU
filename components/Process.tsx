'use client'

import { UserCheck, Shield, AlertTriangle, Music, RotateCcw, Clock, Zap, Target, Heart, Star } from 'lucide-react'
import { useRouter } from 'next/navigation'
import { useHomepageSections } from '@/lib/hooks/useHomepageSections'

/**
 * Affiche la section "Process" uniquement si la section homepage 'process' est active.
 */
const Process = () => {
  const router = useRouter()
  const { getSectionByKey, getSectionContent, loading } = useHomepageSections()
  const section = getSectionByKey('process')
  const content = getSectionContent('process')

  // if (loading) return null
  // Toujours afficher la section Process même si pas trouvée dans la base
  // if (!section) return null

  const handleReservation = () => {
    router.push('/reservation')
  }

  // Récupérer les étapes depuis la base de données ou utiliser les données par défaut
  const steps = content?.steps || [
    {
      number: 1,
      icon: 'UserCheck',
      title: 'Accueil des participants',
      duration: '5 min',
      description: 'Nos équipes vous accueillent et vérifient vos réservations',
      color: 'from-kaki-400 to-kaki-600'
    },
    {
      number: 2,
      icon: 'Shield',
      title: 'Zone d\'équipement',
      duration: '10 min',
      description: 'Équipement complet de sécurité de la tête aux pieds',
      color: 'from-kaki-500 to-kaki-700'
    },
    {
      number: 3,
      icon: 'AlertTriangle',
      title: 'Consignes de sécurité',
      duration: '5 min',
      description: 'Briefing sécurité et petit échauffement avant la session',
      color: 'from-kaki-600 to-kaki-800'
    },
    {
      number: 4,
      icon: 'Music',
      title: 'Session de défoulement',
      duration: '20-30 min',
      description: 'La musique commence et la salle est à vous !',
      color: 'from-kaki-700 to-kaki-900'
    },
    {
      number: 5,
      icon: 'RotateCcw',
      title: 'Retrait de l\'équipement',
      duration: '10 min',
      description: 'Déséquipement et retour au calme',
      color: 'from-kaki-500 to-kaki-700'
    }
  ]

  // Récupérer les informations CTA depuis la base de données ou utiliser les données par défaut
  const ctaInfo = content?.cta_info || {
    title: 'U Silenziu - Énergie positive',
    description: 'Repartez détendu et libéré de vos tensions. Nos sessions sont conçues pour vous procurer une sensation de bien-être durable.',
    button_text: 'Réserver une salle de défoulement'
  }

  // Fonction pour obtenir le composant d'icône
  const getIconComponent = (iconName: string) => {
    switch (iconName) {
      case 'UserCheck': return UserCheck
      case 'Shield': return Shield
      case 'AlertTriangle': return AlertTriangle
      case 'Music': return Music
      case 'RotateCcw': return RotateCcw
      case 'Clock': return Clock
      case 'Zap': return Zap
      case 'Target': return Target
      case 'Heart': return Heart
      case 'Star': return Star
      default: return UserCheck
    }
  }

  return (
    <section className="py-20 bg-dark-bg">
      <div className="section-container">
        <div className="text-center mb-16">
          <h2 className="text-4xl lg:text-5xl font-bold text-white mb-6">
            {section?.title ? (
              section.title.includes('séance') || section.title.includes('seance') ? (
                <span dangerouslySetInnerHTML={{
                  __html: section.title
                    .replace('séance', '<span class="text-gradient-kaki">séance</span>')
                    .replace('seance', '<span class="text-gradient-kaki">seance</span>')
                }} />
              ) : section.title
            ) : (
              <>Comment fonctionne une <span className="text-gradient-kaki">séance</span> ?</>
            )}
          </h2>
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            {section?.subtitle || 'Découvrez le déroulement type d\'une session chez U Silenziu. Chaque étape est pensée pour votre sécurité et votre plaisir.'}
          </p>
        </div>

        {/* Timeline */}
        <div className="relative">
          {/* Vertical line for mobile, horizontal for desktop */}
          <div className="hidden lg:block absolute top-1/2 left-0 right-0 h-1 bg-gradient-to-r from-kaki-600 via-kaki-500 to-kaki-600 transform -translate-y-1/2"></div>
          <div className="lg:hidden absolute left-8 top-0 bottom-0 w-1 bg-gradient-to-b from-kaki-600 via-kaki-500 to-kaki-600"></div>

          <div className="grid lg:grid-cols-5 gap-8 lg:gap-4">
            {steps.map((step: any, index: number) => {
              const IconComponent = getIconComponent(step.icon)
              return (
                <div key={index} className="relative flex lg:flex-col items-start lg:items-center">
                  {/* Step number and icon */}
                  <div className="relative z-10 flex lg:flex-col items-center lg:mb-6">
                    {/* Mobile: Icon with centered number overlay */}
                    <div className="lg:hidden relative">
                      <div className={`w-20 h-20 bg-gradient-to-br ${step.color} rounded-full flex items-center justify-center`}>
                        <IconComponent className="text-white" size={32} />
                      </div>
                      <div className="absolute -top-2 -right-2 w-8 h-8 bg-kaki-600 rounded-full flex items-center justify-center">
                        <span className="text-white font-bold text-sm leading-none">{index + 1}</span>
                      </div>
                    </div>
                    
                    {/* Desktop: Icon and number in separate containers */}
                    <div className="hidden lg:flex lg:flex-col items-center">
                      <div className={`w-20 h-20 bg-gradient-to-br ${step.color} rounded-full flex items-center justify-center mb-4`}>
                        <IconComponent className="text-white" size={32} />
                      </div>
                      <div className="w-10 h-10 bg-kaki-600 rounded-full flex items-center justify-center">
                        <span className="text-white font-bold leading-none">{index + 1}</span>
                      </div>
                    </div>
                  </div>

                  {/* Content */}
                  <div className="flex-1 lg:text-center">
                    <div className="card-dark">
                      <div className="mb-3">
                        <span className="inline-block bg-kaki-600 text-white px-3 py-1 rounded-full text-sm font-semibold">
                          {step.duration}
                        </span>
                      </div>
                      <h3 className="text-xl font-bold text-white mb-3">{step.title}</h3>
                      <p className="text-gray-300 text-sm leading-relaxed">{step.description}</p>
                    </div>
                  </div>
                </div>
              )
            })}
          </div>
        </div>

        {/* Bottom CTA */}
        <div className="text-center mt-16">
          <div className="card-dark max-w-2xl mx-auto">
            <h3 className="text-3xl font-bold text-white mb-4">
              <span className="text-gradient-kaki">{ctaInfo.title}</span>
            </h3>
            <p className="text-gray-300 mb-6">
              {ctaInfo.description}
            </p>
            <button 
              onClick={handleReservation}
              className="btn-kaki hover:scale-105 transition-transform duration-200"
            >
              {ctaInfo.button_text}
            </button>
          </div>
        </div>
      </div>
    </section>
  )
}

export default Process
