'use client'

import { Phone, Mail, MapPin, Clock } from 'lucide-react'
import { useHomepageSections } from '@/lib/hooks/useHomepageSections'

/**
 * Affiche la section "Contact" uniquement si la section homepage 'contact' est active.
 */
const Contact = () => {
  const { getSectionByKey, getSectionContent, loading } = useHomepageSections()
  const section = getSectionByKey('contact')
  const content = getSectionContent('contact')

  if (loading) return null
  if (!section) return null

  // Récupérer les informations de contact depuis la base de données ou utiliser les données par défaut
  const contactInfo = content?.contact_info || [
    {
      icon: 'Phone',
      title: 'Téléphone',
      details: '+33 7 83 83 64 53',
      link: 'tel:+33783836453'
    },
    {
      icon: 'Mail',
      title: 'Email',
      details: 'info@usilenziu.com',
      link: 'mailto:info@usilenziu.com'
    },
    {
      icon: 'MapPin',
      title: 'Adresse',
      details: '18 Rue du Pont Long\n64160 Buros\nZone Berlanne',
      link: 'https://maps.google.com/?q=18+Rue+du+Pont+Long+64160+Buros'
    }
  ]

  // Récupérer les horaires depuis la base de données ou utiliser les données par défaut
  const horaires = content?.horaires || [
    {
      jours: 'Mardi au Jeudi',
      heures: '14:00 – 21:00'
    },
    {
      jours: 'Vendredi au Samedi',
      heures: '14:00 – 00:00'
    },
    {
      jours: 'Dimanche',
      heures: 'Sur réservation uniquement',
      note: 'Minimum 5 personnes - Merci de nous appeler'
    }
  ]


  // Fonction pour obtenir le composant d'icône
  const getIconComponent = (iconName: string) => {
    switch (iconName) {
      case 'Phone': return Phone
      case 'Mail': return Mail
      case 'MapPin': return MapPin
      case 'Clock': return Clock
      default: return Phone
    }
  }

  return (
    <section id="contact" className="py-20 bg-dark-bg">
      <div className="section-container">
        <div className="text-center mb-16">
          <h2 className="text-4xl lg:text-5xl font-bold text-white mb-6">
            {section.title ? (
              section.title.includes('Contacter') ? (
                <span dangerouslySetInnerHTML={{
                  __html: section.title.replace('Contacter', '<span class="text-gradient-kaki">Contacter</span>')
                }} />
              ) : section.title
            ) : (
              <>Nous <span className="text-gradient-kaki">Contacter</span></>
            )}
          </h2>
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            {section.subtitle || 'Prêt à réserver votre session de défoulement ? Notre équipe est là pour vous accompagner.'}
          </p>
        </div>

        {/* Contact Information */}
        <div className="max-w-4xl mx-auto space-y-8">
          <div>
            <h3 className="text-2xl font-bold text-white mb-6 flex items-center">
              <Phone className="text-kaki-500 mr-3" size={28} />
              Informations de contact
            </h3>
            <div className="space-y-6">
              {contactInfo.map((info: any, index: number) => {
                const IconComponent = getIconComponent(info.icon)
                return (
                  <div key={index} className="card-dark hover:border-kaki-600/50 transition-all duration-300">
                    <div className="flex items-start space-x-4">
                      <div className="w-12 h-12 bg-gradient-to-br from-kaki-500 to-kaki-700 rounded-lg flex items-center justify-center flex-shrink-0">
                        <IconComponent className="text-white" size={24} />
                      </div>
                      <div>
                        <h4 className="text-white font-semibold mb-2">{info.title}</h4>
                        {info.link ? (
                          <a 
                            href={info.link}
                            className="text-kaki-400 hover:text-kaki-300 transition-colors whitespace-pre-line"
                            target={info.link.startsWith('http') ? '_blank' : undefined}
                            rel={info.link.startsWith('http') ? 'noopener noreferrer' : undefined}
                          >
                            {info.details}
                          </a>
                        ) : (
                          <p className="text-gray-300 whitespace-pre-line">{info.details}</p>
                        )}
                      </div>
                    </div>
                  </div>
                )
              })}
            </div>
          </div>

          {/* Horaires */}
          <div>
            <h3 className="text-2xl font-bold text-white mb-6 flex items-center">
              <Clock className="text-kaki-500 mr-3" size={28} />
              Horaires d'ouverture
            </h3>
            <div className="card-dark">
              {horaires.map((horaire: any, index: number) => (
                <div key={index} className={`flex justify-between items-start ${index !== horaires.length - 1 ? 'mb-4 pb-4 border-b border-kaki-800/30' : ''}`}>
                  <div>
                    <h4 className="text-white font-semibold">{horaire.jours}</h4>
                    {horaire.note && (
                      <p className="text-xs text-gray-400 mt-1">{horaire.note}</p>
                    )}
                  </div>
                  <div className="text-kaki-400 font-medium text-right">
                    {horaire.heures}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </section>
  )
}

export default Contact
