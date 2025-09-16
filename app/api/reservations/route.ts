import { NextRequest, NextResponse } from 'next/server'
import { createReservation, getAllReservations, generateReservationNumber, getRoomByName } from '@/lib/database'
import { sendReservationConfirmationEmail } from '@/lib/reservationEmails'

// GET - Récupérer toutes les réservations
export async function GET() {
  try {
    const reservations = await getAllReservations()
    return NextResponse.json(reservations)
  } catch (error) {
    console.error('Erreur lors de la récupération des réservations:', error)
    return NextResponse.json(
      { error: 'Erreur lors de la récupération des réservations' },
      { status: 500 }
    )
  }
}

// POST - Créer une nouvelle réservation
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    
    // Validation des champs requis
    const requiredFields = [
      'firstName', 'lastName', 'email', 'phone', 
      'date', 'timeSlot', 'duration', 'numberOfPeople', 
      'formula', 'roomName'
    ]
    
    for (const field of requiredFields) {
      if (!body[field]) {
        return NextResponse.json(
          { error: `Le champ ${field} est requis` },
          { status: 400 }
        )
      }
    }

    // Validation du nombre de personnes (optionnel - peut être commenté si pas nécessaire)
    if (body.numberOfPeople < 1 || body.numberOfPeople > 8) {
      return NextResponse.json(
        { error: 'Le nombre de personnes doit être entre 1 et 8' },
        { status: 400 }
      )
    }

    // Vérifier que la salle existe dans la base de données
    const room = await getRoomByName(body.roomName)
    if (!room) {
      return NextResponse.json(
        { error: `Salle non trouvée: ${body.roomName}` },
        { status: 400 }
      )
    }

    // Générer le numéro de réservation
    const reservationNumber = await generateReservationNumber()
    
    // Extraire l'heure de début du créneau (ex: "16:30 - 16:50" -> "16:30:00")
    const startTime = body.timeSlot.split(' - ')[0] + ':00'
    
    // Calculer le montant total (prix par personne × nombre de personnes)
    const amount = room.price * body.numberOfPeople
    
    // Créer la réservation
    const reservation = await createReservation({
      reservation_number: reservationNumber,
      first_name: body.firstName,
      last_name: body.lastName,
      email: body.email,
      phone: body.phone,
      date: body.date,
      time: startTime,
      duration: body.duration,
      number_of_people: body.numberOfPeople,
      room_name: body.roomName,
      status: 'pending',
      amount: amount
    })

    // Envoyer l'email de confirmation
    try {
      console.log('📧 Tentative d\'envoi de l\'email de confirmation pour la réservation:', reservation.reservation_number)
      const emailSent = await sendReservationConfirmationEmail(reservation)
      if (emailSent) {
        console.log('✅ Email de confirmation envoyé avec succès pour la réservation:', reservation.reservation_number)
      } else {
        console.error('❌ Échec de l\'envoi de l\'email de confirmation pour la réservation:', reservation.reservation_number)
      }
    } catch (error) {
      console.error('❌ Erreur lors de l\'envoi de l\'email de confirmation:', error)
    }

    return NextResponse.json(reservation, { status: 201 })
  } catch (error) {
    console.error('Erreur lors de la création de la réservation:', error)
    console.error('Détails de l\'erreur:', {
      message: error instanceof Error ? error.message : 'Erreur inconnue',
      stack: error instanceof Error ? error.stack : undefined,
      body: request.body
    })
    return NextResponse.json(
      { 
        error: 'Erreur lors de la création de la réservation',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}
