import { NextRequest, NextResponse } from 'next/server'
import { cronService } from '@/lib/cronService'

// Désactiver le cache pour cette route
export const dynamic = 'force-dynamic'
export const revalidate = 0

export async function GET(request: NextRequest) {
  try {
    console.log('📊 API Status CRON appelée - ' + new Date().toISOString())
    
    // Forcer l'initialisation du service CRON
    console.log('🔄 Initialisation du service CRON...')
    const isInitialized = await cronService.initialize()
    console.log('🔄 Résultat de l\'initialisation:', isInitialized)
    
    // Récupérer le statut après initialisation
    const status = cronService.getStatus()
    console.log('📊 Statut final retourné:', status)
    
    // Créer la réponse avec des headers pour éviter le cache
    const response = NextResponse.json({
      success: true,
      status: status,
      timestamp: new Date().toISOString()
    })
    
    // Ajouter des headers pour éviter le cache
    response.headers.set('Cache-Control', 'no-cache, no-store, must-revalidate')
    response.headers.set('Pragma', 'no-cache')
    response.headers.set('Expires', '0')
    
    return response
  } catch (error) {
    console.error('Erreur lors de la récupération du statut CRON:', error)
    return NextResponse.json(
      {
        success: false,
        message: 'Erreur lors de la récupération du statut'
      },
      { status: 500 }
    )
  }
}
