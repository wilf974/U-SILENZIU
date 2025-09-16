import { NextRequest, NextResponse } from 'next/server'
import { getPageById, updatePage, deletePage } from '@/lib/database'

/**
 * GET /api/admin/pages/[id]
 * Récupère une page spécifique par ID
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
          error: 'ID de page requis' 
        },
        { status: 400 }
      )
    }

    const page = await getPageById(id)
    
    if (!page) {
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

/**
 * PUT /api/admin/pages/[id]
 * Met à jour une page existante
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
          error: 'ID de page requis' 
        },
        { status: 400 }
      )
    }

    // Validation des champs requis
    const { title, slug, content, metaDescription, seoTitle, keywords, isPublished } = body
    
    if (!title || !slug || !content) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Les champs titre, slug et contenu sont obligatoires' 
        },
        { status: 400 }
      )
    }

    // Validation du slug (format URL-friendly)
    const slugRegex = /^[a-z0-9-]+$/
    if (!slugRegex.test(slug)) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Le slug doit contenir uniquement des lettres minuscules, chiffres et tirets' 
        },
        { status: 400 }
      )
    }

    // Préparation des données de mise à jour
    const updateData = {
      title: title.trim(),
      slug: slug.trim().toLowerCase(),
      content: content.trim(),
      metaDescription: metaDescription?.trim() || '',
      seoTitle: seoTitle?.trim() || title.trim(),
      keywords: Array.isArray(keywords) ? keywords : keywords?.split(',').map((k: string) => k.trim()).filter(Boolean) || [],
      is_published: Boolean(isPublished)
    }

    // Mise à jour de la page
    const updatedPage = await updatePage(id, updateData)
    
    if (!updatedPage) {
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
      data: updatedPage,
      message: 'Page mise à jour avec succès'
    })
    
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la page:', error)
    
    // Gestion des erreurs spécifiques
    if (error instanceof Error) {
      if (error.message.includes('duplicate key')) {
        return NextResponse.json(
          { 
            success: false, 
            error: 'Une page avec ce slug existe déjà' 
          },
          { status: 409 }
        )
      }
    }
    
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la mise à jour de la page',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}

/**
 * DELETE /api/admin/pages/[id]
 * Supprime une page
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
          error: 'ID de page requis' 
        },
        { status: 400 }
      )
    }

    // Vérifier que la page existe avant de la supprimer
    const existingPage = await getPageById(id)
    if (!existingPage) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Page non trouvée' 
        },
        { status: 404 }
      )
    }

    // Suppression de la page
    const deleted = await deletePage(id)
    
    if (!deleted) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Erreur lors de la suppression de la page' 
        },
        { status: 500 }
      )
    }
    
    return NextResponse.json({
      success: true,
      message: 'Page supprimée avec succès'
    })
    
  } catch (error) {
    console.error('Erreur lors de la suppression de la page:', error)
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la suppression de la page',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}
