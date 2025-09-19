/**
 * API WebSocket pour les mises à jour en temps réel
 * U Silenziu - Septembre 2025
 */

import { NextRequest, NextResponse } from 'next/server'
import { Server as SocketIOServer } from 'socket.io'
import { Server as NetServer } from 'http'
import { Socket as NetSocket } from 'net'

// Interface pour étendre NextRequest avec socket.io
interface SocketServer extends NetServer {
  io?: SocketIOServer | undefined
}

interface SocketWithIO extends NetSocket {
  server: SocketServer
}

// Configuration CORS pour WebSocket
const ioConfig = {
  cors: {
    origin: process.env.NODE_ENV === 'production' 
      ? ['https://rageroom.usilenziu.com', 'https://rageroom.usilenziu.com/admin']
      : ['http://localhost:3000', 'http://localhost:3000/admin'],
    methods: ['GET', 'POST'],
    credentials: true
  },
  transports: ['websocket', 'polling']
}

// Instance globale du serveur WebSocket
let io: SocketIOServer | null = null

export async function GET(request: NextRequest) {
  try {
    // Initialiser Socket.IO si pas déjà fait
    if (!io) {
      const { Server } = await import('socket.io')
      const { createServer } = await import('http')
      
      const httpServer = createServer()
      io = new Server(httpServer, ioConfig)
      
      // Gestion des connexions
      io.on('connection', (socket) => {
        console.log(`🔌 Client connecté: ${socket.id}`)
        
        // Rejoindre les rooms selon le type de client
        socket.on('join:admin', () => {
          socket.join('admin')
          console.log(`👤 Admin connecté: ${socket.id}`)
        })
        
        socket.on('join:public', () => {
          socket.join('public')
          console.log(`🌐 Public connecté: ${socket.id}`)
        })
        
        // Événements des salles
        socket.on('rooms:update', async (data) => {
          console.log('🔄 Mise à jour des salles:', data)
          
          // Notifier tous les clients publics
          socket.to('public').emit('rooms:updated', data.rooms)
          
          // Notifier les admins
          socket.to('admin').emit('rooms:updated', data.rooms)
          socket.emit('admin:notification', 'Salles mises à jour', 'success')
        })
        
        socket.on('rooms:add', async (data) => {
          console.log('➕ Nouvelle salle ajoutée:', data)
          
          socket.to('public').emit('rooms:added', data.room)
          socket.to('admin').emit('rooms:added', data.room)
          socket.emit('admin:notification', 'Salle ajoutée avec succès', 'success')
        })
        
        socket.on('rooms:edit', async (data) => {
          console.log('✏️ Salle modifiée:', data)
          
          socket.to('public').emit('rooms:updated', data.room)
          socket.to('admin').emit('rooms:updated', data.room)
          socket.emit('admin:notification', 'Salle modifiée avec succès', 'success')
        })
        
        socket.on('rooms:delete', async (data) => {
          console.log('🗑️ Salle supprimée:', data)
          
          socket.to('public').emit('rooms:deleted', data.roomId)
          socket.to('admin').emit('rooms:deleted', data.roomId)
          socket.emit('admin:notification', 'Salle supprimée avec succès', 'success')
        })
        
        // Événements des sections homepage
        socket.on('homepage:update', async (data) => {
          console.log('🔄 Mise à jour des sections homepage:', data)
          
          socket.to('public').emit('homepage:updated', data.sections)
          socket.to('admin').emit('homepage:updated', data.sections)
          socket.emit('admin:notification', 'Sections homepage mises à jour', 'success')
        })
        
        socket.on('homepage:section:update', async (data) => {
          console.log('✏️ Section homepage modifiée:', data)
          
          socket.to('public').emit('homepage:section:updated', data.section)
          socket.to('admin').emit('homepage:section:updated', data.section)
          socket.emit('admin:notification', 'Section modifiée avec succès', 'success')
        })
        
        // Événements des réservations
        socket.on('reservations:update', async (data) => {
          console.log('🔄 Mise à jour des réservations:', data)
          
          socket.to('admin').emit('reservations:updated', data.reservations)
          socket.emit('admin:notification', 'Réservations mises à jour', 'success')
        })
        
        socket.on('reservations:add', async (data) => {
          console.log('➕ Nouvelle réservation:', data)
          
          socket.to('admin').emit('reservations:added', data.reservation)
          socket.emit('admin:notification', 'Nouvelle réservation reçue', 'info')
        })
        
        // Événement de rafraîchissement général
        socket.on('site:refresh', () => {
          console.log('🔄 Rafraîchissement du site demandé')
          
          socket.to('public').emit('site:refresh')
          socket.emit('admin:notification', 'Site rafraîchi', 'success')
        })
        
        // Gestion de la déconnexion
        socket.on('disconnect', (reason) => {
          console.log(`🔌 Client déconnecté: ${socket.id}, raison: ${reason}`)
        })
      })
      
      // Démarrer le serveur HTTP
      const port = process.env.WS_PORT || 3001
      httpServer.listen(port, () => {
        console.log(`🚀 Serveur WebSocket démarré sur le port ${port}`)
      })
    }
    
    return NextResponse.json({
      success: true,
      message: 'WebSocket server running',
      connected: io.engine.clientsCount
    })
    
  } catch (error) {
    console.error('❌ Erreur WebSocket:', error)
    return NextResponse.json({
      success: false,
      error: 'Erreur serveur WebSocket'
    }, { status: 500 })
  }
}

// Fonction utilitaire pour émettre des événements depuis l'API
export function emitToClients(event: string, data: any, room?: string) {
  if (io) {
    if (room) {
      io.to(room).emit(event, data)
    } else {
      io.emit(event, data)
    }
  }
}

// Fonction pour notifier les mises à jour des salles
export function notifyRoomsUpdate(rooms: any[]) {
  emitToClients('rooms:updated', { rooms }, 'public')
  emitToClients('rooms:updated', { rooms }, 'admin')
}

// Fonction pour notifier les mises à jour des sections homepage
export function notifyHomepageUpdate(sections: any[]) {
  emitToClients('homepage:updated', { sections }, 'public')
  emitToClients('homepage:updated', { sections }, 'admin')
}

// Fonction pour notifier les mises à jour des réservations
export function notifyReservationsUpdate(reservations: any[]) {
  emitToClients('reservations:updated', { reservations }, 'admin')
}
