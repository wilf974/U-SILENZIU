import { NextRequest, NextResponse } from 'next/server'
import { readdir, stat } from 'fs/promises'
import { join } from 'path'
import { existsSync } from 'fs'

export async function GET(request: NextRequest) {
  try {
    const uploadsDir = join(process.cwd(), 'public', 'uploads')
    
    // Vérifier si le dossier existe
    if (!existsSync(uploadsDir)) {
      return NextResponse.json({
        error: 'Dossier uploads inexistant',
        uploadsDir,
        cwd: process.cwd()
      })
    }

    // Lister les fichiers dans le dossier
    const files = await readdir(uploadsDir)
    const fileStats = []

    for (const file of files) {
      const filePath = join(uploadsDir, file)
      const stats = await stat(filePath)
      fileStats.push({
        name: file,
        size: stats.size,
        path: filePath,
        url: `/uploads/${file}`
      })
    }

    return NextResponse.json({
      success: true,
      uploadsDir,
      cwd: process.cwd(),
      files: fileStats,
      count: files.length
    })

  } catch (error) {
    console.error('Erreur lors du test:', error)
    return NextResponse.json({
      error: 'Erreur lors du test',
      details: error instanceof Error ? error.message : 'Erreur inconnue'
    }, { status: 500 })
  }
}
