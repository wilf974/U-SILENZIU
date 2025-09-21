'use client'

import { useState, useMemo, useEffect } from 'react'
import { Calendar, momentLocalizer } from 'react-big-calendar'
import moment from 'moment'
import 'react-big-calendar/lib/css/react-big-calendar.css'
import 'moment/locale/fr'
import { Clock, Users, CalendarDays, ArrowLeft, Check, MapPin, User, Mail, Phone } from 'lucide-react'
import Link from 'next/link'
import { useSearchParams } from 'next/navigation'
import { useRooms, Room } from '@/hooks/useRooms'
import PayplugPayment from '@/components/PayplugPayment'

// Configuration du localizer avec moment en français
moment.locale('fr')
const localizer = momentLocalizer(moment)

// Types pour les créneaux et réservations
interface TimeSlot {
  id: string
  start: Date
  end: Date
  available: boolean
  maxCapacity: number
  currentBookings: number
}

interface Booking {
  reservationNumber: string
  date: Date
  timeSlot: TimeSlot
  duration: number
  numberOfPeople: number
  formula: string
  roomName: string
  firstName: string
  lastName: string
  email: string
  phone: string
}



const ReservationForm = () => {
  const searchParams = useSearchParams()
  const { rooms, loading: roomsLoading, getRoomByName, getActiveRooms } = useRooms()
  
  const [selectedDate, setSelectedDate] = useState<Date>(new Date())
  const [selectedTimeSlot, setSelectedTimeSlot] = useState<TimeSlot | null>(null)
  const [numberOfPeople, setNumberOfPeople] = useState<number>(2)
  const [duration, setDuration] = useState<number>(20)
  const [selectedFormula, setSelectedFormula] = useState<string>('pas-content')
  const [selectedRoom, setSelectedRoom] = useState<string>('')
  const [currentStep, setCurrentStep] = useState<number>(1)
  
  // Nouveaux états pour les informations personnelles
  const [firstName, setFirstName] = useState<string>('')
  const [lastName, setLastName] = useState<string>('')
  const [email, setEmail] = useState<string>('')
  const [phone, setPhone] = useState<string>('')
  const [reservationNumber, setReservationNumber] = useState<string>('')
  const [showPayment, setShowPayment] = useState<boolean>(false)
  
  // État pour le prix de la salle
  const [roomPrice, setRoomPrice] = useState<number>(0)

  // Fonction pour récupérer le prix de la salle
  const fetchRoomPrice = async (roomName: string) => {
    try {
      const response = await fetch(`/api/rooms/price?name=${encodeURIComponent(roomName)}`)
      if (response.ok) {
        const data = await response.json()
        setRoomPrice(data.price || 0)
      }
    } catch (error) {
      console.error('Erreur lors de la récupération du prix:', error)
      setRoomPrice(0)
    }
  }

  // Fonction pour créer une réservation via l'API
  const createReservation = async (reservationData: any): Promise<string> => {
    try {
      const response = await fetch('/api/reservations', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(reservationData),
      })

      if (!response.ok) {
        throw new Error('Erreur lors de la création de la réservation')
      }

      const result = await response.json()
      console.log('Réponse API complète:', result)
      console.log('Numéro de réservation extrait:', result.data?.reservationNumber)
      return result.data?.reservationNumber || 'N/A'
    } catch (error) {
      console.error('Erreur:', error)
      throw error
    }
  }

  // Génération dynamique des formules basée sur les salles disponibles
  const formulas = useMemo(() => {
    if (roomsLoading || !rooms.length) return []
    
    return rooms.map((room, index) => ({
      id: `formula-${room.id}`,
      name: room.name,
      duration: room.duration,
      maxPeople: room.max_people,
      description: room.description || `Session de défoulement dans ${room.name}`,
      roomName: room.name,
      price: room.price
    }))
  }, [rooms, roomsLoading])

  // Récupération du paramètre de formule depuis l'URL - Version dynamique
  useEffect(() => {
    const formuleParam = searchParams.get('formule')
    if (formuleParam && !roomsLoading && formulas.length > 0) {
      // Recherche directe de la salle par nom dans les salles disponibles
      const foundRoom = getRoomByName(formuleParam)
      if (foundRoom) {
        // Trouver la formule correspondante à cette salle
        const formula = formulas.find(f => f.roomName === foundRoom.name)
        if (formula) {
          setSelectedFormula(formula.id)
          setSelectedRoom(foundRoom.name)
          setDuration(foundRoom.duration)
          // Ajuster le nombre de personnes si nécessaire
          if (numberOfPeople > foundRoom.max_people) {
            setNumberOfPeople(foundRoom.max_people)
          }
        }
      } else {
        // Si la salle n'est pas trouvée, essayer de trouver par nom de formule
        const formula = formulas.find(f => f.name === formuleParam)
        if (formula) {
          setSelectedFormula(formula.id)
          setSelectedRoom(formula.roomName)
          setDuration(formula.duration)
          if (numberOfPeople > formula.maxPeople) {
            setNumberOfPeople(formula.maxPeople)
          }
        }
      }
    }
  }, [searchParams, formulas, roomsLoading, numberOfPeople, getRoomByName])

  // Initialisation de la première salle disponible quand les salles sont chargées
  useEffect(() => {
    if (!roomsLoading && rooms.length > 0 && !selectedRoom) {
      const firstRoom = rooms[0]
      setSelectedRoom(firstRoom.name)
      setDuration(firstRoom.duration)
      if (numberOfPeople > firstRoom.max_people) {
        setNumberOfPeople(firstRoom.max_people)
      }
    }
  }, [roomsLoading, rooms, selectedRoom, numberOfPeople])

  // Récupération du prix de la salle quand elle change
  useEffect(() => {
    if (selectedRoom) {
      fetchRoomPrice(selectedRoom)
    }
  }, [selectedRoom])

  // État pour les disponibilités réelles (peut être number ou boolean selon l'API)
  const [availabilityData, setAvailabilityData] = useState<{ [key: string]: { [key: string]: number | boolean } }>({})

  // Fonction pour récupérer les disponibilités réelles depuis l'API
  const fetchAvailabilityData = async (startDate: Date, endDate: Date, roomName?: string) => {
    try {
      // Utiliser la date locale au lieu de l'ISO pour éviter les problèmes de fuseau horaire
      const startYear = startDate.getFullYear()
      const startMonth = String(startDate.getMonth() + 1).padStart(2, '0')
      const startDay = String(startDate.getDate()).padStart(2, '0')
      const startDateStr = `${startYear}-${startMonth}-${startDay}`
      
      const endYear = endDate.getFullYear()
      const endMonth = String(endDate.getMonth() + 1).padStart(2, '0')
      const endDay = String(endDate.getDate()).padStart(2, '0')
      const endDateStr = `${endYear}-${endMonth}-${endDay}`
      
      const url = `/api/reservations/availability?startDate=${startDateStr}&endDate=${endDateStr}${roomName ? `&roomName=${encodeURIComponent(roomName)}` : ''}&t=${Date.now()}`
      
      const response = await fetch(url)
      if (response.ok) {
        const data = await response.json()
        // L'API retourne data.availability, pas data directement
        setAvailabilityData(data.data?.availability || data.data || {})
      } else {
        console.error('Erreur lors de la récupération des disponibilités:', response.statusText)
        setAvailabilityData({})
      }
    } catch (error) {
      console.error('Erreur lors de la récupération des disponibilités:', error)
      setAvailabilityData({})
    }
  }

  // Charger les données de disponibilité quand la date ou la salle change
  useEffect(() => {
    const startOfMonth = new Date(selectedDate.getFullYear(), selectedDate.getMonth(), 1)
    const endOfMonth = new Date(selectedDate.getFullYear(), selectedDate.getMonth() + 1, 0)
    
    fetchAvailabilityData(startOfMonth, endOfMonth, selectedRoom)
  }, [selectedDate, selectedRoom])

  // Génération des créneaux disponibles avec tranches de 20 minutes basée sur les vraies données
  const generateTimeSlots = (date: Date): TimeSlot[] => {
    const slots: TimeSlot[] = []
    const startHour = 14 // 14h00
    const endHour = 21 // 21h00
    
    // Récupérer la capacité réelle de la salle sélectionnée
    const selectedRoomData = getRoomByName(selectedRoom)
    const maxCapacity = selectedRoomData?.max_people || 8 // Utiliser la capacité de la salle ou 8 par défaut
    
    // Vérifier si c'est un jour d'ouverture (mardi à samedi)
    const dayOfWeek = date.getDay()
    const isOpenDay = dayOfWeek >= 2 && dayOfWeek <= 6 // Mardi (2) à Samedi (6)
    
    if (!isOpenDay) {
      return slots // Pas de créneaux les jours fermés
    }
    
    // Utiliser la date locale au lieu de l'ISO pour éviter les problèmes de fuseau horaire
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    const dateStr = `${year}-${month}-${day}`
    const dayReservations = availabilityData[dateStr] || {}
    
    
    
    for (let hour = startHour; hour < endHour; hour++) {
      for (let minute = 0; minute < 60; minute += 20) {
        const start = new Date(date)
        start.setHours(hour, minute, 0, 0)
        
        const end = new Date(start)
        end.setMinutes(start.getMinutes() + duration)
        
        // Format de l'heure pour correspondre à la base de données (HH:MM)
        const timeStr = `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`
        
        // Vérifier la disponibilité depuis l'API (peut être booléen ou nombre)
        const slotData = dayReservations[timeStr]
        
        // Si l'API indique false (booléen), le créneau est indisponible
        // Si pas de données de l'API (undefined), considérer comme disponible par défaut
        const available = slotData !== false
        
        slots.push({
          id: `${hour}-${minute}`,
          start,
          end,
          available,
          maxCapacity,
          currentBookings: available ? 0 : maxCapacity // Simulation pour compatibilité
        })
      }
    }
    
    return slots
  }

  // Créneaux pour la date sélectionnée
  const availableTimeSlots = useMemo(() => {
    return generateTimeSlots(selectedDate)
  }, [selectedDate, numberOfPeople, duration, availabilityData, selectedRoom])

  // Événements pour le calendrier (disponibilités par jour)
  const calendarEvents = useMemo(() => {
    const events: any[] = []
    
    // Générer des événements pour chaque jour du mois visible
    const startOfMonth = new Date(selectedDate.getFullYear(), selectedDate.getMonth(), 1)
    const endOfMonth = new Date(selectedDate.getFullYear(), selectedDate.getMonth() + 1, 0)
    
    for (let d = new Date(startOfMonth); d <= endOfMonth; d.setDate(d.getDate() + 1)) {
      const daySlots = generateTimeSlots(new Date(d))
      const availableSlots = daySlots.filter(slot => slot.available)
      const totalSlots = daySlots.length
      
      if (totalSlots > 0) {
        events.push({
          id: `day-${d.getDate()}`,
          title: `${availableSlots.length}/${totalSlots} créneaux`,
          start: new Date(d.getFullYear(), d.getMonth(), d.getDate(), 14, 0, 0),
          end: new Date(d.getFullYear(), d.getMonth(), d.getDate(), 21, 0, 0),
          resource: { 
            type: 'day-summary', 
            available: availableSlots.length, 
            total: totalSlots,
            day: d.getDate(),
            date: new Date(d)
          }
        })
      }
    }
    
    return events
  }, [selectedDate, numberOfPeople, duration, availabilityData, selectedRoom])

  // Gestion de la sélection de date
  const handleSelectSlot = (slotInfo: any) => {
    setSelectedDate(slotInfo.start)
    setSelectedTimeSlot(null)
  }

  // Gestion de la sélection de créneau horaire
  const handleTimeSlotSelect = (slot: TimeSlot) => {
    if (slot.available) {
      setSelectedTimeSlot(slot)
      setCurrentStep(2)
    }
  }

  // Style des événements du calendrier
  const eventStyleGetter = (event: any) => {
    const resource = event.resource
    
    if (resource.type === 'day-summary') {
      const availabilityRatio = resource.available / resource.total
      let backgroundColor = '#696969' // Gris par défaut
      
      if (availabilityRatio >= 0.8) {
        backgroundColor = '#22c55e' // Vert - beaucoup de disponibilités
      } else if (availabilityRatio >= 0.5) {
        backgroundColor = '#f59e0b' // Orange - disponibilités moyennes
      } else if (availabilityRatio > 0) {
        backgroundColor = '#ef4444' // Rouge - peu de disponibilités
      }
      
      return {
        style: {
          backgroundColor,
          color: 'white',
          border: 'none',
          borderRadius: '6px',
          fontSize: '11px',
          fontWeight: '500',
          padding: '2px 4px',
          textAlign: 'center' as const
        }
      }
    }
    
    // Style par défaut pour les autres événements
    return {
      style: {
        backgroundColor: '#8fbc8f',
        color: 'white',
        border: 'none',
        borderRadius: '4px',
        fontSize: '12px'
      }
    }
  }

  // Gestion du passage à l'étape des informations personnelles
  const handleContinueToPersonalInfo = () => {
    setCurrentStep(3)
  }

  // Validation des champs
  const isPersonalInfoValid = firstName.trim() && lastName.trim() && email.trim() && phone.trim()

  // Gestion des callbacks de paiement
  const handlePaymentSuccess = (paymentId: string) => {
    console.log('Paiement confirmé:', paymentId)
    setShowPayment(false)
    setCurrentStep(4) // Passer à l'étape de confirmation
  }

  const handlePaymentError = (error: string) => {
    console.error('Erreur de paiement:', error)
    alert(`Erreur de paiement: ${error}`)
  }

  const handlePaymentCancel = () => {
    setShowPayment(false)
    // Optionnel: supprimer la réservation en attente
  }

  // Gestion de la soumission finale
  const handleSubmit = async () => {
    if (selectedTimeSlot && firstName && lastName && email && phone) {
      try {
        // Utiliser la date locale au lieu de l'ISO pour éviter les problèmes de fuseau horaire
        const year = selectedDate.getFullYear()
        const month = String(selectedDate.getMonth() + 1).padStart(2, '0')
        const day = String(selectedDate.getDate()).padStart(2, '0')
        const dateStr = `${year}-${month}-${day}`
        
        
        const reservationData = {
          firstName,
          lastName,
          email,
          phone,
          date: dateStr, // Format YYYY-MM-DD en date locale
          timeSlot: `${moment(selectedTimeSlot.start).format('HH:mm')} - ${moment(selectedTimeSlot.end).format('HH:mm')}`,
          duration,
          numberOfPeople,
          formula: selectedFormula,
          roomName: selectedRoom
        }
        
        // Créer la réservation via l'API
        const newReservationNumber = await createReservation(reservationData)
        console.log('Réservation créée avec numéro:', newReservationNumber)
        
        // S'assurer que le numéro est bien défini avant de passer à l'étape de paiement
        if (newReservationNumber && newReservationNumber !== 'N/A') {
          setReservationNumber(newReservationNumber)
          setShowPayment(true)
        } else {
          console.error('Erreur: Numéro de réservation non généré')
          alert('Erreur lors de la génération du numéro de réservation. Veuillez réessayer.')
        }
      } catch (error) {
        console.error('Erreur lors de la création de la réservation:', error)
        alert('Erreur lors de la création de la réservation. Veuillez réessayer.')
      }
    }
  }

  // Affichage du chargement si les salles ne sont pas encore chargées
  if (roomsLoading) {
    return (
      <div className="min-h-screen bg-dark-bg py-20">
        <div className="section-container">
          <div className="text-center">
            <h1 className="text-4xl lg:text-5xl font-bold text-white mb-4">
              Réservez votre <span className="text-gradient-kaki">Session</span>
            </h1>
            <p className="text-xl text-gray-300 mb-8">
              Chargement des salles disponibles...
            </p>
            <div className="flex justify-center items-center py-20">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-kaki-400"></div>
            </div>
          </div>
        </div>
      </div>
    )
  }

  // Affichage d'erreur si aucune salle n'est disponible
  if (!roomsLoading && rooms.length === 0) {
    return (
      <div className="min-h-screen bg-dark-bg py-20">
        <div className="section-container">
          <div className="text-center">
            <h1 className="text-4xl lg:text-5xl font-bold text-white mb-4">
              Réservez votre <span className="text-gradient-kaki">Session</span>
            </h1>
            <p className="text-red-400 text-xl mb-8">
              Aucune salle disponible pour le moment.
            </p>
            <Link 
              href="/" 
              className="inline-block px-6 py-3 bg-kaki-600 text-white rounded-lg hover:bg-kaki-700 transition-colors"
            >
              Retour à l'accueil
            </Link>
          </div>
        </div>
      </div>
    )
  }

  // Affichage de l'étape de paiement
  if (showPayment && reservationNumber) {
    return (
      <div className="min-h-screen bg-dark-bg py-20">
        <div className="section-container">
          <div className="text-center mb-8">
            <h1 className="text-4xl lg:text-5xl font-bold text-white mb-4">
              Finalisez votre <span className="text-gradient-kaki">Réservation</span>
            </h1>
            <p className="text-xl text-gray-300">
              Paiement sécurisé via Payplug
            </p>
          </div>
          
          <PayplugPayment
            reservationData={{
              reservationNumber,
              customerName: `${firstName} ${lastName}`,
              customerEmail: email,
              amount: Math.round(roomPrice * numberOfPeople),
              roomName: selectedRoom,
              date: selectedDate.toLocaleDateString('fr-FR'),
              timeSlot: selectedTimeSlot ? 
                `${moment(selectedTimeSlot.start).format('HH:mm')} - ${moment(selectedTimeSlot.end).format('HH:mm')}` : '',
              participants: numberOfPeople
            }}
            onPaymentSuccess={handlePaymentSuccess}
            onPaymentError={handlePaymentError}
            onCancel={handlePaymentCancel}
          />
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-dark-bg py-20">
      <div className="section-container">
        {/* Header */}
        <div className="mb-8">
          <Link 
            href="/"
            className="inline-flex items-center text-kaki-400 hover:text-kaki-300 transition-colors mb-4"
          >
            <ArrowLeft size={20} className="mr-2" />
            Retour à l'accueil
          </Link>
          
          <h1 className="text-4xl lg:text-5xl font-bold text-white mb-4">
            Réservez votre <span className="text-gradient-kaki">Session</span>
          </h1>
          <p className="text-xl text-gray-300 max-w-3xl">
            Choisissez votre date, votre créneau et configurez votre session de défoulement.
          </p>
        </div>

        {/* Steps Indicator */}
        <div className="flex items-center justify-center mb-12">
          <div className="flex items-center space-x-4">
            <div className={`flex items-center ${currentStep >= 1 ? 'text-kaki-400' : 'text-gray-500'}`}>
              <div className={`w-8 h-8 rounded-full flex items-center justify-center mr-3 ${currentStep >= 1 ? 'bg-kaki-500' : 'bg-gray-600'}`}>
                {currentStep > 1 ? <Check size={16} /> : '1'}
              </div>
              <span className="font-medium text-sm">Date & Heure</span>
            </div>
            
            <div className={`h-0.5 w-8 ${currentStep >= 2 ? 'bg-kaki-500' : 'bg-gray-600'}`}></div>
            
            <div className={`flex items-center ${currentStep >= 2 ? 'text-kaki-400' : 'text-gray-500'}`}>
              <div className={`w-8 h-8 rounded-full flex items-center justify-center mr-3 ${currentStep >= 2 ? 'bg-kaki-500' : 'bg-gray-600'}`}>
                {currentStep > 2 ? <Check size={16} /> : '2'}
              </div>
              <span className="font-medium text-sm">Configuration</span>
            </div>
            
            <div className={`h-0.5 w-8 ${currentStep >= 3 ? 'bg-kaki-500' : 'bg-gray-600'}`}></div>
            
            <div className={`flex items-center ${currentStep >= 3 ? 'text-kaki-400' : 'text-gray-500'}`}>
              <div className={`w-8 h-8 rounded-full flex items-center justify-center mr-3 ${currentStep >= 3 ? 'bg-kaki-500' : 'bg-gray-600'}`}>
                {currentStep > 3 ? <Check size={16} /> : '3'}
              </div>
              <span className="font-medium text-sm">Contact</span>
            </div>
            
            <div className={`h-0.5 w-8 ${currentStep >= 4 ? 'bg-kaki-500' : 'bg-gray-600'}`}></div>
            
            <div className={`flex items-center ${currentStep >= 4 ? 'text-kaki-400' : 'text-gray-500'}`}>
              <div className={`w-8 h-8 rounded-full flex items-center justify-center mr-3 ${currentStep >= 4 ? 'bg-kaki-500' : 'bg-gray-600'}`}>
                {currentStep >= 4 ? <Check size={16} /> : '4'}
              </div>
              <span className="font-medium text-sm">Confirmation</span>
            </div>
          </div>
        </div>

        {currentStep === 1 && (
          <div className="grid lg:grid-cols-2 gap-12">
            {/* Calendrier */}
            <div className="card-dark">
              <h2 className="text-2xl font-bold text-white mb-6 flex items-center">
                <CalendarDays className="text-kaki-500 mr-3" size={28} />
                Sélectionnez une date
              </h2>
              
              {/* Légende des disponibilités */}
              <div className="mb-4 p-3 bg-gray-800/50 rounded-lg">
                <p className="text-sm text-gray-300 mb-2 font-medium">Disponibilités par jour :</p>
                <div className="flex flex-wrap gap-3 text-xs">
                  <div className="flex items-center">
                    <div className="w-3 h-3 bg-green-500 rounded mr-2"></div>
                    <span className="text-gray-300">Beaucoup de créneaux (≥80%)</span>
                  </div>
                  <div className="flex items-center">
                    <div className="w-3 h-3 bg-yellow-500 rounded mr-2"></div>
                    <span className="text-gray-300">Disponibilités moyennes (50-79%)</span>
                  </div>
                  <div className="flex items-center">
                    <div className="w-3 h-3 bg-red-500 rounded mr-2"></div>
                    <span className="text-gray-300">Peu de créneaux (1-49%)</span>
                  </div>
                  <div className="flex items-center">
                    <div className="w-3 h-3 bg-gray-500 rounded mr-2"></div>
                    <span className="text-gray-300">Aucun créneau</span>
                  </div>
                </div>
              </div>

              <div className="calendar-container">
                <Calendar
                  localizer={localizer}
                  events={calendarEvents}
                  startAccessor="start"
                  endAccessor="end"
                  style={{ height: 400 }}
                  onSelectSlot={handleSelectSlot}
                  selectable
                  eventPropGetter={eventStyleGetter}
                  views={['month']}
                  defaultView="month"
                  date={selectedDate}
                  onNavigate={setSelectedDate}
                  messages={{
                    next: 'Suivant',
                    previous: 'Précédent',
                    today: 'Aujourd\'hui',
                    month: 'Mois',
                    week: 'Semaine',
                    day: 'Jour',
                    agenda: 'Agenda',
                    date: 'Date',
                    time: 'Heure',
                    event: 'Événement',
                    noEventsInRange: 'Aucun créneau disponible dans cette période',
                    showMore: total => `+ ${total} créneaux supplémentaires`
                  }}
                />
              </div>
            </div>

            {/* Créneaux horaires */}
            <div className="card-dark">
              <h2 className="text-2xl font-bold text-white mb-6 flex items-center">
                <Clock className="text-kaki-500 mr-3" size={28} />
                Créneaux disponibles
              </h2>
              
              {/* Affichage de la salle sélectionnée */}
              <div className="mb-4 p-3 bg-kaki-600/10 border border-kaki-600/30 rounded-lg">
                <div className="flex items-center text-kaki-300">
                  <MapPin size={16} className="mr-2" />
                  <span className="font-medium">{selectedRoom}</span>
                </div>
              </div>
              
              <div className="mb-4">
                <p className="text-gray-300 mb-2">
                  {moment(selectedDate).format('dddd DD MMMM YYYY')}
                </p>
                <div className="flex items-center space-x-4 text-sm">
                  <div className="flex items-center">
                    <div className="w-3 h-3 bg-kaki-500 rounded mr-2"></div>
                    <span className="text-gray-300">Disponible</span>
                  </div>
                  <div className="flex items-center">
                    <div className="w-3 h-3 bg-gray-600 rounded mr-2"></div>
                    <span className="text-gray-300">Complet</span>
                  </div>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3 max-h-96 overflow-y-auto">
                {availableTimeSlots.map((slot) => (
                  <button
                    key={slot.id}
                    onClick={() => handleTimeSlotSelect(slot)}
                    disabled={!slot.available}
                    className={`p-3 rounded-lg text-left transition-all duration-200 ${
                      slot.available
                        ? 'bg-kaki-600/20 border border-kaki-600/50 hover:bg-kaki-600/30 text-white'
                        : 'bg-gray-800 border border-gray-700 text-gray-500 cursor-not-allowed'
                    }`}
                  >
                    <div className="font-medium">
                      {moment(slot.start).format('HH:mm')} - {moment(slot.end).format('HH:mm')}
                    </div>
                    <div className="text-xs mt-1">
                      {slot.available 
                        ? `${slot.maxCapacity - slot.currentBookings} places restantes`
                        : 'Complet'
                      }
                    </div>
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}

        {currentStep === 2 && selectedTimeSlot && (
          <div className="max-w-2xl mx-auto">
            <div className="card-dark">
              <h2 className="text-2xl font-bold text-white mb-6 flex items-center">
                <Users className="text-kaki-500 mr-3" size={28} />
                Configuration de votre session
              </h2>

              <div className="space-y-6">
                {/* Récapitulatif de la sélection */}
                <div className="bg-kaki-600/10 border border-kaki-600/30 rounded-lg p-4">
                  <h3 className="text-lg font-semibold text-white mb-2">Créneau sélectionné</h3>
                  <div className="space-y-2">
                    <p className="text-kaki-300">
                      {moment(selectedDate).format('dddd DD MMMM YYYY')} - {' '}
                      {moment(selectedTimeSlot.start).format('HH:mm')} à {moment(selectedTimeSlot.end).format('HH:mm')}
                    </p>
                    <div className="flex items-center text-kaki-300">
                      <MapPin size={16} className="mr-2" />
                      <span className="font-medium">{selectedRoom}</span>
                    </div>
                  </div>
                </div>

                {/* Affichage de la formule sélectionnée */}
                <div>
                  <label className="block text-white font-medium mb-3">Formule sélectionnée</label>
                  <div className="p-4 rounded-lg border border-kaki-500 bg-kaki-600/20">
                    <div className="flex justify-between items-start">
                      <div>
                        <h4 className="text-white font-semibold">
                          {formulas.find(f => f.id === selectedFormula)?.name}
                        </h4>
                        <p className="text-gray-300 text-sm mt-1">
                          {formulas.find(f => f.id === selectedFormula)?.description}
                        </p>
                        <p className="text-kaki-400 text-sm mt-2">
                          {duration} minutes - Max {formulas.find(f => f.id === selectedFormula)?.maxPeople} personnes
                        </p>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Nombre de personnes */}
                <div>
                  <label className="block text-white font-medium mb-3">Nombre de personnes</label>
                  <select
                    value={numberOfPeople}
                    onChange={(e) => setNumberOfPeople(parseInt(e.target.value))}
                    className="w-full px-4 py-3 bg-dark-bg border border-kaki-800/50 rounded-lg text-white focus:border-kaki-500 focus:outline-none transition-colors"
                  >
                    {(() => {
                      const maxPeople = formulas.find(f => f.id === selectedFormula)?.maxPeople || 8;
                      return Array.from({ length: maxPeople }, (_, i) => i + 1).map((num) => (
                        <option key={num} value={num}>
                          {num} {num === 1 ? 'personne' : 'personnes'}
                        </option>
                      ));
                    })()}
                  </select>
                </div>

                {/* Prix de la réservation */}
                <div>
                  <label className="block text-white font-medium mb-3">Prix de la réservation</label>
                  <div className="p-4 rounded-lg border border-kaki-500 bg-kaki-600/20">
                    <div className="flex justify-between items-center">
                      <div>
                        <p className="text-gray-300 text-sm">Prix par personne</p>
                        <p className="text-white font-semibold text-lg">{roomPrice}€</p>
                      </div>
                      <div className="text-right">
                        <p className="text-gray-300 text-sm">Total ({numberOfPeople} {numberOfPeople === 1 ? 'personne' : 'personnes'})</p>
                        <p className="text-kaki-400 font-bold text-xl">{roomPrice * numberOfPeople}€</p>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Boutons de navigation */}
                <div className="flex justify-between pt-6">
                  <button
                    onClick={() => setCurrentStep(1)}
                    className="btn-kaki-outline"
                  >
                    Retour
                  </button>
                  <button
                    onClick={handleContinueToPersonalInfo}
                    className="btn-kaki"
                  >
                    Continuer
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        {currentStep === 3 && (
          <div className="max-w-2xl mx-auto">
            <div className="card-dark">
              <h2 className="text-2xl font-bold text-white mb-6 flex items-center">
                <User className="text-kaki-500 mr-3" size={28} />
                Vos informations de contact
              </h2>

              <div className="space-y-6">
                {/* Récapitulatif de la sélection */}
                <div className="bg-kaki-600/10 border border-kaki-600/30 rounded-lg p-4">
                  <h3 className="text-lg font-semibold text-white mb-2">Récapitulatif</h3>
                  <div className="space-y-1 text-sm">
                    <p className="text-kaki-300">
                      {moment(selectedDate).format('dddd DD MMMM YYYY')} - {' '}
                      {moment(selectedTimeSlot?.start).format('HH:mm')} à {moment(selectedTimeSlot?.end).format('HH:mm')}
                    </p>
                    <p className="text-kaki-300">
                      {formulas.find(f => f.id === selectedFormula)?.name} - {numberOfPeople} personne{numberOfPeople > 1 ? 's' : ''}
                    </p>
                    <p className="text-kaki-300">
                      Prix total : <span className="text-kaki-400 font-semibold">{roomPrice * numberOfPeople}€</span>
                    </p>
                  </div>
                </div>

                {/* Formulaire des informations personnelles */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-white font-medium mb-2">Prénom *</label>
                    <input
                      type="text"
                      value={firstName}
                      onChange={(e) => setFirstName(e.target.value)}
                      className="w-full px-4 py-3 bg-dark-bg border border-kaki-800/50 rounded-lg text-white focus:border-kaki-500 focus:outline-none transition-colors"
                      placeholder="Votre prénom"
                      required
                    />
                  </div>
                  
                  <div>
                    <label className="block text-white font-medium mb-2">Nom *</label>
                    <input
                      type="text"
                      value={lastName}
                      onChange={(e) => setLastName(e.target.value)}
                      className="w-full px-4 py-3 bg-dark-bg border border-kaki-800/50 rounded-lg text-white focus:border-kaki-500 focus:outline-none transition-colors"
                      placeholder="Votre nom"
                      required
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-white font-medium mb-2 flex items-center">
                    <Mail className="text-kaki-500 mr-2" size={16} />
                    Email *</label>
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    className="w-full px-4 py-3 bg-dark-bg border border-kaki-800/50 rounded-lg text-white focus:border-kaki-500 focus:outline-none transition-colors"
                    placeholder="votre.email@exemple.com"
                    required
                  />
                </div>

                <div>
                  <label className="block text-white font-medium mb-2 flex items-center">
                    <Phone className="text-kaki-500 mr-2" size={16} />
                    Téléphone *</label>
                  <input
                    type="tel"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    className="w-full px-4 py-3 bg-dark-bg border border-kaki-800/50 rounded-lg text-white focus:border-kaki-500 focus:outline-none transition-colors"
                    placeholder="06 12 34 56 78"
                    required
                  />
                </div>

                {/* Boutons de navigation */}
                <div className="flex justify-between pt-6">
                  <button
                    onClick={() => setCurrentStep(2)}
                    className="btn-kaki-outline"
                  >
                    Retour
                  </button>
                  <button
                    onClick={handleSubmit}
                    disabled={!isPersonalInfoValid}
                    className={`px-6 py-3 rounded-lg font-medium transition-all duration-200 ${
                      isPersonalInfoValid
                        ? 'bg-kaki-500 hover:bg-kaki-600 text-white'
                        : 'bg-gray-600 text-gray-400 cursor-not-allowed'
                    }`}
                  >
                    Confirmer la réservation
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        {currentStep === 4 && (
          <div className="max-w-2xl mx-auto text-center">
            <div className="card-dark">
              <div className="text-center">
                <div className="w-16 h-16 bg-kaki-500 rounded-full flex items-center justify-center mx-auto mb-6">
                  <Check size={32} className="text-white" />
                </div>
                
                <h2 className="text-3xl font-bold text-white mb-4">
                  Réservation confirmée !
                </h2>
                
                <p className="text-gray-300 mb-8">
                  Votre demande de réservation a été envoyée. Nous vous recontacterons rapidement pour confirmer votre créneau.
                </p>

                {/* Numéro de réservation */}
                <div className="bg-kaki-500/20 border border-kaki-500/50 rounded-lg p-4 mb-6">
                  <p className="text-kaki-300 text-sm mb-1">Numéro de réservation</p>
                  <p className="text-2xl font-bold text-kaki-400 font-mono">
                    {reservationNumber || 'Génération en cours...'}
                  </p>
                </div>

                {selectedTimeSlot && (
                  <div className="bg-kaki-600/10 border border-kaki-600/30 rounded-lg p-6 mb-8">
                    <h3 className="text-lg font-semibold text-white mb-4">Détails de votre réservation</h3>
                    <div className="space-y-2 text-left">
                      <div className="flex justify-between">
                        <span className="text-gray-300">Numéro :</span>
                        <span className="text-white font-mono">{reservationNumber}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-300">Nom :</span>
                        <span className="text-white">{firstName} {lastName}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-300">Email :</span>
                        <span className="text-white">{email}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-300">Téléphone :</span>
                        <span className="text-white">{phone}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-300">Date :</span>
                        <span className="text-white">{moment(selectedDate).format('DD/MM/YYYY')}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-300">Heure :</span>
                        <span className="text-white">
                          {moment(selectedTimeSlot.start).format('HH:mm')} - {moment(selectedTimeSlot.end).format('HH:mm')}
                        </span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-300">Formule :</span>
                        <span className="text-white">
                          {formulas.find(f => f.id === selectedFormula)?.name}
                        </span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-300">Durée :</span>
                        <span className="text-white">{duration} minutes</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-300">Personnes :</span>
                        <span className="text-white">{numberOfPeople}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-300">Salle :</span>
                        <span className="text-white">{selectedRoom}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-gray-300">Prix par personne :</span>
                        <span className="text-white">{Math.round(roomPrice)}€</span>
                      </div>
                      <div className="flex justify-between border-t border-kaki-600/30 pt-2 mt-2">
                        <span className="text-kaki-400 font-semibold">Total :</span>
                        <span className="text-kaki-400 font-bold text-lg">{Math.round(roomPrice * numberOfPeople)}€</span>
                      </div>
                    </div>
                  </div>
                )}

                <div className="flex justify-center space-x-4">
                  <Link href="/" className="btn-kaki">
                    Retour à l'accueil
                  </Link>
                  <button
                    onClick={() => {
                      setCurrentStep(1)
                      setSelectedTimeSlot(null)
                      setSelectedDate(new Date())
                      setFirstName('')
                      setLastName('')
                      setEmail('')
                      setPhone('')
                      setReservationNumber('')
                    }}
                    className="btn-kaki-outline"
                  >
                    Nouvelle réservation
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

export default ReservationForm
