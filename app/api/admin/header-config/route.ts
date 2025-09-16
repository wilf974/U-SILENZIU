import { NextRequest, NextResponse } from 'next/server'
import { getHeaderConfig, updateHeaderConfig } from '@/lib/database'

/**
 * API Route pour récupérer la configuration de l'en-tête (admin)
 * GET /api/admin/header-config
 */
export async function GET() {
  try {
    const config = await getHeaderConfig()
    
    if (!config) {
      return NextResponse.json(
        { error: 'Configuration de l\'en-tête non trouvée' },
        { status: 404 }
      )
    }

    return NextResponse.json(config)
  } catch (error) {
    console.error('Erreur lors de la récupération de la configuration de l\'en-tête:', error)
    return NextResponse.json(
      { error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}

/**
 * API Route pour mettre à jour la configuration de l'en-tête (admin)
 * PUT /api/admin/header-config
 */
export async function PUT(request: NextRequest) {
  try {
    const body = await request.json()
    
    // Validation des données
    if (!body.site_name || body.site_name.trim() === '') {
      return NextResponse.json(
        { error: 'Le nom du site est obligatoire' },
        { status: 400 }
      )
    }

    if (!body.logo_type || !['text', 'image'].includes(body.logo_type)) {
      return NextResponse.json(
        { error: 'Le type de logo doit être "text" ou "image"' },
        { status: 400 }
      )
    }

    if (body.logo_type === 'text' && (!body.logo_text || body.logo_text.trim() === '')) {
      return NextResponse.json(
        { error: 'Le texte du logo est obligatoire quand le type est "text"' },
        { status: 400 }
      )
    }

    if (body.logo_type === 'image' && (!body.logo_image_url || body.logo_image_url.trim() === '')) {
      return NextResponse.json(
        { error: 'L\'URL de l\'image du logo est obligatoire quand le type est "image"' },
        { status: 400 }
      )
    }

    // Préparer les données pour la mise à jour
    const configData = {
      site_name: body.site_name.trim(),
      logo_type: body.logo_type,
      logo_text: body.logo_text?.trim() || '',
      logo_image_url: body.logo_image_url?.trim() || null,
      logo_alt_text: body.logo_alt_text?.trim() || 'Logo du site'
    }

    const updatedConfig = await updateHeaderConfig(configData)

    return NextResponse.json({
      message: 'Configuration de l\'en-tête mise à jour avec succès',
      config: updatedConfig
    })
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la configuration de l\'en-tête:', error)
    return NextResponse.json(
      { error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}

