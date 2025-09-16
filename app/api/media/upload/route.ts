import { NextRequest, NextResponse } from 'next/server'
import { writeFile, mkdir } from 'fs/promises'
import { join } from 'path'
import { updateEntryPageConfig, createMediaFile } from '@/lib/database'
import { existsSync } from 'fs'

/**
 * API route pour l'upload de médias (images/vidéos) pour la page d'entrée
 * POST /api/media/upload
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
        { error: 'Type de fichier invalide' },
        { status: 400 }
      )
    }

    // Vérifier le type de fichier
    const isValidType = type === 'image' 
      ? file.type.startsWith('image/')
      : file.type.startsWith('video/')

    if (!isValidType) {
      return NextResponse.json(
        { error: `Type de fichier invalide. Attendu: ${type}` },
        { status: 400 }
      )
    }

    // Vérifier la taille (max 10MB)
    if (file.size > 10 * 1024 * 1024) {
      return NextResponse.json(
        { error: 'Le fichier ne doit pas dépasser 10MB' },
        { status: 400 }
      )
    }

    // Créer le nom de fichier unique
    const timestamp = Date.now()
    const fileExtension = file.name.split('.').pop()
    const fileName = `${timestamp}-${file.name.replace(/[^a-zA-Z0-9.-]/g, '_')}`
    const fullFileName = `${fileName}.${fileExtension}`

    // Chemin de destination (dossier statique comme le Hero)
    const staticDir = join(process.cwd(), 'public', type === 'image' ? 'images' : 'videos', 'entry')
    const staticFileName = type === 'image' ? 'entry-bg.jpg' : 'entry-bg.mp4'
    const staticFilePath = join(staticDir, staticFileName)
    
    // Chemin de sauvegarde (dossier media pour historique)
    const uploadDir = join(process.cwd(), 'public', 'media', 'entry', type)
    const filePath = join(uploadDir, fullFileName)

    // Créer les dossiers s'ils n'existent pas
    if (!existsSync(uploadDir)) {
      await mkdir(uploadDir, { recursive: true })
    }
    if (!existsSync(staticDir)) {
      await mkdir(staticDir, { recursive: true })
    }

    // Convertir le fichier en buffer et l'écrire
    const bytes = await file.arrayBuffer()
    const buffer = Buffer.from(bytes)
    
    // Écrire dans le dossier de sauvegarde (historique)
    await writeFile(filePath, buffer)
    
    // Écrire dans le dossier statique (comme le Hero)
    await writeFile(staticFilePath, buffer)

    // URL publique du fichier (chemin statique comme le Hero)
    const staticUrl = type === 'image' ? '/images/entry/entry-bg.jpg' : '/videos/entry/entry-bg.mp4'
    const publicUrl = `/media/entry/${type}/${fullFileName}`

    // Sauvegarder les métadonnées du fichier en base de données
    let mediaFileId: number | null = null
    try {
      const mediaData = {
        filename: fullFileName,
        original_filename: file.name,
        file_path: filePath,
        file_url: publicUrl,
        file_type: type as 'image' | 'video',
        mime_type: file.type,
        file_size: file.size,
        is_active: true,
        uploaded_by: 'admin', // TODO: Récupérer l'utilisateur connecté
        context: 'entry_page',
        context_id: 1
      }

      const savedMediaFile = await createMediaFile(mediaData)
      mediaFileId = savedMediaFile.id
      console.log(`Fichier média sauvegardé en base de données avec l'ID: ${mediaFileId}`)
    } catch (dbError) {
      console.error('Erreur lors de la sauvegarde des métadonnées:', dbError)
      // On continue même si la sauvegarde des métadonnées échoue
    }

    // Mettre à jour automatiquement la configuration dans la base de données
    try {
      const updateData: any = { id: 1 } // ID de la configuration active
      
      if (type === 'image') {
        updateData.background_image_url = staticUrl
        updateData.background_type = 'image'
      } else if (type === 'video') {
        updateData.background_video_url = staticUrl
        updateData.background_type = 'video'
      }
      
      await updateEntryPageConfig(updateData)
      console.log(`Configuration mise à jour avec ${type}: ${staticUrl}`)
    } catch (dbError) {
      console.error('Erreur lors de la mise à jour de la configuration:', dbError)
      // On continue même si la mise à jour de la BDD échoue
    }

    return NextResponse.json({
      name: fullFileName,
      url: staticUrl,
      type: type as 'image' | 'video',
      size: file.size,
      lastModified: new Date().toISOString(),
      mediaFileId: mediaFileId,
      savedInDatabase: mediaFileId !== null
    })

  } catch (error) {
    console.error('Erreur lors de l\'upload:', error)
    return NextResponse.json(
      { error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}
