import { NextRequest, NextResponse } from 'next/server'
import { getReservationById, updateReservation, deleteReservation } from '@/lib/database'
import { sendReservationValidationEmail, sendReservationCancellationEmail } from '@/lib/reservationEmails'

/**
 * API Route pour la gestion d'une réservation spécifique
 * GET - Récupérer une réservation par ID
 * PUT - Modifier une réservation
 * DELETE - Supprimer une réservation
 */

// GET - Récupérer une réservation par ID
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const reservation = await getReservationById(params.id)
    
    if (!reservation) {
      return NextResponse.json(
        { 
          success: false,
          error: 'Réservation non trouvée' 
        },
        { status: 404 }
      )
    }

    return NextResponse.json({
      success: true,
      data: reservation,
      timestamp: new Date().toISOString()
    })
  } catch (error) {
    console.error('Erreur lors de la récupération de la réservation:', error)
    return NextResponse.json(
      { 
        success: false,
        error: 'Erreur lors de la récupération de la réservation',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}

// PUT - Modifier une réservation
export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const body = await request.json()
    
    // Vérifier que la réservation existe
    const existingReservation = await getReservationById(params.id)
    if (!existingReservation) {
      return NextResponse.json(
        { 
          success: false,
          error: 'Réservation non trouvée' 
        },
        { status: 404 }
      )
    }

    // Validation des champs si fournis
    if (body.number_of_people && (body.number_of_people < 1 || body.number_of_people > 8)) {
      return NextResponse.json(
        { 
          success: false,
          error: 'Le nombre de personnes doit être entre 1 et 8' 
        },
        { status: 400 }
      )
    }

    if (body.status && !['pending', 'confirmed', 'cancelled'].includes(body.status)) {
      return NextResponse.json(
        { 
          success: false,
          error: 'Statut invalide. Valeurs autorisées: pending, confirmed, cancelled' 
        },
        { status: 400 }
      )
    }

    // Mettre à jour la réservation
    const updatedReservation = await updateReservation(params.id, body)
    
    if (!updatedReservation) {
      return NextResponse.json(
        { 
          success: false,
          error: 'Erreur lors de la mise à jour de la réservation' 
        },
        { status: 500 }
      )
    }

    // Envoyer un email de validation si le statut passe à "confirmed"
    if (body.status === 'confirmed' && existingReservation.status !== 'confirmed') {
      try {
        console.log('📧 Tentative d\'envoi de l\'email de validation pour la réservation:', updatedReservation.reservation_number)
        const emailSent = await sendReservationValidationEmail(updatedReservation)
        if (emailSent) {
          console.log('✅ Email de validation envoyé avec succès pour la réservation:', updatedReservation.reservation_number)
        } else {
          console.error('❌ Échec de l\'envoi de l\'email de validation pour la réservation:', updatedReservation.reservation_number)
        }
      } catch (error) {
        console.error('❌ Erreur lors de l\'envoi de l\'email de validation:', error)
      }
    }

    // Envoyer un email d'annulation si le statut passe à "cancelled"
    if (body.status === 'cancelled' && existingReservation.status !== 'cancelled') {
      try {
        console.log('📧 Tentative d\'envoi de l\'email d\'annulation pour la réservation:', updatedReservation.reservation_number)
        const emailSent = await sendReservationCancellationEmail(updatedReservation)
        if (emailSent) {
          console.log('✅ Email d\'annulation envoyé avec succès pour la réservation:', updatedReservation.reservation_number)
        } else {
          console.error('❌ Échec de l\'envoi de l\'email d\'annulation pour la réservation:', updatedReservation.reservation_number)
        }
      } catch (error) {
        console.error('❌ Erreur lors de l\'envoi de l\'email d\'annulation:', error)
      }
    }

    return NextResponse.json({
      success: true,
      data: updatedReservation,
      message: 'Réservation mise à jour avec succès'
    })
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la réservation:', error)
    return NextResponse.json(
      { 
        success: false,
        error: 'Erreur lors de la mise à jour de la réservation',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}

// DELETE - Supprimer une réservation
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    // Vérifier que la réservation existe
    const existingReservation = await getReservationById(params.id)
    if (!existingReservation) {
      return NextResponse.json(
        { 
          success: false,
          error: 'Réservation non trouvée' 
        },
        { status: 404 }
      )
    }

    // Supprimer la réservation
    const deleted = await deleteReservation(params.id)
    
    if (!deleted) {
      return NextResponse.json(
        { 
          success: false,
          error: 'Erreur lors de la suppression de la réservation' 
        },
        { status: 500 }
      )
    }

    return NextResponse.json({
      success: true,
      message: 'Réservation supprimée avec succès',
      data: { id: params.id }
    })
  } catch (error) {
    console.error('Erreur lors de la suppression de la réservation:', error)
    return NextResponse.json(
      { 
        success: false,
        error: 'Erreur lors de la suppression de la réservation',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}
