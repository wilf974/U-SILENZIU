import { NextRequest, NextResponse } from 'next/server'
import { getRoomById, updateRoom, deleteRoom } from '@/lib/database'

// GET - Récupérer une salle spécifique
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params
    
    if (!id) {
      return NextResponse.json(
        { success: false, message: 'ID invalide' },
        { status: 400 }
      )
    }

    const room = await getRoomById(id)
    if (!room) {
      return NextResponse.json(
        { success: false, message: 'Salle non trouvée' },
        { status: 404 }
      )
    }

    return NextResponse.json({
      success: true,
      data: room,
      message: 'Salle récupérée avec succès'
    })
  } catch (error) {
    console.error('❌ Erreur lors de la récupération de la salle:', error)
    return NextResponse.json(
      { success: false, message: 'Erreur serveur' },
      { status: 500 }
    )
  }
}

// PUT - Mettre à jour une salle
export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params
    
    if (!id) {
      return NextResponse.json(
        { success: false, message: 'ID invalide' },
        { status: 400 }
      )
    }

    const body = await request.json()
    
    // Validation basique
    if (!body.name || !body.description) {
      return NextResponse.json(
        { success: false, message: 'Nom et description requis' },
        { status: 400 }
      )
    }

    const updatedRoom = await updateRoom(id, body)
    if (!updatedRoom) {
      return NextResponse.json(
        { success: false, message: 'Salle non trouvée' },
        { status: 404 }
      )
    }

    return NextResponse.json({
      success: true,
      data: updatedRoom,
      message: 'Salle mise à jour avec succès'
    })
  } catch (error) {
    console.error('❌ Erreur lors de la mise à jour de la salle:', error)
    return NextResponse.json(
      { success: false, message: 'Erreur serveur' },
      { status: 500 }
    )
  }
}

// DELETE - Supprimer une salle (désactivation)
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params
    
    if (!id) {
      return NextResponse.json(
        { success: false, message: 'ID invalide' },
        { status: 400 }
      )
    }

    const deletedRoom = await deleteRoom(id)
    if (!deletedRoom) {
      return NextResponse.json(
        { success: false, message: 'Salle non trouvée' },
        { status: 404 }
      )
    }

    return NextResponse.json({
      success: true,
      data: deletedRoom,
      message: 'Salle désactivée avec succès'
    })
  } catch (error) {
    console.error('❌ Erreur lors de la suppression de la salle:', error)
    return NextResponse.json(
      { success: false, message: 'Erreur serveur' },
      { status: 500 }
    )
  }
}
