'use server'

import { 
  getAllRooms, 
  getRoomById, 
  createRoom, 
  updateRoom, 
  deleteRoom, 
  toggleRoomStatus,
  type Room 
} from '@/lib/database'
import { revalidatePath } from 'next/cache'

// Récupérer toutes les salles
export async function getRoomsAction(): Promise<Room[]> {
  try {
    return await getAllRooms()
  } catch (error) {
    console.error('Erreur lors de la récupération des salles:', error)
    throw new Error('Impossible de récupérer les salles')
  }
}

// Récupérer une salle par ID
export async function getRoomAction(id: string): Promise<Room | null> {
  try {
    return await getRoomById(id)
  } catch (error) {
    console.error('Erreur lors de la récupération de la salle:', error)
    throw new Error('Impossible de récupérer la salle')
  }
}

// Créer une nouvelle salle
export async function createRoomAction(formData: FormData): Promise<{ success: boolean; message: string; room?: Room }> {
  try {
    const name = formData.get('name') as string
    const subtitle = formData.get('subtitle') as string
    const duration = parseInt(formData.get('duration') as string)
    const price = parseInt(formData.get('price') as string)
    const description = formData.get('description') as string
    const maxPeople = parseInt(formData.get('maxPeople') as string)
    const objectsToDestroy = (formData.get('objectsToDestroy') as string).split('\n').filter(item => item.trim())
    const included = (formData.get('included') as string).split('\n').filter(item => item.trim())
    const imageUrl = formData.get('imageUrl') as string || undefined
    const isActive = formData.get('isActive') === 'true'

    // Validation
    if (!name || !subtitle || !description) {
      return { success: false, message: 'Tous les champs obligatoires doivent être remplis' }
    }

    if (duration <= 0 || price <= 0 || maxPeople <= 0) {
      return { success: false, message: 'La durée, le prix et le nombre de personnes doivent être positifs' }
    }

    const roomData = {
      name,
      description: subtitle,
      duration,
      price,
      max_people: maxPeople,
      objects_to_destroy: objectsToDestroy,
      included,
      is_active: isActive
    }

    const room = await createRoom(roomData)
    revalidatePath('/admin/rooms')
    
    return { 
      success: true, 
      message: 'Salle créée avec succès',
      room 
    }
  } catch (error) {
    console.error('Erreur lors de la création de la salle:', error)
    return { success: false, message: 'Erreur lors de la création de la salle' }
  }
}

// Mettre à jour une salle
export async function updateRoomAction(id: string, formData: FormData): Promise<{ success: boolean; message: string; room?: Room }> {
  try {
    const name = formData.get('name') as string
    const subtitle = formData.get('subtitle') as string
    const duration = parseInt(formData.get('duration') as string)
    const price = parseInt(formData.get('price') as string)
    const description = formData.get('description') as string
    const maxPeople = parseInt(formData.get('maxPeople') as string)
    const objectsToDestroy = (formData.get('objectsToDestroy') as string).split('\n').filter(item => item.trim())
    const included = (formData.get('included') as string).split('\n').filter(item => item.trim())
    const imageUrl = formData.get('imageUrl') as string || undefined
    const isActive = formData.get('isActive') === 'true'

    // Validation
    if (!name || !subtitle || !description) {
      return { success: false, message: 'Tous les champs obligatoires doivent être remplis' }
    }

    if (duration <= 0 || price <= 0 || maxPeople <= 0) {
      return { success: false, message: 'La durée, le prix et le nombre de personnes doivent être positifs' }
    }

    const roomData = {
      name,
      description: subtitle,
      duration,
      price,
      max_people: maxPeople,
      objects_to_destroy: objectsToDestroy,
      included,
      is_active: isActive
    }

    const room = await updateRoom(id, roomData)
    if (!room) {
      return { success: false, message: 'Salle non trouvée' }
    }

    revalidatePath('/admin/rooms')
    
    return { 
      success: true, 
      message: 'Salle mise à jour avec succès',
      room 
    }
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la salle:', error)
    return { success: false, message: 'Erreur lors de la mise à jour de la salle' }
  }
}

// Supprimer une salle
export async function deleteRoomAction(id: string): Promise<{ success: boolean; message: string }> {
  try {
    const success = await deleteRoom(id)
    if (success) {
      revalidatePath('/admin/rooms')
      return { success: true, message: 'Salle supprimée avec succès' }
    } else {
      return { success: false, message: 'Salle non trouvée' }
    }
  } catch (error) {
    console.error('Erreur lors de la suppression de la salle:', error)
    return { success: false, message: 'Erreur lors de la suppression de la salle' }
  }
}

// Activer/désactiver une salle
export async function toggleRoomAction(id: string): Promise<{ success: boolean; message: string; room?: Room }> {
  try {
    const room = await toggleRoomStatus(id)
    if (room) {
      revalidatePath('/admin/rooms')
      return { 
        success: true, 
        message: `Salle ${room.is_active ? 'activée' : 'désactivée'} avec succès`,
        room 
      }
    } else {
      return { success: false, message: 'Salle non trouvée' }
    }
  } catch (error) {
    console.error('Erreur lors du changement de statut de la salle:', error)
    return { success: false, message: 'Erreur lors du changement de statut' }
  }
}
