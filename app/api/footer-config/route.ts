import { NextRequest, NextResponse } from 'next/server'
import { getFooterConfig, updateFooterConfig } from '@/lib/database'

// Force le rendu dynamique pour éviter les erreurs de prérendu
export const dynamic = 'force-dynamic'

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

/**
 * POST /api/footer-config
 * Met à jour la configuration du pied de page (API admin)
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    
    // Validation des données
    if (!body) {
      return NextResponse.json({
        success: false,
        error: 'Données manquantes'
      }, { status: 400 })
    }

    // Mettre à jour la configuration
    const updatedConfig = await updateFooterConfig(body)
    
    if (!updatedConfig) {
      return NextResponse.json({
        success: false,
        error: 'Erreur lors de la mise à jour de la configuration'
      }, { status: 500 })
    }

    return NextResponse.json({
      success: true,
      data: updatedConfig,
      message: 'Configuration mise à jour avec succès'
    })
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la configuration du pied de page:', error)
    return NextResponse.json({
      success: false,
      error: 'Erreur lors de la mise à jour de la configuration'
    }, { status: 500 })
  }
}
