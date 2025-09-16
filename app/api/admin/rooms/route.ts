import { NextRequest, NextResponse } from 'next/server';
import { getAllRoomsForAdmin, createRoom } from '@/lib/database';

export async function GET() {
  try {
    const rooms = await getAllRoomsForAdmin();
    return NextResponse.json({ 
      success: true, 
      data: rooms,
      count: rooms.length 
    });
  } catch (error) {
    console.error('Erreur lors de la récupération des salles:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la récupération des salles' },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    
    // Validation des champs requis
    const requiredFields = ['name', 'subtitle', 'duration', 'price', 'description', 'maxPeople', 'objectsToDestroy', 'included'];
    for (const field of requiredFields) {
      if (!body[field]) {
        return NextResponse.json(
          { success: false, error: `Le champ ${field} est requis` },
          { status: 400 }
        );
      }
    }

    // Validation des types
    if (typeof body.duration !== 'number' || body.duration <= 0) {
      return NextResponse.json(
        { success: false, error: 'La durée doit être un nombre positif' },
        { status: 400 }
      );
    }

    if (typeof body.price !== 'number' || body.price < 0) {
      return NextResponse.json(
        { success: false, error: 'Le prix doit être un nombre positif' },
        { status: 400 }
      );
    }

    if (typeof body.maxPeople !== 'number' || body.maxPeople <= 0) {
      return NextResponse.json(
        { success: false, error: 'Le nombre maximum de personnes doit être un nombre positif' },
        { status: 400 }
      );
    }

    if (!Array.isArray(body.objectsToDestroy)) {
      return NextResponse.json(
        { success: false, error: 'objectsToDestroy doit être un tableau' },
        { status: 400 }
      );
    }

    if (!Array.isArray(body.included)) {
      return NextResponse.json(
        { success: false, error: 'included doit être un tableau' },
        { status: 400 }
      );
    }

    const roomData = {
      name: body.name,
      description: body.subtitle,
      duration: body.duration,
      price: body.price,
      max_people: body.maxPeople,
      objects_to_destroy: body.objectsToDestroy,
      included: body.included,
      is_active: body.isActive !== undefined ? body.isActive : true
    };

    const newRoom = await createRoom(roomData);
    
    return NextResponse.json({ 
      success: true, 
      data: newRoom,
      message: 'Salle créée avec succès' 
    }, { status: 201 });
    
  } catch (error) {
    console.error('Erreur lors de la création de la salle:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la création de la salle' },
      { status: 500 }
    );
  }
}
