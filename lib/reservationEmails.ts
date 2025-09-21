import { mailerService } from './mailer'
import { Reservation } from './database'

/**
 * Interface pour les données d'email de réservation
 */
export interface ReservationEmailData {
  reservation: Reservation
  type: 'confirmation' | 'validation' | 'cancellation'
}

/**
 * Génère le template HTML pour l'email de confirmation de réservation (statut pending)
 */
function generateConfirmationEmailTemplate(reservation: Reservation): string {
  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr)
    return date.toLocaleDateString('fr-FR', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  }

  const formatTime = (timeStr: string) => {
    const [hours, minutes] = timeStr.split(':')
    return `${hours}:${minutes}`
  }

  return `
    <!DOCTYPE html>
    <html lang="fr">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Confirmation de réservation - U Silenziu</title>
      <style>
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          line-height: 1.6;
          color: #333;
          max-width: 600px;
          margin: 0 auto;
          padding: 20px;
          background-color: #f5f5f5;
        }
        .container {
          background-color: #ffffff;
          border-radius: 10px;
          padding: 30px;
          box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .header {
          text-align: center;
          margin-bottom: 30px;
          padding-bottom: 20px;
          border-bottom: 2px solid #8B7355;
        }
        .logo {
          font-size: 28px;
          font-weight: bold;
          color: #8B7355;
          margin-bottom: 10px;
        }
        .subtitle {
          color: #666;
          font-size: 16px;
        }
        .status-badge {
          display: inline-block;
          background-color: #FFA500;
          color: white;
          padding: 8px 16px;
          border-radius: 20px;
          font-size: 14px;
          font-weight: bold;
          margin: 20px 0;
        }
        .reservation-details {
          background-color: #f8f9fa;
          border-radius: 8px;
          padding: 20px;
          margin: 20px 0;
          border-left: 4px solid #8B7355;
        }
        .detail-row {
          display: flex;
          justify-content: space-between;
          margin-bottom: 10px;
          padding: 5px 0;
        }
        .detail-label {
          font-weight: bold;
          color: #555;
        }
        .detail-value {
          color: #333;
        }
        .highlight {
          background-color: #8B7355;
          color: white;
          padding: 2px 8px;
          border-radius: 4px;
          font-weight: bold;
        }
        .message {
          background-color: #e8f4f8;
          border-radius: 8px;
          padding: 20px;
          margin: 20px 0;
          border-left: 4px solid #17a2b8;
        }
        .footer {
          text-align: center;
          margin-top: 30px;
          padding-top: 20px;
          border-top: 1px solid #ddd;
          color: #666;
          font-size: 14px;
        }
        .contact-info {
          background-color: #f8f9fa;
          border-radius: 8px;
          padding: 15px;
          margin: 20px 0;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <div class="logo">U SILENZIU</div>
          <div class="subtitle">Zone de défoulement</div>
        </div>

        <h2 style="color: #8B7355; text-align: center;">Demande de réservation reçue !</h2>
        
        <div class="status-badge">EN ATTENTE DE CONFIRMATION</div>

        <p>Bonjour <strong>${reservation.customer_name}</strong>,</p>
        
        <p>Nous avons bien reçu votre demande de réservation. Notre équipe va examiner votre demande et vous recontacter rapidement pour confirmer votre créneau.</p>

        <div class="reservation-details">
          <h3 style="color: #8B7355; margin-top: 0;">Détails de votre réservation</h3>
          <div class="detail-row">
            <span class="detail-label">Numéro de réservation :</span>
            <span class="detail-value highlight">${reservation.reservation_number}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Nom :</span>
            <span class="detail-value">${reservation.customer_name}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Email :</span>
            <span class="detail-value">${reservation.customer_email}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Téléphone :</span>
            <span class="detail-value">${reservation.customer_phone}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Date :</span>
            <span class="detail-value">${formatDate(reservation.date)}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Heure :</span>
            <span class="detail-value">${formatTime(reservation.time_slot)} - ${formatTime(reservation.time_slot) + reservation.duration}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Salle :</span>
            <span class="detail-value">${reservation.room_name}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Durée :</span>
            <span class="detail-value">${reservation.duration} minutes</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Nombre de personnes :</span>
            <span class="detail-value">${reservation.participants}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Prix par personne :</span>
            <span class="detail-value">${(Number(reservation.amount) / Number(reservation.participants)).toFixed(2)}€</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Total :</span>
            <span class="detail-value highlight">${Number(reservation.amount).toFixed(2)}€</span>
          </div>
        </div>

        <div class="message">
          <h4 style="color: #17a2b8; margin-top: 0;">Prochaines étapes</h4>
          <p>Notre équipe va examiner votre demande et vous recontacter dans les plus brefs délais pour confirmer votre créneau. Vous recevrez un email de confirmation une fois votre réservation validée.</p>
        </div>

        <div class="contact-info">
          <h4 style="color: #8B7355; margin-top: 0;">Besoin d'aide ?</h4>
          <p>Si vous avez des questions ou souhaitez modifier votre réservation, n'hésitez pas à nous contacter :</p>
          <p><strong>Email :</strong> contact@usilenzu.fr<br>
          <strong>Téléphone :</strong> 05 59 12 34 56</p>
        </div>

        <div class="footer">
          <p><strong>U Silenziu</strong> - Zone de défoulement<br>
          Buros, France</p>
          <p style="font-size: 12px; color: #999;">
            Cet email a été envoyé automatiquement. Merci de ne pas y répondre.
          </p>
        </div>
      </div>
    </body>
    </html>
  `
}

