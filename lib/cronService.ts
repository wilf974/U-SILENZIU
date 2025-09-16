import { CronJob } from 'cron'
import { mailerService } from './mailer'
import { getUpcomingReservations } from './database'
import { format } from 'date-fns'
import { fr } from 'date-fns/locale'

class CronService {
  private notificationJob: CronJob | null = null
  private isInitialized = false

  /**
   * Initialise le service CRON
   */
  async initialize(): Promise<boolean> {
    if (this.isInitialized) {
      console.log('ℹ️ Service CRON déjà initialisé')
      return true
    }

    try {
      // Vérifier que le service mailer est configuré
      const isMailerInitialized = await mailerService.initialize()
      if (!isMailerInitialized) {
        console.log('⚠️ Service CRON: Service mailer non configuré, notifications désactivées')
        return false
      }

      // Créer le job de notifications automatiques
      // Exécution tous les jours à 9h00 du matin
      this.notificationJob = new CronJob(
        '0 9 * * *', // Tous les jours à 9h00
        async () => {
          await this.sendDailyNotifications()
        },
        null, // onComplete
        true, // start (démarrer automatiquement)
        'Europe/Paris', // timeZone
        null, // context
        false, // runOnInit
        null, // utcOffset
        false, // unrefTimeout
        true, // waitForCompletion
        (error) => {
          console.error('❌ Erreur dans le job CRON de notifications:', error)
        },
        'daily-notifications' // name
      )

      // Marquer comme initialisé
      this.isInitialized = true

      console.log('✅ Service CRON initialisé - Notifications automatiques activées')
      console.log('📅 Prochaine exécution:', format(this.notificationJob.nextDate().toJSDate(), 'dd/MM/yyyy HH:mm', { locale: fr }))
      
      return true
    } catch (error) {
      console.error('❌ Erreur lors de l\'initialisation du service CRON:', error)
      return false
    }
  }

  /**
   * Envoie les notifications quotidiennes
   */
  private async sendDailyNotifications(): Promise<void> {
    console.log('🔄 Début de l\'envoi des notifications quotidiennes...')
    
    try {
      // Récupérer les réservations prévues dans les 24h
      const upcomingReservations = await getUpcomingReservations(24)
      
      if (upcomingReservations.length === 0) {
        console.log('ℹ️ Aucune réservation prévue dans les 24h')
        return
      }

      console.log(`📧 Envoi de ${upcomingReservations.length} notification(s) de rappel...`)

      let sentCount = 0
      let errorCount = 0
      const errors: string[] = []

      // Envoyer les emails de rappel
      for (const reservation of upcomingReservations) {
        try {
          // Générer l'email de rappel
          const emailData = {
            to: reservation.email,
            subject: `Rappel de réservation - U Silenziu (${reservation.reservation_number})`,
            html: this.generateReminderEmail(reservation)
          }

          // Envoyer l'email
          const result = await mailerService.sendEmail(emailData)
          
          if (result) {
            sentCount++
            console.log(`✅ Email envoyé: ${reservation.email} (${reservation.reservation_number})`)
          } else {
            errorCount++
            errors.push(`${reservation.email}: Échec de l'envoi`)
            console.error(`❌ Échec envoi: ${reservation.email}`)
          }
        } catch (error) {
          errorCount++
          const errorMessage = error instanceof Error ? error.message : 'Erreur inconnue'
          errors.push(`${reservation.email}: ${errorMessage}`)
          console.error(`❌ Erreur pour ${reservation.email}:`, error)
        }
      }

      // Log des résultats
      console.log(`📊 Résultats des notifications quotidiennes:`)
      console.log(`   ✅ Envoyés: ${sentCount}`)
      console.log(`   ❌ Échecs: ${errorCount}`)
      
      if (errors.length > 0) {
        console.log(`   📝 Erreurs détaillées:`, errors)
      }

    } catch (error) {
      console.error('❌ Erreur lors de l\'envoi des notifications quotidiennes:', error)
    }
  }

