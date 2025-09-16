'use client'

import { useState, useEffect } from 'react'
import { X, Calendar, Clock, Users, MapPin, User, Mail, Phone, Euro, Save, AlertCircle } from 'lucide-react'

interface Room {
  id: string
  name: string
  price: number
  description?: string
}

interface ReservationModalProps {
  isOpen: boolean
  onClose: () => void
  onSave: (reservation: any) => void
  editingReservation?: any
  loading?: boolean
}

/**
 * Composant modal pour créer ou modifier une réservation
 * Permet la sélection de salle, nombre de personnes et saisie des informations client
 */
export default function ReservationModal({ 
  isOpen, 
  onClose, 
  onSave, 
  editingReservation, 
  loading = false 
}: ReservationModalProps) {
  const [rooms, setRooms] = useState<Room[]>([])
  const [formData, setFormData] = useState({
    first_name: '',
    last_name: '',
    email: '',
    phone: '',
    date: '',
    time: '',
    duration: 20,
    number_of_people: 1,
    room_name: '',
    status: 'pending',
    notes: ''
  })
  const [errors, setErrors] = useState<Record<string, string>>({})
  const [selectedRoomPrice, setSelectedRoomPrice] = useState(0)

  // Charger les salles disponibles
  useEffect(() => {
    if (isOpen) {
      fetchRooms()
    }
  }, [isOpen])

  // Initialiser le formulaire avec les données d'édition
  useEffect(() => {
    if (editingReservation) {
      setFormData({
        first_name: editingReservation.first_name || '',
        last_name: editingReservation.last_name || '',
        email: editingReservation.email || '',
        phone: editingReservation.phone || '',
        date: editingReservation.date || '',
        time: editingReservation.time || '',
        duration: editingReservation.duration || 20,
        number_of_people: editingReservation.number_of_people || 1,
        room_name: editingReservation.room_name || '',
        status: editingReservation.status || 'pending',
        notes: editingReservation.notes || ''
      })
      
      // Trouver le prix de la salle sélectionnée
      const room = rooms.find(r => r.name === editingReservation.room_name)
      if (room) {
        setSelectedRoomPrice(room.price)
      }
    } else {
      // Réinitialiser le formulaire pour une nouvelle réservation
      setFormData({
        first_name: '',
        last_name: '',
        email: '',
        phone: '',
        date: '',
        time: '',
        duration: 20,
        number_of_people: 1,
        room_name: '',
        status: 'pending',
        notes: ''
      })
      setSelectedRoomPrice(0)
    }
  }, [editingReservation, rooms])

  /**
   * Récupère la liste des salles disponibles depuis l'API
   */
  const fetchRooms = async () => {
    try {
      const response = await fetch('/api/rooms')
      const data = await response.json()
      if (data.success) {
        setRooms(data.data)
      }
    } catch (error) {
      console.error('Erreur lors du chargement des salles:', error)
    }
  }

  /**
   * Met à jour le prix de la salle sélectionnée
   */
  const handleRoomChange = (roomName: string) => {
    const room = rooms.find(r => r.name === roomName)
    setSelectedRoomPrice(room ? room.price : 0)
    setFormData(prev => ({ ...prev, room_name: roomName }))
  }

  /**
   * Valide les données du formulaire
   */
  const validateForm = () => {
    const newErrors: Record<string, string> = {}

    if (!formData.first_name.trim()) newErrors.first_name = 'Le prénom est requis'
    if (!formData.last_name.trim()) newErrors.last_name = 'Le nom est requis'
    if (!formData.email.trim()) newErrors.email = 'L\'email est requis'
    else if (!/\S+@\S+\.\S+/.test(formData.email)) newErrors.email = 'Format d\'email invalide'
    if (!formData.phone.trim()) newErrors.phone = 'Le téléphone est requis'
    if (!formData.date) newErrors.date = 'La date est requise'
    if (!formData.time) newErrors.time = 'L\'heure est requise'
    if (!formData.room_name) newErrors.room_name = 'La salle est requise'
    if (formData.number_of_people < 1 || formData.number_of_people > 8) {
      newErrors.number_of_people = 'Le nombre de personnes doit être entre 1 et 8'
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  /**
   * Gère la soumission du formulaire
   */
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!validateForm()) {
      return
    }

    const reservationData = {
      ...formData,
      amount: selectedRoomPrice * formData.number_of_people
    }

    onSave(reservationData)
  }

  /**
   * Calcule le montant total de la réservation
   */
  const totalAmount = selectedRoomPrice * formData.number_of_people

  if (!isOpen) return null

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-gray-800 rounded-lg shadow-xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-gray-700">
          <h2 className="text-xl font-semibold text-white">
            {editingReservation ? 'Modifier la réservation' : 'Nouvelle réservation'}
          </h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-white transition-colors"
            disabled={loading}
          >
            <X size={24} />
          </button>
        </div>

        {/* Formulaire */}
        <form onSubmit={handleSubmit} className="p-6 space-y-6">
          {/* Informations client */}
          <div className="space-y-4">
            <h3 className="text-lg font-medium text-white flex items-center gap-2">
              <User size={20} />
              Informations client
            </h3>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  Prénom *
                </label>
                <input
                  type="text"
                  value={formData.first_name}
                  onChange={(e) => setFormData(prev => ({ ...prev, first_name: e.target.value }))}
                  className={`w-full px-3 py-2 bg-gray-700 border rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-kaki-500 ${
                    errors.first_name ? 'border-red-500' : 'border-gray-600'
                  }`}
                  placeholder="Prénom du client"
                  disabled={loading}
                />
                {errors.first_name && (
                  <p className="text-red-400 text-sm mt-1 flex items-center gap-1">
                    <AlertCircle size={14} />
                    {errors.first_name}
                  </p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  Nom *
                </label>
                <input
                  type="text"
                  value={formData.last_name}
                  onChange={(e) => setFormData(prev => ({ ...prev, last_name: e.target.value }))}
                  className={`w-full px-3 py-2 bg-gray-700 border rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-kaki-500 ${
                    errors.last_name ? 'border-red-500' : 'border-gray-600'
                  }`}
                  placeholder="Nom du client"
                  disabled={loading}
                />
                {errors.last_name && (
                  <p className="text-red-400 text-sm mt-1 flex items-center gap-1">
                    <AlertCircle size={14} />
                    {errors.last_name}
                  </p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  Email *
                </label>
                <input
                  type="email"
                  value={formData.email}
                  onChange={(e) => setFormData(prev => ({ ...prev, email: e.target.value }))}
                  className={`w-full px-3 py-2 bg-gray-700 border rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-kaki-500 ${
                    errors.email ? 'border-red-500' : 'border-gray-600'
                  }`}
                  placeholder="email@exemple.com"
                  disabled={loading}
                />
                {errors.email && (
                  <p className="text-red-400 text-sm mt-1 flex items-center gap-1">
                    <AlertCircle size={14} />
                    {errors.email}
                  </p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  Téléphone *
                </label>
                <input
                  type="tel"
                  value={formData.phone}
                  onChange={(e) => setFormData(prev => ({ ...prev, phone: e.target.value }))}
                  className={`w-full px-3 py-2 bg-gray-700 border rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-kaki-500 ${
                    errors.phone ? 'border-red-500' : 'border-gray-600'
                  }`}
                  placeholder="06 12 34 56 78"
                  disabled={loading}
                />
                {errors.phone && (
                  <p className="text-red-400 text-sm mt-1 flex items-center gap-1">
                    <AlertCircle size={14} />
                    {errors.phone}
                  </p>
                )}
              </div>
            </div>
          </div>

          {/* Détails de la réservation */}
          <div className="space-y-4">
            <h3 className="text-lg font-medium text-white flex items-center gap-2">
              <Calendar size={20} />
              Détails de la réservation
            </h3>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  Date *
                </label>
                <input
                  type="date"
                  value={formData.date}
                  onChange={(e) => setFormData(prev => ({ ...prev, date: e.target.value }))}
                  className={`w-full px-3 py-2 bg-gray-700 border rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 ${
                    errors.date ? 'border-red-500' : 'border-gray-600'
                  }`}
                  disabled={loading}
                />
                {errors.date && (
                  <p className="text-red-400 text-sm mt-1 flex items-center gap-1">
                    <AlertCircle size={14} />
                    {errors.date}
                  </p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  Heure *
                </label>
                <input
                  type="time"
                  value={formData.time}
                  onChange={(e) => setFormData(prev => ({ ...prev, time: e.target.value }))}
                  className={`w-full px-3 py-2 bg-gray-700 border rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 ${
                    errors.time ? 'border-red-500' : 'border-gray-600'
                  }`}
                  disabled={loading}
                />
                {errors.time && (
                  <p className="text-red-400 text-sm mt-1 flex items-center gap-1">
                    <AlertCircle size={14} />
                    {errors.time}
                  </p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  Durée (minutes)
                </label>
                <select
                  value={formData.duration}
                  onChange={(e) => setFormData(prev => ({ ...prev, duration: parseInt(e.target.value) }))}
                  className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                  disabled={loading}
                >
                  <option value={20}>20 minutes</option>
                  <option value={30}>30 minutes</option>
                  <option value={45}>45 minutes</option>
                  <option value={60}>60 minutes</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  Nombre de personnes *
                </label>
                <input
                  type="number"
                  min="1"
                  max="8"
                  value={formData.number_of_people}
                  onChange={(e) => setFormData(prev => ({ ...prev, number_of_people: parseInt(e.target.value) }))}
                  className={`w-full px-3 py-2 bg-gray-700 border rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-kaki-500 ${
                    errors.number_of_people ? 'border-red-500' : 'border-gray-600'
                  }`}
                  disabled={loading}
                />
                {errors.number_of_people && (
                  <p className="text-red-400 text-sm mt-1 flex items-center gap-1">
                    <AlertCircle size={14} />
                    {errors.number_of_people}
                  </p>
                )}
              </div>
            </div>
          </div>

          {/* Sélection de salle */}
          <div className="space-y-4">
            <h3 className="text-lg font-medium text-white flex items-center gap-2">
              <MapPin size={20} />
              Salle et tarifs
            </h3>
            
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Salle *
              </label>
              <select
                value={formData.room_name}
                onChange={(e) => handleRoomChange(e.target.value)}
                className={`w-full px-3 py-2 bg-gray-700 border rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 ${
                  errors.room_name ? 'border-red-500' : 'border-gray-600'
                }`}
                disabled={loading}
              >
                <option value="">Sélectionner une salle</option>
                {rooms.map((room) => (
                  <option key={room.id} value={room.name}>
                    {room.name} - {Math.round(room.price)}€/personne
                  </option>
                ))}
              </select>
              {errors.room_name && (
                <p className="text-red-400 text-sm mt-1 flex items-center gap-1">
                  <AlertCircle size={14} />
                  {errors.room_name}
                </p>
              )}
            </div>

            {/* Affichage du prix */}
            {selectedRoomPrice > 0 && (
              <div className="bg-gray-700 p-4 rounded-lg">
                <div className="flex items-center justify-between text-white">
                  <div className="flex items-center gap-2">
                    <Euro size={20} />
                    <span className="font-medium">Prix par personne :</span>
                  </div>
                  <span className="text-kaki-400 font-semibold">{Math.round(selectedRoomPrice)}€</span>
                </div>
                <div className="flex items-center justify-between text-white mt-2">
                  <div className="flex items-center gap-2">
                    <Users size={20} />
                    <span className="font-medium">Nombre de personnes :</span>
                  </div>
                  <span className="text-kaki-400 font-semibold">{formData.number_of_people}</span>
                </div>
                <div className="border-t border-gray-600 mt-3 pt-3">
                  <div className="flex items-center justify-between text-white">
                    <span className="font-semibold text-lg">Total :</span>
                    <span className="text-kaki-400 font-bold text-xl">{Math.round(totalAmount)}€</span>
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Statut et notes */}
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Statut
              </label>
              <select
                value={formData.status}
                onChange={(e) => setFormData(prev => ({ ...prev, status: e.target.value }))}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                disabled={loading}
              >
                <option value="pending">En attente</option>
                <option value="confirmed">Confirmée</option>
                <option value="cancelled">Annulée</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Notes (optionnel)
              </label>
              <textarea
                value={formData.notes}
                onChange={(e) => setFormData(prev => ({ ...prev, notes: e.target.value }))}
                rows={3}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-kaki-500"
                placeholder="Notes supplémentaires..."
                disabled={loading}
              />
            </div>
          </div>

          {/* Boutons d'action */}
          <div className="flex items-center justify-end gap-3 pt-6 border-t border-gray-700">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 text-gray-300 hover:text-white transition-colors"
              disabled={loading}
            >
              Annuler
            </button>
            <button
              type="submit"
              disabled={loading}
              className="px-6 py-2 bg-kaki-600 hover:bg-kaki-700 text-white rounded-md transition-colors flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? (
                <>
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                  Sauvegarde...
                </>
              ) : (
                <>
                  <Save size={16} />
                  {editingReservation ? 'Modifier' : 'Créer'} la réservation
                </>
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}