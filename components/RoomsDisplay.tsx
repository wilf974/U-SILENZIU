'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { MapPin, Clock, Users, Check, ArrowRight, RefreshCw } from 'lucide-react'
import { Room } from '@/lib/database'
import RoomImage from './RoomImage'

export default function RoomsDisplay() {
  const [rooms, setRooms] = useState<Room[]>([])
  const [loading, setLoading] = useState(true)
  const [lastUpdate, setLastUpdate] = useState<string>('')
  const router = useRouter()

  useEffect(() => {
    fetchRooms()
  }, [])

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
      <section className="section-container bg-black py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <h2 className="text-4xl font-bold mb-4">
              <span className="text-white">Nos </span>
              <span className="text-gradient-kaki">Salles</span>
            </h2>
            <div className="flex items-center justify-center gap-2 text-gray-400 mb-12">
              <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-kaki-400"></div>
              <span>Chargement des salles...</span>
            </div>
          </div>
        </div>
      </section>
    )
  }

  return (
    <section className="section-container bg-black py-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header avec bouton de rafraîchissement */}
        <div className="text-center mb-16">
          <div className="flex items-center justify-center gap-4 mb-4">
            <h2 className="text-4xl font-bold">
              <span className="text-white">Nos </span>
              <span className="text-gradient-kaki">Salles</span>
            </h2>
            <button
              onClick={handleRefresh}
              className="p-2 text-kaki-400 hover:text-kaki-300 transition-colors"
              title="Actualiser les salles"
            >
              <RefreshCw size={20} />
            </button>
          </div>
          <p className="text-gray-400 max-w-3xl mx-auto mb-4">
            À chaque besoin, sa salle ! Choisissez l'intensité qui correspond à votre niveau de stress et laissez-vous aller à une expérience libératrice unique.
          </p>
          {lastUpdate && (
            <p className="text-xs text-gray-500">
              Dernière mise à jour : {lastUpdate}
            </p>
          )}
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
              <div key={room.id} className="card-dark border border-kaki-800/30 p-6 hover:border-kaki-600/50 transition-all duration-300 hover:scale-105">
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
                  <div>
                    <h3 className="text-2xl font-bold text-kaki-400 mb-2">{room.name}</h3>
                  </div>

                  {/* Informations clés */}
                  <div className="flex items-center justify-between text-sm">
                    <div className="flex items-center gap-2 text-gray-300">
                      <Clock size={16} />
                      <span>{room.duration} min</span>
                    </div>
                    <div className="flex items-center gap-2 text-gray-300">
                      <Users size={16} />
                      <span>Max {room.max_people}</span>
                    </div>
                  </div>

                  {/* Description */}
                  <p className="text-gray-300 text-sm">{room.description}</p>

                  {/* Objets à détruire */}
                  {room.objects_to_destroy && room.objects_to_destroy.length > 0 && (
                    <div>
                      <h4 className="text-sm font-semibold text-kaki-400 mb-2">Objets à détruire :</h4>
                      <ul className="space-y-1">
                        {room.objects_to_destroy.map((object, idx) => (
                          <li key={idx} className="flex items-center gap-2 text-sm text-gray-300">
                            <Check size={14} className="text-kaki-400 flex-shrink-0" />
                            <span>{object}</span>
                          </li>
                        ))}
                      </ul>
                    </div>
                  )}

                  {/* Inclus */}
                  {room.included && room.included.length > 0 && (
                    <div>
                      <h4 className="text-sm font-semibold text-kaki-400 mb-2">Inclus :</h4>
                      <ul className="space-y-1">
                        {room.included.map((item, idx) => (
                          <li key={idx} className="flex items-center gap-2 text-sm text-gray-300">
                            <Check size={14} className="text-kaki-400 flex-shrink-0" />
                            <span>{item}</span>
                          </li>
                        ))}
                      </ul>
                    </div>
                  )}
                </div>

                {/* Bouton de réservation */}
                <div className="mt-6 pt-4 border-t border-kaki-800/30">
                  <button
                    onClick={() => handleReservation(room.name)}
                    className="w-full btn-kaki flex items-center justify-center gap-2"
                  >
                    <span>Réserver cette salle</span>
                    <ArrowRight size={16} />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </section>
  )
}
