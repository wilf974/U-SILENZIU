'use client'

import React from 'react'
import { Clock, Shield, AlertTriangle, Music, RefreshCw, CheckCircle } from 'lucide-react'

/**
 * Composant "Comment fonctionne une séance ?"
 * U Silenziu - Septembre 2025
 */
export default function CommentCaMarche() {
  const steps = [
    {
      icon: CheckCircle,
      number: "1",
      time: "5 min",
      title: "Accueil des participants",
      description: "Nos équipes vous accueillent et vérifient vos réservations"
    },
    {
      icon: Shield,
      number: "2", 
      time: "10 min",
      title: "Zone d'équipement",
      description: "Équipement complet de sécurité de la tête aux pieds"
    },
    {
      icon: AlertTriangle,
      number: "3",
      time: "5 min", 
      title: "Consignes de sécurité",
      description: "Briefing sécurité et petit échauffement avant la session"
    },
    {
      icon: Music,
      number: "4",
      time: "20-30 min",
      title: "Session de défoulement", 
      description: "La musique commence et la salle est à vous !"
    },
    {
      icon: RefreshCw,
      number: "5",
      time: "10 min",
      title: "Retrait de l'équipement",
      description: "Déséquipement et retour au calme"
    }
  ]

  return (
    <section id="comment-ca-marche" className="section-container py-20" style={{ backgroundColor: '#0a0a0a' }}>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-16">
          <h2 className="text-4xl font-bold mb-4">
            <span className="text-white">Comment fonctionne une </span>
            <span className="text-gradient-kaki">séance ?</span>
          </h2>
          <p className="text-gray-400 max-w-3xl mx-auto">
            Découvrez le déroulement type d'une session chez U Silenziu. Chaque étape est pensée pour votre sécurité et votre plaisir.
          </p>
        </div>

        {/* Timeline */}
        <div className="relative">
          {/* Ligne de connexion */}
          <div className="absolute top-8 left-0 right-0 h-0.5 bg-kaki-600/30 hidden lg:block"></div>
          
          {/* Étapes */}
          <div className="grid gap-8 lg:grid-cols-5">
            {steps.map((step, index) => {
              const IconComponent = step.icon
              return (
                <div key={index} className="relative">
                  {/* Icône et numéro */}
                  <div className="flex flex-col items-center mb-6">
                    <div className="relative z-10 w-16 h-16 bg-kaki-600 rounded-full flex items-center justify-center mb-2">
                      <IconComponent className="w-8 h-8 text-white" />
                    </div>
                    <div className="text-2xl font-bold text-kaki-400">{step.number}</div>
                  </div>

                  {/* Carte de l'étape */}
                  <div className="bg-gray-800 rounded-lg p-6 border border-kaki-800/30 hover:border-kaki-600/50 transition-all duration-300">
                    {/* Temps */}
                    <div className="flex justify-end mb-4">
                      <span className="bg-kaki-600 text-white px-3 py-1 rounded-full text-sm font-medium">
                        {step.time}
                      </span>
                    </div>

                    {/* Titre */}
                    <h3 className="text-xl font-bold text-white mb-3">
                      {step.title}
                    </h3>

                    {/* Description */}
                    <p className="text-gray-300 text-sm leading-relaxed">
                      {step.description}
                    </p>
                  </div>
                </div>
              )
            })}
          </div>
        </div>

        {/* Call to action */}
        <div className="text-center mt-16">
          <p className="text-gray-400 mb-6">
            Prêt à vivre l'expérience U Silenziu ?
          </p>
          <a 
            href="/reservation"
            className="btn-kaki inline-flex items-center gap-2"
          >
            <span>Réserver maintenant</span>
            <Clock className="w-4 h-4" />
          </a>
        </div>
      </div>
    </section>
  )
}
