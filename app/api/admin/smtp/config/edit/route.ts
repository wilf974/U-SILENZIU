import { NextResponse } from 'next/server'
import { getSmtpConfig } from '@/lib/database'

export async function GET() {
  try {
    const config = await getSmtpConfig()
    
    if (!config) {
      return NextResponse.json({
        success: false,
        message: 'Aucune configuration SMTP trouvée',
        config: null
      })
    }

    return NextResponse.json({
      success: true,
      message: 'Configuration SMTP récupérée avec succès',
      config: config
    })

  } catch (error) {
    console.error('Erreur lors de la récupération de la configuration SMTP:', error)
    return NextResponse.json(
      {
        success: false,
        message: 'Erreur lors de la récupération de la configuration',
        error: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}

// Gérer les autres méthodes HTTP
export async function POST() {
  return NextResponse.json(
    { message: 'Cette API n\'accepte que les requêtes GET' },
    { status: 405 }
  )
}
