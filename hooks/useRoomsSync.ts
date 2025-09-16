import React from 'react'
import useSWR from 'swr'
import { useRoomsStore } from '@/store/roomsStore'
import { Room } from '@/lib/database'

// Fetcher simplifié pour SWR
const fetcher = async (url: string) => {
  try {
    const response = await fetch(url, {
      headers: {
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache'
      }
    })
    
    if (!response.ok) {
      throw new Error(`Erreur HTTP: ${response.status}`)
    }
    
    return response.json()
  } catch (error) {
    console.error('Erreur dans le fetcher:', error)
    throw error
  }
}

// Configuration SWR simplifiée
const swrConfig = {
  refreshInterval: 30000,
  revalidateOnFocus: false,
  revalidateOnReconnect: true,
  dedupingInterval: 5000,
  errorRetryCount: 2,
  errorRetryInterval: 5000,
}

export const useRoomsSync = () => {
  const {
    rooms,
    isLoading: storeLoading,
    error: storeError,
    lastSync,
    setRooms,
    setLoading,
    setError,
    setLastSync,
    optimisticUpdate
  } = useRoomsStore()

  // SWR hook pour la synchronisation
  const { data, error, isLoading, mutate: swrMutate } = useSWR(
    '/api/rooms',
    fetcher,
    swrConfig
  )

  // Synchroniser les données SWR avec le store Zustand
  React.useEffect(() => {
    if (data?.success && data.data) {
      setRooms(data.data)
      setLastSync(new Date().toISOString())
      setError(null)
    }
  }, [data, setRooms, setLastSync, setError])

  // Gérer les erreurs
  React.useEffect(() => {
    if (error) {
      setError(error.message || 'Erreur de synchronisation')
    }
  }, [error, setError])

  // Fonction de synchronisation manuelle simplifiée
  const syncRooms = React.useCallback(async () => {
    try {
      setLoading(true)
      setError(null)
      await swrMutate()
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erreur de synchronisation'
      setError(errorMessage)
    } finally {
      setLoading(false)
    }
  }, [swrMutate, setLoading, setError])

  // Fonction pour mettre à jour une salle simplifiée
  const updateRoomOptimistic = React.useCallback(async (
    id: string,
    updates: Partial<Room>
  ) => {
    try {
      // Optimistic update immédiat
      optimisticUpdate(id, updates)
      
      // Mise à jour côté serveur
      const response = await fetch(`/api/rooms/${id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(updates),
      })

      if (!response.ok) {
        throw new Error('Erreur lors de la mise à jour')
      }

      // Revalider les données
      await swrMutate()
    } catch (err) {
      // En cas d'erreur, revalider pour restaurer l'état correct
      await swrMutate()
      const errorMessage = err instanceof Error ? err.message : 'Erreur de mise à jour'
      setError(errorMessage)
    }
  }, [optimisticUpdate, swrMutate, setError])

  // Fonction pour supprimer une salle simplifiée
  const deleteRoom = React.useCallback(async (id: string) => {
    try {
      // Optimistic update immédiat
      useRoomsStore.getState().removeRoom(id)
      
      // Suppression côté serveur
      const response = await fetch(`/api/rooms/${id}`, {
        method: 'DELETE',
      })

      if (!response.ok) {
        throw new Error('Erreur lors de la suppression')
      }

      // Revalider les données
      await swrMutate()
    } catch (err) {
      // En cas d'erreur, revalider pour restaurer l'état correct
      await swrMutate()
      const errorMessage = err instanceof Error ? err.message : 'Erreur de suppression'
      setError(errorMessage)
    }
  }, [swrMutate, setError])

  return {
    // Données
    rooms,
    isLoading: isLoading || storeLoading,
    error: storeError,
    lastSync,
    
    // Actions
    syncRooms,
    updateRoomOptimistic,
    deleteRoom,
    
    // État SWR
    isValidating: isLoading,
    mutate: swrMutate,
  }
}
