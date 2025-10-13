/**
 * Configuration et utilitaires Payplug
 * Documentation: https://docs.payplug.com/api/
 */

interface PayplugConfig {
  secretKey: string
  publicKey: string
  webhookSecret: string
  mode: 'test' | 'live'
}

interface PaymentData {
  amount: number
  currency: string
  billing: {
    title: string
    first_name: string
    last_name: string
    email: string
    mobile_phone_number: string
    address1: string
    address2: string
    postcode: string
    city: string
    country: string
  }
  shipping: {
    title: string
    first_name: string
    last_name: string
    email: string
    mobile_phone_number: string
    address1: string
    address2: string
    postcode: string
    city: string
    country: string
  }
  notification_url: string
  hosted_payment?: {
    return_url: string
    cancel_url: string
  }
  metadata?: Record<string, any>
}

interface PaymentResponse {
  id: string
  object: string
  is_live: boolean
  amount: number
  currency: string
  payment_url: string
  hosted_payment: {
    payment_url: string
    return_url: string
    cancel_url: string
  }
  customer: {
    email: string
    first_name: string
    last_name: string
  }
  order: string
  custom_data?: Record<string, any>
  created_at: number
  is_paid: boolean
  is_refunded: boolean
  refunded_amount: number
  metadata?: Record<string, any>
}

class PayplugService {
  private config: PayplugConfig
  private baseUrl: string

  constructor() {
    this.config = {
      secretKey: process.env.PAYPLUG_SECRET_KEY || '',
      publicKey: process.env.PAYPLUG_PUBLIC_KEY || '',
      webhookSecret: process.env.PAYPLUG_WEBHOOK_SECRET || '',
      mode: (process.env.PAYPLUG_MODE as 'test' | 'live') || 'test'
    }

    // Payplug utilise la même URL pour test et live selon la documentation
    this.baseUrl = 'https://api.payplug.com'
  }

  /**
   * Vérifie si Payplug est correctement configuré
   * D'après la documentation Payplug, seule la clé secrète est nécessaire
   */
  isConfigured(): boolean {
    // Payplug n'utilise que la clé secrète pour l'API (test et live)
    return !!this.config.secretKey && this.config.secretKey.length > 0
  }

  /**
   * Crée un paiement hébergé
   * @param paymentData - Données du paiement
   * @returns URL de redirection vers Payplug
   */
  async createPayment(paymentData: PaymentData): Promise<{ success: boolean; payment_url?: string; error?: string }> {
    if (!this.isConfigured()) {
      return { success: false, error: 'Payplug non configuré' }
    }

    try {
      const response = await fetch(`${this.baseUrl}/v1/payments`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.config.secretKey}`,
          'Content-Type': 'application/json',
          'PayPlug-Version': '2019-08-06' // Version API requise selon la doc
        },
        body: JSON.stringify(paymentData)
      })

      if (!response.ok) {
        const errorData = await response.json()
        console.error('Erreur Payplug:', errorData)
        return { 
          success: false, 
          error: errorData.message || 'Erreur lors de la création du paiement' 
        }
      }

      const payment: PaymentResponse = await response.json()
      
      return {
        success: true,
        payment_url: payment.hosted_payment?.payment_url || payment.payment_url
      }
    } catch (error) {
      console.error('Erreur lors de la création du paiement Payplug:', error)
      return { 
        success: false, 
        error: 'Erreur de connexion avec Payplug' 
      }
    }
  }

  /**
   * Récupère les détails d'un paiement
   * @param paymentId - ID du paiement
   * @returns Détails du paiement
   */
  async getPayment(paymentId: string): Promise<{ success: boolean; payment?: PaymentResponse; error?: string }> {
    if (!this.isConfigured()) {
      return { success: false, error: 'Payplug non configuré' }
    }

    try {
      const response = await fetch(`${this.baseUrl}/v1/payments/${paymentId}`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${this.config.secretKey}`,
          'Content-Type': 'application/json',
          'PayPlug-Version': '2019-08-06'
        }
      })

      if (!response.ok) {
        const errorData = await response.json()
        return { 
          success: false, 
          error: errorData.message || 'Erreur lors de la récupération du paiement' 
        }
      }

      const payment: PaymentResponse = await response.json()
      
      return {
        success: true,
        payment
      }
    } catch (error) {
      console.error('Erreur lors de la récupération du paiement Payplug:', error)
      return { 
        success: false, 
        error: 'Erreur de connexion avec Payplug' 
      }
    }
  }

  /**
   * Vérifie la signature d'un webhook Payplug
   * @param payload - Corps de la requête webhook
   * @param signature - Signature fournie par Payplug
   * @returns true si la signature est valide
   */
  verifyWebhookSignature(payload: string, signature: string): boolean {
    // En mode test sans secret webhook, on accepte tout
    if (this.config.mode === 'test' && !this.config.webhookSecret) {
      console.log('Mode test: signature webhook ignorée')
      return true
    }

    if (!this.config.webhookSecret) {
      console.error('Secret webhook non configuré')
      return false
    }

    try {
      const crypto = require('crypto')
      const expectedSignature = crypto
        .createHmac('sha256', this.config.webhookSecret)
        .update(payload)
        .digest('hex')
      
      return crypto.timingSafeEqual(
        Buffer.from(signature, 'hex'),
        Buffer.from(expectedSignature, 'hex')
      )
    } catch (error) {
      console.error('Erreur lors de la vérification de la signature webhook:', error)
      return false
    }
  }

  /**
   * Traite un webhook Payplug
   * @param payload - Corps de la requête webhook
   * @param signature - Signature fournie par Payplug
   * @returns Données du webhook si valide
   */
  async processWebhook(payload: string, signature: string): Promise<{ success: boolean; data?: any; error?: string }> {
    if (!this.verifyWebhookSignature(payload, signature)) {
      return { success: false, error: 'Signature webhook invalide' }
    }

    try {
      const webhookData = JSON.parse(payload)
      return { success: true, data: webhookData }
    } catch (error) {
      console.error('Erreur lors du parsing du webhook:', error)
      return { success: false, error: 'Payload webhook invalide' }
    }
  }

  /**
   * Crée un remboursement
   * @param paymentId - ID du paiement à rembourser
   * @param amount - Montant du remboursement (optionnel, rembourse tout si non spécifié)
   * @returns Résultat du remboursement
   */
  async createRefund(paymentId: string, amount?: number): Promise<{ success: boolean; refund?: any; error?: string }> {
    if (!this.isConfigured()) {
      return { success: false, error: 'Payplug non configuré' }
    }

    try {
      const refundData = amount ? { amount } : {}
      
      const response = await fetch(`${this.baseUrl}/v1/payments/${paymentId}/refunds`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${this.config.secretKey}`,
          'Content-Type': 'application/json',
          'PayPlug-Version': '2019-08-06'
        },
        body: JSON.stringify(refundData)
      })

      if (!response.ok) {
        const errorData = await response.json()
        return { 
          success: false, 
          error: errorData.message || 'Erreur lors du remboursement' 
        }
      }

      const refund = await response.json()
      
      return {
        success: true,
        refund
      }
    } catch (error) {
      console.error('Erreur lors du remboursement Payplug:', error)
      return { 
        success: false, 
        error: 'Erreur de connexion avec Payplug' 
      }
    }
  }
}

// Instance singleton
export const payplugService = new PayplugService()

// Types exportés
export type { PaymentData, PaymentResponse }
