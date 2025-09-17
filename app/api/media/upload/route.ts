import { NextRequest, NextResponse } from 'next/server'
import { writeFile, mkdir } from 'fs/promises'
import { join } from 'path'

/**
 * POST /api/media/upload
 * Upload d'images et vidéos pour la page d'entrée
 */
export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData()
    const file = formData.get('file') as File
    const type = formData.get('type') as string

    if (!file) {
      return NextResponse.json(
        { error: 'Aucun fichier fourni' },
        { status: 400 }
      )
    }

    if (!type || !['image', 'video'].includes(type)) {
      return NextResponse.json(
        { error: 'Type de média invalide (image ou video requis)' },
        { status: 400 }
      )
    }

    // Validation du type de fichier
    if (type === 'image' && !file.type.startsWith('image/')) {
      return NextResponse.json(
        { error: 'Le fichier doit être une image' },
        { status: 400 }
      )
    }

    if (type === 'video' && !file.type.startsWith('video/')) {
      return NextResponse.json(
        { error: 'Le fichier doit être une vidéo' },
        { status: 400 }
      )
    }

    // Validation de la taille (max 50MB pour les vidéos, 10MB pour les images)
    const maxSize = type === 'video' ? 50 * 1024 * 1024 : 10 * 1024 * 1024
    if (file.size > maxSize) {
      const maxSizeMB = type === 'video' ? '50MB' : '10MB'
      return NextResponse.json(
        { error: `Le fichier ne doit pas dépasser ${maxSizeMB}` },
        { status: 400 }
      )
    }

    // Créer le nom de fichier unique
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-')
    const extension = file.name.split('.').pop()
    const fileName = `entry-${type}-${timestamp}.${extension}`

    // Définir le chemin de destination
    const uploadDir = join(process.cwd(), 'public', 'media', 'entry', type)
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
    const publicUrl = `/media/entry/${type}/${fileName}`

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

/**
 * GET /api/media/upload
 * Informations sur l'API d'upload
 */
export async function GET() {
  return NextResponse.json({
    endpoints: {
      upload: 'POST /api/media/upload',
      supported_types: ['image', 'video'],
      max_sizes: {
        image: '10MB',
        video: '50MB'
      },
      supported_formats: {
        image: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        video: ['mp4', 'webm', 'mov', 'avi']
      }
    }
  })
}
