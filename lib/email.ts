import nodemailer from 'nodemailer'
import { getSmtpConfigDecrypted } from './database'

// Configuration du transporteur email
const createTransporter = async () => {
  const smtpConfig = await getSmtpConfigDecrypted()
  
  if (!smtpConfig) {
    throw new Error('Configuration SMTP non trouvée')
  }

  return nodemailer.createTransport({
    host: smtpConfig.host,
    port: smtpConfig.port,
    secure: smtpConfig.secure,
    auth: {
      user: smtpConfig.username,
      pass: smtpConfig.password,
    },
    tls: {
      rejectUnauthorized: smtpConfig.tls_reject_unauthorized,
      minVersion: smtpConfig.tls_min_version as any,
    },
  })
}

// Interface pour les données de réservation
interface ReservationEmailData {
  reservationNumber: string
  customerName: string
  customerEmail: string
  customerPhone: string
  roomName: string
  date: string
  timeSlot: string
  duration: number
  participants: number
  amount: number
  specialRequests?: string
  paymentConfirmed?: boolean
  paymentStatus?: 'pending' | 'paid' | 'failed' | 'refunded'
}

/**
 * Envoie un email de confirmation de réservation
 */
export async function sendReservationConfirmationEmail(data: ReservationEmailData): Promise<boolean> {
  try {
    // Vérifier la config SMTP en base de données d'abord
    const smtpConfig = await getSmtpConfigDecrypted()
    
    if (!smtpConfig || !smtpConfig.is_active) {
      console.warn('Configuration SMTP manquante ou inactive, email non envoyé')
      return false
    }

    console.log('Configuration SMTP trouvée - initialisation du transporteur')
    const transporter = await createTransporter()
    console.log('Configuration SMTP initialisée avec succès')

    // Template HTML pour l'email
    const htmlTemplate = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>Confirmation de réservation - U Silenziu</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #6f8048; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }
          .reservation-details { background: white; padding: 20px; border-radius: 8px; margin: 20px 0; }
          .detail-row { display: flex; justify-content: space-between; margin: 10px 0; padding: 8px 0; border-bottom: 1px solid #eee; }
          .detail-label { font-weight: bold; color: #666; }
          .detail-value { color: #333; }
          .reservation-number { background: #6f8048; color: white; padding: 15px; text-align: center; border-radius: 8px; margin: 20px 0; font-size: 18px; font-weight: bold; }
          .footer { text-align: center; margin-top: 30px; color: #666; font-size: 14px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🎯 U Silenziu</h1>
            <h2>Confirmation de réservation</h2>
          </div>
          
          <div class="content">
            <p>Bonjour <strong>${data.customerName}</strong>,</p>
            
            <p>Votre demande de réservation a bien été reçue ! Nous vous recontacterons rapidement pour confirmer votre créneau.</p>
            
            <div class="reservation-number">
              Numéro de réservation : ${data.reservationNumber}
            </div>
            
            <div class="reservation-details">
              <h3>Détails de votre réservation</h3>
              
              <div class="detail-row">
                <span class="detail-label">Numéro :</span>
                <span class="detail-value">${data.reservationNumber}</span>
              </div>
              
              <div class="detail-row">
                <span class="detail-label">Nom :</span>
                <span class="detail-value">${data.customerName}</span>
              </div>
              
              <div class="detail-row">
                <span class="detail-label">Email :</span>
                <span class="detail-value">${data.customerEmail}</span>
              </div>
              
              <div class="detail-row">
                <span class="detail-label">Téléphone :</span>
                <span class="detail-value">${data.customerPhone}</span>
              </div>
              
              <div class="detail-row">
                <span class="detail-label">Date :</span>
                <span class="detail-value">${new Date(data.date).toLocaleDateString('fr-FR')}</span>
              </div>
              
              <div class="detail-row">
                <span class="detail-label">Heure :</span>
                <span class="detail-value">${data.timeSlot}</span>
              </div>
              
              <div class="detail-row">
                <span class="detail-label">Formule :</span>
                <span class="detail-value">${data.roomName}</span>
              </div>
              
              <div class="detail-row">
                <span class="detail-label">Durée :</span>
                <span class="detail-value">${data.duration} minutes</span>
              </div>
              
              <div class="detail-row">
                <span class="detail-label">Personnes :</span>
                <span class="detail-value">${data.participants}</span>
              </div>
              
              <div class="detail-row">
                <span class="detail-label">Prix par personne :</span>
                <span class="detail-value">${(data.amount / data.participants).toFixed(2)}€</span>
              </div>
              
              <div class="detail-row" style="border-bottom: none; font-weight: bold; font-size: 16px; background: #f0f0f0; padding: 15px; margin: 10px -20px -20px -20px; border-radius: 0 0 8px 8px;">
                <span class="detail-label">Total :</span>
                <span class="detail-value">${data.amount.toFixed(2)}€</span>
              </div>
            </div>
            
            ${data.paymentConfirmed ? `
              <div class="payment-status" style="background: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 15px; border-radius: 8px; margin: 20px 0;">
                <h3 style="margin: 0 0 10px 0; color: #155724;">✅ Paiement confirmé</h3>
                <p style="margin: 0; font-weight: bold;">Votre réservation est confirmée et payée !</p>
              </div>
            ` : data.paymentStatus === 'pending' ? `
              <div class="payment-status" style="background: #fff3cd; border: 1px solid #ffeaa7; color: #856404; padding: 15px; border-radius: 8px; margin: 20px 0;">
                <h3 style="margin: 0 0 10px 0; color: #856404;">⏳ Paiement en attente</h3>
                <p style="margin: 0;">Votre réservation est en attente de paiement. Vous recevrez un lien de paiement par email.</p>
              </div>
            ` : data.paymentStatus === 'failed' ? `
              <div class="payment-status" style="background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 15px; border-radius: 8px; margin: 20px 0;">
                <h3 style="margin: 0 0 10px 0; color: #721c24;">❌ Paiement échoué</h3>
                <p style="margin: 0;">Le paiement a échoué. Veuillez nous contacter pour finaliser votre réservation.</p>
              </div>
            ` : ''}
            
            ${data.specialRequests ? `
              <div class="reservation-details">
                <h3>Demandes spéciales</h3>
                <p>${data.specialRequests}</p>
              </div>
            ` : ''}
            
            ${data.paymentConfirmed ? `
              <p><strong>Votre réservation est confirmée !</strong></p>
              <ul>
                <li>Vous recevrez un rappel 24h avant votre session</li>
                <li>Présentez-vous 10 minutes avant l'heure prévue</li>
                <li>En cas d'annulation, contactez-nous au moins 24h à l'avance</li>
              </ul>
            ` : `
              <p><strong>Prochaines étapes :</strong></p>
              <ul>
                <li>Nous allons vérifier la disponibilité de votre créneau</li>
                <li>Vous recevrez un email de confirmation dans les 24h</li>
                <li>En cas de problème, nous vous contacterons par téléphone</li>
              </ul>
            `}
            
            <p>Merci de votre confiance et à bientôt chez U Silenziu !</p>
            
            <div class="footer">
              <p>U Silenziu - Zone de défoulement à Buros</p>
              <p>123 Rue de la Libération, 64400 Buros</p>
              <p>Tél: 05 59 12 34 56 | Email: contact@usilenziu.com</p>
            </div>
          </div>
        </div>
      </body>
      </html>
    `

    // Template texte simple
    const textTemplate = `
Confirmation de réservation - U Silenziu

Bonjour ${data.customerName},

Votre demande de réservation a bien été reçue !

Numéro de réservation : ${data.reservationNumber}

Détails de votre réservation :
- Nom : ${data.customerName}
- Email : ${data.customerEmail}
- Téléphone : ${data.customerPhone}
- Date : ${new Date(data.date).toLocaleDateString('fr-FR')}
- Heure : ${data.timeSlot}
- Formule : ${data.roomName}
- Durée : ${data.duration} minutes
- Personnes : ${data.participants}
- Prix par personne : ${(data.amount / data.participants).toFixed(2)}€
- Total : ${data.amount.toFixed(2)}€

${data.specialRequests ? `Demandes spéciales : ${data.specialRequests}` : ''}

Prochaines étapes :
- Nous allons vérifier la disponibilité de votre créneau
- Vous recevrez un email de confirmation dans les 24h
- En cas de problème, nous vous contacterons par téléphone

Merci de votre confiance et à bientôt chez U Silenziu !

U Silenziu - Zone de défoulement à Buros
123 Rue de la Libération, 64400 Buros
Tél: 05 59 12 34 56 | Email: contact@usilenziu.com
    `

    const mailOptions = {
      from: `"${smtpConfig.from_name || 'U Silenziu'}" <${smtpConfig.from_email}>`,
      to: data.customerEmail,
      subject: `Confirmation de réservation ${data.reservationNumber} - U Silenziu`,
      text: textTemplate,
      html: htmlTemplate,
    }

    console.log(`Envoi d'email à: ${data.customerEmail}`)

    const result = await transporter.sendMail(mailOptions)
    console.log(`Email envoyé avec succès: ${result.messageId}`)
    console.log(`Email envoyé avec succès à: ${data.customerEmail} Message ID: ${result.messageId}`)
    return true

  } catch (error) {
    console.error('Erreur lors de l\'envoi de l\'email de confirmation:', error)
    console.error('Détails de l\'erreur:', error instanceof Error ? error.message : 'Erreur inconnue')
    return false
  }
}

/**
 * Envoie un email de validation de réservation (confirmation admin)
 */
export const sendReservationValidationEmail = async (reservation: any) => {
  try {
    // Vérifier la config SMTP en base de données d'abord
    const smtpConfig = await getSmtpConfigDecrypted()
    
    if (!smtpConfig || !smtpConfig.is_active) {
      console.warn('Configuration SMTP manquante ou inactive, email de validation non envoyé')
      return false
    }

    console.log('Configuration SMTP trouvée - envoi email validation')
    const transporter = await createTransporter()

    const htmlTemplate = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>Réservation confirmée - U Silenziu</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #28a745; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }
          .reservation-details { background: white; padding: 20px; border-radius: 8px; margin: 20px 0; }
          .detail-row { display: flex; justify-content: space-between; margin: 10px 0; padding: 8px 0; border-bottom: 1px solid #eee; }
          .detail-label { font-weight: bold; color: #666; }
          .detail-value { color: #333; }
          .reservation-number { background: #28a745; color: white; padding: 15px; text-align: center; border-radius: 8px; margin: 20px 0; font-size: 18px; font-weight: bold; }
          .footer { text-align: center; margin-top: 30px; color: #666; font-size: 14px; }
          .confirmed-badge { background: #28a745; color: white; padding: 10px 20px; border-radius: 20px; display: inline-block; margin: 10px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>✅ U Silenziu</h1>
            <h2>Réservation Confirmée !</h2>
          </div>
          
          <div class="content">
            <div class="confirmed-badge">
              ✅ RÉSERVATION CONFIRMÉE
            </div>
            
            <p>Bonjour <strong>${reservation.customer_name}</strong>,</p>
            
            <p><strong>Excellente nouvelle !</strong> Votre réservation a été confirmée par notre équipe.</p>
            
            <div class="reservation-number">
              Numéro de réservation : ${reservation.reservation_number}
            </div>
            
            <div class="reservation-details">
              <h3>Détails de votre réservation confirmée</h3>
              
              <div class="detail-row">
                <span class="detail-label">Statut :</span>
                <span class="detail-value" style="color: #28a745; font-weight: bold;">✅ CONFIRMÉE</span>
              </div>
              
              <div class="detail-row">
                <span class="detail-label">Date :</span>
                <span class="detail-value">${new Date(reservation.date).toLocaleDateString('fr-FR')}</span>
              </div>
              
              <div class="detail-row">
                <span class="detail-label">Heure :</span>
                <span class="detail-value">${reservation.time_slot}</span>
              </div>
              
              <div class="detail-row">
                <span class="detail-label">Formule :</span>
                <span class="detail-value">${reservation.room_name}</span>
              </div>
              
              <div class="detail-row">
                <span class="detail-label">Durée :</span>
                <span class="detail-value">${reservation.duration} minutes</span>
              </div>
              
              <div class="detail-row">
                <span class="detail-label">Personnes :</span>
                <span class="detail-value">${reservation.participants}</span>
              </div>
              
              <div class="detail-row" style="border-bottom: none; font-weight: bold; font-size: 16px; background: #e8f5e8; padding: 15px; margin: 10px -20px -20px -20px; border-radius: 0 0 8px 8px;">
                <span class="detail-label">Total :</span>
                <span class="detail-value">${parseFloat(reservation.amount).toFixed(2)}€</span>
              </div>
            </div>
            
            <p><strong>Informations importantes :</strong></p>
            <ul>
              <li>✅ Votre créneau est maintenant réservé définitivement</li>
              <li>📍 Présentez-vous 15 minutes avant l'heure prévue</li>
              <li>🆔 Apportez une pièce d'identité</li>
              <li>👕 Portez des vêtements que vous pouvez salir</li>
              <li>📞 Contactez-nous si vous avez des questions</li>
            </ul>
            
            <p>Nous avons hâte de vous accueillir chez U Silenziu !</p>
            
            <div class="footer">
              <p>U Silenziu - Zone de défoulement à Buros</p>
              <p>123 Rue de la Libération, 64400 Buros</p>
              <p>Tél: 05 59 12 34 56 | Email: contact@usilenziu.com</p>
            </div>
          </div>
        </div>
      </body>
      </html>
    `

    const mailOptions = {
      from: `"${smtpConfig.from_name || 'U Silenziu'}" <${smtpConfig.from_email}>`,
      to: reservation.customer_email,
      subject: `✅ Réservation confirmée ${reservation.reservation_number} - U Silenziu`,
      html: htmlTemplate,
    }

    console.log(`Envoi d'email de validation à: ${reservation.customer_email}`)

    const result = await transporter.sendMail(mailOptions)
    console.log(`Email de validation envoyé avec succès: ${result.messageId}`)
    return true

  } catch (error) {
    console.error('Erreur lors de l\'envoi de l\'email de validation:', error)
    console.error('Détails de l\'erreur:', error instanceof Error ? error.message : 'Erreur inconnue')
    return false
  }
}

/**
 * Envoie un email d'annulation de réservation
 */
export const sendReservationCancellationEmail = async (reservation: any) => {
  try {
    // Vérifier la config SMTP en base de données d'abord
    const smtpConfig = await getSmtpConfigDecrypted()
    
    if (!smtpConfig || !smtpConfig.is_active) {
      console.warn('Configuration SMTP manquante ou inactive, email d\'annulation non envoyé')
      return false
    }

    console.log('Configuration SMTP trouvée - envoi email annulation')
    const transporter = await createTransporter()

    const htmlTemplate = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>Réservation annulée - U Silenziu</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #dc3545; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }
          .reservation-details { background: white; padding: 20px; border-radius: 8px; margin: 20px 0; }
          .detail-row { display: flex; justify-content: space-between; margin: 10px 0; padding: 8px 0; border-bottom: 1px solid #eee; }
          .detail-label { font-weight: bold; color: #666; }
          .detail-value { color: #333; }
          .reservation-number { background: #dc3545; color: white; padding: 15px; text-align: center; border-radius: 8px; margin: 20px 0; font-size: 18px; font-weight: bold; }
          .footer { text-align: center; margin-top: 30px; color: #666; font-size: 14px; }
          .cancelled-badge { background: #dc3545; color: white; padding: 10px 20px; border-radius: 20px; display: inline-block; margin: 10px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>❌ U Silenziu</h1>
            <h2>Réservation Annulée</h2>
          </div>
          
          <div class="content">
            <div class="cancelled-badge">
              ❌ RÉSERVATION ANNULÉE
            </div>
            
            <p>Bonjour <strong>${reservation.customer_name}</strong>,</p>
            
            <p>Nous vous informons que votre réservation a été annulée.</p>
            
            <div class="reservation-number">
              Numéro de réservation : ${reservation.reservation_number}
            </div>
            
            <div class="reservation-details">
              <h3>Détails de la réservation annulée</h3>
              
              <div class="detail-row">
                <span class="detail-label">Statut :</span>
                <span class="detail-value" style="color: #dc3545; font-weight: bold;">❌ ANNULÉE</span>
              </div>
              
              <div class="detail-row">
                <span class="detail-label">Date :</span>
                <span class="detail-value">${new Date(reservation.date).toLocaleDateString('fr-FR')}</span>
              </div>
              
              <div class="detail-row">
                <span class="detail-label">Heure :</span>
                <span class="detail-value">${reservation.time_slot}</span>
              </div>
              
              <div class="detail-row">
                <span class="detail-label">Formule :</span>
                <span class="detail-value">${reservation.room_name}</span>
              </div>
              
              <div class="detail-row" style="border-bottom: none; font-weight: bold; font-size: 16px; background: #f8d7da; padding: 15px; margin: 10px -20px -20px -20px; border-radius: 0 0 8px 8px;">
                <span class="detail-label">Montant :</span>
                <span class="detail-value">${parseFloat(reservation.amount).toFixed(2)}€</span>
              </div>
            </div>
            
            <p><strong>Informations importantes :</strong></p>
            <ul>
              <li>❌ Votre créneau est maintenant libéré</li>
              <li>💰 Si un paiement a été effectué, vous serez remboursé</li>
              <li>📞 Pour toute question, contactez-nous</li>
              <li>🔄 Vous pouvez effectuer une nouvelle réservation à tout moment</li>
            </ul>
            
            <p>Nous espérons vous revoir bientôt chez U Silenziu !</p>
            
            <div class="footer">
              <p>U Silenziu - Zone de défoulement à Buros</p>
              <p>123 Rue de la Libération, 64400 Buros</p>
              <p>Tél: 05 59 12 34 56 | Email: contact@usilenziu.com</p>
            </div>
          </div>
        </div>
      </body>
      </html>
    `

    const mailOptions = {
      from: `"${smtpConfig.from_name || 'U Silenziu'}" <${smtpConfig.from_email}>`,
      to: reservation.customer_email,
      subject: `❌ Réservation annulée ${reservation.reservation_number} - U Silenziu`,
      html: htmlTemplate,
    }

    console.log(`Envoi d'email d'annulation à: ${reservation.customer_email}`)

    const result = await transporter.sendMail(mailOptions)
    console.log(`Email d'annulation envoyé avec succès: ${result.messageId}`)
    return true

  } catch (error) {
    console.error('Erreur lors de l\'envoi de l\'email d\'annulation:', error)
    console.error('Détails de l\'erreur:', error instanceof Error ? error.message : 'Erreur inconnue')
    return false
  }
}
