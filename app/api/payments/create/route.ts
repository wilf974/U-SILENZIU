import { NextRequest, NextResponse } from 'next/server'
import { payplugService } from '@/lib/payplug'

/**
 * API pour créer un paiement Payplug
 * POST /api/payments/create
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    
    console.log('Création paiement Payplug:', body)
    
    // Validation des données requises
    const requiredFields = ['reservationNumber', 'amount', 'customer']
    for (const field of requiredFields) {
      if (!body[field]) {
        return NextResponse.json(
          { success: false, error: `Le champ ${field} est requis` },
          { status: 400 }
        )
      }
    }

    // Validation du montant
    if (body.amount <= 0) {
      return NextResponse.json(
        { success: false, error: 'Le montant doit être supérieur à 0' },
        { status: 400 }
      )
    }

    // Validation de l'email client
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(body.customer.email)) {
      return NextResponse.json(
        { success: false, error: 'Format d\'email invalide' },
        { status: 400 }
      )
    }

    // Vérifier que Payplug est configuré
    if (!payplugService.isConfigured()) {
      console.error('Payplug non configuré')
      return NextResponse.json(
        { success: false, error: 'Service de paiement non configuré' },
        { status: 500 }
      )
    }

    // Construire l'URL de base
    const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || 'http://localhost:3000'
    
    // Données du paiement pour Payplug selon la doc officielle
    const paymentData = {
      amount: Math.round(body.amount * 100), // Convertir en centimes
      currency: 'EUR',
      customer: {
        email: body.customer.email,
        first_name: body.customer.first_name || '',
        last_name: body.customer.last_name || ''
      },
      order: body.order || `Réservation ${body.reservationNumber}`,
      custom_data: {
        reservation_number: body.reservationNumber,
        ...body.custom_data
      },
      return_url: `${baseUrl}/reservation/payment/return?reservation=${body.reservationNumber}`,
      notification_url: `${baseUrl}/api/webhooks/payplug`,
      hosted_payment: {
        return_url: `${baseUrl}/reservation/payment/return?reservation=${body.reservationNumber}&status=success`,
        cancel_url: `${baseUrl}/reservation/payment/return?reservation=${body.reservationNumber}&status=cancelled`
      }
    }

    console.log('Données paiement Payplug:', paymentData)

    // Créer le paiement via Payplug
    const result = await payplugService.createPayment(paymentData)

    if (!result.success) {
      console.error('Erreur création paiement Payplug:', result.error)
      return NextResponse.json(
        { success: false, error: result.error || 'Erreur lors de la création du paiement' },
        { status: 500 }
      )
    }

    console.log('Paiement Payplug créé avec succès:', result.payment_url)

    return NextResponse.json({
      success: true,
      payment_url: result.payment_url,
      reservation_number: body.reservationNumber
    })

  } catch (error) {
    console.error('Erreur API création paiement:', error)
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur interne du serveur' 
      },
      { status: 500 }
    )
  }
}