/**
 * Génère le template HTML pour l'email de validation de réservation (statut confirmed)
 */
function generateValidationEmailTemplate(reservation: Reservation): string {
  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr)
    return date.toLocaleDateString('fr-FR', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  }

  const formatTime = (timeStr: string) => {
    const [hours, minutes] = timeStr.split(':')
    return `${hours}:${minutes}`
  }

  return `
    <!DOCTYPE html>
    <html lang="fr">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Réservation confirmée - U Silenziu</title>
      <style>
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          line-height: 1.6;
          color: #333;
          max-width: 600px;
          margin: 0 auto;
          padding: 20px;
          background-color: #f5f5f5;
        }
        .container {
          background-color: #ffffff;
          border-radius: 10px;
          padding: 30px;
          box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .header {
          text-align: center;
          margin-bottom: 30px;
          padding-bottom: 20px;
          border-bottom: 2px solid #8B7355;
        }
        .logo {
          font-size: 28px;
          font-weight: bold;
          color: #8B7355;
          margin-bottom: 10px;
        }
        .subtitle {
          color: #666;
          font-size: 16px;
        }
        .status-badge {
          display: inline-block;
          background-color: #28a745;
          color: white;
          padding: 8px 16px;
          border-radius: 20px;
          font-size: 14px;
          font-weight: bold;
          margin: 20px 0;
        }
        .reservation-details {
          background-color: #f8f9fa;
          border-radius: 8px;
          padding: 20px;
          margin: 20px 0;
          border-left: 4px solid #28a745;
        }
        .detail-row {
          display: flex;
          justify-content: space-between;
          margin-bottom: 10px;
          padding: 5px 0;
        }
        .detail-label {
          font-weight: bold;
          color: #555;
        }
        .detail-value {
          color: #333;
        }
        .highlight {
          background-color: #28a745;
          color: white;
          padding: 2px 8px;
          border-radius: 4px;
          font-weight: bold;
        }
        .success-message {
          background-color: #d4edda;
          border-radius: 8px;
          padding: 20px;
          margin: 20px 0;
          border-left: 4px solid #28a745;
        }
        .footer {
          text-align: center;
          margin-top: 30px;
          padding-top: 20px;
          border-top: 1px solid #ddd;
          color: #666;
          font-size: 14px;
        }
        .contact-info {
          background-color: #f8f9fa;
          border-radius: 8px;
          padding: 15px;
          margin: 20px 0;
        }
        .instructions {
          background-color: #fff3cd;
          border-radius: 8px;
          padding: 20px;
          margin: 20px 0;
          border-left: 4px solid #ffc107;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <div class="logo">U SILENZIU</div>
          <div class="subtitle">Zone de défoulement</div>
        </div>

        <h2 style="color: #28a745; text-align: center;">🎉 Réservation confirmée !</h2>
        
        <div class="status-badge">CONFIRMÉE</div>

        <p>Bonjour <strong>${reservation.customer_name}</strong>,</p>
        
        <div class="success-message">
          <h4 style="color: #28a745; margin-top: 0;">✅ Excellente nouvelle !</h4>
          <p>Votre réservation a été confirmée avec succès ! Nous vous attendons avec impatience pour votre session de défoulement.</p>
        </div>

        <div class="reservation-details">
          <h3 style="color: #8B7355; margin-top: 0;">Détails de votre réservation</h3>
          <div class="detail-row">
            <span class="detail-label">Numéro de réservation :</span>
            <span class="detail-value highlight">${reservation.reservation_number}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Nom :</span>
            <span class="detail-value">${reservation.customer_name}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Email :</span>
            <span class="detail-value">${reservation.customer_email}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Téléphone :</span>
            <span class="detail-value">${reservation.customer_phone}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Date :</span>
            <span class="detail-value">${formatDate(reservation.date)}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Heure :</span>
            <span class="detail-value">${formatTime(reservation.time_slot)} - ${formatTime(reservation.time_slot) + reservation.duration}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Salle :</span>
            <span class="detail-value">${reservation.room_name}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Durée :</span>
            <span class="detail-value">${reservation.duration} minutes</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Nombre de personnes :</span>
            <span class="detail-value">${reservation.participants}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Prix par personne :</span>
            <span class="detail-value">${(Number(reservation.amount) / Number(reservation.participants)).toFixed(2)}€</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Total :</span>
            <span class="detail-value highlight">${Number(reservation.amount).toFixed(2)}€</span>
          </div>
        </div>

        <div class="instructions">
          <h4 style="color: #856404; margin-top: 0;">📋 Instructions importantes</h4>
          <ul>
            <li><strong>Arrivée :</strong> Veuillez arriver 10 minutes avant votre créneau</li>
            <li><strong>Équipement :</strong> Nous fournissons tout le matériel nécessaire</li>
            <li><strong>Tenue :</strong> Portez des vêtements confortables que vous pouvez salir</li>
            <li><strong>Annulation :</strong> Contactez-nous au moins 24h à l'avance pour toute modification</li>
          </ul>
        </div>

        <div class="contact-info">
          <h4 style="color: #8B7355; margin-top: 0;">Besoin d'aide ?</h4>
          <p>Si vous avez des questions ou souhaitez modifier votre réservation, n'hésitez pas à nous contacter :</p>
          <p><strong>Email :</strong> contact@usilenzu.fr<br>
          <strong>Téléphone :</strong> 05 59 12 34 56</p>
        </div>

        <div class="footer">
          <p><strong>U Silenziu</strong> - Zone de défoulement<br>
          Buros, France</p>
          <p style="font-size: 12px; color: #999;">
            Cet email a été envoyé automatiquement. Merci de ne pas y répondre.
          </p>
        </div>
      </div>
    </body>
    </html>
  `
}

