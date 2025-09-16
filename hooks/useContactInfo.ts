'use client'

import { useState, useEffect } from 'react'

/**
 * Interface pour les informations de contact
 */
interface ContactInfo {
  phone: string
  email: string
  address: string
  openingHours: {
    tuesday: { opens: string; closes: string }
    wednesday: { opens: string; closes: string }
    thursday: { opens: string; closes: string }
    friday: { opens: string; closes: string }
    saturday: { opens: string; closes: string }
    sunday: { opens: string; closes: string }
  }
}

/**
 * Hook personnalisé pour récupérer les informations de contact depuis l'API
 * Utilise les données de la configuration du pied de page
 */
export const useContactInfo = () => {
  const [contactInfo, setContactInfo] = useState<ContactInfo | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchContactInfo = async () => {
      try {
        setLoading(true)
        setError(null)

        const response = await fetch('/api/footer-config')
        const result = await response.json()

        if (result.success && result.data) {
          const config = result.data
          
          // Formater les informations de contact
          const formattedInfo: ContactInfo = {
            phone: config.contact_phone || '+33 7 83 83 64 53',
            email: config.contact_email || 'info@usilenziu.com',
            address: config.contact_address || '18 Rue du Pont Long, 64160 Buros',
            openingHours: {
              tuesday: { opens: '14:00', closes: '21:00' },
              wednesday: { opens: '14:00', closes: '21:00' },
              thursday: { opens: '14:00', closes: '21:00' },
              friday: { opens: '14:00', closes: '00:00' },
              saturday: { opens: '14:00', closes: '00:00' },
              sunday: { opens: '00:00', closes: '00:00' }
            }
          }

          setContactInfo(formattedInfo)
        } else {
          // Utiliser les valeurs par défaut si l'API échoue
          setContactInfo({
            phone: '+33 7 83 83 64 53',
            email: 'info@usilenziu.com',
            address: '18 Rue du Pont Long, 64160 Buros',
            openingHours: {
              tuesday: { opens: '14:00', closes: '21:00' },
              wednesday: { opens: '14:00', closes: '21:00' },
              thursday: { opens: '14:00', closes: '21:00' },
              friday: { opens: '14:00', closes: '00:00' },
              saturday: { opens: '14:00', closes: '00:00' },
              sunday: { opens: '00:00', closes: '00:00' }
            }
          })
        }
      } catch (err) {
        console.error('Erreur lors de la récupération des informations de contact:', err)
        setError('Erreur lors du chargement des informations de contact')
        
        // Utiliser les valeurs par défaut en cas d'erreur
        setContactInfo({
          phone: '+33 7 83 83 64 53',
          email: 'info@usilenziu.com',
          address: '18 Rue du Pont Long, 64160 Buros',
          openingHours: {
            tuesday: { opens: '14:00', closes: '21:00' },
            wednesday: { opens: '14:00', closes: '21:00' },
            thursday: { opens: '14:00', closes: '21:00' },
            friday: { opens: '14:00', closes: '00:00' },
            saturday: { opens: '14:00', closes: '00:00' },
            sunday: { opens: '00:00', closes: '00:00' }
          }
        })
      } finally {
        setLoading(false)
      }
    }

    fetchContactInfo()
  }, [])

  /**
   * Formate les horaires d'ouverture pour l'affichage dans le bandeau
   */
  const getFormattedOpeningHours = () => {
    if (!contactInfo) return 'Mardi-Jeudi: 14h-21h | Vendredi-Samedi: 14h-00h'
    
    const { openingHours } = contactInfo
    
    // Formater les heures (14:00 -> 14h)
    const formatTime = (time: string) => {
      if (time === '00:00') return '00h'
      return time.replace(':00', 'h')
    }
    
    // Grouper les jours avec les mêmes horaires
    const tuesdayToThursday = `${formatTime(openingHours.tuesday.opens)}-${formatTime(openingHours.tuesday.closes)}`
    const fridayToSaturday = `${formatTime(openingHours.friday.opens)}-${formatTime(openingHours.friday.closes)}`
    
    return `Mardi-Jeudi: ${tuesdayToThursday} | Vendredi-Samedi: ${fridayToSaturday}`
  }

  return {
    contactInfo,
    loading,
    error,
    getFormattedOpeningHours
  }
}
