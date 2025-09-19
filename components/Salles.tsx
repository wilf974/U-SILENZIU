'use client'

import React from 'react'
import RoomsDisplay from './RoomsDisplay'
import { useHomepageSections } from '@/lib/hooks/useHomepageSections'

/**
 * Affiche la section "Salles" uniquement si la section homepage 'rooms' est active.
 */
export default function Salles() {
  const { getSectionByKey, loading } = useHomepageSections()
  const section = getSectionByKey('rooms')

  if (loading) return null
  if (!section) return null

  return (
    <section id="salles" className="section-container bg-black py-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-16">
          <h2 className="text-4xl font-bold mb-4">
            <span className="text-white">Nos </span>
            <span className="text-gradient-kaki">Salles</span>
          </h2>
          <p className="text-gray-400 max-w-3xl mx-auto">
            À chaque besoin, sa salle ! Choisissez l'intensité qui correspond à votre niveau de stress et laissez-vous aller à une expérience libératrice unique.
          </p>
        </div>

        {/* Liste des salles avec composant simplifié */}
        <RoomsDisplay />
      </div>
    </section>
  )
}
