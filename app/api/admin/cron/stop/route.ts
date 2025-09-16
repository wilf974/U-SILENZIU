import { NextRequest, NextResponse } from 'next/server'
import { cronService } from '@/lib/cronService'

export async function POST(request: NextRequest) {
  try {
    // Arrêter le service CRON
    cronService.stop()
    
    const status = cronService.getStatus()
    
    return NextResponse.json({
      success: true,
      message: 'Service CRON arrêté avec succès',
      status: status
    })
  } catch (error) {
    console.error('Erreur lors de l\'arrêt du service CRON:', error)
    return NextResponse.json(
      {
        success: false,
        message: 'Erreur lors de l\'arrêt du service'
      },
      { status: 500 }
    )
  }
}
