'use client'

import Link from 'next/link'
import { useState, useEffect } from 'react'
import { Phone, Mail, MapPin, Clock, Axe, Star, Target, Hammer, Palette, Dumbbell } from 'lucide-react'

interface FooterConfig {
  id?: string
  site_name: string
  site_description?: string
  site_slogan?: string
  contact_phone?: string
  contact_email?: string
  contact_address?: string
  opening_hours_monday?: string
  opening_hours_tuesday?: string
  opening_hours_wednesday?: string
  opening_hours_thursday?: string
  opening_hours_friday?: string
  opening_hours_saturday?: string
  opening_hours_sunday?: string
  cta_title?: string
  cta_subtitle?: string
  cta_button_text?: string
  cta_button_url?: string
  legal_links: any[]
  copyright_text?: string
  created_at?: string
  updated_at?: string
}

interface LegalPage {
  id: string
  page_type: 'cgv' | 'privacy' | 'legal' | 'cookies'
  title: string
  content: string
  meta_description?: string
  seo_title?: string
  keywords?: string[]
  is_published: boolean
  last_updated_by?: string
  created_at: Date
  updated_at: Date
}

const Footer = () => {
  const [config, setConfig] = useState<FooterConfig | null>(null)
  const [legalPages, setLegalPages] = useState<LegalPage[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchFooterConfig()
    fetchLegalPages()
  }, [])

  const fetchFooterConfig = async () => {
    try {
      const response = await fetch('/api/footer-config')
      const result = await response.json()
      
      if (result.success) {
        setConfig(result.data)
      }
    } catch (error) {
      console.error('Erreur lors du chargement de la configuration du pied de page:', error)
    }
  }

  const fetchLegalPages = async () => {
    try {
      const response = await fetch('/api/legal-pages')
      const result = await response.json()
      
      if (result.success) {
        setLegalPages(result.data)
      }
    } catch (error) {
      console.error('Erreur lors du chargement des pages légales:', error)
    } finally {
      setLoading(false)
    }
  }

  // Données par défaut si la configuration n'est pas chargée
  const defaultConfig: FooterConfig = {
    site_name: 'U SILENZIU',
    site_description: 'Votre zone de défoulement à Buros. Libérez votre stress et vos tensions dans un environnement sécurisé et fun.',
    site_slogan: 'Énergie positive garantie !',
    contact_phone: '+33 7 83 83 64 53',
    contact_email: 'info@usilenziu.com',
    contact_address: '18 Rue du Pont Long, 64160 Buros, Zone Berlanne',
    opening_hours_tuesday: '14:00 – 21:00',
    opening_hours_wednesday: '14:00 – 21:00',
    opening_hours_thursday: '14:00 – 21:00',
    opening_hours_friday: '14:00 – 00:00',
    opening_hours_saturday: '14:00 – 00:00',
    opening_hours_sunday: 'Sur réservation uniquement, Minimum 5 personnes',
    cta_title: 'Prêt à libérer votre stress ?',
    cta_button_text: 'Réserver maintenant',
    cta_button_url: '/reservation',
    legal_links: [],
    copyright_text: '© 2024 U Silenziu. Tous droits réservés.'
  }

  // Utiliser la configuration chargée ou les valeurs par défaut
  const footerConfig = config || defaultConfig

  const activities = [
    { name: 'Salle Douce', icon: Hammer },
    { name: 'Salle Carnage', icon: Axe },
    { name: 'Salle Privatisée', icon: Star }
  ]

  // Fonction pour formater les horaires
  const formatOpeningHours = () => {
    const hours = [
      { day: 'Mardi au Jeudi', hours: footerConfig.opening_hours_tuesday },
      { day: 'Vendredi au Samedi', hours: footerConfig.opening_hours_friday },
      { day: 'Dimanche', hours: footerConfig.opening_hours_sunday }
    ]
    return hours.filter(h => h.hours)
  }

  // Fonction pour mapper les types de pages légales vers des labels français
  const getLegalPageLabel = (pageType: string) => {
    const labels: { [key: string]: string } = {
      'cgv': 'CGV',
      'privacy': 'Politique de confidentialité',
      'legal': 'Mentions légales',
      'cookies': 'Paramètres des cookies'
    }
    return labels[pageType] || pageType
  }

  return (
    <footer className="bg-dark-surface border-t border-kaki-800/30">
      <div className="section-container py-16">
        <div className="grid md:grid-cols-2 lg:grid-cols-5 gap-8">
          {/* Logo and description */}
          <div className="lg:col-span-1">
            <div className="flex items-center space-x-3 mb-6">
              <div className="w-12 h-12 bg-gradient-to-br from-kaki-500 to-kaki-700 rounded-xl flex items-center justify-center">
                <span className="text-white font-bold text-2xl">U</span>
              </div>
              <span className="text-2xl font-bold text-gradient-kaki">{footerConfig.site_name}</span>
            </div>
            <p className="text-gray-300 mb-6 leading-relaxed">
              {footerConfig.site_description}
            </p>
            {footerConfig.site_slogan && (
              <div className="text-kaki-400 font-semibold">
                {footerConfig.site_slogan}
              </div>
            )}
          </div>

          {/* Salles */}
          <div>
            <h3 className="text-xl font-bold text-white mb-6">Nos Salles</h3>
            <ul className="space-y-3">
              {activities.map((activity, index) => {
                const IconComponent = activity.icon
                return (
                  <li key={index}>
                    <Link href="/rooms" className="flex items-center space-x-3 text-gray-300 hover:text-kaki-400 transition-colors">
                      <IconComponent size={16} />
                      <span>{activity.name}</span>
                    </Link>
                  </li>
                )
              })}
            </ul>
          </div>

          {/* Contact rapide */}
          <div>
            <h3 className="text-xl font-bold text-white mb-6">Contact</h3>
            <div className="space-y-4">
              {footerConfig.contact_phone && (
                <a href={`tel:${footerConfig.contact_phone.replace(/\s/g, '')}`} className="flex items-center space-x-3 text-gray-300 hover:text-kaki-400 transition-colors">
                  <Phone size={16} />
                  <span>{footerConfig.contact_phone}</span>
                </a>
              )}
              {footerConfig.contact_email && (
                <a href={`mailto:${footerConfig.contact_email}`} className="flex items-center space-x-3 text-gray-300 hover:text-kaki-400 transition-colors">
                  <Mail size={16} />
                  <span>{footerConfig.contact_email}</span>
                </a>
              )}
              {footerConfig.contact_address && (
                <a 
                  href={`https://maps.google.com/?q=${encodeURIComponent(footerConfig.contact_address)}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-start space-x-3 text-gray-300 hover:text-kaki-400 transition-colors"
                >
                  <MapPin size={16} className="mt-0.5 flex-shrink-0" />
                  <span>{footerConfig.contact_address.split(',').map((line, index) => (
                    <span key={index}>
                      {line.trim()}
                      {index < footerConfig.contact_address!.split(',').length - 1 && <br />}
                    </span>
                  ))}</span>
                </a>
              )}
            </div>
          </div>

          {/* Horaires */}
          <div>
            <h3 className="text-xl font-bold text-white mb-6 flex items-center">
              <Clock className="mr-2" size={20} />
              Horaires
            </h3>
            <div className="space-y-3">
              {formatOpeningHours().map((schedule, index) => (
                <div key={index}>
                  <div className="text-white font-medium">{schedule.day}</div>
                  <div className="text-kaki-400">{schedule.hours}</div>
                </div>
              ))}
            </div>
          </div>

          {/* Liens légaux */}
          {legalPages.length > 0 && (
            <div>
              <h3 className="text-xl font-bold text-white mb-6">Informations légales</h3>
              <ul className="space-y-3">
                {legalPages.map((page) => (
                  <li key={page.id}>
                    <Link 
                      href={`/legal/${page.page_type}`}
                      className="text-gray-300 hover:text-kaki-400 transition-colors"
                    >
                      {getLegalPageLabel(page.page_type)}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>

        {/* Call to action */}
        {footerConfig.cta_title && (
          <div className="mt-12 pt-8 border-t border-kaki-800/30">
            <div className="text-center">
              <h3 className="text-2xl font-bold text-white mb-4">
                {footerConfig.cta_title.includes('stress') ? (
                  <>
                    {footerConfig.cta_title.split('stress')[0]}
                    <span className="text-gradient-kaki">stress</span>
                    {footerConfig.cta_title.split('stress')[1]}
                  </>
                ) : (
                  footerConfig.cta_title
                )}
              </h3>
              {footerConfig.cta_button_text && footerConfig.cta_button_url && (
                <Link 
                  href={footerConfig.cta_button_url}
                  className="btn-kaki"
                >
                  {footerConfig.cta_button_text}
                </Link>
              )}
            </div>
          </div>
        )}

        {/* Bottom bar */}
        <div className="mt-12 pt-8 border-t border-kaki-800/30 flex justify-center items-center">
          <div className="text-gray-400 text-sm">
            {footerConfig.copyright_text || '© 2024 U Silenziu. Tous droits réservés.'}
          </div>
        </div>
      </div>
    </footer>
  )
}

export default Footer