/**
 * Génère le template HTML pour l'email d'annulation de réservation (statut cancelled)
 */
function generateCancellationEmailTemplate(reservation: Reservation): string {
  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr)
    return date.toLocaleDateString('fr-FR', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  }

  const formatTime = (timeStr: string) => {
    const [hours, minutes] = timeStr.split(':')
    return `${hours}:${minutes}`
  }

  return `
    <!DOCTYPE html>
    <html lang="fr">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Réservation annulée - U Silenziu</title>
      <style>
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          line-height: 1.6;
          color: #333;
          max-width: 600px;
          margin: 0 auto;
          padding: 20px;
          background-color: #f5f5f5;
        }
        .container {
          background-color: #ffffff;
          border-radius: 10px;
          padding: 30px;
          box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .header {
          text-align: center;
          margin-bottom: 30px;
          padding-bottom: 20px;
          border-bottom: 2px solid #8B7355;
        }
        .logo {
          font-size: 28px;
          font-weight: bold;
          color: #8B7355;
          margin-bottom: 10px;
        }
        .subtitle {
          color: #666;
          font-size: 16px;
        }
        .status-badge {
          display: inline-block;
          background-color: #dc3545;
          color: white;
          padding: 8px 16px;
          border-radius: 20px;
          font-size: 14px;
          font-weight: bold;
          margin: 20px 0;
        }
        .reservation-details {
          background-color: #f8f9fa;
          border-radius: 8px;
          padding: 20px;
          margin: 20px 0;
          border-left: 4px solid #dc3545;
        }
        .detail-row {
          display: flex;
          justify-content: space-between;
          margin-bottom: 10px;
          padding: 5px 0;
        }
        .detail-label {
          font-weight: bold;
          color: #555;
        }
        .detail-value {
          color: #333;
        }
        .highlight {
          background-color: #dc3545;
          color: white;
          padding: 2px 8px;
          border-radius: 4px;
          font-weight: bold;
        }
        .cancellation-message {
          background-color: #f8d7da;
          border-radius: 8px;
          padding: 20px;
          margin: 20px 0;
          border-left: 4px solid #dc3545;
        }
        .footer {
          text-align: center;
          margin-top: 30px;
          padding-top: 20px;
          border-top: 1px solid #ddd;
          color: #666;
          font-size: 14px;
        }
        .contact-info {
          background-color: #f8f9fa;
          border-radius: 8px;
          padding: 15px;
          margin: 20px 0;
        }
        .rebooking-info {
          background-color: #d1ecf1;
          border-radius: 8px;
          padding: 20px;
          margin: 20px 0;
          border-left: 4px solid #17a2b8;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <div class="logo">U SILENZIU</div>
          <div class="subtitle">Zone de défoulement</div>
        </div>

        <h2 style="color: #dc3545; text-align: center;">❌ Réservation annulée</h2>
        
        <div class="status-badge">ANNULÉE</div>

        <p>Bonjour <strong>${reservation.customer_name}</strong>,</p>
        
        <div class="cancellation-message">
          <h4 style="color: #dc3545; margin-top: 0;">⚠️ Réservation annulée</h4>
          <p>Nous vous informons que votre réservation a été annulée. Nous nous excusons pour la gêne occasionnée.</p>
        </div>

        <div class="reservation-details">
          <h3 style="color: #8B7355; margin-top: 0;">Détails de la réservation annulée</h3>
          <div class="detail-row">
            <span class="detail-label">Numéro de réservation :</span>
            <span class="detail-value highlight">${reservation.reservation_number}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Nom :</span>
            <span class="detail-value">${reservation.customer_name}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Email :</span>
            <span class="detail-value">${reservation.customer_email}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Téléphone :</span>
            <span class="detail-value">${reservation.customer_phone}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Date :</span>
            <span class="detail-value">${formatDate(reservation.date)}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Heure :</span>
            <span class="detail-value">${formatTime(reservation.time_slot)} - ${formatTime(reservation.time_slot) + reservation.duration}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Salle :</span>
            <span class="detail-value">${reservation.room_name}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Durée :</span>
            <span class="detail-value">${reservation.duration} minutes</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Nombre de personnes :</span>
            <span class="detail-value">${reservation.participants}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Montant :</span>
            <span class="detail-value">${Number(reservation.amount).toFixed(2)}€</span>
          </div>
        </div>

        <div class="rebooking-info">
          <h4 style="color: #17a2b8; margin-top: 0;">🔄 Nouvelle réservation</h4>
          <p>Nous vous encourageons à effectuer une nouvelle réservation. Notre équipe reste à votre disposition pour vous aider à trouver un nouveau créneau qui vous convient.</p>
        </div>

        <div class="contact-info">
          <h4 style="color: #8B7355; margin-top: 0;">Besoin d'aide ?</h4>
          <p>Si vous avez des questions ou souhaitez effectuer une nouvelle réservation, n'hésitez pas à nous contacter :</p>
          <p><strong>Email :</strong> contact@usilenzu.fr<br>
          <strong>Téléphone :</strong> 05 59 12 34 56</p>
        </div>

        <div class="footer">
          <p><strong>U Silenziu</strong> - Zone de défoulement<br>
          Buros, France</p>
          <p style="font-size: 12px; color: #999;">
            Cet email a été envoyé automatiquement. Merci de ne pas y répondre.
          </p>
        </div>
      </div>
    </body>
    </html>
  `
}

