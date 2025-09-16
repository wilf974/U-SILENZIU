import { NextResponse } from 'next/server'
import { getActiveHomepageSections } from '@/lib/database'

// Force dynamic rendering to avoid static generation issues
export const dynamic = 'force-dynamic'

/**
 * GET /api/homepage-sections
 * Récupère les sections actives de la page d'accueil pour l'affichage public
 */
export async function GET() {
  try {
    const sections = await getActiveHomepageSections()
    
    const response = NextResponse.json({
      success: true,
      data: sections,
      count: sections.length
    })

    // Ajouter des headers pour éviter la mise en cache côté client
    response.headers.set('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate')
    response.headers.set('Pragma', 'no-cache')
    response.headers.set('Expires', '0')
    response.headers.set('Surrogate-Control', 'no-store')
    
    return response
  } catch (error) {
    console.error('Erreur lors de la récupération des sections:', error)
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la récupération des sections',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}
