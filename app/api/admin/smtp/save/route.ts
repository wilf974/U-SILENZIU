import { NextRequest, NextResponse } from 'next/server'
import { saveSmtpConfig } from '@/lib/database'

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

    // Validation spécifique pour secure (peut être false)
    console.log('Body reçu:', body) // Debug
    console.log('Type de secure:', typeof body.secure, 'Valeur:', body.secure) // Debug
    
    // Le champ secure peut être undefined, true, ou false
    // Si undefined, on utilise false par défaut
    if (body.secure !== undefined && typeof body.secure !== 'boolean') {
      return NextResponse.json(
        {
          success: false,
          message: 'Le champ secure doit être un booléen'
        },
        { status: 400 }
      )
    }

    // Validation du port
    if (body.port < 1 || body.port > 65535) {
      return NextResponse.json(
        {
          success: false,
          message: 'Le port doit être entre 1 et 65535'
        },
        { status: 400 }
      )
    }

    const config = await saveSmtpConfig({
        host: body.host,
        port: body.port,
        secure: body.secure ?? false, // Valeur par défaut si non définie
        username: body.username,
        password_encrypted: body.password, // Le mot de passe sera chiffré dans saveSmtpConfig
        from_email: body.fromEmail || body.username, // Utiliser username comme fallback
        tls_reject_unauthorized: body.tlsRejectUnauthorized ?? true,
        tls_min_version: body.tlsMinVersion ?? 'TLSv1.2',
        is_active: true
      })
    
    return NextResponse.json({
      success: true,
      message: 'Configuration SMTP sauvegardée avec succès',
      config: config
    })
  } catch (error) {
    console.error('Erreur lors de la sauvegarde de la configuration SMTP:', error)
    return NextResponse.json(
      {
        success: false,
        message: `Erreur lors de la sauvegarde de la configuration: ${error instanceof Error ? error.message : 'Erreur inconnue'}`
      },
      { status: 500 }
    )
  }
}
