/**
 * Hook pour l'administration avec WebSocket
 * U Silenziu - Septembre 2025
 */

import { useState, useEffect } from 'react'
import { useWebSocket } from '@/lib/websocket'

export interface AdminNotification {
  id: string
  message: string
  type: 'success' | 'error' | 'info' | 'warning'
  timestamp: Date
  read: boolean
}

export function useWebSocketAdmin() {
  const ws = useWebSocket()
  const [notifications, setNotifications] = useState<AdminNotification[]>([])
  const [isConnected, setIsConnected] = useState(false)

  useEffect(() => {
    // Écouter les changements de connexion
    const handleConnectionChange = () => {
      setIsConnected(ws.isConnected())
    }

    // Écouter les notifications admin
    const handleAdminNotification = (message: string, type: 'success' | 'error' | 'info') => {
      const notification: AdminNotification = {
        id: Date.now().toString(),
        message,
        type,
        timestamp: new Date(),
        read: false
      }
      
      setNotifications(prev => [notification, ...prev].slice(0, 50)) // Garder max 50 notifications
    }

    // Écouter les mises à jour des salles
    const handleRoomsUpdate = (rooms: any[]) => {
      console.log('🔄 Salles mises à jour via WebSocket:', rooms.length)
    }

    // Écouter les mises à jour des réservations
    const handleReservationsUpdate = (reservations: any[]) => {
      console.log('🔄 Réservations mises à jour via WebSocket:', reservations.length)
    }

    // Écouter les mises à jour des sections homepage
    const handleHomepageUpdate = (sections: any[]) => {
      console.log('🔄 Sections homepage mises à jour via WebSocket:', sections.length)
    }

    // S'abonner aux événements
    ws.on('connect', handleConnectionChange)
    ws.on('disconnect', handleConnectionChange)
    ws.on('admin:notification', handleAdminNotification)
    ws.on('rooms:updated', handleRoomsUpdate)
    ws.on('reservations:updated', handleReservationsUpdate)
    ws.on('homepage:updated', handleHomepageUpdate)

    // Rejoindre la room admin
    if (ws.isConnected()) {
      ws.emit('join:admin')
    }

    return () => {
      // Nettoyer les listeners
      ws.socket?.off('connect', handleConnectionChange)
      ws.socket?.off('disconnect', handleConnectionChange)
      ws.socket?.off('admin:notification', handleAdminNotification)
      ws.socket?.off('rooms:updated', handleRoomsUpdate)
      ws.socket?.off('reservations:updated', handleReservationsUpdate)
      ws.socket?.off('homepage:updated', handleHomepageUpdate)
    }
  }, [ws])

  // Fonctions utilitaires
  const markNotificationAsRead = (id: string) => {
    setNotifications(prev => 
      prev.map(notif => 
        notif.id === id ? { ...notif, read: true } : notif
      )
    )
  }

  const clearAllNotifications = () => {
    setNotifications([])
  }

  const getUnreadCount = () => {
    return notifications.filter(notif => !notif.read).length
  }

  // Fonctions pour émettre des événements
  const notifyRoomsUpdate = (rooms: any[]) => {
    ws.emit('rooms:update', { rooms })
  }

  const notifyRoomAdded = (room: any) => {
    ws.emit('rooms:add', { room })
  }

  const notifyRoomUpdated = (room: any) => {
    ws.emit('rooms:edit', { room })
  }

  const notifyRoomDeleted = (roomId: string) => {
    ws.emit('rooms:delete', { roomId })
  }

  const notifyHomepageUpdate = (sections: any[]) => {
    ws.emit('homepage:update', { sections })
  }

  const notifyHomepageSectionUpdate = (section: any) => {
    ws.emit('homepage:section:update', { section })
  }

  const notifyReservationsUpdate = (reservations: any[]) => {
    ws.emit('reservations:update', { reservations })
  }

  const notifyReservationAdded = (reservation: any) => {
    ws.emit('reservations:add', { reservation })
  }

  const refreshSite = () => {
    ws.emit('site:refresh')
  }

  return {
    // État
    isConnected,
    notifications,
    unreadCount: getUnreadCount(),
    
    // Actions
    markNotificationAsRead,
    clearAllNotifications,
    
    // Émissions d'événements
    notifyRoomsUpdate,
    notifyRoomAdded,
    notifyRoomUpdated,
    notifyRoomDeleted,
    notifyHomepageUpdate,
    notifyHomepageSectionUpdate,
    notifyReservationsUpdate,
    notifyReservationAdded,
    refreshSite,
    
    // Utilitaires
    sessionId: ws.getSessionId()
  }
}
