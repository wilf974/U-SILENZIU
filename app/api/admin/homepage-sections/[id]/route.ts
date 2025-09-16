import { NextRequest, NextResponse } from 'next/server'
import { getHomepageSectionById, updateHomepageSection, deleteHomepageSection } from '@/lib/database'

/**
 * GET /api/admin/homepage-sections/[id]
 * Récupère une section spécifique par ID
 */
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params
    
    if (!id) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'ID de section requis' 
        },
        { status: 400 }
      )
    }

    const section = await getHomepageSectionById(id)
    
    if (!section) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Section non trouvée' 
        },
        { status: 404 }
      )
    }
    
    return NextResponse.json({
      success: true,
      data: section
    })
  } catch (error) {
    console.error('Erreur lors de la récupération de la section:', error)
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la récupération de la section',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}

/**
 * PUT /api/admin/homepage-sections/[id]
 * Met à jour une section existante
 */
export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params
    const body = await request.json()
    
    if (!id) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'ID de section requis' 
        },
        { status: 400 }
      )
    }

    // Validation des champs
    const { section_key, title, subtitle, content, image_url, video_url, background_color, text_color, order_index, is_active } = body
    
    // Validation du format de la clé si fournie
    if (section_key) {
      const keyRegex = /^[a-z0-9-]+$/
      if (!keyRegex.test(section_key)) {
        return NextResponse.json(
          { 
            success: false, 
            error: 'La clé de section doit contenir uniquement des lettres minuscules, chiffres et tirets' 
          },
          { status: 400 }
        )
      }
    }

    // Préparation des données de mise à jour
    const updateData: any = {}
    
    if (section_key !== undefined) updateData.section_key = section_key.trim().toLowerCase()
    if (title !== undefined) updateData.title = title.trim()
    if (subtitle !== undefined) updateData.subtitle = subtitle.trim()
    if (content !== undefined) updateData.content = content.trim()
    if (image_url !== undefined) updateData.image_url = image_url.trim()
    if (video_url !== undefined) updateData.video_url = video_url.trim()
    if (background_color !== undefined) updateData.background_color = background_color.trim()
    if (text_color !== undefined) updateData.text_color = text_color.trim()
    if (order_index !== undefined) updateData.order_index = order_index
    if (is_active !== undefined) updateData.is_active = Boolean(is_active)

    // Mise à jour de la section
    const updatedSection = await updateHomepageSection(id, updateData)
    
    if (!updatedSection) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Section non trouvée' 
        },
        { status: 404 }
      )
    }
    
    return NextResponse.json({
      success: true,
      data: updatedSection,
      message: 'Section mise à jour avec succès'
    })
    
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la section:', error)
    
    // Gestion des erreurs spécifiques
    if (error instanceof Error) {
      if (error.message.includes('duplicate key')) {
        return NextResponse.json(
          { 
            success: false, 
            error: 'Une section avec cette clé existe déjà' 
          },
          { status: 409 }
        )
      }
    }
    
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la mise à jour de la section',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}

/**
 * DELETE /api/admin/homepage-sections/[id]
 * Supprime une section
 */
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params
    
    if (!id) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'ID de section requis' 
        },
        { status: 400 }
      )
    }

    // Vérifier que la section existe avant de la supprimer
    const existingSection = await getHomepageSectionById(id)
    if (!existingSection) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Section non trouvée' 
        },
        { status: 404 }
      )
    }

    // Suppression de la section
    const deleted = await deleteHomepageSection(id)
    
    if (!deleted) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Erreur lors de la suppression de la section' 
        },
        { status: 500 }
      )
    }
    
    return NextResponse.json({
      success: true,
      message: 'Section supprimée avec succès'
    })
    
  } catch (error) {
    console.error('Erreur lors de la suppression de la section:', error)
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la suppression de la section',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}