/**
 * Envoie un email de confirmation de réservation (statut pending)
 */
export async function sendReservationConfirmationEmail(reservation: Reservation): Promise<boolean> {
  try {
    // Initialiser le service mailer
    const isInitialized = await mailerService.initialize()
    
    if (!isInitialized) {
      console.error('❌ Service mailer non initialisé pour l\'email de confirmation')
      return false
    }

    const subject = `Demande de réservation reçue - U Silenziu (${reservation.reservation_number})`
    const html = generateConfirmationEmailTemplate(reservation)
    const text = `Demande de réservation reçue pour ${reservation.room_name} le ${reservation.date} à ${reservation.time_slot}. Numéro: ${reservation.reservation_number}`

    const result = await mailerService.sendEmail({
      to: reservation.customer_email,
      subject: subject,
      html: html,
      text: text
    })

    if (result.success) {
      console.log(`✅ Email de confirmation envoyé à ${reservation.customer_email} (${reservation.reservation_number})`)
      return true
    } else {
      console.error(`❌ Échec envoi email de confirmation à ${reservation.customer_email}:`, result.error)
      return false
    }
  } catch (error) {
    console.error('❌ Erreur lors de l\'envoi de l\'email de confirmation:', error)
    return false
  }
}

/**
 * Envoie un email de validation de réservation (statut confirmed)
 */
