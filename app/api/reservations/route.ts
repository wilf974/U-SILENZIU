import { NextRequest, NextResponse } from 'next/server'
import { createReservation, generateReservationNumber, getRoomByName } from '@/lib/database'

/**
 * API Route publique pour les réservations clients
 * POST - Créer une nouvelle réservation
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    
    console.log('Données de réservation reçues:', body)
    
    // Validation des champs requis
    const requiredFields = [
      'firstName', 'lastName', 'email', 'phone', 
      'date', 'timeSlot', 'duration', 'numberOfPeople', 
      'roomName'
    ]
    
    for (const field of requiredFields) {
      if (!body[field]) {
        console.log(`Champ manquant: ${field}`)
        return NextResponse.json(
          { 
            success: false,
            error: `Le champ ${field} est requis` 
          },
          { status: 400 }
        )
      }
    }

    // Validation du nombre de personnes
    if (body.numberOfPeople < 1 || body.numberOfPeople > 8) {
      return NextResponse.json(
        { 
          success: false,
          error: 'Le nombre de personnes doit être entre 1 et 8' 
        },
        { status: 400 }
      )
    }

    // Validation de l'email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(body.email)) {
      return NextResponse.json(
        { 
          success: false,
          error: 'Format d\'email invalide' 
        },
        { status: 400 }
      )
    }

    // Générer le numéro de réservation
    const reservationNumber = await generateReservationNumber()
    
    // Récupérer les informations de la salle et calculer le prix
    console.log('Recherche de la salle:', body.roomName)
    const room = await getRoomByName(body.roomName)
    console.log('Salle trouvée:', room)
    
    if (!room) {
      console.log('Salle non trouvée:', body.roomName)
      return NextResponse.json(
        { 
          success: false,
          error: 'Salle non trouvée' 
        },
        { status: 404 }
      )
    }

    // Calculer le montant total (prix par personne × nombre de personnes)
    const totalAmount = room.price * body.numberOfPeople
    
    console.log(`Calcul prix: ${room.price} × ${body.numberOfPeople} = ${totalAmount}`)
    
    // Créer la réservation avec les bons noms de champs (correspondant à la structure DB)
    const reservationData = {
      customer_name: `${body.firstName} ${body.lastName}`,
      customer_email: body.email,
      customer_phone: body.phone,
      room_name: body.roomName,
      date: body.date,
      time_slot: body.timeSlot,
      duration: body.duration,
      participants: body.numberOfPeople,
      amount: totalAmount,
      status: 'pending' as const,
      special_requests: body.specialRequests || ''
    }
    
    console.log('Données pour createReservation:', reservationData)
    
    // Créer la réservation
    const reservation = await createReservation(reservationData)

    console.log('Réservation créée:', reservation)

    return NextResponse.json({
      success: true,
      data: {
        id: reservation.id,
        reservationNumber: reservation.reservation_number,
        amount: totalAmount,
        status: 'pending',
        room: room.name,
        date: body.date,
        time: body.timeSlot,
        numberOfPeople: body.numberOfPeople
      },
      message: 'Réservation créée avec succès'
    }, { status: 201 })

  } catch (error) {
    console.error('Erreur lors de la création de la réservation:', error)
    return NextResponse.json(
      { 
        success: false,
        error: 'Erreur lors de la création de la réservation',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}

/**
 * GET /api/reservations
 * Récupérer une réservation par numéro (pour vérification)
 */
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const reservationNumber = searchParams.get('number')
    
    if (!reservationNumber) {
      return NextResponse.json(
        { 
          success: false,
          error: 'Numéro de réservation requis' 
        },
        { status: 400 }
      )
    }

    // Cette fonctionnalité pourrait être implémentée plus tard
    return NextResponse.json(
      { 
        success: false,
        error: 'Fonctionnalité non implémentée' 
      },
      { status: 501 }
    )

  } catch (error) {
    console.error('Erreur lors de la récupération de la réservation:', error)
    return NextResponse.json(
      { 
        success: false,
        error: 'Erreur interne du serveur' 
      },
      { status: 500 }
    )
  }
}