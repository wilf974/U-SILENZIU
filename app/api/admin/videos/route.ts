import { NextRequest, NextResponse } from 'next/server'
import { readdirSync, statSync } from 'fs'
import { join } from 'path'

/**
 * GET /api/admin/videos
 * Liste toutes les vidéos disponibles dans le dossier public/video/
 */
export async function GET(request: NextRequest) {
  try {
    const videoDir = join(process.cwd(), 'public', 'video')

    // Lire tous les fichiers du dossier vidéo
    const files = readdirSync(videoDir)

    // Filtrer les fichiers vidéo et ajouter des métadonnées
    const videos = files
      .filter(file => {
        const ext = file.toLowerCase().split('.').pop()
        return ['mp4', 'webm', 'ogg', 'mov', 'avi'].includes(ext || '')
      })
      .map(file => {
        const filePath = join(videoDir, file)
        const stats = statSync(filePath)

        return {
          filename: file,
          path: `/video/${file}`,
          size: stats.size,
          sizeKB: Math.round(stats.size / 1024),
          sizeMB: (stats.size / (1024 * 1024)).toFixed(2),
          createdAt: stats.birthtime,
          modifiedAt: stats.mtime,
        }
      })
      .sort((a, b) => {
        // Trier par date de modification (plus récent en premier)
        return new Date(b.modifiedAt).getTime() - new Date(a.modifiedAt).getTime()
      })

    return NextResponse.json({
      success: true,
      count: videos.length,
      videos,
    })
  } catch (error) {
    console.error('Erreur lors de la lecture des vidéos:', error)

    return NextResponse.json({
      success: false,
      error: 'Impossible de lire le dossier des vidéos',
    }, { status: 500 })
  }
}
