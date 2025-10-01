import { NextRequest, NextResponse } from 'next/server'
import { createReservation, generateReservationNumber, getRoomByName } from '@/lib/database'
import { sendReservationConfirmationEmail } from '@/lib/email'

/**
 * Nettoie et valide les données de réservation côté serveur
 */
function sanitizeReservationData(body: any) {
  const sanitized = { ...body }

  // Nettoyer les chaînes de caractères
  Object.keys(sanitized).forEach(key => {
    if (typeof sanitized[key] === 'string') {
      sanitized[key] = sanitized[key].trim()
      if (sanitized[key] === '') {
        sanitized[key] = null
      }
    }
  })

  // Valeurs par défaut pour les champs critiques
  const defaults = {
    firstName: 'Client',
    lastName: 'Inconnu',
    timeSlot: '14:00-16:00',
    duration: 60,
    numberOfPeople: 1,
    amount: 25.00,
    status: 'pending',
    paymentStatus: 'pending'
  }

  // Appliquer les valeurs par défaut si nécessaire
  Object.keys(defaults).forEach(key => {
    if (sanitized[key] === null || sanitized[key] === undefined || sanitized[key] === '') {
      sanitized[key] = defaults[key as keyof typeof defaults]
    }
  })

  // S'assurer que les champs numériques sont corrects
  if (sanitized.duration) {
    sanitized.duration = parseInt(sanitized.duration)
    if (isNaN(sanitized.duration) || sanitized.duration < 20) {
      sanitized.duration = 60
    }
  }

  if (sanitized.numberOfPeople) {
    sanitized.numberOfPeople = parseInt(sanitized.numberOfPeople)
    if (isNaN(sanitized.numberOfPeople) || sanitized.numberOfPeople < 1) {
      sanitized.numberOfPeople = 1
    }
  }

  if (sanitized.amount) {
    sanitized.amount = parseFloat(sanitized.amount)
    if (isNaN(sanitized.amount) || sanitized.amount <= 0) {
      sanitized.amount = 25.00
    }
  }

  return sanitized
}

/**
 * API Route publique pour les réservations clients
 * POST - Créer une nouvelle réservation
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()

    console.log('Données de réservation reçues:', body)

    // Nettoyer et valider les données côté serveur
    const sanitizedBody = sanitizeReservationData(body)
    console.log('Données nettoyées:', sanitizedBody)
    
    // Validation des champs requis
    const requiredFields = [
      'firstName', 'lastName', 'email', 'phone', 
      'date', 'timeSlot', 'duration', 'numberOfPeople', 
      'roomName'
    ]
    
    for (const field of requiredFields) {
      if (!sanitizedBody[field]) {
        console.log(`Champ manquant après nettoyage: ${field}`)
        return NextResponse.json(
          {
            success: false,
            error: `Le champ ${field} est requis`
          },
          { status: 400 }
        )
      }
    }

    // Validation du nombre de personnes (après nettoyage)
    if (sanitizedBody.numberOfPeople < 1 || sanitizedBody.numberOfPeople > 8) {
      return NextResponse.json(
        {
          success: false,
          error: 'Le nombre de personnes doit être entre 1 et 8'
        },
        { status: 400 }
      )
    }

    // Validation de l'email (après nettoyage)
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(sanitizedBody.email)) {
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
      reservation_number: reservationNumber,
      first_name: body.firstName,
      last_name: body.lastName,
      email: body.email,
      phone: body.phone,
      room_name: body.roomName,
      date: body.date,
      time: body.timeSlot.split(' - ')[0], // Extraire l'heure de début
      duration: body.duration,
      number_of_people: body.numberOfPeople,
      amount: totalAmount,
      status: 'pending' as const,
      notes: body.specialRequests || ''
    }
    
    console.log('Données pour createReservation:', reservationData)
    
    // Créer la réservation
    const reservation = await createReservation(reservationData)

    console.log('Réservation créée:', reservation)

    // Envoyer l'email de confirmation (en arrière-plan, ne pas bloquer la réponse)
    sendReservationConfirmationEmail({
      reservationNumber: reservation.reservation_number,
      customerName: `${body.firstName} ${body.lastName}`,
      customerEmail: body.email,
      customerPhone: body.phone,
      roomName: body.roomName,
      date: body.date,
      timeSlot: body.timeSlot,
      duration: body.duration,
      participants: body.numberOfPeople,
      amount: totalAmount,
      specialRequests: body.specialRequests || ''
    }).catch(error => {
      console.error('Erreur lors de l\'envoi de l\'email de confirmation:', error)
    })

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