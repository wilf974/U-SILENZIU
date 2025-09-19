'use client'

import { Target, Users, Recycle, Music } from 'lucide-react'
import { useHomepageSections } from '@/lib/hooks/useHomepageSections'

const Concept = () => {
  const { getSectionByKey, getSectionContent, loading } = useHomepageSections()
  const conceptSection = getSectionByKey('concept')
  const conceptContent = getSectionContent('concept')

  // Ne pas afficher si chargement ou si la section est inactive/absente
  if (loading) return null
  if (!conceptSection) return null

  // Données par défaut si certains sous-champs manquent
  const rawTitle = (conceptSection as any)?.title
  const rawSubtitle = (conceptSection as any)?.subtitle
  const title = typeof rawTitle === 'string' && rawTitle.trim().length > 0
    ? rawTitle
    : 'Le Concept'
  const subtitle = typeof rawSubtitle === 'string' && rawSubtitle.trim().length > 0
    ? rawSubtitle
    : "U Silenziu vous offre une expérience unique pour libérer votre stress et vos émotions négatives. Nous mettons à votre disposition un environnement sûr et contrôlé pour évacuer vos tensions."
  const features = conceptContent?.features || [
    { icon: 'Target', title: 'Environnement Sécurisé', description: "Un espace contrôlé où vous pouvez casser et briser des objets en toute sécurité, sans avoir à nettoyer après." },
    { icon: 'Users', title: 'Pour Tous', description: "Que vous ayez passé une mauvaise journée ou envie de vous défouler entre amis, notre espace est fait pour vous." },
    { icon: 'Recycle', title: 'Éco-Responsable', description: 'Tous les objets cassés sont collectés et recyclés par des sociétés spécialisées.' },
    { icon: 'Music', title: 'Ambiance Personnalisée', description: 'Connectez votre musique en Bluetooth et défoulez-vous sur vos morceaux préférés.' }
  ]
  const additionalInfo = conceptContent?.additional_info || {
    title: "C'est quoi une salle de défoulement ?",
    content: "Une salle de défoulement est exactement ce que son nom indique : un endroit où l'on peut se défouler en toute liberté. Non seulement c'est une excellente thérapie pour soulager le stress, mais c'est aussi une expérience extrêmement amusante ! Que vous ayez eu des tensions au travail, avec votre partenaire ou simplement envie de vous amuser entre amis ou collègues, U Silenziu est l'endroit idéal pour ça !"
  }

  const getIconComponent = (iconName: string) => {
    switch (iconName) {
      case 'Target': return Target
      case 'Users': return Users
      case 'Recycle': return Recycle
      case 'Music': return Music
      default: return Target
    }
  }

  return (
    <section id="concept" className="py-20 bg-dark-surface">
      <div className="section-container">
        <div className="text-center mb-16">
          <h2 className="text-4xl lg:text-5xl font-bold text-white mb-6">
            {title.split(' ').slice(0, -1).join(' ')} <span className="text-gradient-kaki">{title.split(' ').slice(-1)[0]}</span>
          </h2>
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            {subtitle}
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
          {features.map((feature: any, index: number) => {
            const IconComponent = getIconComponent(feature.icon)
            return (
              <div key={index} className="card-dark text-center hover:border-kaki-600/50 transition-all duration-300">
                <div className="w-16 h-16 bg-gradient-to-br from-kaki-500 to-kaki-700 rounded-xl flex items-center justify-center mx-auto mb-6">
                  <IconComponent className="text-white" size={32} />
                </div>
                <h3 className="text-xl font-bold text-white mb-4">{feature.title}</h3>
                <p className="text-gray-300 leading-relaxed">{feature.description}</p>
              </div>
            )
          })}
        </div>

        {/* Additional info */}
        <div className="mt-16 text-center">
          <div className="card-dark max-w-4xl mx-auto">
            <h3 className="text-2xl font-bold text-white mb-4">
              {additionalInfo.title}
            </h3>
            <p className="text-gray-300 text-lg leading-relaxed">
              {additionalInfo.content}
            </p>
          </div>
        </div>
      </div>
    </section>
  )
}

export default Concept
