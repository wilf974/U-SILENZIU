import { NextRequest, NextResponse } from 'next/server'
import { payplugService } from '@/lib/payplug'
import { updateReservationByNumber } from '@/lib/database'
import { sendReservationConfirmationEmail } from '@/lib/email'

/**
 * Webhook Payplug pour traiter les notifications de paiement
 * POST /api/webhooks/payplug
 */
export async function POST(request: NextRequest) {
  try {
    // Récupérer le corps de la requête
    const body = await request.text()
    
    // Récupérer la signature Payplug
    const signature = request.headers.get('payplug-signature')
    
    if (!signature) {
      console.error('Webhook Payplug: Signature manquante')
      return NextResponse.json(
        { error: 'Signature manquante' },
        { status: 400 }
      )
    }

    console.log('Webhook Payplug reçu:', { signature: signature.substring(0, 20) + '...' })

    // Vérifier la signature et parser les données
    const webhookResult = await payplugService.processWebhook(body, signature)
    
    if (!webhookResult.success) {
      console.error('Webhook Payplug: Signature invalide ou données corrompues')
      return NextResponse.json(
        { error: webhookResult.error },
        { status: 400 }
      )
    }

    const webhookData = webhookResult.data
    console.log('Webhook Payplug: Données validées:', {
      type: webhookData.type,
      payment_id: webhookData.data?.id,
      is_paid: webhookData.data?.is_paid
    })

    // Traiter selon le type de webhook
    switch (webhookData.type) {
      case 'payment.paid':
        await handlePaymentPaid(webhookData.data)
        break
      
      case 'payment.refunded':
        await handlePaymentRefunded(webhookData.data)
        break
      
      case 'payment.failed':
        await handlePaymentFailed(webhookData.data)
        break
      
      default:
        console.log('Webhook Payplug: Type non géré:', webhookData.type)
    }

    return NextResponse.json({ success: true })

  } catch (error) {
    console.error('Erreur webhook Payplug:', error)
    return NextResponse.json(
      { error: 'Erreur interne du serveur' },
      { status: 500 }
    )
  }
}

/**
 * Traite un paiement confirmé
 */
async function handlePaymentPaid(paymentData: any) {
  try {
    console.log('Traitement paiement confirmé:', paymentData.id)
    
    // Récupérer le numéro de réservation depuis custom_data
    const reservationNumber = paymentData.custom_data?.reservation_number
    
    if (!reservationNumber) {
      console.error('Webhook Payplug: Numéro de réservation manquant dans custom_data')
      return
    }

    // Mettre à jour la réservation en base
    const updateData = {
      payment_id: paymentData.id,
      payment_status: 'paid',
      status: 'confirmed' as const,
      payment_amount: paymentData.amount / 100, // Convertir de centimes en euros
      payment_date: new Date(paymentData.created_at * 1000).toISOString()
    }

    console.log('Mise à jour réservation:', { reservationNumber, updateData })
    
    const updatedReservation = await updateReservationByNumber(reservationNumber, updateData)
    
    if (!updatedReservation) {
      console.error('Webhook Payplug: Réservation non trouvée:', reservationNumber)
      return
    }

    console.log('Réservation mise à jour avec succès:', updatedReservation.id)

    // Envoyer l'email de confirmation de paiement
    try {
      await sendReservationConfirmationEmail({
        reservationNumber: updatedReservation.reservation_number,
        customerName: `${updatedReservation.first_name} ${updatedReservation.last_name}`,
        customerEmail: updatedReservation.email,
        customerPhone: updatedReservation.phone,
        roomName: updatedReservation.room_name,
        date: updatedReservation.date,
        timeSlot: `${updatedReservation.time} - ${updatedReservation.time}`,
        duration: updatedReservation.duration,
        participants: updatedReservation.number_of_people,
        amount: updatedReservation.amount,
        specialRequests: updatedReservation.notes || '',
        paymentConfirmed: true
      })
      
      console.log('Email de confirmation envoyé pour:', reservationNumber)
    } catch (emailError) {
      console.error('Erreur envoi email confirmation:', emailError)
    }

  } catch (error) {
    console.error('Erreur traitement paiement confirmé:', error)
  }
}

/**
 * Traite un paiement remboursé
 */
async function handlePaymentRefunded(paymentData: any) {
  try {
    console.log('Traitement paiement remboursé:', paymentData.id)
    
    const reservationNumber = paymentData.custom_data?.reservation_number
    
    if (!reservationNumber) {
      console.error('Webhook Payplug: Numéro de réservation manquant pour remboursement')
      return
    }

    // Mettre à jour la réservation
    const updateData = {
      payment_status: 'refunded',
      status: 'cancelled' as const,
      refund_amount: paymentData.refunded_amount / 100,
      refund_date: new Date().toISOString()
    }

    await updateReservationByNumber(reservationNumber, updateData)
    console.log('Réservation marquée comme remboursée:', reservationNumber)

  } catch (error) {
    console.error('Erreur traitement remboursement:', error)
  }
}

/**
 * Traite un paiement échoué
 */
async function handlePaymentFailed(paymentData: any) {
  try {
    console.log('Traitement paiement échoué:', paymentData.id)
    
    const reservationNumber = paymentData.custom_data?.reservation_number
    
    if (!reservationNumber) {
      console.error('Webhook Payplug: Numéro de réservation manquant pour échec')
      return
    }

    // Mettre à jour la réservation
    const updateData = {
      payment_status: 'failed',
      status: 'cancelled' as const,
      payment_error: 'Paiement échoué'
    }

    await updateReservationByNumber(reservationNumber, updateData)
    console.log('Réservation marquée comme échouée:', reservationNumber)

  } catch (error) {
    console.error('Erreur traitement échec paiement:', error)
  }
}
