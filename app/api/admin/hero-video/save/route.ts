import { NextRequest, NextResponse } from 'next/server'
import { Pool } from 'pg'

export const dynamic = 'force-dynamic'

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://usilenzio_user:usilenzio_password_2024@postgres:5432/usilenzio',
})

/**
 * POST /api/admin/hero-video/save
 * Sauvegarde l'URL de la vidéo hero dans la base de données
 */
export async function POST(request: NextRequest) {
  try {
    // Vérifier l'authentification admin
    const token = request.cookies.get('admin_token')?.value
    if (!token) {
      return NextResponse.json(
        { error: 'Non authentifié' },
        { status: 401 }
      )
    }

    const body = await request.json()
    const { videoUrl } = body

    if (!videoUrl || typeof videoUrl !== 'string') {
      return NextResponse.json(
        { error: 'URL de vidéo invalide' },
        { status: 400 }
      )
    }

    const client = await pool.connect()

    try {
      // Mettre à jour ou créer la configuration homepage avec la vidéo hero
      const result = await client.query(
        `UPDATE homepage_config
         SET video_url = $1, updated_at = NOW()
         WHERE id = 1
         RETURNING id, video_url, updated_at`,
        [videoUrl]
      )

      if (result.rows.length === 0) {
        // Si aucune ligne n'existe, en créer une
        const insertResult = await client.query(
          `INSERT INTO homepage_config (id, video_url, created_at, updated_at)
           VALUES (1, $1, NOW(), NOW())
           RETURNING id, video_url, updated_at`,
          [videoUrl]
        )

        return NextResponse.json({
          success: true,
          message: 'Vidéo hero sauvegardée avec succès',
          videoUrl: insertResult.rows[0].video_url,
          updatedAt: insertResult.rows[0].updated_at
        })
      }

      return NextResponse.json({
        success: true,
        message: 'Vidéo hero mise à jour avec succès',
        videoUrl: result.rows[0].video_url,
        updatedAt: result.rows[0].updated_at
      })

    } finally {
      client.release()
    }

  } catch (error) {
    console.error('Erreur lors de la sauvegarde:', error)
    return NextResponse.json(
      { error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}

/**
 * GET /api/admin/hero-video/save
 * Récupère l'URL actuelle de la vidéo hero
 */
export async function GET(request: NextRequest) {
  try {
    // Vérifier l'authentification admin
    const token = request.cookies.get('admin_token')?.value
    if (!token) {
      return NextResponse.json(
        { error: 'Non authentifié' },
        { status: 401 }
      )
    }

    const client = await pool.connect()

    try {
      const result = await client.query(
        `SELECT video_url FROM homepage_config WHERE id = 1`
      )

      const videoUrl = result.rows.length > 0 ? result.rows[0].video_url : '/video/hero-video.mp4'

      return NextResponse.json({
        success: true,
        videoUrl
      })

    } finally {
      client.release()
    }

  } catch (error) {
    console.error('Erreur lors de la récupération:', error)
    return NextResponse.json(
      { error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}
