'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { MapPin, Clock, Users, Check, ArrowRight, RefreshCw, Wifi, WifiOff } from 'lucide-react'
import { Room } from '@/lib/database'
import { useRoomsWebSocket } from '@/lib/websocket'
import RoomImage from './RoomImage'

/**
 * Composant d'affichage des salles avec WebSocket en temps réel
 * U Silenziu - Septembre 2025
 */
export default function RoomsDisplayWebSocket() {
  const [rooms, setRooms] = useState<Room[]>([])
  const [loading, setLoading] = useState(true)
  const [lastUpdate, setLastUpdate] = useState<string>('')
  const router = useRouter()
  
  // Hook WebSocket pour les mises à jour en temps réel
  const { rooms: wsRooms, isConnected } = useRoomsWebSocket()

  // Charger les salles initiales
  useEffect(() => {
    fetchRooms()
  }, [])

  // Synchroniser avec les données WebSocket
  useEffect(() => {
    if (wsRooms.length > 0) {
      setRooms(wsRooms)
      setLastUpdate(new Date().toLocaleTimeString('fr-FR'))
    }
  }, [wsRooms])

  const fetchRooms = async () => {
    try {
      setLoading(true)
      const response = await fetch('/api/rooms', {
        cache: 'no-store',
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0'
        }
      })
      
      if (response.ok) {
        const result = await response.json()
        const roomsData = result.data || result
        setRooms(roomsData)
        setLastUpdate(new Date().toLocaleTimeString('fr-FR'))
      }
    } catch (error) {
      console.error('Erreur lors du chargement des salles:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleReservation = (roomName: string) => {
    try {
      router.push(`/reservation?formule=${encodeURIComponent(roomName)}`)
    } catch (error) {
      console.error('Erreur lors de la navigation:', error)
      window.location.href = `/reservation?formule=${encodeURIComponent(roomName)}`
    }
  }

  const handleRefresh = () => {
    fetchRooms()
  }

  if (loading) {
    return (
      <section className="py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-kaki-600 mx-auto mb-4"></div>
            <p className="text-gray-400">Chargement des salles...</p>
          </div>
        </div>
      </section>
    )
  }

  return (
    <div className="space-y-6">
      {/* Indicateur de connexion WebSocket */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2 text-sm text-gray-400">
          {isConnected ? (
            <>
              <Wifi className="w-4 h-4 text-green-500" />
              <span>Mises à jour en temps réel</span>
            </>
          ) : (
            <>
              <WifiOff className="w-4 h-4 text-red-500" />
              <span>Mode hors ligne</span>
            </>
          )}
        </div>
        
        <div className="flex items-center gap-4">
          {lastUpdate && (
            <span className="text-xs text-gray-500">
              Dernière mise à jour: {lastUpdate}
            </span>
          )}
          
          <button
            onClick={handleRefresh}
            className="btn-kaki-sm flex items-center gap-2"
            title="Actualiser manuellement"
          >
            <RefreshCw size={14} />
            Actualiser
          </button>
        </div>
      </div>

      {/* Message si aucune salle active */}
      {rooms.length === 0 && (
        <div className="text-center py-12">
          <div className="text-kaki-600 text-6xl mb-4">🏠</div>
          <h3 className="text-xl font-semibold text-gray-300 mb-2">Aucune salle disponible</h3>
          <p className="text-gray-500 mb-6">Les salles sont actuellement en cours de configuration.</p>
          <button
            onClick={handleRefresh}
            className="btn-kaki flex items-center gap-2 mx-auto"
          >
            <RefreshCw size={16} />
            Actualiser
          </button>
        </div>
      )}

      {/* Grille des salles */}
      {rooms.length > 0 && (
        <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
          {rooms.map((room, index) => (
            <div 
              key={room.id} 
              className="card-dark border border-kaki-800/30 p-6 hover:border-kaki-600/50 transition-all duration-300 hover:scale-105 animate-fade-in"
              style={{
                animationDelay: `${index * 100}ms`,
                animationFillMode: 'both'
              }}
            >
              {/* Image de la salle */}
              <div className="relative mb-6">
                <div className="relative w-full h-48 bg-kaki-900/20 rounded-lg overflow-hidden">
                  <RoomImage
                    src={room.image_url}
                    alt={`Image de la salle ${room.name}`}
                    className="w-full h-full"
                    priority={index < 3}
                    quality={85}
                  />
                </div>
                <div className="absolute top-4 right-4 bg-black/70 text-white px-3 py-1 rounded-full text-sm font-medium">
                  {Math.round(room.price)}€
                </div>
              </div>

              {/* Contenu */}
              <div className="space-y-4">
                {/* Titre */}
                <h3 className="text-xl font-bold text-white mb-2">
                  {room.name}
                </h3>

                {/* Description */}
                <p className="text-gray-300 text-sm leading-relaxed">
                  {room.description}
                </p>

                {/* Informations pratiques */}
                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-sm text-gray-400">
                    <Clock className="w-4 h-4" />
                    <span>{room.duration} minutes</span>
                  </div>
                  
                  <div className="flex items-center gap-2 text-sm text-gray-400">
                    <Users className="w-4 h-4" />
                    <span>Jusqu'à {room.max_people} personnes</span>
                  </div>
                </div>

                {/* Objets à détruire */}
                {room.objects_to_destroy && room.objects_to_destroy.length > 0 && (
                  <div className="space-y-2">
                    <h4 className="text-sm font-semibold text-kaki-400">Objets à détruire :</h4>
                    <div className="flex flex-wrap gap-1">
                      {room.objects_to_destroy.map((object, idx) => (
                        <span 
                          key={idx}
                          className="px-2 py-1 bg-kaki-900/30 text-kaki-300 text-xs rounded"
                        >
                          {object}
                        </span>
                      ))}
                    </div>
                  </div>
                )}

                {/* Inclus */}
                {room.included && room.included.length > 0 && (
                  <div className="space-y-2">
                    <h4 className="text-sm font-semibold text-green-400">Inclus :</h4>
                    <div className="space-y-1">
                      {room.included.map((item, idx) => (
                        <div key={idx} className="flex items-center gap-2 text-sm text-gray-300">
                          <Check className="w-3 h-3 text-green-500" />
                          <span>{item}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {/* Bouton de réservation */}
                <button
                  onClick={() => handleReservation(room.name)}
                  className="btn-kaki w-full flex items-center justify-center gap-2 mt-6"
                >
                  <span>Réserver maintenant</span>
                  <ArrowRight className="w-4 h-4" />
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

// Styles CSS pour les animations
const styles = `
  @keyframes fade-in {
    from {
      opacity: 0;
      transform: translateY(20px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }
  
  .animate-fade-in {
    animation: fade-in 0.5s ease-out;
  }
`
