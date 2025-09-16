import { NextRequest, NextResponse } from 'next/server';
import { ensureAllRoomsHavePrice, getRoomsWithoutPrice } from '@/lib/database';

/**
 * API route pour s'assurer que toutes les salles ont un prix défini
 * GET /api/admin/rooms/ensure-prices - Vérifier les salles sans prix
 * POST /api/admin/rooms/ensure-prices - Appliquer un prix par défaut aux salles sans prix
 */

// GET - Vérifier les salles sans prix
export async function GET() {
  try {
    const roomsWithoutPrice = await getRoomsWithoutPrice();
    
    return NextResponse.json({
      success: true,
      data: {
        roomsWithoutPrice,
        count: roomsWithoutPrice.length
      },
      message: roomsWithoutPrice.length === 0 
        ? 'Toutes les salles ont un prix défini' 
        : `${roomsWithoutPrice.length} salle(s) sans prix trouvée(s)`
    });
  } catch (error) {
    console.error('Erreur lors de la vérification des prix des salles:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la vérification des prix des salles' },
      { status: 500 }
    );
  }
}

// POST - Appliquer un prix par défaut aux salles sans prix
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const defaultPrice = body.defaultPrice || 30.00;
    
    // Validation du prix
    if (typeof defaultPrice !== 'number' || defaultPrice <= 0) {
      return NextResponse.json(
        { success: false, error: 'Le prix par défaut doit être un nombre positif' },
        { status: 400 }
      );
    }
    
    // Mettre à jour les salles sans prix
    const updatedCount = await ensureAllRoomsHavePrice(defaultPrice);
    
    return NextResponse.json({
      success: true,
      data: {
        updatedCount,
        defaultPrice
      },
      message: updatedCount === 0 
        ? 'Toutes les salles avaient déjà un prix défini' 
        : `${updatedCount} salle(s) mise(s) à jour avec le prix ${defaultPrice}€`
    });
  } catch (error) {
    console.error('Erreur lors de la mise à jour des prix des salles:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la mise à jour des prix des salles' },
      { status: 500 }
    );
  }
}
