import { NextRequest, NextResponse } from 'next/server'
import { getClient } from '@/lib/database'

/**
 * API pour récupérer les horaires d'ouverture unifiés
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
    
    // Formater les horaires pour l'affichage
    const openingHours = [
      { day: 'Lundi', hours: config.opening_hours_monday || 'Fermé' },
      { day: 'Mardi', hours: config.opening_hours_tuesday || 'Fermé' },
      { day: 'Mercredi', hours: config.opening_hours_wednesday || 'Fermé' },
      { day: 'Jeudi', hours: config.opening_hours_thursday || 'Fermé' },
      { day: 'Vendredi', hours: config.opening_hours_friday || 'Fermé' },
      { day: 'Samedi', hours: config.opening_hours_saturday || 'Fermé' },
      { day: 'Dimanche', hours: config.opening_hours_sunday || 'Fermé' }
    ]
    
    // Déterminer si on est ouvert aujourd'hui
    const today = new Date()
    const dayNames = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi']
    const todayName = dayNames[today.getDay()]
    const todayHours = openingHours.find(h => h.day === todayName)
    
    const isOpenToday = todayHours && todayHours.hours !== 'Fermé' && !todayHours.hours.includes('réservation')
    
    return NextResponse.json({
      success: true,
      data: {
        openingHours,
        isOpenToday,
        todayHours: todayHours?.hours || 'Fermé',
        todayName
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
