import { NextResponse } from 'next/server'
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
 * GET /api/entry-page-config
 * API publique pour récupérer la configuration de la page d'entrée
 */
export async function GET() {
  try {
    const result = await query(
      'SELECT * FROM entry_page_config WHERE is_active = true ORDER BY created_at DESC LIMIT 1'
    )

    if (result.rows.length === 0) {
      // Retourner une configuration par défaut si aucune n'existe
      const defaultConfig: Omit<EntryPageConfig, 'id' | 'created_at' | 'updated_at'> = {
        title: 'U SILENZIU',
        subtitle: 'Zone de défoulement',
        description: 'Libérez votre stress dans nos salles sécurisées',
        button_text: 'ENTRER DANS LE SITE',
        background_type: 'image',
        background_image_url: '/images/entry/entry-bg.jpg',
        background_video_url: undefined,
        is_active: true
      }

      return NextResponse.json(defaultConfig)
    }

    // Retourner seulement les champs nécessaires pour le front-end
    const config = result.rows[0]
    const publicConfig = {
      title: config.title,
      subtitle: config.subtitle,
      description: config.description,
      button_text: config.button_text,
      background_type: config.background_type,
      background_image_url: config.background_image_url,
      background_video_url: config.background_video_url,
      is_active: config.is_active
    }

    return NextResponse.json(publicConfig)
  } catch (error) {
    console.error('Erreur lors de la récupération de la configuration:', error)
    
    // En cas d'erreur, retourner une configuration par défaut
    const fallbackConfig = {
      title: 'U SILENZIU',
      subtitle: 'Zone de défoulement',
      description: 'Libérez votre stress dans nos salles sécurisées',
      button_text: 'ENTRER DANS LE SITE',
      background_type: 'image' as const,
      background_image_url: '/images/entry/entry-bg.jpg',
      background_video_url: undefined,
      is_active: true
    }

    return NextResponse.json(fallbackConfig)
  }
}

/**
 * OPTIONS /api/entry-page-config
 * Gestion des requêtes CORS
 */
export async function OPTIONS() {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    },
  })
}
