import { NextRequest, NextResponse } from 'next/server'
import { writeFile, copyFile, readdir, unlink, access, mkdir } from 'fs/promises'
import { join } from 'path'
import { ADMIN_TOKEN_COOKIE, verifyAdminToken } from '@/lib/auth'

export const runtime = 'nodejs'

/**
 * POST /api/admin/video/hero/upload
 * Upload une nouvelle vidéo hero avec backup de l'ancienne
 * Authentification requise (cookie admin_token)
 */
export async function POST(request: NextRequest) {
  try {
    // Vérifier l'authentification
    const token = request.cookies.get(ADMIN_TOKEN_COOKIE)?.value

    if (!token) {
      return NextResponse.json(
        { success: false, error: 'Non authentifié - Token requis' },
        { status: 401 }
      )
    }

    // Vérifier la validité du token
    try {
      verifyAdminToken(token)
    } catch (error) {
      return NextResponse.json(
        { success: false, error: 'Token invalide ou expiré' },
        { status: 401 }
      )
    }

    // Récupérer le fichier du formulaire
    const formData = await request.formData()
    const file = formData.get('video') as File

    if (!file) {
      return NextResponse.json(
        { success: false, error: 'Aucune vidéo fournie' },
        { status: 400 }
      )
    }

    // Vérifier le type de fichier
    if (!file.type.startsWith('video/')) {
      return NextResponse.json(
        { success: false, error: 'Le fichier doit être une vidéo' },
        { status: 400 }
      )
    }

    // Vérifier la taille (max 50MB)
    const maxSize = 50 * 1024 * 1024
    if (file.size > maxSize) {
      return NextResponse.json(
        { success: false, error: 'La vidéo ne doit pas dépasser 50MB' },
        { status: 400 }
      )
    }

    // Obtenir le chemin du répertoire et du fichier
    // En production, on écrit dans /tmp (volume Docker)
    const videoDir = process.env.VIDEO_UPLOAD_DIR || '/tmp/hero-video'
    const heroVideoPath = join(videoDir, 'hero-video.mp4')
    const backupPath = join(videoDir, `hero-video.backup-${Date.now()}.mp4`)

    // Créer le répertoire s'il n'existe pas
    try {
      await mkdir(videoDir, { recursive: true })
    } catch (error) {
      console.error('Erreur lors de la création du répertoire:', error)
    }

    // Backup de l'ancienne vidéo si elle existe
    let backupCreated = false
    try {
      await access(heroVideoPath)
      // Le fichier existe, on le sauvegarde
      await copyFile(heroVideoPath, backupPath)
      backupCreated = true
      console.log(`Backup créé: ${backupPath}`)
    } catch (error) {
      // Le fichier n'existe pas, ce n'est pas grave
      console.log('Aucune vidéo existante à sauvegarder')
    }

    // Écrire la nouvelle vidéo
    const bytes = await file.arrayBuffer()
    const buffer = Buffer.from(bytes)

    try {
      await writeFile(heroVideoPath, buffer)
    } catch (error) {
      console.error('Erreur lors de l\'écriture du fichier vidéo:', error)

      // Essayer de restaurer le backup en cas d'erreur
      if (backupCreated) {
        try {
          await copyFile(backupPath, heroVideoPath)
          console.log('Vidéo restaurée depuis le backup')
        } catch (restoreError) {
          console.error('Erreur lors de la restauration du backup:', restoreError)
        }
      }

      return NextResponse.json(
        { success: false, error: 'Erreur lors de l\'upload de la vidéo' },
        { status: 500 }
      )
    }

    // Nettoyer les anciens backups (garder seulement les 3 derniers)
    try {
      const files = await readdir(videoDir)
      const backupFiles = files
        .filter(f => f.startsWith('hero-video.backup-') && f.endsWith('.mp4'))
        .sort()
        .reverse()

      // Supprimer les backups au-delà du 3e
      if (backupFiles.length > 3) {
        for (let i = 3; i < backupFiles.length; i++) {
          const oldBackup = join(videoDir, backupFiles[i])
          try {
            await unlink(oldBackup)
            console.log(`Ancien backup supprimé: ${backupFiles[i]}`)
          } catch (error) {
            console.error(`Erreur lors de la suppression du backup ${backupFiles[i]}:`, error)
          }
        }
      }
    } catch (error) {
      console.error('Erreur lors du nettoyage des backups:', error)
    }

    return NextResponse.json({
      success: true,
      message: 'Vidéo hero uploadée avec succès',
      data: {
        filename: 'hero-video.mp4',
        size: file.size,
        type: file.type,
        backup_created: backupCreated,
        backup_path: backupCreated ? backupPath : null,
        public_url: '/video/hero-video.mp4'
      }
    })

  } catch (error) {
    console.error('Erreur lors de l\'upload de la vidéo hero:', error)
    return NextResponse.json(
      { success: false, error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}

/**
 * GET /api/admin/video/hero/upload
 * Informations sur l'API d'upload
 */
export async function GET() {
  return NextResponse.json({
    success: true,
    endpoint: 'POST /api/admin/video/hero/upload',
    description: 'Upload une nouvelle vidéo hero avec backup automatique',
    requirements: {
      authentication: 'admin_token cookie requis',
      file_type: 'video/* (mp4, webm, mov, avi, etc.)',
      max_size: '50MB'
    },
    backup: {
      enabled: true,
      max_backups: 3,
      naming_pattern: 'hero-video.backup-{timestamp}.mp4'
    }
  })
}
