import { NextRequest, NextResponse } from 'next/server'
import { getAllReservations } from '@/lib/database'

/**
 * API pour vérifier la disponibilité des créneaux
 * GET /api/reservations/availability
 */
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const startDate = searchParams.get('startDate')
    const endDate = searchParams.get('endDate')
    const roomName = searchParams.get('roomName')

    console.log('Vérification disponibilité:', { startDate, endDate, roomName })

    if (!startDate || !endDate) {
      return NextResponse.json(
        { 
          success: false,
          error: 'Les paramètres startDate et endDate sont requis' 
        },
        { status: 400 }
      )
    }

    // Récupérer toutes les réservations confirmées ou en attente
    const reservations = await getAllReservations()
    
    // Filtrer les réservations par salle si spécifiée
    let filteredReservations = reservations.filter(r => 
      r.status === 'confirmed' || r.status === 'pending'
    )
    
    if (roomName) {
      filteredReservations = filteredReservations.filter(r => 
        r.room_name === roomName
      )
    }
    
    // Filtrer par période de dates
    const start = new Date(startDate)
    const end = new Date(endDate)
    
    const reservationsInPeriod = filteredReservations.filter(r => {
      const reservationDate = new Date(r.date)
      return reservationDate >= start && reservationDate <= end
    })

    // Créer une structure de disponibilité par date et créneau
    const availability: Record<string, Record<string, boolean>> = {}
    
    // Créneaux horaires disponibles (tranches de 20 minutes de 16h à 23h selon les horaires d'ouverture)
    const timeSlots = [
      '16:00', '16:20', '16:40', '17:00', '17:20', '17:40',
      '18:00', '18:20', '18:40', '19:00', '19:20', '19:40',
      '20:00', '20:20', '20:40', '21:00', '21:20', '21:40',
      '22:00', '22:20', '22:40'
    ]
    
    // Initialiser tous les créneaux comme disponibles
    const currentDate = new Date(start)
    while (currentDate <= end) {
      const dateStr = currentDate.toISOString().split('T')[0]
      availability[dateStr] = {}
      
      timeSlots.forEach(slot => {
        availability[dateStr][slot] = true
      })
      
      currentDate.setDate(currentDate.getDate() + 1)
    }
    
    // Marquer les créneaux occupés
    reservationsInPeriod.forEach(reservation => {
      // Normaliser la date de la réservation (peut être ISO ou YYYY-MM-DD)
      const reservationDate = new Date(reservation.date)
      const dateStr = reservationDate.toISOString().split('T')[0]
      
      // Gérer les deux formats : time_slot (format "16:00 - 16:20") et time (format "16:00")
      let startTime = null
      if (reservation.time_slot) {
        // Format "16:00 - 16:20" -> extraire "16:00"
        startTime = reservation.time_slot.split(' - ')[0]
      } else if (reservation.time) {
        // Format "16:00" -> utiliser directement
        startTime = reservation.time
      }
      
      console.log('Réservation trouvée:', { 
        originalDate: reservation.date,
        normalizedDate: dateStr, 
        timeSlot: reservation.time_slot,
        time: reservation.time,
        extractedStartTime: startTime,
        duration: reservation.duration, 
        participants: reservation.participants,
        number_of_people: reservation.number_of_people
      })
      
      console.log('Availability keys:', Object.keys(availability))
      console.log('Looking for dateStr:', dateStr)
      
      if (availability[dateStr] && startTime) {
        console.log('Availability for date before:', availability[dateStr])
        
        if (availability[dateStr][startTime] !== undefined) {
          availability[dateStr][startTime] = false
          console.log(`✅ Créneau marqué comme occupé: ${dateStr} ${startTime}`)
        } else {
          console.log(`❌ StartTime ${startTime} not found in availability for ${dateStr}`)
        }
      } else {
        console.log(`❌ Date ${dateStr} not found in availability or startTime missing`)
      }
        
      // Marquer aussi les créneaux suivants si la durée le nécessite (seulement si le créneau principal a été trouvé)
      if (availability[dateStr] && startTime) {
        const duration = reservation.duration || 20
        const additionalSlots = Math.ceil(duration / 20) - 1 // Créneaux de 20 minutes
        
        const currentSlotIndex = timeSlots.indexOf(startTime)
        if (currentSlotIndex !== -1) {
          for (let i = 1; i <= additionalSlots; i++) {
            const nextSlotIndex = currentSlotIndex + i
            if (nextSlotIndex < timeSlots.length) {
              availability[dateStr][timeSlots[nextSlotIndex]] = false
              console.log(`Créneau suivant marqué comme occupé: ${dateStr} ${timeSlots[nextSlotIndex]}`)
            }
          }
        }
      }
    })

    return NextResponse.json({
      success: true,
      data: {
        availability,
        reservationsCount: reservationsInPeriod.length,
        period: { startDate, endDate },
        roomName: roomName || 'all'
      }
    })

  } catch (error) {
    console.error('Erreur lors de la vérification de disponibilité:', error)
    return NextResponse.json(
      { 
        success: false,
        error: 'Erreur lors de la vérification de disponibilité',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}