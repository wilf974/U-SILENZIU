import { NextRequest, NextResponse } from 'next/server'
import { getRoomByName } from '@/lib/database'

/**
 * API route pour récupérer le prix d'une salle par son nom
 * GET /api/rooms/price?name=nom_de_la_salle
 */
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const roomName = searchParams.get('name')

    if (!roomName) {
      return NextResponse.json(
        { error: 'Le nom de la salle est requis' },
        { status: 400 }
      )
    }

    // Récupérer la salle par son nom
    const room = await getRoomByName(roomName)

    if (!room) {
      return NextResponse.json(
        { error: 'Salle non trouvée' },
        { status: 404 }
      )
    }

    // Retourner le prix de la salle
    return NextResponse.json({
      name: room.name,
      price: room.price,
      duration: room.duration,
      max_people: room.max_people
    })

  } catch (error) {
    console.error('Erreur lors de la récupération du prix de la salle:', error)
    return NextResponse.json(
      { error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}
