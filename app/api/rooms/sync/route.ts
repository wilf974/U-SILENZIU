import { NextRequest, NextResponse } from 'next/server'
import { getAllRooms } from '@/lib/database'

// Force dynamic rendering to avoid static generation issues
export const dynamic = 'force-dynamic'

export async function GET(request: NextRequest) {
  try {
    console.log('🔄 API /api/rooms/sync appelée')
    
    const allRooms = await getAllRooms()
    const activeRooms = allRooms.filter(room => room.is_active)
    
    const response = {
      success: true,
      data: activeRooms,
      message: 'Salles synchronisées avec succès',
      timestamp: new Date().toISOString(),
      count: activeRooms.length
    }
    
    // Désactiver le cache pour la synchronisation
    const nextResponse = NextResponse.json(response)
    nextResponse.headers.set('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate')
    nextResponse.headers.set('Pragma', 'no-cache')
    nextResponse.headers.set('Expires', '0')
    
    console.log('✅ Synchronisation terminée:', activeRooms.length, 'salles')
    return nextResponse
  } catch (error) {
    console.error('❌ Erreur lors de la synchronisation:', error)
    return NextResponse.json(
      {
        success: false,
        data: [],
        message: 'Erreur lors de la synchronisation des salles',
        timestamp: new Date().toISOString(),
        count: 0
      },
      { status: 500 }
    )
  }
}
