/**
 * Système WebSocket pour les mises à jour en temps réel
 * U Silenziu - Septembre 2025
 */

import { io, Socket } from 'socket.io-client'
import { useState, useEffect } from 'react'

export interface WebSocketEvents {
  // Événements des salles
  'rooms:updated': (rooms: any[]) => void
  'rooms:added': (room: any) => void
  'rooms:updated': (room: any) => void
  'rooms:deleted': (roomId: string) => void
  
  // Événements des sections homepage
  'homepage:updated': (sections: any[]) => void
  'homepage:section:updated': (section: any) => void
  
  // Événements des réservations
  'reservations:updated': (reservations: any[]) => void
  'reservations:added': (reservation: any) => void
  'reservations:updated': (reservation: any) => void
  'reservations:deleted': (reservationId: string) => void
  
  // Événements généraux
  'site:refresh': () => void
  'admin:notification': (message: string, type: 'success' | 'error' | 'info') => void
}

class WebSocketManager {
  private socket: Socket | null = null
  private reconnectAttempts = 0
  private maxReconnectAttempts = 5
  private reconnectDelay = 1000

  constructor() {
    this.connect()
  }

  private connect() {
    try {
      this.socket = io(process.env.NEXT_PUBLIC_WS_URL || 'ws://localhost:3001', {
        transports: ['websocket', 'polling'],
        timeout: 20000,
        forceNew: true
      })

      this.socket.on('connect', () => {
        console.log('🔌 WebSocket connecté')
        this.reconnectAttempts = 0
      })

      this.socket.on('disconnect', () => {
        console.log('🔌 WebSocket déconnecté')
        this.handleReconnect()
      })

      this.socket.on('connect_error', (error) => {
        console.error('❌ Erreur connexion WebSocket:', error)
        this.handleReconnect()
      })

    } catch (error) {
      console.error('❌ Erreur initialisation WebSocket:', error)
    }
  }

  private handleReconnect() {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++
      const delay = this.reconnectDelay * Math.pow(2, this.reconnectAttempts - 1)
      
      console.log(`🔄 Reconnexion WebSocket dans ${delay}ms (tentative ${this.reconnectAttempts}/${this.maxReconnectAttempts})`)
      
      setTimeout(() => {
        this.connect()
      }, delay)
    } else {
      console.error('❌ Impossible de se reconnecter au WebSocket')
    }
  }

  // Écouter un événement
  on<K extends keyof WebSocketEvents>(event: K, callback: WebSocketEvents[K]) {
    if (this.socket) {
      this.socket.on(event, callback as any)
    }
  }

  // Émettre un événement
  emit(event: string, data?: any) {
    if (this.socket && this.socket.connected) {
      this.socket.emit(event, data)
    }
  }

  // Se déconnecter
  disconnect() {
    if (this.socket) {
      this.socket.disconnect()
      this.socket = null
    }
  }

  // Vérifier si connecté
  isConnected(): boolean {
    return this.socket?.connected || false
  }

  // Obtenir l'ID de la session
  getSessionId(): string | undefined {
    return this.socket?.id
  }
}

// Instance singleton
export const wsManager = new WebSocketManager()

// Hook React pour utiliser WebSocket
export function useWebSocket() {
  return wsManager
}


// Hook pour écouter les mises à jour des salles
export function useRoomsWebSocket() {
  const [rooms, setRooms] = useState<any[]>([])
  const [isConnected, setIsConnected] = useState(false)

  useEffect(() => {
    const handleRoomsUpdated = (updatedRooms: any[]) => {
      setRooms(updatedRooms)
    }

    const handleConnectionChange = () => {
      setIsConnected(wsManager.isConnected())
    }

    wsManager.on('rooms:updated', handleRoomsUpdated)
    wsManager.on('connect', handleConnectionChange)
    wsManager.on('disconnect', handleConnectionChange)

    return () => {
      wsManager.socket?.off('rooms:updated', handleRoomsUpdated)
      wsManager.socket?.off('connect', handleConnectionChange)
      wsManager.socket?.off('disconnect', handleConnectionChange)
    }
  }, [])

  return { rooms, isConnected }
}

// Hook pour écouter les mises à jour des sections homepage
export function useHomepageWebSocket() {
  const [sections, setSections] = useState<any[]>([])
  const [isConnected, setIsConnected] = useState(false)

  useEffect(() => {
    const handleSectionsUpdated = (updatedSections: any[]) => {
      setSections(updatedSections)
    }

    const handleSectionUpdated = (section: any) => {
      setSections(prev => prev.map(s => s.id === section.id ? section : s))
    }

    const handleConnectionChange = () => {
      setIsConnected(wsManager.isConnected())
    }

    wsManager.on('homepage:updated', handleSectionsUpdated)
    wsManager.on('homepage:section:updated', handleSectionUpdated)
    wsManager.on('connect', handleConnectionChange)
    wsManager.on('disconnect', handleConnectionChange)

    return () => {
      wsManager.socket?.off('homepage:updated', handleSectionsUpdated)
      wsManager.socket?.off('homepage:section:updated', handleSectionUpdated)
      wsManager.socket?.off('connect', handleConnectionChange)
      wsManager.socket?.off('disconnect', handleConnectionChange)
    }
  }, [])

  return { sections, isConnected }
}
