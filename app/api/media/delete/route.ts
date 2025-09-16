import { NextRequest, NextResponse } from 'next/server'
import { unlink } from 'fs/promises'
import { join } from 'path'

/**
 * API route pour supprimer un fichier média
 * DELETE /api/media/delete
 */
export async function DELETE(request: NextRequest) {
  try {
    const body = await request.json()
    const { fileName, type } = body

    if (!fileName || !type) {
      return NextResponse.json(
        { error: 'Nom de fichier et type requis' },
        { status: 400 }
      )
    }

    if (!['image', 'video'].includes(type)) {
      return NextResponse.json(
        { error: 'Type de fichier invalide' },
        { status: 400 }
      )
    }

    // Chemin vers le fichier
    const filePath = join(process.cwd(), 'public', 'media', 'entry', type, fileName)

    try {
      // Supprimer le fichier
      await unlink(filePath)
      
      return NextResponse.json({ 
        message: 'Fichier supprimé avec succès',
        fileName 
      })

    } catch (error: any) {
      if (error.code === 'ENOENT') {
        return NextResponse.json(
          { error: 'Fichier non trouvé' },
          { status: 404 }
        )
      }
      throw error
    }

  } catch (error: any) {
    console.error('Erreur lors de la suppression du fichier:', error)
    return NextResponse.json(
      { error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}