export async function sendReservationValidationEmail(reservation: Reservation): Promise<boolean> {
  try {
    // Initialiser le service mailer
    const isInitialized = await mailerService.initialize()
    
    if (!isInitialized) {
      console.error('❌ Service mailer non initialisé pour l\'email de validation')
      return false
    }

    const subject = `Réservation confirmée - U Silenziu (${reservation.reservation_number})`
    const html = generateValidationEmailTemplate(reservation)
    const text = `Votre réservation pour ${reservation.room_name} le ${reservation.date} à ${reservation.time_slot} a été confirmée. Numéro: ${reservation.reservation_number}`

    const result = await mailerService.sendEmail({
      to: reservation.customer_email,
      subject: subject,
      html: html,
      text: text
    })

    if (result.success) {
      console.log(`✅ Email de validation envoyé à ${reservation.customer_email} (${reservation.reservation_number})`)
      return true
    } else {
      console.error(`❌ Échec envoi email de validation à ${reservation.customer_email}:`, result.error)
      return false
    }
  } catch (error) {
    console.error('❌ Erreur lors de l\'envoi de l\'email de validation:', error)
    return false
  }
}

/**
 * Envoie un email d'annulation de réservation (statut cancelled)
 */
export async function sendReservationCancellationEmail(reservation: Reservation): Promise<boolean> {
  try {
    // Initialiser le service mailer
    const isInitialized = await mailerService.initialize()
    
    if (!isInitialized) {
      console.error('❌ Service mailer non initialisé pour l\'email d\'annulation')
      return false
    }

    const subject = `Réservation annulée - U Silenziu (${reservation.reservation_number})`
    const html = generateCancellationEmailTemplate(reservation)
    const text = `Votre réservation pour ${reservation.room_name} le ${reservation.date} à ${reservation.time_slot} a été annulée. Numéro: ${reservation.reservation_number}`

    const result = await mailerService.sendEmail({
      to: reservation.customer_email,
      subject: subject,
      html: html,
      text: text
    })

    if (result.success) {
      console.log(`✅ Email d'annulation envoyé à ${reservation.customer_email} (${reservation.reservation_number})`)
      return true
    } else {
      console.error(`❌ Échec envoi email d'annulation à ${reservation.customer_email}:`, result.error)
      return false
    }
  } catch (error) {
    console.error('❌ Erreur lors de l\'envoi de l\'email d\'annulation:', error)
    return false
  }
}

/**
 * Envoie un email de réservation selon le type
 */
export async function sendReservationEmail(data: ReservationEmailData): Promise<boolean> {
  switch (data.type) {
    case 'confirmation':
      return await sendReservationConfirmationEmail(data.reservation)
    case 'validation':
      return await sendReservationValidationEmail(data.reservation)
    case 'cancellation':
      return await sendReservationCancellationEmail(data.reservation)
    default:
      console.error('❌ Type d\'email de réservation non reconnu:', data.type)
      return false
  }
}
