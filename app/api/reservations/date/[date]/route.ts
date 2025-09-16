import { NextRequest, NextResponse } from 'next/server'
import { getReservationsByDate } from '@/lib/database'

// GET - Récupérer les réservations pour une date spécifique
export async function GET(
  request: NextRequest,
  { params }: { params: { date: string } }
) {
  try {
    // Validation du format de date (YYYY-MM-DD)
    const dateRegex = /^\d{4}-\d{2}-\d{2}$/
    if (!dateRegex.test(params.date)) {
      return NextResponse.json(
        { error: 'Format de date invalide. Utilisez YYYY-MM-DD' },
        { status: 400 }
      )
    }
    
    const reservations = await getReservationsByDate(params.date)
    return NextResponse.json(reservations)
  } catch (error) {
    console.error('Erreur lors de la récupération des réservations par date:', error)
    return NextResponse.json(
      { error: 'Erreur lors de la récupération des réservations' },
      { status: 500 }
    )
  }
}
