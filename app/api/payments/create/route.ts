import { NextRequest, NextResponse } from 'next/server'
import { payplugService } from '@/lib/payplug'

/**
 * Formate un numéro de téléphone français au format international pour Payplug
 * @param phone - Numéro de téléphone (ex: "0612345678", "0123456789")
 * @returns Numéro formaté (ex: "+33612345678", "+33123456789")
 */
function formatPhoneForPayplug(phone: string): string {
  if (!phone) return '+33123456789'
  
  // Si déjà au format international, retourner tel quel
  if (phone.startsWith('+33')) return phone
  
  // Nettoyer le numéro (supprimer espaces, tirets, points)
  const cleanPhone = phone.replace(/[\s\-\.]/g, '')
  
  // Si commence par 0, remplacer par +33
  if (cleanPhone.startsWith('0')) {
    return '+33' + cleanPhone.substring(1)
  }
  
  // Si commence par 33, ajouter le +
  if (cleanPhone.startsWith('33')) {
    return '+' + cleanPhone
  }
  
  // Par défaut, ajouter +33
  return '+33' + cleanPhone
}

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
    const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || 'http://localhost:8080'
    
    // Données du paiement pour Payplug selon la doc officielle
    const paymentData = {
      amount: Math.round(body.amount * 100), // Convertir en centimes
      currency: 'EUR',
      billing: {
        title: 'mr',
        first_name: body.customer.first_name || 'Test',
        last_name: body.customer.last_name || 'User',
        email: body.customer.email,
        mobile_phone_number: formatPhoneForPayplug(body.customer.phone),
        address1: '18 Rue du Pont Long',
        address2: 'Zone Berlanne',
        postcode: '64160',
        city: 'Buros',
        country: 'FR'
      },
      shipping: {
        title: 'mr',
        first_name: body.customer.first_name || 'Test',
        last_name: body.customer.last_name || 'User',
        email: body.customer.email,
        mobile_phone_number: formatPhoneForPayplug(body.customer.phone),
        address1: '18 Rue du Pont Long',
        address2: 'Zone Berlanne',
        postcode: '64160',
        city: 'Buros',
        country: 'FR'
      },
      // Pas de webhook - vérification manuelle uniquement
      notification_url: `${baseUrl}/api/webhooks/payplug`,
      hosted_payment: {
        return_url: `${baseUrl}/reservation/payment/success?reservation=${body.reservationNumber}`,
        cancel_url: `${baseUrl}/reservation/payment/cancelled?reservation=${body.reservationNumber}`
      },
      metadata: {
        reservation_number: body.reservationNumber,
        ...body.metadata
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
