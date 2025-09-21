'use client'

import { useEffect, useState, Suspense } from 'react'
import { useSearchParams, useRouter } from 'next/navigation'
import { CheckCircle, XCircle, Clock, AlertCircle } from 'lucide-react'
import Link from 'next/link'

/**
 * Page de retour après paiement Payplug
 * Gère l'affichage du statut de paiement
 */
function PaymentReturnContent() {
  const searchParams = useSearchParams()
  const router = useRouter()
  const [status, setStatus] = useState<'loading' | 'success' | 'error' | 'pending'>('loading')
  const [reservationNumber, setReservationNumber] = useState<string>('')
  const [error, setError] = useState<string>('')

  useEffect(() => {
    const reservation = searchParams.get('reservation')
    const paymentStatus = searchParams.get('payment_status')
    const paymentId = searchParams.get('payment_id')

    if (reservation) {
      setReservationNumber(reservation)
    }

    // Déterminer le statut basé sur les paramètres URL
    if (paymentStatus === 'success' && paymentId) {
      setStatus('success')
    } else if (paymentStatus === 'error') {
      setStatus('error')
      setError('Le paiement a échoué')
    } else if (paymentStatus === 'cancelled') {
      setStatus('error')
      setError('Le paiement a été annulé')
    } else {
      setStatus('pending')
    }
  }, [searchParams])

  const getStatusIcon = () => {
    switch (status) {
      case 'success':
        return <CheckCircle className="w-16 h-16 text-green-500" />
      case 'error':
        return <XCircle className="w-16 h-16 text-red-500" />
      case 'pending':
        return <Clock className="w-16 h-16 text-yellow-500" />
      default:
        return <AlertCircle className="w-16 h-16 text-gray-500" />
    }
  }

  const getStatusTitle = () => {
    switch (status) {
      case 'success':
        return 'Paiement confirmé !'
      case 'error':
        return 'Paiement échoué'
      case 'pending':
        return 'Paiement en cours'
      default:
        return 'Statut inconnu'
    }
  }

  const getStatusMessage = () => {
    switch (status) {
      case 'success':
        return 'Votre réservation a été confirmée et payée avec succès. Vous recevrez un email de confirmation sous peu.'
      case 'error':
        return error || 'Une erreur est survenue lors du paiement. Veuillez réessayer ou nous contacter.'
      case 'pending':
        return 'Votre paiement est en cours de traitement. Vous recevrez une confirmation par email une fois le paiement validé.'
      default:
        return 'Statut de paiement inconnu.'
    }
  }

  const getStatusColor = () => {
    switch (status) {
      case 'success':
        return 'text-green-500'
      case 'error':
        return 'text-red-500'
      case 'pending':
        return 'text-yellow-500'
      default:
        return 'text-gray-500'
    }
  }

  return (
    <div className="min-h-screen bg-dark-bg py-20">
      <div className="section-container">
        <div className="max-w-2xl mx-auto text-center">
          {/* Icône de statut */}
          <div className="flex justify-center mb-8">
            {getStatusIcon()}
          </div>

          {/* Titre */}
          <h1 className={`text-4xl lg:text-5xl font-bold mb-6 ${getStatusColor()}`}>
            {getStatusTitle()}
          </h1>

          {/* Message */}
          <p className="text-xl text-gray-300 mb-8">
            {getStatusMessage()}
          </p>

          {/* Numéro de réservation */}
          {reservationNumber && (
            <div className="bg-gray-800 rounded-lg p-6 mb-8 border border-gray-700">
              <h3 className="text-lg font-semibold text-white mb-2">Numéro de réservation</h3>
              <p className="text-2xl font-mono text-kaki-400">{reservationNumber}</p>
            </div>
          )}

          {/* Actions */}
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            {status === 'success' && (
              <>
                <Link
                  href="/reservation/success"
                  className="bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg font-medium transition-colors"
                >
                  Voir ma réservation
                </Link>
                <Link
                  href="/"
                  className="bg-kaki-600 hover:bg-kaki-700 text-white px-6 py-3 rounded-lg font-medium transition-colors"
                >
                  Retour à l'accueil
                </Link>
              </>
            )}

            {status === 'error' && (
              <>
                <Link
                  href="/reservation"
                  className="bg-kaki-600 hover:bg-kaki-700 text-white px-6 py-3 rounded-lg font-medium transition-colors"
                >
                  Réessayer
                </Link>
                <Link
                  href="/contact"
                  className="bg-gray-600 hover:bg-gray-700 text-white px-6 py-3 rounded-lg font-medium transition-colors"
                >
                  Nous contacter
                </Link>
              </>
            )}

            {status === 'pending' && (
              <>
                <Link
                  href="/"
                  className="bg-kaki-600 hover:bg-kaki-700 text-white px-6 py-3 rounded-lg font-medium transition-colors"
                >
                  Retour à l'accueil
                </Link>
                <button
                  onClick={() => window.location.reload()}
                  className="bg-gray-600 hover:bg-gray-700 text-white px-6 py-3 rounded-lg font-medium transition-colors"
                >
                  Actualiser
                </button>
              </>
            )}
          </div>

          {/* Informations supplémentaires */}
          <div className="mt-12 text-sm text-gray-500">
            <p>
              Si vous avez des questions concernant votre réservation, 
              n'hésitez pas à nous contacter au{' '}
              <a href="tel:0559123456" className="text-kaki-400 hover:text-kaki-300">
                05 59 12 34 56
              </a>
              {' '}ou par email à{' '}
              <a href="mailto:contact@usilenziu.com" className="text-kaki-400 hover:text-kaki-300">
                contact@usilenziu.com
              </a>
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}

export default function PaymentReturnPage() {
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
      <PaymentReturnContent />
    </Suspense>
  )
}
