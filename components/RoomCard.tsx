'use client'

import React from 'react'
import { useRouter } from 'next/navigation'
import { Clock, Users, Check, ArrowRight, Wifi, WifiOff } from 'lucide-react'
import { Room } from '@/lib/database'
import RoomImage from './RoomImage'

interface RoomCardProps {
  room: Room
}

export default function RoomCard({ room }: RoomCardProps) {
  const router = useRouter()

  const handleReservation = () => {
    router.push(`/reservation?formule=${encodeURIComponent(room.name)}`)
  }

  return (
    <div className="group relative card-dark border border-kaki-800/30 p-6 hover:border-kaki-600/50 transition-all duration-300 hover:scale-105 hover:shadow-lg hover:shadow-kaki-500/20">
      {/* Image de la salle */}
      <div className="relative mb-6">
        <div className="relative w-full h-48 bg-kaki-900/20 rounded-lg overflow-hidden">
          <RoomImage
            src={room.image_url}
            alt={`Image de la salle ${room.name}`}
            className="w-full h-full"
            priority={false}
            quality={85}
          />
        </div>
        
        {/* Badge de prix */}
        <div className="absolute top-4 right-4 bg-black/70 text-white px-3 py-1 rounded-full text-sm font-medium backdrop-blur-sm">
          {Math.round(room.price)}€
        </div>
      </div>

      {/* Contenu */}
      <div className="space-y-4">
        {/* Titre */}
        <div>
          <h3 className="text-2xl font-bold text-kaki-400 mb-2 group-hover:text-kaki-300 transition-colors">
            {room.name}
          </h3>
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
        <p className="text-gray-300 text-sm line-clamp-3">{room.description}</p>

        {/* Objets à détruire */}
        {room.objects_to_destroy && room.objects_to_destroy.length > 0 && (
          <div className="space-y-2">
            <h4 className="text-kaki-400 font-semibold text-sm">Objets à détruire :</h4>
            <ul className="space-y-1">
              {room.objects_to_destroy.slice(0, 3).map((object, idx) => (
                <li key={idx} className="flex items-center gap-2 text-gray-300 text-sm">
                  <Check size={14} className="text-kaki-400 flex-shrink-0" />
                  <span>{object}</span>
                </li>
              ))}
              {room.objects_to_destroy.length > 3 && (
                <li className="text-gray-500 text-xs">
                  +{room.objects_to_destroy.length - 3} autres objets
                </li>
              )}
            </ul>
          </div>
        )}

        {/* Inclus */}
        {room.included && room.included.length > 0 && (
          <div className="space-y-2">
            <h4 className="text-kaki-400 font-semibold text-sm">Inclus :</h4>
            <ul className="space-y-1">
              {room.included.slice(0, 3).map((item, idx) => (
                <li key={idx} className="flex items-center gap-2 text-gray-300 text-sm">
                  <Check size={14} className="text-kaki-400 flex-shrink-0" />
                  <span>{item}</span>
                </li>
              ))}
              {room.included.length > 3 && (
                <li className="text-gray-500 text-xs">
                  +{room.included.length - 3} autres éléments
                </li>
              )}
            </ul>
          </div>
        )}

        {/* Bouton de réservation */}
        <button
          onClick={handleReservation}
          className="btn-kaki w-full flex items-center justify-center gap-2 group/btn mt-6"
        >
          Réserver cette salle
          <ArrowRight size={16} className="group-hover/btn:translate-x-1 transition-transform" />
        </button>
      </div>

      {/* Overlay de hover */}
      <div className="absolute inset-0 bg-gradient-to-t from-black/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 rounded-lg pointer-events-none"></div>
    </div>
  )
}
