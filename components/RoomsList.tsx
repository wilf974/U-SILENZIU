'use client'

import React from 'react'
import { useRoomsSync } from '@/hooks/useRoomsSync'
import RoomCard from './RoomCard'
import RoomsLoadingSkeleton from './RoomsLoadingSkeleton'
import RoomsErrorBoundary from './RoomsErrorBoundary'
import { RefreshCw, AlertCircle } from 'lucide-react'

export default function RoomsList() {
  const {
    rooms,
    isLoading,
    error,
    lastSync,
    syncRooms,
    isValidating
  } = useRoomsSync()

  // État de loading initial
  if (isLoading && rooms.length === 0) {
    return <RoomsLoadingSkeleton />
  }

  // Gestion d'erreur
  if (error) {
    return <RoomsErrorBoundary error={error} onRetry={syncRooms} />
  }

  return (
    <div className="space-y-6">
      {/* Liste des salles */}
      {rooms.length === 0 ? (
        <div className="text-center py-12">
          <div className="text-gray-400 mb-4">
            <div className="text-6xl mb-4">🏠</div>
            <p className="text-xl">Aucune salle disponible</p>
            <p className="text-sm mt-2">Les salles apparaîtront ici une fois ajoutées</p>
          </div>
        </div>
      ) : (
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {rooms.map((room, index) => (
            <div
              key={room.id}
              className="animate-fade-in"
              style={{
                animationDelay: `${index * 100}ms`,
                animationFillMode: 'both'
              }}
            >
              <RoomCard room={room} />
            </div>
          ))}
        </div>
      )}

      {/* Indicateur de synchronisation en cours */}
      {isValidating && rooms.length > 0 && (
        <div className="fixed bottom-4 right-4 bg-kaki-600 text-white px-4 py-2 rounded-lg shadow-lg flex items-center gap-2">
          <RefreshCw className="animate-spin" size={16} />
          <span className="text-sm">Mise à jour en cours...</span>
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

// Injecter les styles
if (typeof document !== 'undefined') {
  const styleSheet = document.createElement('style')
  styleSheet.textContent = styles
  document.head.appendChild(styleSheet)
}
