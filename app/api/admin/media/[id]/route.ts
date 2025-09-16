import { NextRequest, NextResponse } from 'next/server'
import { getMediaFileById, updateMediaFile, deleteMediaFile } from '@/lib/database'

/**
 * API route pour la gestion d'un fichier média spécifique
 * GET /api/admin/media/[id] - Récupère un fichier média par son ID
 * PUT /api/admin/media/[id] - Met à jour un fichier média
 * DELETE /api/admin/media/[id] - Supprime un fichier média (marque comme inactif)
 */

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const id = parseInt(params.id)
    
    if (isNaN(id)) {
      return NextResponse.json(
        { success: false, error: 'ID invalide' },
        { status: 400 }
      )
    }

    const mediaFile = await getMediaFileById(id)
    
    if (!mediaFile) {
      return NextResponse.json(
        { success: false, error: 'Fichier média non trouvé' },
        { status: 404 }
      )
    }

    return NextResponse.json({
      success: true,
      data: mediaFile
    })

  } catch (error) {
    console.error('Erreur lors de la récupération du fichier média:', error)
    return NextResponse.json(
      { success: false, error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}

export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const id = parseInt(params.id)
    
    if (isNaN(id)) {
      return NextResponse.json(
        { success: false, error: 'ID invalide' },
        { status: 400 }
      )
    }

    const body = await request.json()
    
    // Vérifier que le fichier existe
    const existingFile = await getMediaFileById(id)
    if (!existingFile) {
      return NextResponse.json(
        { success: false, error: 'Fichier média non trouvé' },
        { status: 404 }
      )
    }

    // Mettre à jour le fichier média
    const updatedMediaFile = await updateMediaFile(id, body)

    return NextResponse.json({
      success: true,
      data: updatedMediaFile,
      message: 'Fichier média mis à jour avec succès'
    })

  } catch (error) {
    console.error('Erreur lors de la mise à jour du fichier média:', error)
    return NextResponse.json(
      { success: false, error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const id = parseInt(params.id)
    
    if (isNaN(id)) {
      return NextResponse.json(
        { success: false, error: 'ID invalide' },
        { status: 400 }
      )
    }

    // Vérifier que le fichier existe
    const existingFile = await getMediaFileById(id)
    if (!existingFile) {
      return NextResponse.json(
        { success: false, error: 'Fichier média non trouvé' },
        { status: 404 }
      )
    }

    // Supprimer le fichier média (marquer comme inactif)
    const deleted = await deleteMediaFile(id)

    if (!deleted) {
      return NextResponse.json(
        { success: false, error: 'Erreur lors de la suppression' },
        { status: 500 }
      )
    }

    return NextResponse.json({
      success: true,
      message: 'Fichier média supprimé avec succès'
    })

  } catch (error) {
    console.error('Erreur lors de la suppression du fichier média:', error)
    return NextResponse.json(
      { success: false, error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}