  /**
   * Génère le contenu HTML de l'email de rappel
   */
  private generateReminderEmail(reservation: any): string {
    const date = new Date(reservation.date)
    const formattedDate = format(date, 'EEEE, dd MMMM yyyy', { locale: fr })

    return `
      <!DOCTYPE html>
      <html lang="fr">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Rappel de réservation - U Silenziu</title>
        <style>
          * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
          }
          
          body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333333;
            background-color: #f8f9fa;
            margin: 0;
            padding: 20px;
          }
          
          .email-container {
            max-width: 650px;
            margin: 0 auto;
            background-color: #ffffff;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
            border: 1px solid #e9ecef;
          }
          
          .header {
            background: linear-gradient(135deg, #6b8e23 0%, #8fbc8f 100%);
            padding: 40px 30px;
            text-align: center;
            color: white;
          }
          
          .header h1 {
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 10px;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
          }
          
          .header .subtitle {
            font-size: 18px;
            opacity: 0.9;
            font-weight: 300;
          }
          
          .content {
            padding: 40px 30px;
          }
          
          .greeting {
            font-size: 18px;
            color: #2c3e50;
            margin-bottom: 20px;
            font-weight: 500;
          }
          
          .intro-text {
            font-size: 16px;
            color: #555555;
            margin-bottom: 30px;
            line-height: 1.7;
          }
          
          .reservation-card {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border-radius: 12px;
            padding: 30px;
            margin: 30px 0;
            border-left: 5px solid #6b8e23;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
          }
          
          .reservation-card h2 {
            color: #2c3e50;
            font-size: 24px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 10px;
          }
          
          .detail-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
          }
          
          .detail-item {
            display: flex;
            flex-direction: column;
            gap: 5px;
          }
          
          .detail-label {
            font-weight: 600;
            color: #6b8e23;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
          }
          
          .detail-value {
            font-size: 16px;
            color: #2c3e50;
            font-weight: 500;
          }
          
          .reservation-number {
            background-color: #6b8e23;
            color: white;
            padding: 15px 20px;
            border-radius: 8px;
            text-align: center;
            font-size: 18px;
            font-weight: 700;
            margin: 20px 0;
            letter-spacing: 1px;
          }
          
          .reminder-section {
            background-color: #fff3cd;
            border: 1px solid #ffeaa7;
            border-radius: 12px;
            padding: 25px;
            margin: 30px 0;
          }
          
          .reminder-section h3 {
            color: #856404;
            font-size: 20px;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
          }
          
          .reminder-list {
            list-style: none;
            padding: 0;
          }
          
          .reminder-list li {
            color: #856404;
            margin: 12px 0;
            padding-left: 25px;
            position: relative;
            font-size: 15px;
            line-height: 1.5;
          }
          
          .reminder-list li:before {
            content: "✓";
            position: absolute;
            left: 0;
            color: #6b8e23;
            font-weight: bold;
            font-size: 16px;
          }
          
          .contact-section {
            background-color: #f8f9fa;
            border-radius: 12px;
            padding: 25px;
            margin: 30px 0;
            border: 1px solid #e9ecef;
          }
          
          .contact-section h3 {
            color: #2c3e50;
            font-size: 20px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
          }
          
          .contact-info {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
          }
          
          .contact-item {
            display: flex;
            align-items: center;
            gap: 12px;
            color: #555555;
            font-size: 15px;
          }
          
          .contact-item .icon {
            width: 20px;
            height: 20px;
            color: #6b8e23;
          }
          
          .closing-message {
            text-align: center;
            font-size: 18px;
            color: #2c3e50;
            margin: 30px 0;
            font-weight: 500;
          }
          
          .footer {
            background-color: #2c3e50;
            color: #ecf0f1;
            padding: 30px;
            text-align: center;
            font-size: 14px;
            line-height: 1.6;
          }
          
          .footer p {
            margin: 5px 0;
          }
          
          .footer .copyright {
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #34495e;
            color: #bdc3c7;
          }
          
          @media (max-width: 600px) {
            .detail-grid {
              grid-template-columns: 1fr;
            }
            
            .contact-info {
              grid-template-columns: 1fr;
            }
            
            .header {
              padding: 30px 20px;
            }
            
            .content {
              padding: 30px 20px;
            }
            
            .header h1 {
              font-size: 28px;
            }
          }
        </style>
      </head>
      <body>
        <div class="email-container">
          <div class="header">
            <h1>🎯 U SILENZIU</h1>
            <div class="subtitle">Rappel de réservation</div>
          </div>
          
          <div class="content">
            <div class="greeting">Bonjour ${reservation.first_name} ${reservation.last_name},</div>
            
            <div class="intro-text">
              Ceci est un rappel amical pour votre réservation chez <strong>U Silenziu</strong>. 
              Nous avons hâte de vous accueillir pour une session de défoulement mémorable !
            </div>
            
            <div class="reservation-card">
              <h2>📋 Détails de votre réservation</h2>
              
              <div class="reservation-number">
                N° ${reservation.reservation_number}
              </div>
              
              <div class="detail-grid">
                <div class="detail-item">
                  <div class="detail-label">Salle</div>
                  <div class="detail-value">${reservation.room_name}</div>
                </div>
                <div class="detail-item">
                  <div class="detail-label">Date</div>
                  <div class="detail-value">${formattedDate}</div>
                </div>
                <div class="detail-item">
                  <div class="detail-label">Heure</div>
                  <div class="detail-value">${reservation.time}</div>
                </div>
                <div class="detail-item">
                  <div class="detail-label">Durée</div>
                  <div class="detail-value">${reservation.duration} minutes</div>
                </div>
                <div class="detail-item">
                  <div class="detail-label">Nombre de personnes</div>
                  <div class="detail-value">${reservation.number_of_people}</div>
                </div>
                <div class="detail-item">
                  <div class="detail-label">Formule</div>
                  <div class="detail-value">${reservation.formula || 'Standard'}</div>
                </div>
              </div>
            </div>
            
            <div class="reminder-section">
              <h3>⚠️ Rappels importants</h3>
              <ul class="reminder-list">
                <li>Arrivez 15 minutes avant votre créneau pour les formalités d'accueil</li>
                <li>Prévoyez des vêtements confortables et fermés</li>
                <li>L'équipement de sécurité sera fourni sur place</li>
                <li>Présentez-vous à l'accueil avec votre numéro de réservation</li>
              </ul>
            </div>
            
            <div class="contact-section">
              <h3>📍 Informations pratiques</h3>
              <div class="contact-info">
                <div class="contact-item">
                  <span class="icon">🏢</span>
                  <span>Zone de défoulement U Silenziu, Buros</span>
                </div>
                <div class="contact-item">
                  <span class="icon">📞</span>
                  <span>05 59 12 34 56</span>
                </div>
                <div class="contact-item">
                  <span class="icon">✉️</span>
                  <span>contact@usilenziu.fr</span>
                </div>
                <div class="contact-item">
                  <span class="icon">🌐</span>
                  <span>www.usilenziu.fr</span>
                </div>
              </div>
            </div>
            
            <div class="closing-message">
              Nous vous attendons pour une expérience de défoulement exceptionnelle ! 🎯
            </div>
          </div>
          
          <div class="footer">
            <p><strong>U Silenziu</strong> - Zone de défoulement</p>
            <p>Buros, France</p>
            <div class="copyright">
              <p>Ce message a été envoyé automatiquement. Merci de ne pas y répondre.</p>
              <p>© 2024 U Silenziu - Tous droits réservés</p>
            </div>
          </div>
        </div>
      </body>
      </html>
    `
  }

