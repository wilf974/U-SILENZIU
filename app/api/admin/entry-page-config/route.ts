import { NextRequest, NextResponse } from 'next/server'
import { Pool } from 'pg'

// Configuration de la base de données PostgreSQL
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://usilenzio_user:usilenzio_password_2024@localhost:5432/usilenzio',
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
})

// Fonction utilitaire pour exécuter des requêtes
async function query(text: string, params?: any[]) {
  const client = await pool.connect()
  try {
    const result = await client.query(text, params)
    return result
  } finally {
    client.release()
  }
}

/**
 * Interface pour la configuration de la page d'entrée
 */
interface EntryPageConfig {
  id: number
  title: string
  subtitle: string
  description: string
  button_text: string
  background_type: 'image' | 'video'
  background_image_url?: string
  background_video_url?: string
  is_active: boolean
  created_at: string
  updated_at: string
}

/**
 * GET /api/admin/entry-page-config
 * Récupère la configuration de la page d'entrée
 */
export async function GET() {
  try {
    const result = await query(
      'SELECT * FROM entry_page_config WHERE is_active = true ORDER BY created_at DESC LIMIT 1'
    )

    if (result.rows.length === 0) {
      // Créer une configuration par défaut si aucune n'existe
      const defaultConfig = await query(`
        INSERT INTO entry_page_config (
          title, subtitle, description, button_text, 
          background_type, background_image_url, is_active
        ) VALUES (
          $1, $2, $3, $4, $5, $6, $7
        ) RETURNING *
      `, [
        'U SILENZIU',
        'Zone de défoulement', 
        'Libérez votre stress dans nos salles sécurisées',
        'ENTRER DANS LE SITE',
        'image',
        '/images/entry/entry-bg.jpg',
        true
      ])
      
      return NextResponse.json(defaultConfig.rows[0])
    }

    return NextResponse.json(result.rows[0])
  } catch (error) {
    console.error('Erreur lors de la récupération de la configuration:', error)
    return NextResponse.json(
      { error: 'Erreur lors de la récupération de la configuration' },
      { status: 500 }
    )
  }
}

/**
 * PUT /api/admin/entry-page-config
 * Met à jour la configuration de la page d'entrée
 */
export async function PUT(request: NextRequest) {
  try {
    const body: Partial<EntryPageConfig> = await request.json()

    // Validation des données requises
    if (!body.title || !body.subtitle || !body.description || !body.button_text) {
      return NextResponse.json(
        { error: 'Tous les champs requis doivent être renseignés' },
        { status: 400 }
      )
    }

    // Validation du type d'arrière-plan
    if (body.background_type && !['image', 'video'].includes(body.background_type)) {
      return NextResponse.json(
        { error: 'Le type d\'arrière-plan doit être "image" ou "video"' },
        { status: 400 }
      )
    }

    // Vérifier si une configuration existe
    const existingResult = await query(
      'SELECT id FROM entry_page_config ORDER BY created_at DESC LIMIT 1'
    )

    let result

    if (existingResult.rows.length === 0) {
      // Créer une nouvelle configuration
      result = await query(`
        INSERT INTO entry_page_config (
          title, subtitle, description, button_text, background_type,
          background_image_url, background_video_url, is_active
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        RETURNING *
      `, [
        body.title,
        body.subtitle,
        body.description,
        body.button_text,
        body.background_type || 'image',
        body.background_image_url || null,
        body.background_video_url || null,
        body.is_active !== undefined ? body.is_active : true
      ])
    } else {
      // Mettre à jour la configuration existante
      const configId = existingResult.rows[0].id
      result = await query(`
        UPDATE entry_page_config 
        SET 
          title = $1,
          subtitle = $2, 
          description = $3,
          button_text = $4,
          background_type = $5,
          background_image_url = $6,
          background_video_url = $7,
          is_active = $8,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = $9
        RETURNING *
      `, [
        body.title,
        body.subtitle,
        body.description,
        body.button_text,
        body.background_type || 'image',
        body.background_image_url || null,
        body.background_video_url || null,
        body.is_active !== undefined ? body.is_active : true,
        configId
      ])
    }

    return NextResponse.json(result.rows[0])
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la configuration:', error)
    return NextResponse.json(
      { error: 'Erreur lors de la mise à jour de la configuration' },
      { status: 500 }
    )
  }
}

/**
 * POST /api/admin/entry-page-config
 * Crée une nouvelle configuration de page d'entrée
 */
export async function POST(request: NextRequest) {
  try {
    const body: Partial<EntryPageConfig> = await request.json()

    // Validation des données requises
    if (!body.title || !body.subtitle || !body.description || !body.button_text) {
      return NextResponse.json(
        { error: 'Tous les champs requis doivent être renseignés' },
        { status: 400 }
      )
    }

    // Désactiver les configurations existantes
    await query('UPDATE entry_page_config SET is_active = false')

    // Créer la nouvelle configuration
    const result = await query(`
      INSERT INTO entry_page_config (
        title, subtitle, description, button_text, background_type,
        background_image_url, background_video_url, is_active
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING *
    `, [
      body.title,
      body.subtitle,
      body.description,
      body.button_text,
      body.background_type || 'image',
      body.background_image_url || null,
      body.background_video_url || null,
      true
    ])

    return NextResponse.json(result.rows[0], { status: 201 })
  } catch (error) {
    console.error('Erreur lors de la création de la configuration:', error)
    return NextResponse.json(
      { error: 'Erreur lors de la création de la configuration' },
      { status: 500 }
    )
  }
}
