'use client'

import { useState, useEffect } from 'react'

export interface Room {
  id: string
  name: string
  description: string
  price: number
  duration: number
  max_people: number
  objects_to_destroy: string[]
  included: string[]
  image_url?: string
  is_active: boolean
  created_at: string
  updated_at: string
}

/**
 * Hook personnalisé pour récupérer les salles dynamiquement depuis l'API
 * @returns {Object} Objet contenant les salles, l'état de chargement et les erreurs
 */
export function useRooms() {
  const [rooms, setRooms] = useState<Room[]>([])
  const [loading, setLoading] = useState<boolean>(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchRooms = async () => {
      try {
        setLoading(true)
        setError(null)
        
        const response = await fetch('/api/rooms')
        const data = await response.json()
        
        if (data.success) {
          setRooms(data.data)
        } else {
          setError(data.error || 'Erreur lors de la récupération des salles')
        }
      } catch (err) {
        setError('Erreur de connexion lors de la récupération des salles')
        console.error('Erreur useRooms:', err)
      } finally {
        setLoading(false)
      }
    }

    fetchRooms()
  }, [])

  /**
   * Fonction pour récupérer une salle par son nom
   * @param roomName - Nom de la salle à rechercher
   * @returns La salle trouvée ou null
   */
  const getRoomByName = (roomName: string): Room | null => {
    return rooms.find(room => room.name === roomName) || null
  }

  /**
   * Fonction pour récupérer les salles actives
   * @returns Liste des salles actives
   */
  const getActiveRooms = (): Room[] => {
    return rooms.filter(room => room.is_active)
  }

  /**
   * Fonction pour recharger les salles
   */
  const refetchRooms = async () => {
    try {
      setLoading(true)
      setError(null)
      
      const response = await fetch('/api/rooms')
      const data = await response.json()
      
      if (data.success) {
        setRooms(data.data)
      } else {
        setError(data.error || 'Erreur lors de la récupération des salles')
      }
    } catch (err) {
      setError('Erreur de connexion lors de la récupération des salles')
      console.error('Erreur refetchRooms:', err)
    } finally {
      setLoading(false)
    }
  }

  return {
    rooms,
    loading,
    error,
    getRoomByName,
    getActiveRooms,
    refetchRooms
  }
}
