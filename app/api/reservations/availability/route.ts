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
    
    // Créneaux horaires disponibles (exemple: 14h-21h)
    const timeSlots = [
      '14:00', '14:30', '15:00', '15:30', '16:00', '16:30',
      '17:00', '17:30', '18:00', '18:30', '19:00', '19:30',
      '20:00', '20:30'
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
      const dateStr = reservation.date
      const timeSlot = reservation.time || reservation.time_slot
      
      if (availability[dateStr] && timeSlot) {
        availability[dateStr][timeSlot] = false
        
        // Marquer aussi les créneaux suivants si la durée le nécessite
        const duration = reservation.duration || 30
        const additionalSlots = Math.ceil(duration / 30) - 1
        
        const currentSlotIndex = timeSlots.indexOf(timeSlot)
        if (currentSlotIndex !== -1) {
          for (let i = 1; i <= additionalSlots; i++) {
            const nextSlotIndex = currentSlotIndex + i
            if (nextSlotIndex < timeSlots.length) {
              availability[dateStr][timeSlots[nextSlotIndex]] = false
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