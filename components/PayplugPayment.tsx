'use client'

import { useState, useEffect } from 'react'
import { CreditCard, Loader2, CheckCircle, XCircle, AlertCircle } from 'lucide-react'

interface PayplugPaymentProps {
  reservationData: {
    reservationNumber: string
    customerName: string
    customerEmail: string
    amount: number
    roomName: string
    date: string
    timeSlot: string
    participants: number
  }
  onPaymentSuccess: (paymentId: string) => void
  onPaymentError: (error: string) => void
  onCancel: () => void
}

type PaymentStatus = 'idle' | 'loading' | 'redirecting' | 'success' | 'error'

/**
 * Composant de paiement Payplug
 * Gère la création et redirection vers le paiement hébergé
 */
export default function PayplugPayment({ 
  reservationData, 
  onPaymentSuccess, 
  onPaymentError, 
  onCancel 
}: PayplugPaymentProps) {
  const [status, setStatus] = useState<PaymentStatus>('idle')
  const [error, setError] = useState<string | null>(null)

  /**
   * Crée le paiement et redirige vers Payplug
   */
  const handlePayment = async () => {
    setStatus('loading')
    setError(null)

    try {
      const response = await fetch('/api/payments/create', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          reservationNumber: reservationData.reservationNumber,
          amount: reservationData.amount,
          customer: {
            email: reservationData.customerEmail,
            first_name: reservationData.customerName.split(' ')[0] || '',
            last_name: reservationData.customerName.split(' ').slice(1).join(' ') || ''
          },
          order: `Réservation ${reservationData.reservationNumber}`,
          custom_data: {
            room_name: reservationData.roomName,
            date: reservationData.date,
            time_slot: reservationData.timeSlot,
            participants: reservationData.participants
          }
        })
      })

      const result = await response.json()

      if (!response.ok) {
        throw new Error(result.error || 'Erreur lors de la création du paiement')
      }

      if (result.success && result.payment_url) {
        setStatus('redirecting')
        
        // Redirection vers Payplug
        window.location.href = result.payment_url
      } else {
        throw new Error(result.error || 'Erreur inconnue')
      }
    } catch (error) {
      console.error('Erreur lors de la création du paiement:', error)
      setError(error instanceof Error ? error.message : 'Erreur inconnue')
      setStatus('error')
      onPaymentError(error instanceof Error ? error.message : 'Erreur inconnue')
    }
  }

  /**
   * Vérifie le statut du paiement depuis l'URL
   */
  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search)
    const paymentStatus = urlParams.get('payment_status')
    const paymentId = urlParams.get('payment_id')

    if (paymentStatus === 'success' && paymentId) {
      setStatus('success')
      onPaymentSuccess(paymentId)
    } else if (paymentStatus === 'error') {
      setStatus('error')
      setError('Le paiement a échoué')
      onPaymentError('Le paiement a échoué')
    }
  }, [onPaymentSuccess, onPaymentError])

  const getStatusIcon = () => {
    switch (status) {
      case 'loading':
      case 'redirecting':
        return <Loader2 className="w-6 h-6 animate-spin text-kaki-500" />
      case 'success':
        return <CheckCircle className="w-6 h-6 text-green-500" />
      case 'error':
        return <XCircle className="w-6 h-6 text-red-500" />
      default:
        return <CreditCard className="w-6 h-6 text-kaki-500" />
    }
  }

  const getStatusText = () => {
    switch (status) {
      case 'loading':
        return 'Préparation du paiement...'
      case 'redirecting':
        return 'Redirection vers Payplug...'
      case 'success':
        return 'Paiement confirmé !'
      case 'error':
        return 'Erreur de paiement'
      default:
        return 'Paiement sécurisé'
    }
  }

  const getStatusColor = () => {
    switch (status) {
      case 'loading':
      case 'redirecting':
        return 'text-kaki-500'
      case 'success':
        return 'text-green-500'
      case 'error':
        return 'text-red-500'
      default:
        return 'text-gray-300'
    }
  }

  return (
    <div className="max-w-md mx-auto bg-gray-800 rounded-lg p-6 border border-gray-700">
      {/* En-tête */}
      <div className="text-center mb-6">
        <div className="flex justify-center mb-4">
          {getStatusIcon()}
        </div>
        <h3 className="text-xl font-semibold text-white mb-2">
          {getStatusText()}
        </h3>
        <p className={`text-sm ${getStatusColor()}`}>
          {status === 'idle' && 'Cliquez sur le bouton ci-dessous pour procéder au paiement sécurisé'}
          {status === 'loading' && 'Veuillez patienter...'}
          {status === 'redirecting' && 'Vous allez être redirigé vers Payplug...'}
          {status === 'success' && 'Votre réservation est confirmée !'}
          {status === 'error' && 'Une erreur est survenue lors du paiement'}
        </p>
      </div>

      {/* Détails de la réservation */}
      <div className="bg-gray-700 rounded-lg p-4 mb-6">
        <h4 className="text-white font-medium mb-3">Détails de la réservation</h4>
        <div className="space-y-2 text-sm">
          <div className="flex justify-between">
            <span className="text-gray-400">N° Réservation:</span>
            <span className="text-white font-mono">{reservationData.reservationNumber}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-400">Salle:</span>
            <span className="text-white">{reservationData.roomName}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-400">Date:</span>
            <span className="text-white">{reservationData.date}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-400">Horaire:</span>
            <span className="text-white">{reservationData.timeSlot}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-400">Participants:</span>
            <span className="text-white">{reservationData.participants}</span>
          </div>
          <div className="flex justify-between border-t border-gray-600 pt-2">
            <span className="text-gray-400 font-medium">Total:</span>
            <span className="text-kaki-400 font-bold text-lg">{reservationData.amount}€</span>
          </div>
        </div>
      </div>

      {/* Message d'erreur */}
      {error && (
        <div className="bg-red-900/20 border border-red-500/50 rounded-lg p-4 mb-6">
          <div className="flex items-center gap-2">
            <AlertCircle className="w-5 h-5 text-red-500 flex-shrink-0" />
            <p className="text-red-300 text-sm">{error}</p>
          </div>
        </div>
      )}

      {/* Boutons d'action */}
      <div className="flex gap-3">
        {status === 'idle' && (
          <>
            <button
              onClick={handlePayment}
              className="flex-1 bg-kaki-600 hover:bg-kaki-700 text-white px-4 py-3 rounded-lg font-medium transition-colors flex items-center justify-center gap-2"
            >
              <CreditCard className="w-5 h-5" />
              Payer maintenant
            </button>
            <button
              onClick={onCancel}
              className="px-4 py-3 border border-gray-600 text-gray-300 hover:bg-gray-700 rounded-lg transition-colors"
            >
              Annuler
            </button>
          </>
        )}

        {status === 'error' && (
          <>
            <button
              onClick={handlePayment}
              className="flex-1 bg-kaki-600 hover:bg-kaki-700 text-white px-4 py-3 rounded-lg font-medium transition-colors flex items-center justify-center gap-2"
            >
              <CreditCard className="w-5 h-5" />
              Réessayer
            </button>
            <button
              onClick={onCancel}
              className="px-4 py-3 border border-gray-600 text-gray-300 hover:bg-gray-700 rounded-lg transition-colors"
            >
              Annuler
            </button>
          </>
        )}

        {status === 'success' && (
          <button
            onClick={() => window.location.href = '/reservation/success'}
            className="w-full bg-green-600 hover:bg-green-700 text-white px-4 py-3 rounded-lg font-medium transition-colors flex items-center justify-center gap-2"
          >
            <CheckCircle className="w-5 h-5" />
            Voir ma réservation
          </button>
        )}

        {(status === 'loading' || status === 'redirecting') && (
          <div className="w-full flex items-center justify-center py-3">
            <Loader2 className="w-6 h-6 animate-spin text-kaki-500" />
          </div>
        )}
      </div>

      {/* Informations de sécurité */}
      <div className="mt-6 text-center">
        <p className="text-xs text-gray-500">
          Paiement sécurisé par Payplug • 
          <span className="text-green-400">🔒</span> SSL • 
          <span className="text-blue-400">💳</span> Cartes acceptées
        </p>
      </div>
    </div>
  )
}
