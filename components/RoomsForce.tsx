'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { Clock, Users, Check, ArrowRight, RefreshCw } from 'lucide-react'

/**
 * Composant d'affichage FORCÉ des salles
 * U Silenziu - Septembre 2025
 */
export default function RoomsForce() {
  const [rooms, setRooms] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const router = useRouter()

  useEffect(() => {
    fetchRooms()
  }, [])

  const fetchRooms = async () => {
    try {
      setLoading(true)
      setError(null)
      console.log('🔄 FORCE: Chargement des salles...')
      
      const response = await fetch('/api/rooms', {
        cache: 'no-store',
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0'
        }
      })
      
      console.log('📡 FORCE: Réponse API rooms:', response.status, response.statusText)
      
      if (response.ok) {
        const result = await response.json()
        console.log('📦 FORCE: Données reçues:', result)
        
        const roomsData = result.data || result
        console.log('🏠 FORCE: Salles extraites:', roomsData)
        
        if (Array.isArray(roomsData)) {
          setRooms(roomsData)
          console.log('✅ FORCE: Salles chargées avec succès:', roomsData.length)
        } else {
          console.error('❌ FORCE: Données invalides:', roomsData)
          setError('Format de données invalide')
        }
      } else {
        const errorText = await response.text()
        console.error('❌ FORCE: Erreur API rooms:', response.status, response.statusText, errorText)
        setError(`Erreur ${response.status}: ${response.statusText}`)
      }
    } catch (error) {
      console.error('❌ FORCE: Erreur lors du chargement des salles:', error)
      setError('Erreur de connexion')
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

  // AFFICHAGE FORCÉ - Toujours montrer quelque chose
  return (
    <div className="space-y-6">
      {/* Debug info */}
      <div className="text-center p-4 bg-gray-800 rounded-lg">
        <p className="text-sm text-green-400 mb-2">
          🔧 MODE DEBUG ACTIVÉ
        </p>
        <p className="text-xs text-gray-400">
          Loading: {loading ? 'true' : 'false'} | 
          Error: {error || 'none'} | 
          Rooms: {rooms.length}
        </p>
        <button 
          onClick={fetchRooms}
          className="btn-kaki-sm mt-2"
        >
          <RefreshCw size={14} className="mr-1" />
          Recharger
        </button>
      </div>

      {loading && (
        <div className="text-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-kaki-600 mx-auto mb-4"></div>
          <p className="text-gray-400 mb-4">Chargement des salles...</p>
        </div>
      )}

      {error && (
        <div className="text-center py-12">
          <div className="text-red-500 text-6xl mb-4">⚠️</div>
          <h3 className="text-xl font-semibold text-red-400 mb-2">Erreur de chargement</h3>
          <p className="text-gray-400 mb-4">{error}</p>
          <button 
            onClick={fetchRooms}
            className="btn-kaki-sm"
          >
            <RefreshCw size={16} className="mr-2" />
            Réessayer
          </button>
        </div>
      )}

      {!loading && !error && rooms.length === 0 && (
        <div className="text-center py-12">
          <div className="text-kaki-600 text-6xl mb-4">🏠</div>
          <h3 className="text-xl font-semibold text-gray-300 mb-2">Aucune salle disponible</h3>
          <p className="text-gray-500 mb-6">Les salles sont actuellement en cours de configuration.</p>
          <button 
            onClick={fetchRooms}
            className="btn-kaki flex items-center gap-2 mx-auto"
          >
            <RefreshCw size={16} />
            Actualiser
          </button>
        </div>
      )}

      {!loading && !error && rooms.length > 0 && (
        <>
          {/* Message de succès */}
          <div className="text-center">
            <p className="text-sm text-green-400 mb-4">
              ✅ {rooms.length} salle{rooms.length > 1 ? 's' : ''} chargée{rooms.length > 1 ? 's' : ''} avec succès
            </p>
          </div>

          {/* Grille des salles */}
          <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
            {rooms.map((room, index) => (
              <div 
                key={room.id || index} 
                className="card-dark border border-kaki-800/30 p-6 hover:border-kaki-600/50 transition-all duration-300 hover:scale-105"
              >
                {/* Image de la salle */}
                <div className="relative mb-6">
                  <div className="relative w-full h-48 bg-kaki-900/20 rounded-lg overflow-hidden">
                    {room.image_url ? (
                      <img
                        src={room.image_url}
                        alt={`Image de la salle ${room.name}`}
                        className="w-full h-full object-cover"
                        onError={(e) => {
                          console.log('Erreur image:', room.image_url)
                          e.currentTarget.style.display = 'none'
                        }}
                      />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center bg-kaki-900/30">
                        <span className="text-kaki-400 text-4xl">🏠</span>
                      </div>
                    )}
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
        </>
      )}
    </div>
  )
}
