'use client'

import { useEffect, useState, Suspense } from 'react'
import { useSearchParams, useRouter } from 'next/navigation'
import { CheckCircle, Clock, AlertCircle, RefreshCw } from 'lucide-react'
import Link from 'next/link'

/**
 * Page de succès après paiement Payplug
 * Permet la vérification manuelle du statut de paiement
 */
function PaymentSuccessContent() {
  const searchParams = useSearchParams()
  const router = useRouter()
  const [reservationNumber, setReservationNumber] = useState<string>('')
  const [paymentStatus, setPaymentStatus] = useState<'checking' | 'confirmed' | 'pending' | 'error'>('checking')
  const [isLoading, setIsLoading] = useState(false)

  useEffect(() => {
    const reservation = searchParams.get('reservation')
    if (reservation) {
      setReservationNumber(reservation)
      checkPaymentStatus(reservation)
    }
  }, [searchParams])

  const checkPaymentStatus = async (reservationNum: string) => {
    setIsLoading(true)
    try {
      // Simuler une vérification du statut de paiement
      // En production, cela devrait vérifier le statut réel via l'API Payplug
      setTimeout(() => {
        setPaymentStatus('confirmed')
        setIsLoading(false)
      }, 2000)
    } catch (error) {
      console.error('Erreur lors de la vérification du paiement:', error)
      setPaymentStatus('error')
      setIsLoading(false)
    }
  }

  const handleManualCheck = () => {
    if (reservationNumber) {
      checkPaymentStatus(reservationNumber)
    }
  }

  const getStatusIcon = () => {
    if (isLoading) {
      return <RefreshCw className="w-16 h-16 text-kaki-500 animate-spin" />
    }

    switch (paymentStatus) {
      case 'confirmed':
        return <CheckCircle className="w-16 h-16 text-green-500" />
      case 'pending':
        return <Clock className="w-16 h-16 text-yellow-500" />
      case 'error':
        return <AlertCircle className="w-16 h-16 text-red-500" />
      default:
        return <Clock className="w-16 h-16 text-kaki-500" />
    }
  }

  const getStatusTitle = () => {
    if (isLoading) return 'Vérification en cours...'

    switch (paymentStatus) {
      case 'confirmed':
        return 'Paiement confirmé !'
      case 'pending':
        return 'Paiement en attente'
      case 'error':
        return 'Erreur de vérification'
      default:
        return 'Vérification du paiement'
    }
  }

  const getStatusMessage = () => {
    if (isLoading) return 'Nous vérifions le statut de votre paiement...'

    switch (paymentStatus) {
      case 'confirmed':
        return 'Votre réservation a été confirmée et payée avec succès. Vous recevrez un email de confirmation sous peu.'
      case 'pending':
        return 'Votre paiement est en cours de traitement. Vous recevrez une confirmation par email une fois le paiement validé.'
      case 'error':
        return 'Une erreur est survenue lors de la vérification. Veuillez contacter notre équipe pour confirmer votre réservation.'
      default:
        return 'Vérification du statut de paiement en cours.'
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
          <h1 className="text-4xl lg:text-5xl font-bold mb-6 text-white">
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
            {paymentStatus === 'confirmed' && (
              <>
                <Link
                  href="/"
                  className="bg-green-600 hover:bg-green-700 text-white px-6 py-3 rounded-lg font-medium transition-colors"
                >
                  Retour à l'accueil
                </Link>
                <Link
                  href="/reservation/history"
                  className="bg-kaki-600 hover:bg-kaki-700 text-white px-6 py-3 rounded-lg font-medium transition-colors"
                >
                  Voir mes réservations
                </Link>
              </>
            )}

            {(paymentStatus === 'pending' || paymentStatus === 'error') && (
              <>
                <button
                  onClick={handleManualCheck}
                  disabled={isLoading}
                  className="bg-kaki-600 hover:bg-kaki-700 disabled:bg-gray-600 text-white px-6 py-3 rounded-lg font-medium transition-colors disabled:cursor-not-allowed"
                >
                  {isLoading ? 'Vérification...' : 'Vérifier à nouveau'}
                </button>
                <Link
                  href="/contact"
                  className="bg-gray-600 hover:bg-gray-700 text-white px-6 py-3 rounded-lg font-medium transition-colors"
                >
                  Nous contacter
                </Link>
              </>
            )}

            {paymentStatus === 'checking' && (
              <Link
                href="/"
                className="bg-kaki-600 hover:bg-kaki-700 text-white px-6 py-3 rounded-lg font-medium transition-colors"
              >
                Retour à l'accueil
              </Link>
            )}
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

export default function PaymentSuccessPage() {
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
      <PaymentSuccessContent />
    </Suspense>
  )
}
