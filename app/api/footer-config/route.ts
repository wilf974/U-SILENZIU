import { NextRequest, NextResponse } from 'next/server'
import { getFooterConfig } from '@/lib/database'

/**
 * GET /api/footer-config
 * Récupère la configuration du pied de page (API publique)
 */
export async function GET() {
  try {
    const config = await getFooterConfig()
    
    if (!config) {
      return NextResponse.json({
        success: false,
        error: 'Configuration du pied de page non trouvée'
      }, { status: 404 })
    }

    return NextResponse.json({
      success: true,
      data: config
    })
  } catch (error) {
    console.error('Erreur lors de la récupération de la configuration du pied de page:', error)
    return NextResponse.json({
      success: false,
      error: 'Erreur lors de la récupération de la configuration'
    }, { status: 500 })
  }
}
