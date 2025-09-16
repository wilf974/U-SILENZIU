import { NextRequest, NextResponse } from 'next/server'
import { getAllGlobalSections, createGlobalSection } from '@/lib/database'

/**
 * GET /api/admin/global-sections
 * Récupère toutes les sections globales pour l'administration
 */
export async function GET() {
  try {
    const sections = await getAllGlobalSections()
    
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

/**
 * POST /api/admin/global-sections
 * Crée une nouvelle section globale
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    
    // Validation des champs requis
    if (!body.section_key || !body.section_name || !body.page_identifier) {
      return NextResponse.json(
        { success: false, error: 'section_key, section_name et page_identifier sont requis' },
        { status: 400 }
      )
    }

    const sectionData = {
      section_key: body.section_key,
      section_name: body.section_name,
      title: body.title || null,
      subtitle: body.subtitle || null,
      content: body.content || null,
      image_url: body.image_url || null,
      video_url: body.video_url || null,
      background_color: body.background_color || null,
      text_color: body.text_color || null,
      order_index: body.order_index || 0,
      is_active: body.is_active !== undefined ? body.is_active : true,
      page_identifier: body.page_identifier
    }

    const newSection = await createGlobalSection(sectionData)
    
    return NextResponse.json({
      success: true,
      data: newSection
    })
  } catch (error) {
    console.error('Erreur lors de la création de la section globale:', error)
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la création de la section globale' },
      { status: 500 }
    )
  }
}
