import { NextRequest, NextResponse } from 'next/server'
import { getSmtpConfigDecrypted } from '@/lib/database'
import { MailerService } from '@/lib/mailer'

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    
    // Initialiser le service mailer
    const mailerService = new MailerService()
    const isInitialized = await mailerService.initialize()
    
    if (!isInitialized) {
      return NextResponse.json(
        {
          success: false,
          message: 'Configuration SMTP non trouvée ou invalide. Veuillez configurer SMTP dans l\'interface d\'administration.'
        },
        { status: 400 }
      )
    }

    // Déterminer le destinataire et le message
    let to: string
    let subject: string
    let text: string
    let html: string

    if (body.testEmail) {
      // Email de test
      to = body.testEmail
      subject = 'Test SMTP - U Silenziu'
      text = body.message || 'Ceci est un email de test pour vérifier la configuration SMTP d\'U Silenziu.'
      html = `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #8B7355;">Test SMTP - U Silenziu</h2>
          <p>${body.message || 'Ceci est un email de test pour vérifier la configuration SMTP d\'U Silenziu.'}</p>
          <hr style="border: 1px solid #ddd; margin: 20px 0;">
          <p style="color: #666; font-size: 12px;">
            Cet email a été envoyé automatiquement pour tester la configuration SMTP.<br>
            Timestamp: ${new Date().toLocaleString('fr-FR')}
          </p>
        </div>
      `
    } else if (body.reservationId) {
      // Email de confirmation de réservation
      to = body.email
      subject = 'Confirmation de réservation - U Silenziu'
      text = `Votre réservation pour ${body.roomName} le ${body.date} à ${body.timeSlot} a été confirmée.`
      html = `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #8B7355;">Confirmation de réservation - U Silenziu</h2>
          <p>Bonjour ${body.firstName} ${body.lastName},</p>
          <p>Votre réservation a été confirmée avec succès !</p>
          <div style="background: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0;">
            <h3>Détails de votre réservation :</h3>
            <p><strong>Salle :</strong> ${body.roomName}</p>
            <p><strong>Date :</strong> ${body.date}</p>
            <p><strong>Heure :</strong> ${body.timeSlot}</p>
            <p><strong>Durée :</strong> ${body.duration} minutes</p>
            <p><strong>Nombre de personnes :</strong> ${body.numberOfPeople}</p>
            <p><strong>Numéro de réservation :</strong> ${body.reservationNumber}</p>
          </div>
          <p>Nous vous attendons avec impatience !</p>
          <hr style="border: 1px solid #ddd; margin: 20px 0;">
          <p style="color: #666; font-size: 12px;">
            U Silenziu - Zone de défoulement<br>
            Buros, France
          </p>
        </div>
      `
    } else {
      return NextResponse.json(
        {
          success: false,
          message: 'Paramètres manquants. Spécifiez soit testEmail soit reservationId.'
        },
        { status: 400 }
      )
    }

    // Envoyer l'email réel
    console.log('Envoi d\'email à:', to)
    
    const result = await mailerService.sendEmail({
      to: to,
      subject: subject,
      html: html,
      text: text
    })

    if (result.success) {
      console.log('Email envoyé avec succès à:', to, 'Message ID:', result.messageId)
      return NextResponse.json({
        success: true,
        message: body.testEmail ? 'Email de test envoyé avec succès ! Vérifiez votre boîte de réception et vos spams.' : 'Email de confirmation envoyé avec succès !',
        messageId: result.messageId,
        timestamp: new Date().toISOString()
      })
    } else {
      console.error('Échec de l\'envoi d\'email:', result.error)
      return NextResponse.json({
        success: false,
        message: `Erreur lors de l'envoi de l'email: ${result.error || 'Erreur inconnue'}. Vérifiez la configuration SMTP.`
      }, { status: 500 })
    }

  } catch (error) {
    console.error('Erreur lors de l\'envoi de notification:', error)
    
    // Messages d'erreur plus détaillés
    let errorMessage = 'Erreur lors de l\'envoi de notification'
    
    if (error instanceof Error) {
      if (error.message.includes('Invalid login')) {
        errorMessage = 'Identifiants SMTP incorrects. Vérifiez le nom d\'utilisateur et le mot de passe.'
      } else if (error.message.includes('wrong version number')) {
        errorMessage = 'Erreur SSL/TLS. Essayez de décocher "Connexion sécurisée" pour Office 365.'
      } else if (error.message.includes('ECONNREFUSED')) {
        errorMessage = 'Connexion refusée. Vérifiez l\'hôte et le port SMTP.'
      } else if (error.message.includes('timeout')) {
        errorMessage = 'Délai d\'attente dépassé. Vérifiez votre connexion internet et les paramètres SMTP.'
      } else {
        errorMessage = `Erreur SMTP: ${error.message}`
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
