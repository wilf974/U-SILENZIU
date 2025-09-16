import { NextRequest, NextResponse } from 'next/server'
import { getHeaderConfig } from '@/lib/database'

/**
 * API Route pour récupérer le logo uploadé
 * GET /api/header-config/logo
 */
export async function GET() {
  try {
    const config = await getHeaderConfig()
    
    if (!config || config.logo_type !== 'uploaded' || !config.logo_uploaded_data) {
      return NextResponse.json(
        { error: 'Aucun logo uploadé trouvé' },
        { status: 404 }
      )
    }

    // Retourner l'image avec les bons headers
    return new NextResponse(config.logo_uploaded_data as any, {
      status: 200,
      headers: {
        'Content-Type': config.logo_uploaded_mimetype || 'image/png',
        'Content-Length': config.logo_uploaded_size?.toString() || '0',
        'Cache-Control': 'public, max-age=3600', // Cache pendant 1 heure
        'Content-Disposition': `inline; filename="${config.logo_uploaded_filename || 'logo.png'}"`
      }
    })
  } catch (error) {
    console.error('Erreur lors de la récupération du logo:', error)
    return NextResponse.json(
      { error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}
