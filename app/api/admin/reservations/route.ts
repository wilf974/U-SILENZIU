import { NextRequest, NextResponse } from 'next/server'
import { getAllReservations, createReservation, generateReservationNumber, getRoomByName } from '@/lib/database'

/**
 * API Route pour la gestion administrative des réservations
 * GET - Récupérer toutes les réservations avec filtres
 * POST - Créer une nouvelle réservation manuellement
 */

// GET - Récupérer toutes les réservations avec filtres optionnels
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const status = searchParams.get('status')
    const date = searchParams.get('date')
    const room = searchParams.get('room')
    const search = searchParams.get('search')

    let reservations = await getAllReservations()

    // Appliquer les filtres
    if (status) {
      reservations = reservations.filter(r => r.status === status)
    }

    if (date) {
      reservations = reservations.filter(r => r.date === date)
    }

    if (room) {
      reservations = reservations.filter(r => r.room_name === room)
    }

    if (search) {
      const searchLower = search.toLowerCase()
      reservations = reservations.filter(r => 
        r.customer_name.toLowerCase().includes(searchLower) ||
        r.customer_email.toLowerCase().includes(searchLower) ||
        r.reservation_number.includes(search) ||
        r.customer_phone.includes(search)
      )
    }

    // Calculer les statistiques
    const stats = {
      total: reservations.length,
      pending: reservations.filter(r => r.status === 'pending').length,
      confirmed: reservations.filter(r => r.status === 'confirmed').length,
      cancelled: reservations.filter(r => r.status === 'cancelled').length,
      totalRevenue: reservations
        .filter(r => r.status === 'confirmed') // Seulement les réservations confirmées
        .reduce((sum, r) => sum + (typeof r.amount === 'string' ? parseFloat(r.amount) : (r.amount || 0)), 0)
    }

    return NextResponse.json({
      success: true,
      data: reservations,
      stats,
      filters: { status, date, room, search },
      timestamp: new Date().toISOString()
    })
  } catch (error) {
    console.error('Erreur lors de la récupération des réservations:', error)
    return NextResponse.json(
      { 
        success: false,
        error: 'Erreur lors de la récupération des réservations',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}

// POST - Créer une nouvelle réservation manuellement (admin)
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    
    // Validation des champs requis
    const requiredFields = [
      'first_name', 'last_name', 'email', 'phone', 
      'date', 'time', 'duration', 'number_of_people', 
      'room_name'
    ]
    
    for (const field of requiredFields) {
      if (!body[field]) {
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
    if (body.number_of_people < 1 || body.number_of_people > 8) {
      return NextResponse.json(
        { 
          success: false,
          error: 'Le nombre de personnes doit être entre 1 et 8' 
        },
        { status: 400 }
      )
    }

    // Générer le numéro de réservation
    const reservationNumber = await generateReservationNumber()
    
    // Récupérer le prix de la salle si le montant n'est pas fourni
    let amount = body.amount || 0
    if (!body.amount && body.room_name) {
      const room = await getRoomByName(body.room_name)
      // Calculer le montant total (prix par personne × nombre de personnes)
      amount = room ? room.price * body.number_of_people : 0
    }
    
    // Créer la réservation
    const reservation = await createReservation({
      reservation_number: reservationNumber,
      customer_name: `${body.first_name} ${body.last_name}`,
      customer_email: body.email,
      customer_phone: body.phone,
      date: body.date,
      time_slot: body.time,
      duration: body.duration,
      participants: body.number_of_people,
      room_name: body.room_name,
      status: body.status || 'pending',
      amount: amount,
      special_requests: body.notes || ''
    })

    return NextResponse.json({
      success: true,
      data: reservation,
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
