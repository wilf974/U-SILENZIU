import { NextRequest, NextResponse } from 'next/server'
import { getRoomByName } from '@/lib/database'

/**
 * API pour récupérer le prix d'une salle
 * GET /api/rooms/price?name=NomDeLaSalle
 */
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const roomName = searchParams.get('name')

    console.log('Récupération prix pour:', roomName)

    if (!roomName) {
      return NextResponse.json(
        { 
          success: false,
          error: 'Le paramètre name est requis' 
        },
        { status: 400 }
      )
    }

    // Récupérer les informations de la salle
    const room = await getRoomByName(roomName)
    
    if (!room) {
      return NextResponse.json(
        { 
          success: false,
          error: 'Salle non trouvée' 
        },
        { status: 404 }
      )
    }

    if (!room.is_active) {
      return NextResponse.json(
        { 
          success: false,
          error: 'Salle non disponible' 
        },
        { status: 404 }
      )
    }

    return NextResponse.json({
      success: true,
      roomName: room.name,
      price: room.price,
      duration: room.duration,
      maxPeople: room.max_people,
      description: room.description
    })

  } catch (error) {
    console.error('Erreur lors de la récupération du prix:', error)
    return NextResponse.json(
      { 
        success: false,
        error: 'Erreur lors de la récupération du prix',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}