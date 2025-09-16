import { NextRequest, NextResponse } from 'next/server';
import { getRoomById, updateRoom, deleteRoom, toggleRoomStatus } from '@/lib/database';

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    
    if (!id) {
      return NextResponse.json(
        { success: false, error: 'ID de salle invalide' },
        { status: 400 }
      );
    }

    const room = await getRoomById(id);
    
    if (!room) {
      return NextResponse.json(
        { success: false, error: 'Salle non trouvée' },
        { status: 404 }
      );
    }

    return NextResponse.json({ 
      success: true, 
      data: room 
    });
    
  } catch (error) {
    console.error('Erreur lors de la récupération de la salle:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la récupération de la salle' },
      { status: 500 }
    );
  }
}

export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    
    if (!id) {
      return NextResponse.json(
        { success: false, error: 'ID de salle invalide' },
        { status: 400 }
      );
    }

    const body = await request.json();
    
    // Validation des types pour les champs optionnels
    if (body.duration !== undefined && (typeof body.duration !== 'number' || body.duration <= 0)) {
      return NextResponse.json(
        { success: false, error: 'La durée doit être un nombre positif' },
        { status: 400 }
      );
    }

    if (body.price !== undefined && (typeof body.price !== 'number' || body.price < 0)) {
      return NextResponse.json(
        { success: false, error: 'Le prix doit être un nombre positif' },
        { status: 400 }
      );
    }

    if (body.maxPeople !== undefined && (typeof body.maxPeople !== 'number' || body.maxPeople <= 0)) {
      return NextResponse.json(
        { success: false, error: 'Le nombre maximum de personnes doit être un nombre positif' },
        { status: 400 }
      );
    }

    if (body.objectsToDestroy !== undefined && !Array.isArray(body.objectsToDestroy)) {
      return NextResponse.json(
        { success: false, error: 'objectsToDestroy doit être un tableau' },
        { status: 400 }
      );
    }

    if (body.included !== undefined && !Array.isArray(body.included)) {
      return NextResponse.json(
        { success: false, error: 'included doit être un tableau' },
        { status: 400 }
      );
    }

    const updatedRoom = await updateRoom(id, body);
    
    if (!updatedRoom) {
      return NextResponse.json(
        { success: false, error: 'Salle non trouvée' },
        { status: 404 }
      );
    }

    return NextResponse.json({ 
      success: true, 
      data: updatedRoom,
      message: 'Salle mise à jour avec succès' 
    });
    
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la salle:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la mise à jour de la salle' },
      { status: 500 }
    );
  }
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    
    if (!id) {
      return NextResponse.json(
        { success: false, error: 'ID de salle invalide' },
        { status: 400 }
      );
    }

    const success = await deleteRoom(id);
    
    if (!success) {
      return NextResponse.json(
        { success: false, error: 'Salle non trouvée' },
        { status: 404 }
      );
    }

    return NextResponse.json({ 
      success: true, 
      message: 'Salle supprimée avec succès' 
    });
    
  } catch (error) {
    console.error('Erreur lors de la suppression de la salle:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la suppression de la salle' },
      { status: 500 }
    );
  }
}

export async function PATCH(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    
    if (!id) {
      return NextResponse.json(
        { success: false, error: 'ID de salle invalide' },
        { status: 400 }
      );
    }

    const body = await request.json();
    
    // Si l'action est 'toggle', on bascule le statut
    if (body.action === 'toggle') {
      const updatedRoom = await toggleRoomStatus(id);
      
      if (!updatedRoom) {
        return NextResponse.json(
          { success: false, error: 'Salle non trouvée' },
          { status: 404 }
        );
      }

      return NextResponse.json({ 
        success: true, 
        data: updatedRoom,
        message: `Salle ${updatedRoom.is_active ? 'activée' : 'désactivée'} avec succès` 
      });
    }

    return NextResponse.json(
      { success: false, error: 'Action non reconnue' },
      { status: 400 }
    );
    
  } catch (error) {
    console.error('Erreur lors de la modification de la salle:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la modification de la salle' },
      { status: 500 }
    );
  }
}

