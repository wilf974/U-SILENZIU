import { NextRequest, NextResponse } from 'next/server'
import { reorderHomepageSections } from '@/lib/database'

/**
 * PUT /api/admin/homepage-sections/reorder
 * Met à jour l'ordre de toutes les sections en une seule fois
 */
export async function PUT(request: NextRequest) {
  try {
    const body = await request.json()
    const { sections } = body
    
    if (!sections || !Array.isArray(sections)) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Tableau de sections requis' 
        },
        { status: 400 }
      )
    }

    // Validation des données
    for (const section of sections) {
      if (!section.id || typeof section.order_index !== 'number') {
        return NextResponse.json(
          { 
            success: false, 
            error: 'Chaque section doit avoir un id et un order_index valides' 
          },
          { status: 400 }
        )
      }
    }

    // Mettre à jour l'ordre de toutes les sections
    const updatedSections = await reorderHomepageSections(sections)
    
    return NextResponse.json({
      success: true,
      data: updatedSections,
      message: 'Ordre des sections mis à jour avec succès'
    })
    
  } catch (error) {
    console.error('Erreur lors de la mise à jour de l\'ordre des sections:', error)
    
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la mise à jour de l\'ordre des sections',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}
