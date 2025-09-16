import { NextRequest, NextResponse } from 'next/server'
import { updateHeaderConfig } from '@/lib/database'

/**
 * API Route pour uploader un logo et le stocker en base de données
 * POST /api/admin/header-config/upload
 */
export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData()
    const file = formData.get('logo') as File
    const siteName = formData.get('site_name') as string
    const logoAltText = formData.get('logo_alt_text') as string

    // Validation du fichier
    if (!file) {
      return NextResponse.json(
        { error: 'Aucun fichier fourni' },
        { status: 400 }
      )
    }

    // Validation du type de fichier
    const allowedTypes = ['image/png', 'image/jpeg', 'image/jpg', 'image/gif', 'image/webp']
    if (!allowedTypes.includes(file.type)) {
      return NextResponse.json(
        { error: 'Type de fichier non supporté. Formats acceptés: PNG, JPEG, JPG, GIF, WebP' },
        { status: 400 }
      )
    }

    // Validation de la taille (max 2MB)
    const maxSize = 2 * 1024 * 1024 // 2MB
    if (file.size > maxSize) {
      return NextResponse.json(
        { error: 'Fichier trop volumineux. Taille maximale: 2MB' },
        { status: 400 }
      )
    }

    // Validation des champs obligatoires
    if (!siteName || siteName.trim() === '') {
      return NextResponse.json(
        { error: 'Le nom du site est obligatoire' },
        { status: 400 }
      )
    }

    // Convertir le fichier en Buffer
    const bytes = await file.arrayBuffer()
    const buffer = Buffer.from(bytes)

    // Préparer les données pour la mise à jour
    const configData = {
      site_name: siteName.trim(),
      logo_type: 'uploaded' as const,
      logo_text: '', // Pas utilisé pour les logos uploadés
      logo_image_url: undefined, // Pas utilisé pour les logos uploadés
      logo_alt_text: logoAltText?.trim() || 'Logo du site',
      logo_uploaded_data: buffer,
      logo_uploaded_filename: file.name,
      logo_uploaded_mimetype: file.type,
      logo_uploaded_size: file.size
    }

    // Mettre à jour la configuration
    const updatedConfig = await updateHeaderConfig(configData)

    return NextResponse.json({
      message: 'Logo uploadé et sauvegardé avec succès',
      config: {
        id: updatedConfig.id,
        site_name: updatedConfig.site_name,
        logo_type: updatedConfig.logo_type,
        logo_alt_text: updatedConfig.logo_alt_text,
        logo_uploaded_filename: updatedConfig.logo_uploaded_filename,
        logo_uploaded_mimetype: updatedConfig.logo_uploaded_mimetype,
        logo_uploaded_size: updatedConfig.logo_uploaded_size,
        created_at: updatedConfig.created_at,
        updated_at: updatedConfig.updated_at
      }
    })
  } catch (error) {
    console.error('Erreur lors de l\'upload du logo:', error)
    return NextResponse.json(
      { error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}
