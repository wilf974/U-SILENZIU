import { NextResponse } from 'next/server'
import { getSmtpConfig } from '@/lib/database'
import nodemailer from 'nodemailer'

export async function GET() {
  try {
    const config = await getSmtpConfig()
    
    if (!config) {
      return NextResponse.json({
        success: false,
        message: 'Aucune configuration SMTP trouvée',
        configured: false
      })
    }

    // Retourner les informations de configuration (sans tester la connexion car mot de passe chiffré)
    return NextResponse.json({
      success: true,
      message: 'Configuration SMTP trouvée',
      configured: true,
      host: config.host,
      port: config.port,
      username: config.username,
      secure: config.secure,
      from_email: config.from_email,
      note: 'Le mot de passe est chiffré, impossible de tester la connexion sans déchiffrement'
    })

  } catch (error) {
    console.error('Erreur lors de la vérification du statut SMTP:', error)
    return NextResponse.json(
      {
        success: false,
        message: 'Erreur lors de la vérification du statut',
        configured: false,
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
