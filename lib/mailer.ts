import nodemailer, { Transporter } from 'nodemailer';
import { getSmtpConfig, getSmtpConfigDecrypted, SmtpConfig as DbSmtpConfig } from './database';

export interface SmtpConfig {
  host: string;
  port: number;
  secure: boolean;
  auth: {
    user: string;
    pass: string;
  };
  tls?: {
    rejectUnauthorized: boolean;
    minVersion?: string;
  };
}

export interface MailerResult {
  success: boolean;
  messageId?: string;
  error?: string;
}

export interface EmailData {
  to: string;
  subject: string;
  html: string;
  text?: string;
}

export class MailerService {
  private transporter: Transporter | null = null;
  private config: SmtpConfig | null = null;
  private isInitialized: boolean = false;

  async initialize(): Promise<boolean> {
    if (this.isInitialized && this.transporter) {
      return true;
    }

    try {
      const dbConfig = await getSmtpConfigDecrypted();
      if (!dbConfig) {
        console.log('Aucune configuration SMTP trouvée');
        return false;
      }

      console.log('Configuration SMTP trouvée - initialisation du transporteur');
      
      // Configuration optimisée pour nodemailer
      const transporterConfig: any = {
        host: dbConfig.host,
        port: dbConfig.port,
        secure: dbConfig.secure, // true pour 465, false pour autres ports
        auth: {
          user: dbConfig.username,
          pass: dbConfig.password, // Mot de passe déchiffré
        },
        tls: {
          rejectUnauthorized: dbConfig.tls_reject_unauthorized,
          minVersion: dbConfig.tls_min_version || 'TLSv1.2',
        },
        // Configuration de pool pour de meilleures performances
        pool: true,
        maxConnections: 5,
        maxMessages: 100,
        rateLimit: 10, // 10 emails par seconde max
        // Timeout configuration
        connectionTimeout: 60000, // 60 secondes
        greetingTimeout: 30000,   // 30 secondes
        socketTimeout: 60000,     // 60 secondes
      };

      this.transporter = nodemailer.createTransport(transporterConfig);
      this.config = {
        host: dbConfig.host,
        port: dbConfig.port,
        secure: dbConfig.secure,
        auth: {
          user: dbConfig.username,
          pass: dbConfig.password,
        },
        tls: {
          rejectUnauthorized: dbConfig.tls_reject_unauthorized,
          minVersion: dbConfig.tls_min_version || 'TLSv1.2',
        },
      };
      
      // Vérification de la connexion avec timeout
      await Promise.race([
        this.transporter.verify(),
        new Promise((_, reject) => 
          setTimeout(() => reject(new Error('Timeout de vérification SMTP')), 30000)
        )
      ]);
      
      this.isInitialized = true;
      console.log('Configuration SMTP initialisée avec succès');
      return true;
    } catch (error) {
      console.error('Erreur lors de l\'initialisation SMTP:', error);
      this.transporter = null;
      this.isInitialized = false;
      return false;
    }
  }

  async sendEmail(emailData: EmailData): Promise<MailerResult> {
    if (!this.transporter || !this.config || !this.isInitialized) {
      const error = 'Transporter SMTP non initialisé';
      console.error(error);
      return { success: false, error };
    }

    try {
      const mailOptions = {
        from: `"U Silenziu" <${this.config.auth.user}>`,
        to: emailData.to,
        subject: emailData.subject,
        html: emailData.html,
        text: emailData.text || this.stripHtml(emailData.html),
        // Ajout d'en-têtes pour améliorer la délivrabilité
        headers: {
          'X-Mailer': 'U Silenziu Mailer v1.0',
          'X-Priority': '3',
          'X-MSMail-Priority': 'Normal',
        },
      };

      const info = await this.transporter.sendMail(mailOptions);
      console.log('Email envoyé avec succès:', info.messageId);
      return { success: true, messageId: info.messageId };
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Erreur inconnue';
      console.error('Erreur lors de l\'envoi d\'email:', errorMessage);
      return { success: false, error: errorMessage };
    }
  }

  async testConnection(): Promise<{ success: boolean; message: string }> {
    try {
      const isInitialized = await this.initialize();
      if (!isInitialized) {
        return {
          success: false,
          message: 'Configuration SMTP invalide ou manquante'
        };
      }

      // Note: Impossible de tester la connexion car le mot de passe est chiffré
      return {
        success: true,
        message: 'Configuration SMTP trouvée (mot de passe chiffré, test de connexion impossible)'
      };
    } catch (error) {
      return {
        success: false,
        message: `Erreur de connexion: ${error instanceof Error ? error.message : 'Erreur inconnue'}`
      };
    }
  }

  async testConnectionWithConfig(config: any): Promise<{ success: boolean; message: string }> {
    try {
      const transporter = nodemailer.createTransport(config);
      await transporter.verify();
      
      return {
        success: true,
        message: 'Test de connexion SMTP réussi'
      };
    } catch (error) {
      return {
        success: false,
        message: `Erreur de connexion: ${error instanceof Error ? error.message : 'Erreur inconnue'}`
      };
    }
  }

  private stripHtml(html: string): string {
    return html.replace(/<[^>]*>/g, '').replace(/\s+/g, ' ').trim();
  }

  // Template pour les rappels de réservation
  generateReservationReminderEmail(reservation: any): EmailData {
    const html = `
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
            <div class="greeting">Bonjour ${reservation.firstName} ${reservation.lastName},</div>
            
            <div class="intro-text">
              Ceci est un rappel amical pour votre réservation chez <strong>U Silenziu</strong>. 
              Nous avons hâte de vous accueillir pour une session de défoulement mémorable !
            </div>
            
            <div class="reservation-card">
              <h2>📋 Détails de votre réservation</h2>
              
              <div class="reservation-number">
                N° ${reservation.reservationNumber}
              </div>
              
              <div class="detail-grid">
                <div class="detail-item">
                  <div class="detail-label">Salle</div>
                  <div class="detail-value">${reservation.roomName}</div>
                </div>
                <div class="detail-item">
                  <div class="detail-label">Date</div>
                  <div class="detail-value">${new Date(reservation.date).toLocaleDateString('fr-FR', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}</div>
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
                  <div class="detail-value">${reservation.numberOfPeople}</div>
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
    `;

    return {
      to: reservation.email,
      subject: `Rappel: Votre réservation U Silenziu - ${reservation.reservationNumber}`,
      html: html
    };
  }
}

// Instance singleton
export const mailerService = new MailerService();
