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
    monday: { opens: string; closes: string }
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
          
          // Parser les horaires depuis la base de données
          const parseHours = (hoursStr: string) => {
            if (!hoursStr || hoursStr.includes('réservation') || hoursStr.includes('Fermé')) {
              return { opens: '00:00', closes: '00:00' }
            }
            
            // Format attendu: "16:00 – 23:00" ou "16:00-23:00"
            const match = hoursStr.match(/(\d{1,2}):(\d{2})\s*[–-]\s*(\d{1,2}):(\d{2})/)
            if (match) {
              return {
                opens: `${match[1].padStart(2, '0')}:${match[2]}`,
                closes: `${match[3].padStart(2, '0')}:${match[4]}`
              }
            }
            
            return { opens: '00:00', closes: '00:00' }
          }
          
          // Formater les informations de contact
          const formattedInfo: ContactInfo = {
            phone: config.contact_phone || '+33 7 83 83 64 53',
            email: config.contact_email || 'info@usilenziu.com',
            address: config.contact_address || '18 Rue du Pont Long, 64160 Buros',
            openingHours: {
              monday: parseHours(config.opening_hours_monday),
              tuesday: parseHours(config.opening_hours_tuesday),
              wednesday: parseHours(config.opening_hours_wednesday),
              thursday: parseHours(config.opening_hours_thursday),
              friday: parseHours(config.opening_hours_friday),
              saturday: parseHours(config.opening_hours_saturday),
              sunday: parseHours(config.opening_hours_sunday)
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
            monday: { opens: '00:00', closes: '00:00' },
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
            monday: { opens: '00:00', closes: '00:00' },
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
    
    // Formater les heures (14:00 -> 14h, 00:00 -> 00h)
    const formatTime = (time: string) => {
      if (time === '00:00') return '00h'
      return time.replace(':00', 'h')
    }
    
    // Vérifier si un jour est fermé
    const isClosed = (day: { opens: string; closes: string }) => {
      return day.opens === '00:00' && day.closes === '00:00'
    }
    
    // Grouper les jours avec les mêmes horaires
    const groups: Array<{ days: string; hours: string }> = []
    
    // Vérifier si tous les jours de la semaine (lundi-samedi) ont les mêmes horaires
    const weekdays = [openingHours.monday, openingHours.tuesday, openingHours.wednesday, openingHours.thursday, openingHours.friday, openingHours.saturday]
    const allWeekdaysSame = weekdays.every(day => 
      !isClosed(day) && 
      day.opens === weekdays[0].opens && 
      day.closes === weekdays[0].closes
    )
    
    if (allWeekdaysSame && !isClosed(openingHours.monday)) {
      // Tous les jours de la semaine ont les mêmes horaires
      groups.push({
        days: 'Lundi-Samedi',
        hours: `${formatTime(openingHours.monday.opens)}-${formatTime(openingHours.monday.closes)}`
      })
    } else {
      // Horaires différents, grouper intelligemment
      
      // Lundi (si ouvert et différent)
      if (!isClosed(openingHours.monday)) {
        groups.push({
          days: 'Lundi',
          hours: `${formatTime(openingHours.monday.opens)}-${formatTime(openingHours.monday.closes)}`
        })
      }
      
      // Mardi au Jeudi
      if (!isClosed(openingHours.tuesday) && 
          openingHours.tuesday.opens === openingHours.wednesday.opens &&
          openingHours.tuesday.closes === openingHours.wednesday.closes &&
          openingHours.tuesday.opens === openingHours.thursday.opens &&
          openingHours.tuesday.closes === openingHours.thursday.closes) {
        groups.push({
          days: 'Mardi-Jeudi',
          hours: `${formatTime(openingHours.tuesday.opens)}-${formatTime(openingHours.tuesday.closes)}`
        })
      }
      
      // Vendredi au Samedi
      if (!isClosed(openingHours.friday) && 
          openingHours.friday.opens === openingHours.saturday.opens &&
          openingHours.friday.closes === openingHours.saturday.closes) {
        groups.push({
          days: 'Vendredi-Samedi',
          hours: `${formatTime(openingHours.friday.opens)}-${formatTime(openingHours.friday.closes)}`
        })
      }
    }
    
    // Dimanche (si différent)
    if (!isClosed(openingHours.sunday)) {
      groups.push({
        days: 'Dimanche',
        hours: `${formatTime(openingHours.sunday.opens)}-${formatTime(openingHours.sunday.closes)}`
      })
    }
    
    // Si aucun groupe trouvé, afficher les horaires individuels
    if (groups.length === 0) {
      const individualHours = []
      if (!isClosed(openingHours.tuesday)) {
        individualHours.push(`Mar: ${formatTime(openingHours.tuesday.opens)}-${formatTime(openingHours.tuesday.closes)}`)
      }
      if (!isClosed(openingHours.friday)) {
        individualHours.push(`Ven: ${formatTime(openingHours.friday.opens)}-${formatTime(openingHours.friday.closes)}`)
      }
      return individualHours.join(' | ') || 'Horaires sur demande'
    }
    
    return groups.map(group => `${group.days}: ${group.hours}`).join(' | ')
  }

  return {
    contactInfo,
    loading,
    error,
    getFormattedOpeningHours
  }
}
