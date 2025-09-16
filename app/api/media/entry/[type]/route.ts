import { NextRequest, NextResponse } from 'next/server'
import { readdir, stat } from 'fs/promises'
import { join } from 'path'

/**
 * API route pour récupérer la liste des médias (images/vidéos) pour la page d'entrée
 * GET /api/media/entry/[type]
 */
export async function GET(
  request: NextRequest,
  { params }: { params: { type: string } }
) {
  try {
    const { type } = params

    if (!type || !['image', 'video'].includes(type)) {
      return NextResponse.json(
        { error: 'Type de média invalide' },
        { status: 400 }
      )
    }

    // Chemin vers le dossier des médias
    const mediaDir = join(process.cwd(), 'public', 'media', 'entry', type)

    try {
      // Lire le contenu du dossier
      const files = await readdir(mediaDir)
      
      // Filtrer les fichiers selon le type
      const validExtensions = type === 'image' 
        ? ['.jpg', '.jpeg', '.png', '.gif', '.webp']
        : ['.mp4', '.webm', '.mov', '.avi']

      const mediaFiles = await Promise.all(
        files
          .filter(file => {
            const ext = file.toLowerCase().substring(file.lastIndexOf('.'))
            return validExtensions.includes(ext)
          })
          .map(async (file) => {
            const filePath = join(mediaDir, file)
            const stats = await stat(filePath)
            
            return {
              name: file,
              url: `/media/entry/${type}/${file}`,
              type: type as 'image' | 'video',
              size: stats.size,
              lastModified: stats.mtime.toISOString()
            }
          })
      )

      // Trier par date de modification (plus récent en premier)
      mediaFiles.sort((a, b) => 
        new Date(b.lastModified).getTime() - new Date(a.lastModified).getTime()
      )

      return NextResponse.json(mediaFiles)

    } catch (error: any) {
      // Si le dossier n'existe pas, retourner une liste vide     
      if (error.code === 'ENOENT') {
        return NextResponse.json([])
      }
      throw error
    }

  } catch (error: any) {
    console.error('Erreur lors de la récupération des médias:', error)
    return NextResponse.json(
      { error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}
