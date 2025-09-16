import { NextRequest, NextResponse } from 'next/server'
import { getEntryPageConfig } from '@/lib/database'

/**
 * API route pour récupérer la configuration de la page d'entrée
 * GET /api/entry-page-config
 */
export async function GET(request: NextRequest) {
  try {
    const config = await getEntryPageConfig()
    
    if (!config) {
      return NextResponse.json(
        { error: 'Configuration de la page d\'entrée non trouvée' },
        { status: 404 }
      )
    }

    return NextResponse.json(config)
  } catch (error) {
    console.error('Erreur lors de la récupération de la configuration de la page d\'entrée:', error)
    return NextResponse.json(
      { error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}
