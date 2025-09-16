import { create } from 'zustand'
import { Room } from '@/lib/database'

interface RoomsState {
  rooms: Room[]
  isLoading: boolean
  error: string | null
  lastSync: string | null
}

interface RoomsActions {
  setRooms: (rooms: Room[]) => void
  addRoom: (room: Room) => void
  updateRoom: (id: string, updates: Partial<Room>) => void
  removeRoom: (id: string) => void
  setLoading: (loading: boolean) => void
  setError: (error: string | null) => void
  setLastSync: (timestamp: string) => void
  optimisticUpdate: (id: string, updates: Partial<Room>) => void
  reset: () => void
}

interface RoomsStore extends RoomsState, RoomsActions {}

const initialState: RoomsState = {
  rooms: [],
  isLoading: false,
  error: null,
  lastSync: null,
}

export const useRoomsStore = create<RoomsStore>((set, get) => ({
  ...initialState,

  setRooms: (rooms) => set({ rooms, error: null }),

  addRoom: (room) => set((state) => ({
    rooms: [...state.rooms, room]
  })),

  updateRoom: (id, updates) => set((state) => ({
    rooms: state.rooms.map(room =>
      room.id === id ? { ...room, ...updates } : room
    )
  })),

  removeRoom: (id) => set((state) => ({
    rooms: state.rooms.filter(room => room.id !== id)
  })),

  setLoading: (isLoading) => set({ isLoading }),

  setError: (error) => set({ error }),

  setLastSync: (timestamp) => set({ lastSync: timestamp }),

  // Optimistic update pour une meilleure UX
  optimisticUpdate: (id, updates) => {
    const currentRooms = get().rooms
    const roomIndex = currentRooms.findIndex(room => room.id === id)
    
    if (roomIndex !== -1) {
      const updatedRooms = [...currentRooms]
      updatedRooms[roomIndex] = { ...updatedRooms[roomIndex], ...updates }
      set({ rooms: updatedRooms })
    }
  },

  reset: () => set(initialState),
}))
