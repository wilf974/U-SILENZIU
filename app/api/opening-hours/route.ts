import { NextRequest, NextResponse } from 'next/server'
import { getClient } from '@/lib/database'

/**
 * API pour récupérer les horaires d'ouverture pour les réservations
 * GET - Récupère les horaires depuis la configuration du footer
 */
export async function GET(request: NextRequest) {
  try {
    const client = await getClient()
    
    // Récupérer la configuration du footer
    const result = await client.query(`
      SELECT 
        opening_hours_monday,
        opening_hours_tuesday,
        opening_hours_wednesday,
        opening_hours_thursday,
        opening_hours_friday,
        opening_hours_saturday,
        opening_hours_sunday
      FROM footer_config 
      WHERE id = 'default'
    `)
    
    client.release()
    
    if (result.rows.length === 0) {
      return NextResponse.json({
        success: false,
        error: 'Configuration du footer non trouvée'
      }, { status: 404 })
    }
    
    const config = result.rows[0]
    
    // Parser les horaires pour extraire les heures de début et fin
    const parseHours = (hoursStr: string) => {
      if (!hoursStr || hoursStr.includes('réservation') || hoursStr.includes('Fermé')) {
        return null
      }
      
      // Format attendu: "16:00 – 23:00" ou "16:00-23:00"
      const match = hoursStr.match(/(\d{1,2}):(\d{2})\s*[–-]\s*(\d{1,2}):(\d{2})/)
      if (match) {
        const startHour = parseInt(match[1])
        const startMinute = parseInt(match[2])
        const endHour = parseInt(match[3])
        const endMinute = parseInt(match[4])
        
        return {
          start: startHour * 60 + startMinute, // en minutes depuis minuit
          end: endHour * 60 + endMinute
        }
      }
      
      return null
    }
    
    // Mapper les jours de la semaine (0 = Dimanche, 1 = Lundi, etc.)
    const dayMapping = [
      'opening_hours_sunday',    // 0
      'opening_hours_monday',    // 1
      'opening_hours_tuesday',   // 2
      'opening_hours_wednesday', // 3
      'opening_hours_thursday',  // 4
      'opening_hours_friday',    // 5
      'opening_hours_saturday'   // 6
    ]
    
    // Créer un objet avec les horaires par jour
    const openingHours = {}
    dayMapping.forEach((dayKey, index) => {
      const hours = parseHours(config[dayKey])
      openingHours[index] = hours
    })
    
    // Déterminer les horaires pour aujourd'hui
    const today = new Date()
    const todayDay = today.getDay()
    const todayHours = openingHours[todayDay]
    
    return NextResponse.json({
      success: true,
      data: {
        openingHours,
        todayHours,
        todayDay,
        rawConfig: config
      },
      timestamp: new Date().toISOString()
    })
  } catch (error) {
    console.error('Erreur lors de la récupération des horaires:', error)
    return NextResponse.json(
      { 
        success: false,
        error: 'Erreur lors de la récupération des horaires',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}
