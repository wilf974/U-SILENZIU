import { NextRequest, NextResponse } from 'next/server'
import nodemailer from 'nodemailer'

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    
    // Validation des données
    const requiredFields = ['host', 'port', 'username', 'password']
    for (const field of requiredFields) {
      if (!body[field]) {
        return NextResponse.json(
          {
            success: false,
            message: `Le champ ${field} est requis`
          },
          { status: 400 }
        )
      }
    }

    // Créer le transporteur SMTP pour le test
    const transporter = nodemailer.createTransport({
      host: body.host,
      port: body.port,
      secure: body.secure || false,
      auth: {
        user: body.username,
        pass: body.password
      },
      tls: {
        rejectUnauthorized: body.tlsRejectUnauthorized !== false,
        minVersion: body.tlsMinVersion || 'TLSv1.2'
      }
    } as any)

    // Tester la connexion
    await transporter.verify()
    
    console.log('Test SMTP réussi pour:', body.host)

    return NextResponse.json({
      success: true,
      message: `Connexion SMTP réussie à ${body.host}:${body.port}`,
      details: {
        host: body.host,
        port: body.port,
        secure: body.secure,
        username: body.username
      }
    })

  } catch (error) {
    console.error('Erreur lors du test SMTP:', error)
    
    // Messages d'erreur détaillés
    let errorMessage = 'Erreur lors du test de connexion SMTP'
    
    if (error instanceof Error) {
      if (error.message.includes('Invalid login')) {
        errorMessage = 'Identifiants incorrects. Vérifiez le nom d\'utilisateur et le mot de passe.'
      } else if (error.message.includes('wrong version number')) {
        errorMessage = 'Erreur SSL/TLS. Essayez de décocher "Connexion sécurisée" pour Office 365.'
      } else if (error.message.includes('ECONNREFUSED')) {
        errorMessage = 'Connexion refusée. Vérifiez l\'hôte et le port SMTP.'
      } else if (error.message.includes('timeout')) {
        errorMessage = 'Délai d\'attente dépassé. Vérifiez votre connexion internet.'
      } else if (error.message.includes('ENOTFOUND')) {
        errorMessage = 'Hôte SMTP introuvable. Vérifiez l\'adresse du serveur.'
      } else {
        errorMessage = `Erreur de connexion: ${error.message}`
      }
    }

    return NextResponse.json(
      {
        success: false,
        message: errorMessage,
        error: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}

// Gérer les autres méthodes HTTP
export async function GET() {
  return NextResponse.json(
    { message: 'Cette API n\'accepte que les requêtes POST' },
    { status: 405 }
  )
}
