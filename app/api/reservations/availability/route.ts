import { NextRequest, NextResponse } from 'next/server'
import { getReservationsByDateRange } from '@/lib/database'

/**
 * API pour récupérer les disponibilités réelles basées sur les réservations existantes
 * GET /api/reservations/availability?startDate=YYYY-MM-DD&endDate=YYYY-MM-DD&roomName=nom_salle
 */
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const startDate = searchParams.get('startDate')
    const endDate = searchParams.get('endDate')
    const roomName = searchParams.get('roomName')

    if (!startDate || !endDate) {
      return NextResponse.json(
        { error: 'Les paramètres startDate et endDate sont requis' },
        { status: 400 }
      )
    }

    // Récupérer les réservations dans la plage de dates
    const reservations = await getReservationsByDateRange(startDate, endDate, roomName || undefined)

    // Organiser les réservations par date et heure
    const availabilityData: { [key: string]: { [key: string]: number } } = {}

    reservations.forEach(reservation => {
      // Convertir la date au format ISO (YYYY-MM-DD)
      const date = new Date(reservation.date).toISOString().split('T')[0]
      const time = reservation.time
      
      if (!availabilityData[date]) {
        availabilityData[date] = {}
      }
      
      if (!availabilityData[date][time]) {
        availabilityData[date][time] = 0
      }
      
      availabilityData[date][time] += reservation.number_of_people
    })

    return NextResponse.json({
      success: true,
      data: availabilityData,
      totalReservations: reservations.length
    })

  } catch (error) {
    console.error('Erreur lors de la récupération des disponibilités:', error)
    return NextResponse.json(
      { error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}
