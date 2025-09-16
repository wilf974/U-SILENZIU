import { NextRequest, NextResponse } from 'next/server'
import { getPageBySlug } from '@/lib/database'

/**
 * GET /api/pages/[slug]
 * Récupère une page publique par slug (uniquement les pages publiées)
 */
export async function GET(
  request: NextRequest,
  { params }: { params: { slug: string } }
) {
  try {
    const { slug } = params
    
    if (!slug) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Slug de page requis' 
        },
        { status: 400 }
      )
    }

    const page = await getPageBySlug(slug)
    
    if (!page) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Page non trouvée' 
        },
        { status: 404 }
      )
    }

    // Vérifier que la page est publiée
    if (!page.is_published) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Page non trouvée' 
        },
        { status: 404 }
      )
    }
    
    return NextResponse.json({
      success: true,
      data: page
    })
  } catch (error) {
    console.error('Erreur lors de la récupération de la page:', error)
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la récupération de la page',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}
