import { NextRequest, NextResponse } from 'next/server'
import { readFile } from 'fs/promises'
import { join } from 'path'
import { existsSync } from 'fs'

/**
 * Route API pour servir les fichiers uploadés (images de salles, etc.)
 * Utilise la variable d'environnement UPLOAD_DIR ou le chemin par défaut
 */
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ filename: string[] }> }
) {
  try {
    const { filename } = await params
    
    // Utiliser UPLOAD_DIR si défini, sinon utiliser le chemin par défaut
    const uploadsBaseDir = process.env.UPLOAD_DIR || join(process.cwd(), 'public', 'uploads')
    const filePath = join(uploadsBaseDir, ...filename)

    // Vérifier que le fichier existe
    if (!existsSync(filePath)) {
      console.error(`Image non trouvée: ${filePath}`)
      return new NextResponse('Image non trouvée', { status: 404 })
    }

    // Lire le fichier
    const fileBuffer = await readFile(filePath)
    
    // Déterminer le type MIME basé sur l'extension
    const extension = filename[filename.length - 1].split('.').pop()?.toLowerCase()
    let contentType = 'application/octet-stream'
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        contentType = 'image/jpeg'
        break
      case 'png':
        contentType = 'image/png'
        break
      case 'gif':
        contentType = 'image/gif'
        break
      case 'webp':
        contentType = 'image/webp'
        break
      case 'svg':
        contentType = 'image/svg+xml'
        break
    }

    // Retourner le fichier avec les bons headers
    return new NextResponse(fileBuffer as any, {
      headers: {
        'Content-Type': contentType,
        'Cache-Control': 'public, max-age=31536000, immutable', // Cache 1 an
      },
    })
  } catch (error) {
    console.error('Erreur lors de la lecture de l\'image:', error)
    return new NextResponse('Erreur serveur', { status: 500 })
  }
}
