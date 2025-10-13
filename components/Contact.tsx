'use client'

import { Phone, Mail, MapPin, Clock } from 'lucide-react'
import { useContactInfo } from '@/hooks/useContactInfo'

/**
 * Composant de contact utilisant les données dynamiques de la base de données
 */
const Contact = () => {
  const { contactInfo, loading, error } = useContactInfo()

  if (loading) {
    return (
      <section id="contact" className="py-20 bg-dark-bg">
        <div className="section-container">
          <div className="text-center">
            <div className="animate-pulse">
              <div className="h-12 bg-gray-700 rounded-lg mb-6 mx-auto max-w-md"></div>
              <div className="h-6 bg-gray-700 rounded-lg mb-16 mx-auto max-w-2xl"></div>
            </div>
          </div>
        </div>
      </section>
    )
  }

  if (error) {
    console.error('Erreur lors du chargement des informations de contact:', error)
  }

  // Convertir les informations de contact en tableau pour le rendu
  const contactInfoArray = [
    {
      icon: 'Phone',
      title: 'Téléphone',
      details: contactInfo?.phone || '+33 7 83 83 64 53',
      link: `tel:${(contactInfo?.phone || '+33783836453').replace(/\s/g, '')}`
    },
    {
      icon: 'Mail',
      title: 'Email',
      details: contactInfo?.email || 'info@usilenziu.com',
      link: `mailto:${contactInfo?.email || 'info@usilenziu.com'}`
    },
    {
      icon: 'MapPin',
      title: 'Adresse',
      details: contactInfo?.address || '18 Rue du Pont Long, 64160 Buros',
      link: `https://maps.google.com/?q=${encodeURIComponent(contactInfo?.address || '18 Rue du Pont Long, 64160 Buros')}`
    }
  ]

  // Formater les horaires pour l'affichage
  const formatOpeningHours = () => {
    if (!contactInfo?.openingHours) {
      return [
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
    }

    const { openingHours } = contactInfo
    const groups: Array<{ jours: string; heures: string; note?: string }> = []
    
    // Vérifier si tous les jours de la semaine (lundi-samedi) ont les mêmes horaires
    const weekdays = [openingHours.monday, openingHours.tuesday, openingHours.wednesday, openingHours.thursday, openingHours.friday, openingHours.saturday]
    const allWeekdaysSame = weekdays.every(day => 
      day.opens !== '00:00' && 
      day.opens === weekdays[0].opens && 
      day.closes === weekdays[0].closes
    )
    
    if (allWeekdaysSame && openingHours.monday.opens !== '00:00') {
      // Tous les jours de la semaine ont les mêmes horaires
      groups.push({
        jours: 'Lundi au Samedi',
        heures: `${openingHours.monday.opens.replace(':00', 'h')} – ${openingHours.monday.closes.replace(':00', 'h')}`
      })
    } else {
      // Horaires différents, grouper intelligemment
      
      // Lundi (si ouvert et différent)
      if (openingHours.monday.opens !== '00:00') {
        groups.push({
          jours: 'Lundi',
          heures: `${openingHours.monday.opens.replace(':00', 'h')} – ${openingHours.monday.closes.replace(':00', 'h')}`
        })
      }
      
      // Mardi au Jeudi
      if (openingHours.tuesday.opens !== '00:00' && 
          openingHours.tuesday.opens === openingHours.wednesday.opens &&
          openingHours.tuesday.closes === openingHours.wednesday.closes &&
          openingHours.tuesday.opens === openingHours.thursday.opens &&
          openingHours.tuesday.closes === openingHours.thursday.closes) {
        groups.push({
          jours: 'Mardi au Jeudi',
          heures: `${openingHours.tuesday.opens.replace(':00', 'h')} – ${openingHours.tuesday.closes.replace(':00', 'h')}`
        })
      }
      
      // Vendredi au Samedi
      if (openingHours.friday.opens !== '00:00' && 
          openingHours.friday.opens === openingHours.saturday.opens &&
          openingHours.friday.closes === openingHours.saturday.closes) {
        groups.push({
          jours: 'Vendredi au Samedi',
          heures: `${openingHours.friday.opens.replace(':00', 'h')} – ${openingHours.friday.closes.replace(':00', 'h')}`
        })
      }
    }
    
    // Dimanche (si différent)
    if (openingHours.sunday.opens !== '00:00') {
      groups.push({
        jours: 'Dimanche',
        heures: 'Sur réservation uniquement',
        note: 'Minimum 5 personnes - Merci de nous appeler'
      })
    }
    
    return groups
  }

  const horaires = formatOpeningHours()


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
            Nous <span className="text-gradient-kaki">Contacter</span>
          </h2>
          <p className="text-xl text-gray-300 max-w-3xl mx-auto">
            Prêt à réserver votre session de défoulement ? Notre équipe est là pour vous accompagner.
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
              {contactInfoArray.map((info: any, index: number) => {
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
