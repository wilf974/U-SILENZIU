import { NextRequest, NextResponse } from 'next/server'
import { getHeaderConfig } from '@/lib/database'

// Force le rendu dynamique pour éviter les erreurs de prérendu
export const dynamic = 'force-dynamic'

/**
 * API Route pour récupérer la configuration de l'en-tête (publique)
 * GET /api/header-config
 */
export async function GET() {
  try {
    const config = await getHeaderConfig()
    
    if (!config) {
      return NextResponse.json(
        { error: 'Configuration de l\'en-tête non trouvée' },
        { status: 404 }
      )
    }

    return NextResponse.json(config)
  } catch (error) {
    console.error('Erreur lors de la récupération de la configuration de l\'en-tête:', error)
    return NextResponse.json(
      { error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}

