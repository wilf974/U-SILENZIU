'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { 
  Calendar, 
  Users, 
  DollarSign, 
  Search, 
  Filter, 
  Plus, 
  Edit, 
  Trash2, 
  Eye, 
  Clock, 
  CheckCircle, 
  XCircle, 
  AlertCircle,
  ArrowLeft,
  RefreshCw,
  Download,
  Mail
} from 'lucide-react'
import ReservationModal from '@/components/ReservationModal'
import CalendarWeekly from '@/components/CalendarWeekly'

interface Reservation {
  id: string
  reservation_number: string
  customer_name: string
  customer_email: string
  customer_phone: string
  room_name: string
  date: string
  time_slot: string
  duration: number
  participants: number
  status: 'pending' | 'confirmed' | 'cancelled'
  amount: number
  special_requests?: string
  created_at: string
  updated_at: string
}

interface ReservationStats {
  total: number
  pending: number
  confirmed: number
  cancelled: number
  totalRevenue: number
}

export default function ReservationsAdminPage() {
  const router = useRouter()
  
  const [reservations, setReservations] = useState<Reservation[]>([])
  const [stats, setStats] = useState<ReservationStats>({
    total: 0,
    pending: 0,
    confirmed: 0,
    cancelled: 0,
    totalRevenue: 0
  })
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  
  // Filtres
  const [filters, setFilters] = useState({
    status: '',
    date: '',
    room: '',
    search: ''
  })
  
  // Pagination
  const [currentPage, setCurrentPage] = useState(1)
  const [itemsPerPage] = useState(10)
  
  // États pour les modales
  const [showCreateModal, setShowCreateModal] = useState(false)
  const [showEditModal, setShowEditModal] = useState(false)
  const [showDeleteModal, setShowDeleteModal] = useState(false)
  const [selectedReservation, setSelectedReservation] = useState<Reservation | null>(null)
  
  // Vue active (liste ou calendrier)
  const [activeView, setActiveView] = useState<'list' | 'calendar'>('list')

  useEffect(() => {
    fetchReservations()
  }, [filters, currentPage])

  // Vérifier si on doit ouvrir la modal de création (depuis le dashboard)
  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search)
    if (urlParams.get('new') === 'true') {
      setShowCreateModal(true)
      // Nettoyer l'URL
      window.history.replaceState({}, '', '/admin/reservations')
    }
  }, [])

  /**
   * Récupère toutes les réservations avec les filtres appliqués
   */
  const fetchReservations = async () => {
    try {
      setLoading(true)
      setError(null)
      
      const queryParams = new URLSearchParams()
      if (filters.status) queryParams.append('status', filters.status)
      if (filters.date) queryParams.append('date', filters.date)
      if (filters.room) queryParams.append('room', filters.room)
      if (filters.search) queryParams.append('search', filters.search)
      
      const response = await fetch(`/api/admin/reservations?${queryParams.toString()}`)
      const data = await response.json()
      
      if (data.success) {
        setReservations(data.data)
        setStats(data.stats)
      } else {
        setError(data.error || 'Erreur lors du chargement des réservations')
      }
    } catch (error) {
      console.error('Erreur lors du chargement des réservations:', error)
      setError('Erreur de connexion au serveur')
    } finally {
      setLoading(false)
    }
  }

  /**
   * Met à jour le statut d'une réservation
   */
  const updateReservationStatus = async (id: string, newStatus: string) => {
    try {
      const response = await fetch(`/api/admin/reservations/${id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ status: newStatus }),
      })
      
      const data = await response.json()
      
      if (data.success) {
        // Mettre à jour la liste locale
        setReservations(prev => 
          prev.map(res => 
            res.id === id ? { ...res, status: newStatus as any } : res
          )
        )
        // Recharger les statistiques
        fetchReservations()
      } else {
        setError(data.error || 'Erreur lors de la mise à jour')
      }
    } catch (error) {
      console.error('Erreur lors de la mise à jour:', error)
      setError('Erreur de connexion au serveur')
    }
  }

  /**
   * Supprime une réservation
   */
  const deleteReservation = async (id: string) => {
    try {
      const response = await fetch(`/api/admin/reservations/${id}`, {
        method: 'DELETE',
      })
      
      const data = await response.json()
      
      if (data.success) {
        setReservations(prev => prev.filter(res => res.id !== id))
        setShowDeleteModal(false)
        setSelectedReservation(null)
        fetchReservations() // Recharger les stats
      } else {
        setError(data.error || 'Erreur lors de la suppression')
      }
    } catch (error) {
      console.error('Erreur lors de la suppression:', error)
      setError('Erreur de connexion au serveur')
    }
  }

  /**
   * Crée une nouvelle réservation
   */
  const createReservation = async (reservationData: any) => {
    try {
      setLoading(true)
      const response = await fetch('/api/admin/reservations', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(reservationData),
      })
      
      const data = await response.json()
      
      if (data.success) {
        setShowCreateModal(false)
        fetchReservations() // Recharger la liste et les stats
        setError(null)
      } else {
        setError(data.error || 'Erreur lors de la création de la réservation')
      }
    } catch (error) {
      console.error('Erreur lors de la création:', error)
      setError('Erreur de connexion au serveur')
    } finally {
      setLoading(false)
    }
  }

  /**
   * Modifie une réservation existante
   */
  const updateReservation = async (reservationData: any) => {
    if (!selectedReservation) return
    
    try {
      setLoading(true)
      const response = await fetch(`/api/admin/reservations/${selectedReservation.id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(reservationData),
      })
      
      const data = await response.json()
      
      if (data.success) {
        setShowEditModal(false)
        setSelectedReservation(null)
        fetchReservations() // Recharger la liste et les stats
        setError(null)
      } else {
        setError(data.error || 'Erreur lors de la modification de la réservation')
      }
    } catch (error) {
      console.error('Erreur lors de la modification:', error)
      setError('Erreur de connexion au serveur')
    } finally {
      setLoading(false)
    }
  }

  /**
   * Obtient l'icône et la couleur pour le statut
   */
  const getStatusDisplay = (status: string) => {
    switch (status) {
      case 'confirmed':
        return { 
          icon: <CheckCircle className="w-4 h-4" />, 
          color: 'bg-green-100 text-green-800 border-green-200',
          text: 'Confirmée'
        }
      case 'pending':
        return { 
          icon: <Clock className="w-4 h-4" />, 
          color: 'bg-yellow-100 text-yellow-800 border-yellow-200',
          text: 'En attente'
        }
      case 'cancelled':
        return { 
          icon: <XCircle className="w-4 h-4" />, 
          color: 'bg-red-100 text-red-800 border-red-200',
          text: 'Annulée'
        }
      default:
        return { 
          icon: <AlertCircle className="w-4 h-4" />, 
          color: 'bg-gray-100 text-gray-800 border-gray-200',
          text: 'Inconnu'
        }
    }
  }

  /**
   * Formate la date pour l'affichage avec gestion d'erreur
   */
  const formatDate = (dateString?: string | null) => {
    if (!dateString) return 'N/A'
    try {
      return new Date(dateString).toLocaleDateString('fr-FR')
    } catch (error) {
      console.error('Erreur lors du formatage de la date:', error)
      return 'Date invalide'
    }
  }

  /**
   * Formate l'heure pour l'affichage avec gestion d'erreur
   */
  const formatTime = (timeString?: string | null) => {
    if (!timeString || timeString === null || timeString === undefined) return 'N/A'
    try {
      // Vérifier que la chaîne est bien une chaîne et contient au moins le format HH:MM
      if (typeof timeString === 'string' && timeString.length >= 5) {
        return timeString.substring(0, 5) // Affiche seulement HH:MM
      }
      return timeString // Retourner tel quel si format inattendu
    } catch (error) {
      console.error('Erreur lors du formatage de l\'heure:', error)
      return 'Heure invalide'
    }
  }

  /**
   * Formate le nom du client avec gestion d'erreur
   */
  const formatClientName = (firstName?: string | null, lastName?: string | null) => {
    if (!firstName && !lastName) return 'Client inconnu'
    return `${firstName || ''} ${lastName || ''}`.trim() || 'Client inconnu'
  }

  /**
   * Formate le téléphone avec gestion d'erreur
   */
  const formatPhone = (phone?: string | null) => {
    if (!phone) return 'N/A'
    return phone
  }

  /**
   * Formate l'email avec gestion d'erreur
   */
  const formatEmail = (email?: string | null) => {
    if (!email) return 'N/A'
    return email
  }

  // Pagination
  const totalPages = Math.ceil(reservations.length / itemsPerPage)
  const startIndex = (currentPage - 1) * itemsPerPage
  const endIndex = startIndex + itemsPerPage
  const currentReservations = reservations.slice(startIndex, endIndex)

  return (
    <div className="min-h-screen bg-gray-900 text-white">
      {/* Header */}
      <div className="bg-gray-800 border-b border-gray-700">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center space-x-4">
              <button
                onClick={() => router.push('/admin')}
                className="flex items-center space-x-2 text-gray-300 hover:text-white transition-colors"
              >
                <ArrowLeft className="w-5 h-5" />
                <span>Retour au tableau de bord</span>
              </button>
              <h1 className="text-2xl font-bold">Gestion des Réservations</h1>
            </div>
            <div className="flex items-center space-x-4">
              {/* Boutons de vue */}
              <div className="flex bg-gray-700 rounded-lg p-1">
                <button
                  onClick={() => setActiveView('list')}
                  className={`px-3 py-1 rounded-md text-sm transition-colors ${
                    activeView === 'list' 
                      ? 'bg-kaki-600 text-white' 
                      : 'text-gray-300 hover:text-white'
                  }`}
                >
                  Liste
                </button>
                <button
                  onClick={() => setActiveView('calendar')}
                  className={`px-3 py-1 rounded-md text-sm transition-colors ${
                    activeView === 'calendar' 
                      ? 'bg-kaki-600 text-white' 
                      : 'text-gray-300 hover:text-white'
                  }`}
                >
                  Calendrier
                </button>
              </div>
              
              <button
                onClick={fetchReservations}
                className="flex items-center space-x-2 bg-kaki-600 hover:bg-kaki-700 px-4 py-2 rounded-lg transition-colors"
              >
                <RefreshCw className="w-4 h-4" />
                <span>Actualiser</span>
              </button>
              <button
                onClick={() => setShowCreateModal(true)}
                className="flex items-center space-x-2 bg-green-600 hover:bg-green-700 px-4 py-2 rounded-lg transition-colors"
              >
                <Plus className="w-4 h-4" />
                <span>Nouvelle Réservation</span>
              </button>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Statistiques */}
        <div className="grid grid-cols-1 md:grid-cols-5 gap-6 mb-8">
          <div className="bg-gray-800 p-6 rounded-lg border border-gray-700">
            <div className="flex items-center">
              <Calendar className="w-8 h-8 text-kaki-400" />
              <div className="ml-4">
                <p className="text-sm text-gray-400">Total Réservations</p>
                <p className="text-2xl font-bold">{stats.total}</p>
              </div>
            </div>
          </div>
          
          <div className="bg-gray-800 p-6 rounded-lg border border-gray-700">
            <div className="flex items-center">
              <Clock className="w-8 h-8 text-yellow-400" />
              <div className="ml-4">
                <p className="text-sm text-gray-400">En Attente</p>
                <p className="text-2xl font-bold">{stats.pending}</p>
              </div>
            </div>
          </div>
          
          <div className="bg-gray-800 p-6 rounded-lg border border-gray-700">
            <div className="flex items-center">
              <CheckCircle className="w-8 h-8 text-green-400" />
              <div className="ml-4">
                <p className="text-sm text-gray-400">Confirmées</p>
                <p className="text-2xl font-bold">{stats.confirmed}</p>
              </div>
            </div>
          </div>
          
          <div className="bg-gray-800 p-6 rounded-lg border border-gray-700">
            <div className="flex items-center">
              <XCircle className="w-8 h-8 text-red-400" />
              <div className="ml-4">
                <p className="text-sm text-gray-400">Annulées</p>
                <p className="text-2xl font-bold">{stats.cancelled}</p>
              </div>
            </div>
          </div>
          
          <div className="bg-gray-800 p-6 rounded-lg border border-gray-700">
            <div className="flex items-center">
              <DollarSign className="w-8 h-8 text-green-400" />
              <div className="ml-4">
                <p className="text-sm text-gray-400">Revenus Totaux</p>
                <p className="text-2xl font-bold">{stats.totalRevenue}€</p>
              </div>
            </div>
          </div>
        </div>

        {/* Contenu principal - Liste ou Calendrier */}
        {activeView === 'calendar' ? (
          <div className="mb-8">
            <CalendarWeekly />
          </div>
        ) : (
          <>
            {/* Filtres */}
            <div className="bg-gray-800 p-6 rounded-lg border border-gray-700 mb-6">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Recherche
              </label>
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  type="text"
                  placeholder="Nom, email, téléphone..."
                  value={filters.search}
                  onChange={(e) => setFilters(prev => ({ ...prev, search: e.target.value }))}
                  className="w-full pl-10 pr-4 py-2 bg-gray-700 border border-gray-600 rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-kaki-500"
                />
              </div>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Statut
              </label>
              <select
                value={filters.status}
                onChange={(e) => setFilters(prev => ({ ...prev, status: e.target.value }))}
                className="w-full px-4 py-2 bg-gray-700 border border-gray-600 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
              >
                <option value="">Tous les statuts</option>
                <option value="pending">En attente</option>
                <option value="confirmed">Confirmée</option>
                <option value="cancelled">Annulée</option>
              </select>
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Date
              </label>
              <input
                type="date"
                value={filters.date}
                onChange={(e) => setFilters(prev => ({ ...prev, date: e.target.value }))}
                className="w-full px-4 py-2 bg-gray-700 border border-gray-600 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Salle
              </label>
              <select
                value={filters.room}
                onChange={(e) => setFilters(prev => ({ ...prev, room: e.target.value }))}
                className="w-full px-4 py-2 bg-gray-700 border border-gray-600 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
              >
                <option value="">Toutes les salles</option>
                <option value="Salle de Défoulement U Silenziu">Salle de Défoulement U Silenziu</option>
                <option value="Salle Douce">Salle Douce</option>
                <option value="Salle Carnage">Salle Carnage</option>
                <option value="Salle Privatisée">Salle Privatisée</option>
                <option value="Salle Haches">Salle Haches</option>
                <option value="Salle Test">Salle Test</option>
              </select>
            </div>
          </div>
        </div>

        {/* Message d'erreur */}
        {error && (
          <div className="bg-red-900 border border-red-700 text-red-100 px-4 py-3 rounded-lg mb-6">
            {error}
          </div>
        )}

        {/* Tableau des réservations */}
        <div className="bg-gray-800 rounded-lg border border-gray-700 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-700">
              <thead className="bg-gray-700">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                    N° Réservation
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                    Client
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                    Salle
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                    Date & Heure
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                    Statut
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                    Montant
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-gray-800 divide-y divide-gray-700">
                {loading ? (
                  <tr>
                    <td colSpan={7} className="px-6 py-12 text-center text-gray-400">
                      <RefreshCw className="w-6 h-6 animate-spin mx-auto mb-2" />
                      Chargement des réservations...
                    </td>
                  </tr>
                ) : currentReservations.length === 0 ? (
                  <tr>
                    <td colSpan={7} className="px-6 py-12 text-center text-gray-400">
                      Aucune réservation trouvée
                    </td>
                  </tr>
                ) : (
                  currentReservations.map((reservation) => {
                    const statusDisplay = getStatusDisplay(reservation.status)
                    return (
                      <tr key={reservation.id} className="hover:bg-gray-700">
                        <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-white">
                          {reservation.reservation_number || 'N/A'}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                          <div>
                            <div className="font-medium">{formatClientName(reservation.first_name, reservation.last_name) || reservation.customer_name || 'Client inconnu'}</div>
                            <div className="text-gray-400">{formatEmail(reservation.email) || reservation.customer_email || 'N/A'}</div>
                            <div className="text-gray-400">{formatPhone(reservation.phone) || reservation.customer_phone || 'N/A'}</div>
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                          {reservation.room_name || 'Salle inconnue'}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                          <div>
                            <div>{formatDate(reservation.date)}</div>
                            <div className="text-gray-400">{formatTime(reservation.time_slot || reservation.time || null)}</div>
                            <div className="text-gray-400">{reservation.duration || reservation.number_of_people ? `${reservation.duration || reservation.number_of_people} pers.` : 'N/A'}</div>
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium border ${statusDisplay.color}`}>
                            {statusDisplay.icon}
                            <span className="ml-1">{statusDisplay.text}</span>
                          </span>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                          {reservation.amount ? `${reservation.amount}€` : 'N/A'}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                          <div className="flex items-center space-x-2">
                            <button
                              onClick={() => {
                                setSelectedReservation(reservation)
                                setShowEditModal(true)
                              }}
                              className="text-kaki-400 hover:text-kaki-300 transition-colors"
                              title="Modifier"
                            >
                              <Edit className="w-4 h-4" />
                            </button>
                            <button
                              onClick={() => {
                                setSelectedReservation(reservation)
                                setShowDeleteModal(true)
                              }}
                              className="text-red-400 hover:text-red-300 transition-colors"
                              title="Supprimer"
                            >
                              <Trash2 className="w-4 h-4" />
                            </button>
                            {reservation.status === 'pending' && (
                              <button
                                onClick={() => updateReservationStatus(reservation.id, 'confirmed')}
                                className="text-green-400 hover:text-green-300 transition-colors"
                                title="Confirmer"
                              >
                                <CheckCircle className="w-4 h-4" />
                              </button>
                            )}
                            {reservation.status === 'confirmed' && (
                              <button
                                onClick={() => updateReservationStatus(reservation.id, 'cancelled')}
                                className="text-red-400 hover:text-red-300 transition-colors"
                                title="Annuler"
                              >
                                <XCircle className="w-4 h-4" />
                              </button>
                            )}
                          </div>
                        </td>
                      </tr>
                    )
                  })
                )}
              </tbody>
            </table>
          </div>
        </div>

        {/* Pagination */}
        {totalPages > 1 && (
          <div className="flex items-center justify-between mt-6">
            <div className="text-sm text-gray-400">
              Affichage de {startIndex + 1} à {Math.min(endIndex, reservations.length)} sur {reservations.length} réservations
            </div>
            <div className="flex items-center space-x-2">
              <button
                onClick={() => setCurrentPage(prev => Math.max(1, prev - 1))}
                disabled={currentPage === 1}
                className="px-3 py-2 bg-gray-700 text-white rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-600 transition-colors"
              >
                Précédent
              </button>
              <span className="px-3 py-2 text-gray-300">
                Page {currentPage} sur {totalPages}
              </span>
              <button
                onClick={() => setCurrentPage(prev => Math.min(totalPages, prev + 1))}
                disabled={currentPage === totalPages}
                className="px-3 py-2 bg-gray-700 text-white rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-600 transition-colors"
              >
                Suivant
              </button>
            </div>
          </div>
        )}

          </>
        )}

        {/* Modal de confirmation de suppression */}
        {showDeleteModal && selectedReservation && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
            <div className="bg-gray-800 rounded-lg border border-gray-700 w-full max-w-md">
              <div className="p-6">
                <h3 className="text-lg font-semibold text-white mb-4">
                  Confirmer la suppression
                </h3>
                <p className="text-gray-300 mb-6">
                  Êtes-vous sûr de vouloir supprimer la réservation{' '}
                  <span className="font-medium text-white">
                    {selectedReservation.reservation_number}
                  </span>{' '}
                  de {selectedReservation.customer_name} ?
                </p>
                <p className="text-sm text-red-400 mb-6">
                  Cette action est irréversible.
                </p>
                <div className="flex items-center justify-end space-x-4">
                  <button
                    onClick={() => {
                      setShowDeleteModal(false)
                      setSelectedReservation(null)
                    }}
                    className="px-4 py-2 bg-gray-700 text-white rounded-lg hover:bg-gray-600 transition-colors"
                  >
                    Annuler
                  </button>
                  <button
                    onClick={() => deleteReservation(selectedReservation.id)}
                    className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
                  >
                    Supprimer
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Modales */}
        <ReservationModal
          isOpen={showCreateModal}
          onClose={() => setShowCreateModal(false)}
          onSave={createReservation}
          loading={loading}
        />

        <ReservationModal
          isOpen={showEditModal}
          onClose={() => {
            setShowEditModal(false)
            setSelectedReservation(null)
          }}
          onSave={updateReservation}
          editingReservation={selectedReservation}
          loading={loading}
        />
      </div>
    </div>
  )
}