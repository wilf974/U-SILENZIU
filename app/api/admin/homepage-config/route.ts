import { NextRequest, NextResponse } from 'next/server'
import { Pool } from 'pg'

export const dynamic = 'force-dynamic'

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://usilenzio_user:usilenzio_password_2024@postgres:5432/usilenzio',
})

/**
 * GET /api/admin/homepage-config
 * Récupère la configuration générale de la page d'accueil
 */
export async function GET() {
  try {
    const client = await pool.connect()
    
    try {
      // Récupérer la configuration générale
      const configResult = await client.query(`
        SELECT * FROM homepage_config 
        WHERE is_active = true 
        ORDER BY created_at DESC 
        LIMIT 1
      `)

      if (configResult.rows.length === 0) {
        // Créer une configuration par défaut
        const defaultConfig = await client.query(`
          INSERT INTO homepage_config (
            site_title, site_description, site_name, 
            contact_email, contact_phone, address, 
            opening_hours, seo_keywords, seo_description,
            is_active
          ) VALUES (
            $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
          ) RETURNING *
        `, [
          'U SILENZIU',
          'Votre zone de défoulement à Buros. Libérez votre stress et vos tensions dans un environnement sécurisé et fun.',
          'U SILENZIU',
          'contact@usilenziu.com',
          '05 59 12 34 56',
          '123 Rue de la Libération, 64400 Buros',
          'Mardi au Jeudi: 14:00 - 21:00\nVendredi au Samedi: 14:00 - 00:00\nDimanche: Sur réservation uniquement',
          'défoulement, stress, rage room, Buros, relaxation',
          'U Silenziu - Zone de défoulement à Buros. Libérez votre stress dans nos salles sécurisées.',
          true
        ])

        return NextResponse.json({
          success: true,
          data: defaultConfig.rows[0]
        })
      }

      return NextResponse.json({
        success: true,
        data: configResult.rows[0]
      })

    } finally {
      client.release()
    }
  } catch (error) {
    console.error('Erreur lors de la récupération de la configuration homepage:', error)
    return NextResponse.json({
      success: false,
      error: 'Erreur lors de la récupération de la configuration',
      details: error instanceof Error ? error.message : 'Erreur inconnue'
    }, { status: 500 })
  }
}

/**
 * PUT /api/admin/homepage-config
 * Met à jour la configuration générale de la page d'accueil
 */
export async function PUT(request: NextRequest) {
  try {
    const body = await request.json()
    const client = await pool.connect()
    
    try {
      // Désactiver les configurations existantes
      await client.query('UPDATE homepage_config SET is_active = false')

      // Créer la nouvelle configuration
      const result = await client.query(`
        INSERT INTO homepage_config (
          site_title, site_description, site_name,
          contact_email, contact_phone, address,
          opening_hours, seo_keywords, seo_description,
          is_active
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        RETURNING *
      `, [
        body.site_title || 'U SILENZIU',
        body.site_description || '',
        body.site_name || 'U SILENZIU',
        body.contact_email || '',
        body.contact_phone || '',
        body.address || '',
        body.opening_hours || '',
        body.seo_keywords || '',
        body.seo_description || '',
        true
      ])

      return NextResponse.json({
        success: true,
        message: 'Configuration mise à jour avec succès',
        data: result.rows[0]
      })

    } finally {
      client.release()
    }
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la configuration homepage:', error)
    return NextResponse.json({
      success: false,
      error: 'Erreur lors de la mise à jour de la configuration',
      details: error instanceof Error ? error.message : 'Erreur inconnue'
    }, { status: 500 })
  }
}