  /**
   * Démarre le service CRON
   */
  start(): void {
    if (this.notificationJob && !this.notificationJob.isActive) {
      this.notificationJob.start()
      console.log('✅ Service CRON démarré')
    } else if (this.notificationJob && this.notificationJob.isActive) {
      console.log('ℹ️ Service CRON déjà actif')
    } else {
      console.log('⚠️ Service CRON non initialisé')
    }
  }

  /**
   * Arrête le service CRON
   */
  stop(): void {
    if (this.notificationJob && this.notificationJob.isActive) {
      this.notificationJob.stop()
      console.log('⏹️ Service CRON arrêté')
    }
  }

  /**
   * Retourne le statut du service CRON
   */
  getStatus(): {
    isInitialized: boolean
    isActive: boolean
    nextExecution: string | null
    lastExecution: string | null
  } {
    // Vérifier si le job existe et est actif
    const isJobActive = this.notificationJob ? this.notificationJob.isActive : false
    
    // Debug: afficher l'état du service
    console.log('🔍 Debug statut CRON:', {
      isInitialized: this.isInitialized,
      hasJob: !!this.notificationJob,
      isJobActive: isJobActive,
      nextDate: this.notificationJob?.nextDate()?.toJSDate()
    })
    
    return {
      isInitialized: this.isInitialized,
      isActive: isJobActive,
      nextExecution: this.notificationJob?.nextDate() ? format(this.notificationJob.nextDate().toJSDate(), 'dd/MM/yyyy HH:mm', { locale: fr }) : null,
      lastExecution: this.notificationJob?.lastDate() ? format(this.notificationJob.lastDate()!, 'dd/MM/yyyy HH:mm', { locale: fr }) : null
    }
  }

  /**
   * Force l'exécution immédiate des notifications (pour les tests)
   */
  async forceExecution(): Promise<void> {
    console.log('🔄 Exécution forcée des notifications...')
    await this.sendDailyNotifications()
  }
}

// Instance singleton
export const cronService = new CronService()
