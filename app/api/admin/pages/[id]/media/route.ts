import { NextRequest, NextResponse } from 'next/server'
import { writeFile, mkdir } from 'fs/promises'
import { join } from 'path'
import { existsSync } from 'fs'

/**
 * POST /api/admin/pages/[id]/media
 * Upload un média pour une page spécifique
 */
export async function POST(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params
    
    if (!id) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'ID de page requis' 
        },
        { status: 400 }
      )
    }

    const formData = await request.formData()
    const file = formData.get('file') as File
    
    if (!file) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Aucun fichier fourni' 
        },
        { status: 400 }
      )
    }

    // Validation du type de fichier
    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp']
    if (!allowedTypes.includes(file.type)) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Type de fichier non autorisé. Utilisez JPEG, PNG, GIF ou WebP' 
        },
        { status: 400 }
      )
    }

    // Validation de la taille (max 5MB)
    const maxSize = 5 * 1024 * 1024 // 5MB
    if (file.size > maxSize) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Fichier trop volumineux. Taille maximum : 5MB' 
        },
        { status: 400 }
      )
    }

    // Créer le dossier de destination s'il n'existe pas
    const uploadDir = join(process.cwd(), 'public', 'uploads', 'pages', id)
    if (!existsSync(uploadDir)) {
      await mkdir(uploadDir, { recursive: true })
    }

    // Générer un nom de fichier unique
    const timestamp = Date.now()
    const extension = file.name.split('.').pop()
    const filename = `media-${timestamp}.${extension}`
    const filepath = join(uploadDir, filename)

    // Convertir le fichier en buffer et l'écrire
    const bytes = await file.arrayBuffer()
    const buffer = Buffer.from(bytes)
    await writeFile(filepath, buffer)

    // Retourner l'URL du fichier
    const fileUrl = `/uploads/pages/${id}/${filename}`
    
    return NextResponse.json({
      success: true,
      data: {
        url: fileUrl,
        filename: filename,
        size: file.size,
        type: file.type
      },
      message: 'Média uploadé avec succès'
    })
    
  } catch (error) {
    console.error('Erreur lors de l\'upload du média:', error)
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de l\'upload du média',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}

/**
 * GET /api/admin/pages/[id]/media
 * Récupérer la liste des médias d'une page
 */
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params
    
    if (!id) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'ID de page requis' 
        },
        { status: 400 }
      )
    }

    // Pour l'instant, on retourne un tableau vide
    // Cette fonction pourrait être étendue pour scanner le dossier des médias
    return NextResponse.json({
      success: true,
      data: [],
      count: 0
    })
    
  } catch (error) {
    console.error('Erreur lors de la récupération des médias:', error)
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la récupération des médias',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}
