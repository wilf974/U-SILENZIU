import { NextRequest, NextResponse } from 'next/server'
import { cronService } from '@/lib/cronService'

export async function POST(request: NextRequest) {
  try {
    // Initialiser le service CRON si nécessaire
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

    // Forcer l'exécution des notifications
    await cronService.forceExecution()
    
    return NextResponse.json({
      success: true,
      message: 'Test d\'exécution des notifications terminé. Vérifiez les logs pour les détails.'
    })
  } catch (error) {
    console.error('Erreur lors du test d\'exécution CRON:', error)
    return NextResponse.json(
      {
        success: false,
        message: 'Erreur lors du test d\'exécution'
      },
      { status: 500 }
    )
  }
}
