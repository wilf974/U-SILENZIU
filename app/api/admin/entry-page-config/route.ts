import { NextRequest, NextResponse } from 'next/server'
import { getEntryPageConfig, updateEntryPageConfig, createEntryPageConfig } from '@/lib/database'

/**
 * API route admin pour gérer la configuration de la page d'entrée
 * GET /api/admin/entry-page-config - Récupérer la configuration
 * PUT /api/admin/entry-page-config - Mettre à jour la configuration
 * POST /api/admin/entry-page-config - Créer une nouvelle configuration
 */
export async function GET(request: NextRequest) {
  try {
    const config = await getEntryPageConfig()
    
    if (!config) {
      return NextResponse.json(
        { error: 'Configuration de la page d\'entrée non trouvée' },
        { status: 404 }
      )
    }

    return NextResponse.json(config)
  } catch (error) {
    console.error('Erreur lors de la récupération de la configuration de la page d\'entrée:', error)
    return NextResponse.json(
      { error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}

export async function PUT(request: NextRequest) {
  try {
    const body = await request.json()
    
    // Validation des champs requis
    if (!body.id) {
      return NextResponse.json(
        { error: 'ID de la configuration requis' },
        { status: 400 }
      )
    }

    // Validation du type d'arrière-plan
    if (body.background_type && !['image', 'video'].includes(body.background_type)) {
      return NextResponse.json(
        { error: 'Type d\'arrière-plan invalide. Doit être "image" ou "video"' },
        { status: 400 }
      )
    }

    const updatedConfig = await updateEntryPageConfig(body)
    
    return NextResponse.json(updatedConfig)
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la configuration de la page d\'entrée:', error)
    return NextResponse.json(
      { error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    
    // Validation des champs requis
    const requiredFields = ['title', 'subtitle', 'description', 'button_text', 'background_type']
    for (const field of requiredFields) {
      if (!body[field]) {
        return NextResponse.json(
          { error: `Champ requis manquant: ${field}` },
          { status: 400 }
        )
      }
    }

    // Validation du type d'arrière-plan
    if (!['image', 'video'].includes(body.background_type)) {
      return NextResponse.json(
        { error: 'Type d\'arrière-plan invalide. Doit être "image" ou "video"' },
        { status: 400 }
      )
    }

    const newConfig = await createEntryPageConfig({
      title: body.title,
      subtitle: body.subtitle,
      description: body.description,
      button_text: body.button_text,
      background_type: body.background_type,
      background_url: body.background_url,
      background_image_url: body.background_image_url,
      background_video_url: body.background_video_url,
      is_active: body.is_active !== undefined ? body.is_active : true
    })
    
    return NextResponse.json(newConfig, { status: 201 })
  } catch (error) {
    console.error('Erreur lors de la création de la configuration de la page d\'entrée:', error)
    return NextResponse.json(
      { error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}
