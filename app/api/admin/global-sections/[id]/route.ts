import { NextRequest, NextResponse } from 'next/server'
import { getGlobalSectionById, updateGlobalSection, deleteGlobalSection, toggleGlobalSectionStatus } from '@/lib/database'

/**
 * GET /api/admin/global-sections/[id]
 * Récupère une section globale par son ID
 */
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const section = await getGlobalSectionById(params.id)
    
    if (!section) {
      return NextResponse.json(
        { success: false, error: 'Section globale non trouvée' },
        { status: 404 }
      )
    }
    
    return NextResponse.json({
      success: true,
      data: section
    })
  } catch (error) {
    console.error('Erreur lors de la récupération de la section globale:', error)
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la récupération de la section globale' },
      { status: 500 }
    )
  }
}

/**
 * PUT /api/admin/global-sections/[id]
 * Met à jour une section globale
 */
export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const body = await request.json()
    
    // Vérifier si la section existe
    const existingSection = await getGlobalSectionById(params.id)
    if (!existingSection) {
      return NextResponse.json(
        { success: false, error: 'Section globale non trouvée' },
        { status: 404 }
      )
    }

    const updateData: any = {}
    
    // Mise à jour des champs fournis
    if (body.title !== undefined) updateData.title = body.title
    if (body.subtitle !== undefined) updateData.subtitle = body.subtitle
    if (body.content !== undefined) updateData.content = body.content
    if (body.image_url !== undefined) updateData.image_url = body.image_url
    if (body.video_url !== undefined) updateData.video_url = body.video_url
    if (body.background_color !== undefined) updateData.background_color = body.background_color
    if (body.text_color !== undefined) updateData.text_color = body.text_color
    if (body.order_index !== undefined) updateData.order_index = body.order_index
    if (body.is_active !== undefined) updateData.is_active = body.is_active
    if (body.section_name !== undefined) updateData.section_name = body.section_name
    if (body.page_identifier !== undefined) updateData.page_identifier = body.page_identifier

    const updatedSection = await updateGlobalSection(params.id, updateData)
    
    if (!updatedSection) {
      return NextResponse.json(
        { success: false, error: 'Erreur lors de la mise à jour de la section globale' },
        { status: 500 }
      )
    }
    
    return NextResponse.json({
      success: true,
      data: updatedSection
    })
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la section globale:', error)
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la mise à jour de la section globale' },
      { status: 500 }
    )
  }
}

/**
 * DELETE /api/admin/global-sections/[id]
 * Supprime une section globale
 */
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    // Vérifier si la section existe
    const existingSection = await getGlobalSectionById(params.id)
    if (!existingSection) {
      return NextResponse.json(
        { success: false, error: 'Section globale non trouvée' },
        { status: 404 }
      )
    }

    const deleted = await deleteGlobalSection(params.id)
    
    if (!deleted) {
      return NextResponse.json(
        { success: false, error: 'Erreur lors de la suppression de la section globale' },
        { status: 500 }
      )
    }
    
    return NextResponse.json({
      success: true,
      message: 'Section globale supprimée avec succès'
    })
  } catch (error) {
    console.error('Erreur lors de la suppression de la section globale:', error)
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la suppression de la section globale' },
      { status: 500 }
    )
  }
}

/**
 * PATCH /api/admin/global-sections/[id]/toggle
 * Bascule le statut actif/inactif d'une section globale
 */
export async function PATCH(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    // Vérifier si la section existe
    const existingSection = await getGlobalSectionById(params.id)
    if (!existingSection) {
      return NextResponse.json(
        { success: false, error: 'Section globale non trouvée' },
        { status: 404 }
      )
    }

    const updatedSection = await toggleGlobalSectionStatus(params.id)
    
    if (!updatedSection) {
      return NextResponse.json(
        { success: false, error: 'Erreur lors du basculement du statut de la section globale' },
        { status: 500 }
      )
    }
    
    return NextResponse.json({
      success: true,
      data: updatedSection
    })
  } catch (error) {
    console.error('Erreur lors du basculement du statut de la section globale:', error)
    return NextResponse.json(
      { success: false, error: 'Erreur lors du basculement du statut de la section globale' },
      { status: 500 }
    )
  }
}
