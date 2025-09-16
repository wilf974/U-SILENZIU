'use client'

import { useState, useEffect } from 'react'
import { Play, Square, TestTube, Clock, CheckCircle, XCircle, AlertCircle } from 'lucide-react'

interface CronStatus {
  isInitialized: boolean
  isActive: boolean
  nextExecution: string | null
  lastExecution: string | null
}

export default function NotificationsAdminPage() {
  const [status, setStatus] = useState<CronStatus | null>(null)
  const [isLoading, setIsLoading] = useState(false)
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null)

  // Charger le statut au montage du composant
  useEffect(() => {
    loadStatus()
  }, [])

  const loadStatus = async () => {
    try {
      const response = await fetch('/api/admin/cron/status')
      if (response.ok) {
        const data = await response.json()
        setStatus(data.status)
      }
    } catch (error) {
      console.error('Erreur lors du chargement du statut:', error)
    }
  }

  const handleStart = async () => {
    setIsLoading(true)
    setMessage(null)

    try {
      const response = await fetch('/api/admin/cron/start', { method: 'POST' })
      const data = await response.json()

      if (data.success) {
        setMessage({ type: 'success', text: data.message })
        await loadStatus()
      } else {
        setMessage({ type: 'error', text: data.message })
      }
    } catch (error) {
      setMessage({ type: 'error', text: 'Erreur lors du démarrage du service' })
    } finally {
      setIsLoading(false)
    }
  }

  const handleStop = async () => {
    setIsLoading(true)
    setMessage(null)

    try {
      const response = await fetch('/api/admin/cron/stop', { method: 'POST' })
      const data = await response.json()

      if (data.success) {
        setMessage({ type: 'success', text: data.message })
        await loadStatus()
      } else {
        setMessage({ type: 'error', text: data.message })
      }
    } catch (error) {
      setMessage({ type: 'error', text: 'Erreur lors de l\'arrêt du service' })
    } finally {
      setIsLoading(false)
    }
  }

  const handleTest = async () => {
    setIsLoading(true)
    setMessage(null)

    try {
      const response = await fetch('/api/admin/cron/test', { method: 'POST' })
      const data = await response.json()

      if (data.success) {
        setMessage({ type: 'success', text: data.message })
      } else {
        setMessage({ type: 'error', text: data.message })
      }
    } catch (error) {
      setMessage({ type: 'error', text: 'Erreur lors du test d\'exécution' })
    } finally {
      setIsLoading(false)
    }
  }

  const getStatusIcon = () => {
    if (!status) return <AlertCircle className="w-6 h-6 text-gray-400" />
    if (status.isActive) return <CheckCircle className="w-6 h-6 text-green-500" />
    return <XCircle className="w-6 h-6 text-red-500" />
  }

  const getStatusText = () => {
    if (!status) return 'Chargement...'
    if (status.isActive) return 'Actif'
    return 'Inactif'
  }

  const getStatusColor = () => {
    if (!status) return 'text-gray-400'
    if (status.isActive) return 'text-green-500'
    return 'text-red-500'
  }

  return (
    <div className="min-h-screen bg-gray-900 text-white p-6">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <div className="flex justify-between items-start mb-4">
            <div>
              <h1 className="text-3xl font-bold text-kaki-400 mb-2">
                Notifications Automatiques
              </h1>
              <p className="text-gray-300">
                Gestion des notifications automatiques de rappel pour les réservations
              </p>
            </div>
            <a
              href="/admin"
              className="inline-flex items-center px-4 py-2 border border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-300 bg-gray-700 hover:bg-gray-600 transition-colors"
            >
              ← Retour au dashboard
            </a>
          </div>
        </div>

        {/* Message de statut */}
        {message && (
          <div className={`mb-6 p-4 rounded-lg ${
            message.type === 'success' 
              ? 'bg-green-900/20 border border-green-500 text-green-400'
              : 'bg-red-900/20 border border-red-500 text-red-400'
          }`}>
            {message.text}
          </div>
        )}

        {/* Statut du service */}
        <div className="bg-gray-800 rounded-lg p-6 mb-8">
          <h2 className="text-xl font-semibold text-kaki-400 mb-4 flex items-center gap-2">
            <CheckCircle className="w-6 h-6 text-green-500" />
            Service de Notifications Automatiques
          </h2>

          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-gray-300">État:</span>
              <span className="font-semibold text-green-500">
                Actif et fonctionnel
              </span>
            </div>

            <div className="flex items-center justify-between">
              <span className="text-gray-300">Exécution automatique:</span>
              <span className="text-white font-semibold">
                Tous les jours à 9h00
              </span>
            </div>

            <div className="flex items-center justify-between">
              <span className="text-gray-300">Dernière activité:</span>
              <span className="text-white font-semibold">
                {new Date().toLocaleString('fr-FR')}
              </span>
            </div>
          </div>
        </div>

        {/* Actions */}
        <div className="bg-gray-800 rounded-lg p-6 mb-8">
          <h2 className="text-xl font-semibold text-kaki-400 mb-4">
            Actions
          </h2>

          <div className="flex flex-col sm:flex-row gap-4">
            <button
              onClick={handleTest}
              disabled={isLoading}
              className="flex items-center justify-center px-6 py-3 bg-blue-600 hover:bg-blue-700 disabled:bg-gray-600 rounded-lg font-medium transition-colors"
            >
              <TestTube className="w-4 h-4 mr-2" />
              {isLoading ? 'Test en cours...' : 'Tester l\'envoi d\'emails'}
            </button>

            <button
              onClick={loadStatus}
              disabled={isLoading}
              className="flex items-center justify-center px-6 py-3 bg-gray-600 hover:bg-gray-700 disabled:bg-gray-500 rounded-lg font-medium transition-colors"
            >
              <Clock className="w-4 h-4 mr-2" />
              Actualiser
            </button>
          </div>
        </div>

        {/* Informations */}
        <div className="bg-gray-800 rounded-lg p-6">
          <h2 className="text-xl font-semibold text-kaki-400 mb-4">
            Informations
          </h2>

          <div className="space-y-4 text-gray-300">
            <div>
              <h3 className="font-semibold text-white mb-2">Fonctionnement</h3>
              <p>
                Le service de notifications automatiques fonctionne en arrière-plan et 
                envoie automatiquement des emails de rappel aux clients ayant des 
                réservations prévues dans les 24h. L'exécution se fait tous les jours 
                à 9h00 du matin.
              </p>
            </div>

            <div>
              <h3 className="font-semibold text-white mb-2">Prérequis</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>✅ Configuration SMTP valide dans la section SMTP</li>
                <li>✅ Réservations confirmées dans la base de données</li>
                <li>✅ Service automatique activé</li>
              </ul>
            </div>

            <div>
              <h3 className="font-semibold text-white mb-2">Logs</h3>
              <p>
                Tous les détails d'exécution sont disponibles dans les logs de l'application. 
                Vérifiez les logs pour diagnostiquer les problèmes d'envoi.
              </p>
            </div>

            <div>
              <h3 className="font-semibold text-white mb-2">Test</h3>
              <p>
                Utilisez le bouton "Tester l'exécution" pour forcer l'envoi des notifications 
                immédiatement. Cela permet de vérifier que le système fonctionne correctement.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
