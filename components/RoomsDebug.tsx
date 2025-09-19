'use client'

import { useState, useEffect } from 'react'

/**
 * Composant de debug ultra-simple pour les salles
 * U Silenziu - Septembre 2025
 */
export default function RoomsDebug() {
  const [rooms, setRooms] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchRooms()
  }, [])

  const fetchRooms = async () => {
    try {
      setLoading(true)
      setError(null)
      console.log('🔍 DEBUG: Début du chargement des salles...')
      
      const response = await fetch('/api/rooms')
      console.log('🔍 DEBUG: Réponse reçue:', response.status, response.statusText)
      
      if (response.ok) {
        const result = await response.json()
        console.log('🔍 DEBUG: Données complètes:', result)
        
        const roomsData = result.data || result
        console.log('🔍 DEBUG: Salles extraites:', roomsData)
        
        if (Array.isArray(roomsData)) {
          setRooms(roomsData)
          console.log('🔍 DEBUG: Salles définies:', roomsData.length)
        } else {
          console.error('🔍 DEBUG: Données non-array:', roomsData)
          setError('Format de données invalide')
        }
      } else {
        const errorText = await response.text()
        console.error('🔍 DEBUG: Erreur HTTP:', response.status, errorText)
        setError(`Erreur ${response.status}`)
      }
    } catch (error) {
      console.error('🔍 DEBUG: Erreur catch:', error)
      setError('Erreur de connexion')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-4">
      {/* Panneau de debug visible */}
      <div className="bg-red-900 border-2 border-red-500 p-4 rounded-lg">
        <h3 className="text-white font-bold text-lg mb-2">🔍 DEBUG SALLES</h3>
        <div className="text-white text-sm space-y-1">
          <p>Loading: {loading ? 'true' : 'false'}</p>
          <p>Error: {error || 'none'}</p>
          <p>Rooms count: {rooms.length}</p>
          <p>Rooms data: {JSON.stringify(rooms, null, 2)}</p>
        </div>
        <button 
          onClick={fetchRooms}
          className="bg-red-600 text-white px-4 py-2 rounded mt-2"
        >
          Recharger
        </button>
      </div>

      {/* Affichage des salles */}
      {loading && (
        <div className="text-center py-8">
          <div className="text-white">Chargement...</div>
        </div>
      )}

      {error && (
        <div className="text-center py-8">
          <div className="text-red-400">Erreur: {error}</div>
        </div>
      )}

      {!loading && !error && rooms.length === 0 && (
        <div className="text-center py-8">
          <div className="text-yellow-400">Aucune salle trouvée</div>
        </div>
      )}

      {!loading && !error && rooms.length > 0 && (
        <div className="grid gap-4 md:grid-cols-2">
          {rooms.map((room, index) => (
            <div key={room.id || index} className="bg-gray-800 p-4 rounded-lg">
              <h3 className="text-white font-bold text-xl mb-2">{room.name}</h3>
              <p className="text-gray-300 mb-2">{room.description}</p>
              <p className="text-green-400 font-bold">{room.price}€</p>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
