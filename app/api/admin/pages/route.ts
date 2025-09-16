import { NextRequest, NextResponse } from 'next/server'
import { getAllPages, createPage } from '@/lib/database'

/**
 * GET /api/admin/pages
 * Récupère toutes les pages pour l'administration
 */
export async function GET() {
  try {
    const pages = await getAllPages()
    
    return NextResponse.json({
      success: true,
      data: pages,
      count: pages.length
    })
  } catch (error) {
    console.error('Erreur lors de la récupération des pages:', error)
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la récupération des pages',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}

/**
 * POST /api/admin/pages
 * Crée une nouvelle page
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    
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

    // Préparation des données
    const pageData = {
      title: title.trim(),
      slug: slug.trim().toLowerCase(),
      content: content.trim(),
      metaDescription: metaDescription?.trim() || '',
      seoTitle: seoTitle?.trim() || title.trim(),
      keywords: Array.isArray(keywords) ? keywords : keywords?.split(',').map((k: string) => k.trim()).filter(Boolean) || [],
      is_published: Boolean(isPublished)
    }

    // Création de la page
    const newPage = await createPage(pageData)
    
    return NextResponse.json({
      success: true,
      data: newPage,
      message: 'Page créée avec succès'
    }, { status: 201 })
    
  } catch (error) {
    console.error('Erreur lors de la création de la page:', error)
    
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
        error: 'Erreur lors de la création de la page',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}
