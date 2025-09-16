import { NextRequest, NextResponse } from 'next/server'
import { getGlobalSectionsByPage } from '@/lib/database'

// Force dynamic rendering to avoid static generation issues
export const dynamic = 'force-dynamic'

/**
 * GET /api/global-sections
 * Récupère les sections globales actives par page
 */
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const pageIdentifier = searchParams.get('page')
    
    if (!pageIdentifier) {
      return NextResponse.json(
        { success: false, error: 'Le paramètre "page" est requis' },
        { status: 400 }
      )
    }

    const sections = await getGlobalSectionsByPage(pageIdentifier)
    
    return NextResponse.json({
      success: true,
      data: sections
    })
  } catch (error) {
    console.error('Erreur lors de la récupération des sections globales:', error)
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la récupération des sections globales' },
      { status: 500 }
    )
  }
}
