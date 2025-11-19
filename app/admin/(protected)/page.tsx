'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import Link from 'next/link'
import { useAuth } from '@/hooks/useAuth'
import { Crown, Shield } from 'lucide-react'
import {
  Calendar,
  Users,
  DollarSign,
  TrendingUp,
  Settings,
  Mail,
  FileText,
  Plus,
  Edit,
  Trash2,
  Eye,
  Clock,
  CheckCircle,
  XCircle,
  AlertCircle,
  LogOut,
  Home,
  Bell,
  Film
} from 'lucide-react'

interface DashboardStats {
  totalReservations: number
  todayReservations: number
  totalRevenue: number
  activeRooms: number
  pendingReservations: number
  confirmedReservations: number
  cancelledReservations: number
}

interface SystemStatus {
  smtp: boolean
  notifications: boolean
  database: boolean
}

interface RecentReservation {
  id: string
  reservationNumber: string
  customerName: string
  roomName: string
  date: string
  time: string
  status: 'pending' | 'confirmed' | 'cancelled'
  amount: number
}

export default function AdminDashboard() {
  const router = useRouter()
  const { isAuthenticated, user, loading: authLoading, requireAuth, logout, isSuperAdmin } = useAuth()
  const [stats, setStats] = useState<DashboardStats>({
    totalReservations: 0,
    todayReservations: 0,
    totalRevenue: 0,
    activeRooms: 0,
    pendingReservations: 0,
    confirmedReservations: 0,
    cancelledReservations: 0
  })
  const [recentReservations, setRecentReservations] = useState<RecentReservation[]>([])
  const [systemStatus, setSystemStatus] = useState<SystemStatus>({
    smtp: false,
    notifications: false,
    database: false
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    requireAuth()
    if (isAuthenticated) {
      fetchDashboardData()
    }
  }, [isAuthenticated, requireAuth])

  const fetchDashboardData = async () => {
    try {
      // Récupérer les vraies données depuis l'API
      const response = await fetch('/api/admin/stats?includeRecent=true')
      
      if (!response.ok) {
        throw new Error('Erreur lors de la récupération des statistiques')
      }
      
      const result = await response.json()
      
      if (result.success) {
        const { dashboard, recentReservations, system } = result.data
        
        // Mettre à jour les statistiques
        setStats({
          totalReservations: dashboard.totalReservations,
          todayReservations: dashboard.todayReservations,
          totalRevenue: dashboard.totalRevenue,
          activeRooms: dashboard.activeRooms,
          pendingReservations: dashboard.pendingReservations,
          confirmedReservations: dashboard.confirmedReservations,
          cancelledReservations: dashboard.cancelledReservations
        })

        // Mettre à jour le statut du système
        if (system) {
          setSystemStatus(system)
        }

        // Mettre à jour les réservations récentes
        if (recentReservations) {
          const formattedReservations = recentReservations.map((reservation: any) => ({
            id: reservation.id,
            reservationNumber: reservation.reservation_number,
            customerName: `${reservation.first_name} ${reservation.last_name}`,
            roomName: reservation.room_name,
            date: reservation.date,
            time: reservation.time,
            status: reservation.status,
            amount: reservation.amount
          }))
          setRecentReservations(formattedReservations)
        }
      } else {
        throw new Error(result.error || 'Erreur inconnue')
      }
    } catch (error) {
      console.error('Erreur lors du chargement des données:', error)
      // En cas d'erreur, afficher des données par défaut
      setStats({
        totalReservations: 0,
        todayReservations: 0,
        totalRevenue: 0,
        activeRooms: 0,
        pendingReservations: 0,
        confirmedReservations: 0,
        cancelledReservations: 0
      })
      setRecentReservations([])
    } finally {
      setLoading(false)
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'confirmed':
        return <CheckCircle className="w-4 h-4 text-green-500" />
      case 'pending':
        return <Clock className="w-4 h-4 text-yellow-500" />
      case 'cancelled':
        return <XCircle className="w-4 h-4 text-red-500" />
      default:
        return <AlertCircle className="w-4 h-4 text-gray-500" />
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'confirmed':
        return 'text-green-500 bg-green-500/10'
      case 'pending':
        return 'text-yellow-500 bg-yellow-500/10'
      case 'cancelled':
        return 'text-red-500 bg-red-500/10'
      default:
        return 'text-gray-500 bg-gray-500/10'
    }
  }

  // Actions de base pour tous les admins
  const baseActions = [
    {
      title: 'Gestion des Réservations',
      description: 'Voir et gérer toutes les réservations',
      icon: Calendar,
      href: '/admin/reservations',
      color: 'bg-kaki-600 hover:bg-kaki-700',
      requiredRole: 'admin' as const
    },
    {
      title: 'Nouvelle Réservation',
      description: 'Créer une réservation manuelle',
      icon: Plus,
      href: '/admin/reservations?new=true',
      color: 'bg-green-600 hover:bg-green-700',
      requiredRole: 'admin' as const
    },
    {
      title: 'Gérer les Salles',
      description: 'Modifier les salles et formules',
      icon: Settings,
      href: '/admin/rooms',
      color: 'bg-purple-600 hover:bg-purple-700',
      requiredRole: 'admin' as const
    },
    {
      title: 'Page d\'Accueil',
      description: 'Modifier le contenu de la page d\'accueil',
      icon: Home,
      href: '/admin/homepage',
      color: 'bg-kaki-600 hover:bg-kaki-700',
      requiredRole: 'admin' as const
    },
    {
      title: 'Page d\'Entrée',
      description: 'Configurer la page d\'entrée avec photo/vidéo',
      icon: Eye,
      href: '/admin/entry-page',
      color: 'bg-purple-600 hover:bg-purple-700',
      requiredRole: 'admin' as const
    },
    {
      title: 'Vidéo Hero',
      description: 'Modifier la vidéo de fond de la page d\'accueil',
      icon: Film,
      href: '/admin/hero-video',
      color: 'bg-cyan-600 hover:bg-cyan-700',
      requiredRole: 'admin' as const
    },
    {
      title: 'Pages Légales',
      description: 'Gérer CGV, politique de confidentialité, mentions légales',
      icon: FileText,
      href: '/admin/legal-pages',
      color: 'bg-orange-600 hover:bg-orange-700',
      requiredRole: 'admin' as const
    }
  ]

  // Actions spécifiques au super admin
  const superAdminActions = [
    {
      title: 'Configuration SMTP',
      description: 'Paramètres d\'envoi d\'emails (Super Admin)',
      icon: Mail,
      href: '/admin/smtp',
      color: 'bg-orange-600 hover:bg-orange-700',
      requiredRole: 'super-admin' as const
    },
    {
      title: 'Notifications',
      description: 'Gérer les notifications automatiques (Super Admin)',
      icon: Bell,
      href: '/admin/notifications',
      color: 'bg-cyan-600 hover:bg-cyan-700',
      requiredRole: 'super-admin' as const
    },
    {
      title: 'Gestion des Utilisateurs',
      description: 'Créer et gérer les comptes admin (Super Admin)',
      icon: Users,
      href: '/admin/users',
      color: 'bg-red-600 hover:bg-red-700',
      requiredRole: 'super-admin' as const
    }
  ]

  // Filtrer les actions selon le rôle de l'utilisateur
  const quickActions = [
    ...baseActions,
    ...(isSuperAdmin() ? superAdminActions : [])
  ]

  const handleQuickAction = (href: string) => {
    router.push(href)
  }


  const handleViewCalendar = () => {
    router.push('/admin/reservations')
  }

  const handleExportData = () => {
    // Fonctionnalité d'export à implémenter
    console.log('Export des données...')
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-kaki-500"></div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-900 text-white">
      {/* Header */}
      <div className="bg-gray-800 border-b border-gray-700">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div>
              <h1 className="text-3xl font-bold text-white">Dashboard U Silenziu</h1>
              <p className="text-gray-400 mt-1">Gestion complète de votre zone de défoulement</p>
            </div>
            <div className="flex items-center space-x-4">
              {/* Informations utilisateur */}
              <div className="flex items-center space-x-2 bg-gray-700 rounded-lg px-3 py-2">
                {isSuperAdmin() ? (
                  <Crown className="w-4 h-4 text-purple-400" />
                ) : (
                  <Shield className="w-4 h-4 text-kaki-400" />
                )}
                <div className="text-sm">
                  <p className="text-white font-medium">{user?.username}</p>
                  <p className="text-gray-400 text-xs">
                    {user?.role === 'super-admin' ? 'Super Admin' : 'Admin'}
                  </p>
                </div>
              </div>
              
              <span className="text-sm text-gray-400">
                {new Date().toLocaleDateString('fr-FR', { 
                  weekday: 'long', 
                  year: 'numeric', 
                  month: 'long', 
                  day: 'numeric' 
                })}
              </span>
              
              <button
                onClick={logout}
                className="flex items-center space-x-2 bg-red-600 hover:bg-red-700 text-white px-3 py-2 rounded-lg transition-colors duration-200"
              >
                <LogOut className="w-4 h-4" />
                <span>Déconnexion</span>
              </button>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Statistiques principales */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
            <div className="flex items-center">
              <div className="p-2 bg-kaki-600 rounded-lg">
                <Calendar className="w-6 h-6 text-white" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-400">Réservations Aujourd'hui</p>
                <p className="text-2xl font-bold text-white">{stats.todayReservations}</p>
              </div>
            </div>
          </div>

          <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
            <div className="flex items-center">
              <div className="p-2 bg-green-600 rounded-lg">
                <DollarSign className="w-6 h-6 text-white" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-400">Revenus Totaux</p>
                <p className="text-2xl font-bold text-white">{stats.totalRevenue.toLocaleString('fr-FR')}€</p>
              </div>
            </div>
          </div>

          <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
            <div className="flex items-center">
              <div className="p-2 bg-purple-600 rounded-lg">
                <Users className="w-6 h-6 text-white" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-400">Salles Actives</p>
                <p className="text-2xl font-bold text-white">{stats.activeRooms}</p>
              </div>
            </div>
          </div>

          <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
            <div className="flex items-center">
              <div className="p-2 bg-orange-600 rounded-lg">
                <TrendingUp className="w-6 h-6 text-white" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-400">Total Réservations</p>
                <p className="text-2xl font-bold text-white">{stats.totalReservations}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Statistiques détaillées */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
            <h3 className="text-lg font-semibold text-white mb-4">Statuts des Réservations</h3>
            <div className="space-y-3">
              <div className="flex justify-between items-center">
                <span className="text-gray-400">En attente</span>
                <span className="text-yellow-500 font-semibold">{stats.pendingReservations}</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-gray-400">Confirmées</span>
                <span className="text-green-500 font-semibold">{stats.confirmedReservations}</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-gray-400">Annulées</span>
                <span className="text-red-500 font-semibold">{stats.cancelledReservations}</span>
              </div>
            </div>
          </div>


          <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
            <h3 className="text-lg font-semibold text-white mb-4">Système</h3>
            <div className="space-y-3">
              <div className="flex justify-between items-center">
                <span className="text-gray-400">SMTP</span>
                <span className={`text-sm ${systemStatus.smtp ? 'text-green-500' : 'text-red-500'}`}>
                  {systemStatus.smtp ? '✓ Configuré' : '✗ Non configuré'}
                </span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-gray-400">Notifications</span>
                <span className={`text-sm ${systemStatus.notifications ? 'text-green-500' : 'text-red-500'}`}>
                  {systemStatus.notifications ? '✓ Actives' : '✗ Inactives'}
                </span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-gray-400">Base de données</span>
                <span className={`text-sm ${systemStatus.database ? 'text-green-500' : 'text-red-500'}`}>
                  {systemStatus.database ? '✓ Opérationnelle' : '✗ Erreur'}
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* Actions rapides */}
        <div className="mb-8">
          <h2 className="text-2xl font-bold text-white mb-6">Actions Rapides</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {quickActions.map((action, index) => (
              <div key={index} className={`bg-gray-800 rounded-lg p-6 border transition-colors ${
                action.requiredRole === 'super-admin' 
                  ? 'border-purple-600 hover:border-purple-500' 
                  : 'border-gray-700 hover:border-kaki-500'
              }`}>
                <div className="flex items-center mb-4">
                  <div className={`p-3 rounded-lg ${action.color}`}>
                    <action.icon className="w-6 h-6 text-white" />
                  </div>
                  <div className="ml-4 flex-1">
                    <div className="flex items-center space-x-2">
                      <h3 className="text-lg font-semibold text-white">{action.title}</h3>
                      {action.requiredRole === 'super-admin' && (
                        <Crown className="w-4 h-4 text-purple-400" />
                      )}
                    </div>
                  </div>
                </div>
                <p className="text-gray-400 mb-4">{action.description}</p>
                <button 
                  onClick={() => handleQuickAction(action.href)}
                  className={`w-full ${action.color} text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors`}
                >
                  {action.requiredRole === 'super-admin' ? 'Accéder (Super Admin)' : 'Accéder'}
                </button>
              </div>
            ))}
          </div>
        </div>

        {/* Réservations récentes */}
        <div className="bg-gray-800 rounded-lg border border-gray-700">
          <div className="px-6 py-4 border-b border-gray-700">
            <h2 className="text-xl font-semibold text-white">Réservations Récentes</h2>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full">
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
                {recentReservations.map((reservation) => (
                  <tr key={reservation.id} className="hover:bg-gray-700">
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-white">
                      {reservation.reservationNumber}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                      {reservation.customerName}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                      {reservation.roomName}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                      {new Date(reservation.date).toLocaleDateString('fr-FR')} à {reservation.time}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(reservation.status)}`}>
                        {getStatusIcon(reservation.status)}
                        <span className="ml-1">
                          {reservation.status === 'confirmed' ? 'Confirmée' : 
                           reservation.status === 'pending' ? 'En attente' : 'Annulée'}
                        </span>
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-300">
                      {reservation.amount}€
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <div className="flex space-x-2">
                        <button 
                          onClick={() => router.push(`/admin/reservations/${reservation.id}`)}
                          className="text-kaki-400 hover:text-kaki-300"
                        >
                          <Eye className="w-4 h-4" />
                        </button>
                        <button 
                          onClick={() => router.push(`/admin/reservations/${reservation.id}/edit`)}
                          className="text-green-400 hover:text-green-300"
                        >
                          <Edit className="w-4 h-4" />
                        </button>
                        <button 
                          onClick={() => {
                            // Fonctionnalité de suppression à implémenter
                            console.log('Supprimer la réservation:', reservation.id)
                          }}
                          className="text-red-400 hover:text-red-300"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  )
}
