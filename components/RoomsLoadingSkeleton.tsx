'use client'

import React from 'react'

export default function RoomsLoadingSkeleton() {
  return (
    <div className="space-y-6">
      {/* Header skeleton */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="h-8 w-32 bg-kaki-800/50 rounded animate-pulse"></div>
        </div>
        <div className="h-8 w-24 bg-kaki-800/50 rounded animate-pulse"></div>
      </div>

      {/* Grille de skeletons */}
      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        {Array.from({ length: 6 }).map((_, index) => (
          <div
            key={index}
            className="card-dark border border-kaki-800/30 p-6 animate-pulse"
          >
            {/* Image skeleton */}
            <div className="w-full h-48 bg-kaki-800/50 rounded-lg mb-6 relative">
              <div className="absolute top-4 right-4 w-12 h-6 bg-kaki-700/50 rounded-full"></div>
            </div>

            {/* Contenu skeleton */}
            <div className="space-y-4">
              {/* Titre */}
              <div>
                <div className="h-6 w-3/4 bg-kaki-800/50 rounded mb-2"></div>
                <div className="h-4 w-1/2 bg-gray-700/50 rounded"></div>
              </div>

              {/* Informations clés */}
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div className="w-4 h-4 bg-kaki-800/50 rounded"></div>
                  <div className="h-4 w-12 bg-gray-700/50 rounded"></div>
                </div>
                <div className="flex items-center gap-2">
                  <div className="w-4 h-4 bg-kaki-800/50 rounded"></div>
                  <div className="h-4 w-16 bg-gray-700/50 rounded"></div>
                </div>
              </div>

              {/* Description */}
              <div className="space-y-2">
                <div className="h-4 w-full bg-gray-700/50 rounded"></div>
                <div className="h-4 w-3/4 bg-gray-700/50 rounded"></div>
                <div className="h-4 w-1/2 bg-gray-700/50 rounded"></div>
              </div>

              {/* Listes */}
              <div className="space-y-2">
                <div className="h-4 w-24 bg-kaki-800/50 rounded"></div>
                <div className="space-y-1">
                  {Array.from({ length: 3 }).map((_, idx) => (
                    <div key={idx} className="flex items-center gap-2">
                      <div className="w-3 h-3 bg-kaki-800/50 rounded-full"></div>
                      <div className="h-3 w-32 bg-gray-700/50 rounded"></div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Bouton */}
              <div className="h-12 w-full bg-kaki-800/50 rounded-lg mt-6"></div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
