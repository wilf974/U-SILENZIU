import { NextRequest, NextResponse } from 'next/server'
import { getAllHomepageSections, createHomepageSection } from '@/lib/database'

/**
 * GET /api/admin/homepage-sections
 * Récupère toutes les sections de la page d'accueil
 */
export async function GET() {
  try {
    const sections = await getAllHomepageSections()
    
    return NextResponse.json({
      success: true,
      data: sections,
      count: sections.length
    })
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

/**
 * POST /api/admin/homepage-sections
 * Crée une nouvelle section
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    
    // Validation des champs requis
    const { section_key, title, subtitle, content, image_url, video_url, background_color, text_color, order_index, is_active } = body
    
    if (!section_key) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'La clé de section est obligatoire' 
        },
        { status: 400 }
      )
    }

    // Validation du format de la clé (alphanumérique et tirets)
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

    // Préparation des données
    const sectionData = {
      section_key: section_key.trim().toLowerCase(),
      title: title?.trim() || '',
      subtitle: subtitle?.trim() || '',
      content: content?.trim() || '',
      image_url: image_url?.trim() || '',
      video_url: video_url?.trim() || '',
      background_color: background_color?.trim() || '',
      text_color: text_color?.trim() || '',
      order_index: order_index || 0,
      is_active: Boolean(is_active)
    }

    // Création de la section
    const newSection = await createHomepageSection(sectionData)
    
    return NextResponse.json({
      success: true,
      data: newSection,
      message: 'Section créée avec succès'
    }, { status: 201 })
    
  } catch (error) {
    console.error('Erreur lors de la création de la section:', error)
    
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
        error: 'Erreur lors de la création de la section',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}
