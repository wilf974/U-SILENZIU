import { NextRequest, NextResponse } from 'next/server'
import { getMediaFiles, getMediaStats, createMediaFile, MediaFile } from '@/lib/database'

/**
 * API route pour la gestion des fichiers médias
 * GET /api/admin/media - Récupère tous les fichiers médias avec filtres
 * POST /api/admin/media - Crée un nouveau fichier média (pour les uploads directs)
 */

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    
    // Récupérer les paramètres de filtrage
    const fileType = searchParams.get('type') as 'image' | 'video' | null
    const context = searchParams.get('context')
    const contextId = searchParams.get('context_id')
    const isActive = searchParams.get('is_active')
    const stats = searchParams.get('stats')

    // Si on demande les statistiques
    if (stats === 'true') {
      const mediaStats = await getMediaStats()
      return NextResponse.json({
        success: true,
        data: mediaStats
      })
    }

    // Construire les filtres
    const filters: any = {}
    if (fileType) filters.file_type = fileType
    if (context) filters.context = context
    if (contextId) filters.context_id = parseInt(contextId)
    if (isActive !== null) filters.is_active = isActive === 'true'

    // Récupérer les fichiers médias
    const mediaFiles = await getMediaFiles(filters)

    return NextResponse.json({
      success: true,
      data: mediaFiles,
      count: mediaFiles.length
    })

  } catch (error) {
    console.error('Erreur lors de la récupération des fichiers médias:', error)
    return NextResponse.json(
      { success: false, error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    
    // Validation des données requises
    const requiredFields = ['filename', 'original_filename', 'file_path', 'file_url', 'file_type', 'mime_type', 'file_size']
    for (const field of requiredFields) {
      if (!body[field]) {
        return NextResponse.json(
          { success: false, error: `Champ requis manquant: ${field}` },
          { status: 400 }
        )
      }
    }

    // Créer le fichier média
    const mediaData: Omit<MediaFile, 'id' | 'created_at' | 'updated_at'> = {
      filename: body.filename,
      original_filename: body.original_filename,
      file_path: body.file_path,
      file_url: body.file_url,
      file_type: body.file_type,
      mime_type: body.mime_type,
      file_size: body.file_size,
      width: body.width,
      height: body.height,
      duration: body.duration,
      is_active: body.is_active !== undefined ? body.is_active : true,
      uploaded_by: body.uploaded_by,
      context: body.context,
      context_id: body.context_id
    }

    const savedMediaFile = await createMediaFile(mediaData)

    return NextResponse.json({
      success: true,
      data: savedMediaFile,
      message: 'Fichier média créé avec succès'
    })

  } catch (error) {
    console.error('Erreur lors de la création du fichier média:', error)
    return NextResponse.json(
      { success: false, error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}

