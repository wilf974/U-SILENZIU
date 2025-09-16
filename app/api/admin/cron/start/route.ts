import { NextRequest, NextResponse } from 'next/server'
import { cronService } from '@/lib/cronService'

export async function POST(request: NextRequest) {
  try {
    // Initialiser le service CRON (démarre automatiquement)
    const isInitialized = await cronService.initialize()
    
    if (!isInitialized) {
      return NextResponse.json(
        {
          success: false,
          message: 'Impossible d\'initialiser le service CRON. Vérifiez la configuration SMTP.'
        },
        { status: 400 }
      )
    }

    // Récupérer le statut après initialisation
    const status = cronService.getStatus()
    
    return NextResponse.json({
      success: true,
      message: 'Service CRON démarré avec succès',
      status: status
    })
  } catch (error) {
    console.error('Erreur lors du démarrage du service CRON:', error)
    return NextResponse.json(
      {
        success: false,
        message: 'Erreur lors du démarrage du service'
      },
      { status: 500 }
    )
  }
}
