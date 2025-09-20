import nodemailer from 'nodemailer'
import { getSmtpConfigDecrypted } from './database'

// Configuration du transporteur email
const createTransporter = async () => {
  const smtpConfig = await getSmtpConfigDecrypted()
  
  if (!smtpConfig) {
    throw new Error('Configuration SMTP non trouvée')
  }

  return nodemailer.createTransporter({
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
}

/**
 * Envoie un email de confirmation de réservation
 */
export async function sendReservationConfirmationEmail(data: ReservationEmailData): Promise<boolean> {
  try {
    const transporter = createTransporter()
    
    // Vérifier que les variables d'environnement sont configurées
    if (!process.env.SMTP_USER || !process.env.SMTP_PASS) {
      console.warn('Configuration SMTP manquante, email non envoyé')
      return false
    }

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
            
            ${data.specialRequests ? `
              <div class="reservation-details">
                <h3>Demandes spéciales</h3>
                <p>${data.specialRequests}</p>
              </div>
            ` : ''}
            
            <p><strong>Prochaines étapes :</strong></p>
            <ul>
              <li>Nous allons vérifier la disponibilité de votre créneau</li>
              <li>Vous recevrez un email de confirmation dans les 24h</li>
              <li>En cas de problème, nous vous contacterons par téléphone</li>
            </ul>
            
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
      from: `"U Silenziu" <${process.env.SMTP_USER}>`,
      to: data.customerEmail,
      subject: `Confirmation de réservation ${data.reservationNumber} - U Silenziu`,
      text: textTemplate,
      html: htmlTemplate,
    }

    await transporter.sendMail(mailOptions)
    console.log(`Email de confirmation envoyé à ${data.customerEmail} pour la réservation ${data.reservationNumber}`)
    return true

  } catch (error) {
    console.error('Erreur lors de l\'envoi de l\'email de confirmation:', error)
    return false
  }
}
