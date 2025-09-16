import { NextRequest, NextResponse } from 'next/server'
import { 
  getReservationByNumber, 
  updateReservationStatus, 
  deleteReservation 
} from '@/lib/database'

// GET - Récupérer une réservation par numéro
export async function GET(
  request: NextRequest,
  { params }: { params: { number: string } }
) {
  try {
    const reservation = await getReservationByNumber(params.number)
    
    if (!reservation) {
      return NextResponse.json(
        { error: 'Réservation non trouvée' },
        { status: 404 }
      )
    }
    
    return NextResponse.json(reservation)
  } catch (error) {
    console.error('Erreur lors de la récupération de la réservation:', error)
    return NextResponse.json(
      { error: 'Erreur lors de la récupération de la réservation' },
      { status: 500 }
    )
  }
}

// PUT - Mettre à jour le statut d'une réservation
export async function PUT(
  request: NextRequest,
  { params }: { params: { number: string } }
) {
  try {
    const body = await request.json()
    
    if (!body.status || !['pending', 'confirmed', 'cancelled'].includes(body.status)) {
      return NextResponse.json(
        { error: 'Statut invalide. Doit être pending, confirmed ou cancelled' },
        { status: 400 }
      )
    }
    
    const success = await updateReservationStatus(params.number, body.status)
    
    if (!success) {
      return NextResponse.json(
        { error: 'Réservation non trouvée' },
        { status: 404 }
      )
    }
    
    // Récupérer la réservation mise à jour
    const reservation = await getReservationByNumber(params.number)
    return NextResponse.json(reservation)
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la réservation:', error)
    return NextResponse.json(
      { error: 'Erreur lors de la mise à jour de la réservation' },
      { status: 500 }
    )
  }
}

// DELETE - Supprimer une réservation
export async function DELETE(
  request: NextRequest,
  { params }: { params: { number: string } }
) {
  try {
    const success = await deleteReservation(params.number)
    
    if (!success) {
      return NextResponse.json(
        { error: 'Réservation non trouvée' },
        { status: 404 }
      )
    }
    
    return NextResponse.json(
      { message: 'Réservation supprimée avec succès' },
      { status: 200 }
    )
  } catch (error) {
    console.error('Erreur lors de la suppression de la réservation:', error)
    return NextResponse.json(
      { error: 'Erreur lors de la suppression de la réservation' },
      { status: 500 }
    )
  }
}
