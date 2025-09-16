import { NextResponse } from 'next/server';
import { getActiveRooms } from '@/lib/database';

// Force dynamic rendering to avoid static generation issues
export const dynamic = 'force-dynamic'

export async function GET() {
  try {
    const rooms = await getActiveRooms();
    return NextResponse.json({ 
      success: true, 
      data: rooms,
      count: rooms.length,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Erreur lors de la récupération des salles actives:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la récupération des salles' },
      { status: 500 }
    );
  }
}
