'use client'

import { Axe, Star, Target, Hammer, Palette, Dumbbell } from 'lucide-react'

const Activities = () => {
  const scrollToFormules = () => {
    const formulesSection = document.getElementById('formules')
    if (formulesSection) {
      formulesSection.scrollIntoView({ behavior: 'smooth' })
    }
  }

  const activities = [
    {
      icon: Axe,
      title: 'Lancer de haches',
      description: 'Perfectionnez votre précision avec nos haches spécialement conçues pour la sécurité.',
      color: 'from-kaki-500 to-kaki-700'
    },
    {
      icon: Star,
      title: 'Lancer de shurikens',
      description: 'Découvrez l\'art du lancer de shurikens dans un environnement sécurisé.',
      color: 'from-kaki-600 to-kaki-800'
    },
    {
      icon: Target,
      title: 'Lancer de fléchettes',
      description: 'Jeu traditionnel revisité avec nos cibles professionnelles.',
      color: 'from-kaki-400 to-kaki-600'
    },
    {
      icon: Hammer,
      title: 'Défoulement',
      description: 'Cassez et détruisez des objets en toute sécurité pour évacuer votre stress.',
      color: 'from-kaki-700 to-kaki-900'
    },
    {
      icon: Palette,
      title: 'Color Zone',
      description: 'Exprimez votre créativité dans notre espace dédié aux couleurs.',
      color: 'from-kaki-500 to-kaki-700'
    },
    {
      icon: Dumbbell,
      title: 'Bras de fer',
      description: 'Testez votre force dans nos competitions amicales de bras de fer.',
      color: 'from-kaki-600 to-kaki-800'
    }
  ]

  return (
    <section id="activities" className="py-20 bg-dark-bg">
      <div className="section-container">
        <div className="text-center mb-16">
          <h2 className="text-4xl lg:text-5xl font-bold text-white mb-6">
            Nos <span className="text-gradient-kaki">Activités</span>
          </h2>
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            Découvrez notre gamme complète d'activités conçues pour vous divertir et vous défouler. 
            Chaque activité est encadrée par nos professionnels pour garantir votre sécurité.
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {activities.map((activity, index) => {
            const IconComponent = activity.icon
            return (
              <div key={index} className="group card-dark hover:border-kaki-600/50 transition-all duration-300 hover:scale-105">
                <div className={`w-20 h-20 bg-gradient-to-br ${activity.color} rounded-2xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform duration-300`}>
                  <IconComponent className="text-white" size={36} />
                </div>
                <h3 className="text-2xl font-bold text-white mb-4">{activity.title}</h3>
                <p className="text-gray-300 leading-relaxed mb-6">{activity.description}</p>
                <button 
                  onClick={scrollToFormules}
                  className="btn-kaki-outline w-full"
                >
                  En savoir plus
                </button>
              </div>
            )
          })}
        </div>

        {/* Call to action */}
        <div className="text-center mt-16">
          <div className="card-dark max-w-2xl mx-auto">
            <h3 className="text-3xl font-bold text-white mb-4">
              Prêt à vous <span className="text-gradient-kaki">défouler</span> ?
            </h3>
            <p className="text-gray-300 mb-6">
              Choisissez votre activité favorite ou découvrez-les toutes avec nos salles combinées.
            </p>
            <button 
              onClick={scrollToFormules}
              className="btn-kaki"
            >
              Découvrir nos salles
            </button>
          </div>
        </div>
      </div>
    </section>
  )
}

export default Activities
