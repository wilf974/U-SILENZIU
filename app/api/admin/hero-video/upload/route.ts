import { NextRequest, NextResponse } from 'next/server'
import { writeFile, mkdir } from 'fs/promises'
import { join } from 'path'

/**
 * POST /api/admin/hero-video/upload
 * Upload de la vidéo hero
 */
export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData()
    const file = formData.get('file') as File

    if (!file) {
      return NextResponse.json(
        { error: 'Aucun fichier fourni' },
        { status: 400 }
      )
    }

    // Validation du type de fichier
    if (!file.type.startsWith('video/')) {
      return NextResponse.json(
        { error: 'Le fichier doit être une vidéo' },
        { status: 400 }
      )
    }

    // Validation de la taille (max 100MB pour les vidéos hero)
    const maxSize = 100 * 1024 * 1024
    if (file.size > maxSize) {
      return NextResponse.json(
        { error: 'Le fichier ne doit pas dépasser 100MB' },
        { status: 400 }
      )
    }

    // Créer le nom de fichier unique
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-')
    const extension = file.name.split('.').pop()
    const fileName = `hero-video-${timestamp}.${extension}`

    // Définir le chemin de destination - public/video/
    const uploadDir = join(process.cwd(), 'public', 'video')
    const filePath = join(uploadDir, fileName)

    // Créer le répertoire s'il n'existe pas
    try {
      await mkdir(uploadDir, { recursive: true })
    } catch (error) {
      console.error('Erreur lors de la création du répertoire:', error)
    }

    // Convertir le fichier en buffer et l'écrire
    const bytes = await file.arrayBuffer()
    const buffer = Buffer.from(bytes)

    await writeFile(filePath, buffer)

    // Construire l'URL publique
    const publicUrl = `/video/${fileName}`

    return NextResponse.json({
      success: true,
      url: publicUrl,
      filename: fileName,
      size: file.size,
      type: file.type
    })

  } catch (error) {
    console.error('Erreur lors de l\'upload:', error)
    return NextResponse.json(
      { error: 'Erreur interne du serveur lors de l\'upload' },
      { status: 500 }
    )
  }
}
