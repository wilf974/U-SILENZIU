'use client'

import { useEffect, useState, Suspense } from 'react'
import { useSearchParams, useRouter } from 'next/navigation'
import { XCircle, RefreshCw } from 'lucide-react'
import Link from 'next/link'

/**
 * Page d'annulation après paiement Payplug
 */
function PaymentCancelledContent() {
  const searchParams = useSearchParams()
  const router = useRouter()
  const [reservationNumber, setReservationNumber] = useState<string>('')

  useEffect(() => {
    const reservation = searchParams.get('reservation')
    if (reservation) {
      setReservationNumber(reservation)
    }
  }, [searchParams])

  return (
    <div className="min-h-screen bg-dark-bg py-20">
      <div className="section-container">
        <div className="max-w-2xl mx-auto text-center">
          {/* Icône d'annulation */}
          <div className="flex justify-center mb-8">
            <XCircle className="w-16 h-16 text-red-500" />
          </div>

          {/* Titre */}
          <h1 className="text-4xl lg:text-5xl font-bold mb-6 text-red-500">
            Paiement annulé
          </h1>

          {/* Message */}
          <p className="text-xl text-gray-300 mb-8">
            Votre paiement a été annulé. Vous pouvez réessayer ou nous contacter si vous avez besoin d'aide.
          </p>

          {/* Numéro de réservation */}
          {reservationNumber && (
            <div className="bg-gray-800 rounded-lg p-6 mb-8 border border-gray-700">
              <h3 className="text-lg font-semibold text-white mb-2">Numéro de réservation</h3>
              <p className="text-2xl font-mono text-kaki-400">{reservationNumber}</p>
              <p className="text-sm text-gray-400 mt-2">
                Cette réservation est toujours en attente de paiement.
              </p>
            </div>
          )}

          {/* Actions */}
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href={`/reservation?step=payment&reservation=${reservationNumber}`}
              className="bg-kaki-600 hover:bg-kaki-700 text-white px-6 py-3 rounded-lg font-medium transition-colors"
            >
              Payer maintenant
            </Link>
            <Link
              href="/reservation"
              className="bg-gray-600 hover:bg-gray-700 text-white px-6 py-3 rounded-lg font-medium transition-colors"
            >
              Nouvelle réservation
            </Link>
            <Link
              href="/contact"
              className="bg-red-600 hover:bg-red-700 text-white px-6 py-3 rounded-lg font-medium transition-colors"
            >
              Besoin d'aide ?
            </Link>
          </div>

          {/* Informations de contact */}
          <div className="mt-12 text-sm text-gray-500">
            <p>
              Pour toute question concernant votre réservation, contactez-nous au{' '}
              <a href="tel:+33783836453" className="text-kaki-400 hover:text-kaki-300">
                07 83 83 64 53
              </a>
              {' '}ou par email à{' '}
              <a href="mailto:info@usilenziu.com" className="text-kaki-400 hover:text-kaki-300">
                info@usilenziu.com
              </a>
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}

export default function PaymentCancelledPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-dark-bg py-20">
        <div className="section-container">
          <div className="max-w-2xl mx-auto text-center">
            <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-kaki-500 mx-auto mb-8"></div>
            <h1 className="text-2xl text-white">Chargement...</h1>
          </div>
        </div>
      </div>
    }>
      <PaymentCancelledContent />
    </Suspense>
  )
}
