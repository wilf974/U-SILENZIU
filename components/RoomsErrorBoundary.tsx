'use client'

import React from 'react'
import { AlertCircle, RefreshCw, WifiOff } from 'lucide-react'

interface RoomsErrorBoundaryProps {
  error: string
  onRetry: () => void
}

export default function RoomsErrorBoundary({ error, onRetry }: RoomsErrorBoundaryProps) {
  return (
    <div className="text-center py-12">
      <div className="max-w-md mx-auto">
        {/* Icône d'erreur */}
        <div className="mb-6">
          <div className="w-16 h-16 bg-red-500/20 rounded-full flex items-center justify-center mx-auto mb-4">
            <AlertCircle className="text-red-400" size={32} />
          </div>
        </div>

        {/* Message d'erreur */}
        <h3 className="text-xl font-semibold text-white mb-2">
          Erreur de synchronisation
        </h3>
        <p className="text-gray-400 mb-6">
          {error || 'Impossible de charger les salles. Veuillez vérifier votre connexion.'}
        </p>

        {/* Actions */}
        <div className="space-y-3">
          <button
            onClick={onRetry}
            className="btn-kaki flex items-center justify-center gap-2 w-full"
          >
            <RefreshCw size={16} />
            Réessayer
          </button>
          
          <button
            onClick={() => window.location.reload()}
            className="btn-kaki-outline flex items-center justify-center gap-2 w-full"
          >
            <WifiOff size={16} />
            Recharger la page
          </button>
        </div>

        {/* Informations supplémentaires */}
        <div className="mt-8 text-xs text-gray-500">
          <p>Si le problème persiste, contactez le support technique.</p>
          <p className="mt-1">Code d'erreur: {error ? error.substring(0, 50) + '...' : 'Erreur inconnue'}</p>
        </div>
      </div>
    </div>
  )
}
