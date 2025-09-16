import type { Metadata } from 'next'
import { Suspense } from 'react'
import ReservationForm from './ReservationForm'
import { generatePageMetadata } from '@/lib/metadata'

export const metadata: Metadata = generatePageMetadata(
  'Réservation',
  'Réservez votre session de défoulement chez U Silenziu à Buros. Choisissez votre créneau, votre formule et réservez en ligne. Salles sécurisées et équipements professionnels.',
  '/reservation',
  ['réservation', 'défoulement', 'Buros', 'salle de défoulement', 'booking', 'créneau', 'formule']
)

function ReservationFallback() {
  return (
    <div className="min-h-screen bg-dark-bg flex items-center justify-center">
      <div className="text-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-kaki-500 mx-auto mb-4"></div>
        <p className="text-white">Chargement de la réservation...</p>
      </div>
    </div>
  )
}

export default function ReservationPage() {
  return (
    <div className="min-h-screen bg-dark-bg">
      <Suspense fallback={<ReservationFallback />}>
        <ReservationForm />
      </Suspense>
    </div>
  )
}
