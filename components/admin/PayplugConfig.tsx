'use client'

import { useState, useEffect } from 'react'
import { Save, RefreshCw, Key, Shield, AlertCircle, CheckCircle } from 'lucide-react'

interface PayplugConfig {
  secretKey: string
  publicKey: string
  webhookSecret: string
  mode: 'test' | 'live'
}

interface PayplugConfigProps {
  onClose: () => void
}

/**
 * Composant de configuration Payplug pour l'administration
 */
export default function PayplugConfig({ onClose }: PayplugConfigProps) {
  const [config, setConfig] = useState<PayplugConfig>({
    secretKey: '',
    publicKey: '',
    webhookSecret: '',
    mode: 'test'
  })
  const [loading, setLoading] = useState(false)
  const [saving, setSaving] = useState(false)
  const [message, setMessage] = useState<{ type: 'success' | 'error', text: string } | null>(null)

  /**
   * Charge la configuration actuelle
   */
  const loadConfig = async () => {
    setLoading(true)
    try {
      const response = await fetch('/api/admin/payplug-config')
      const result = await response.json()
      
      if (result.success) {
        setConfig(result.config)
      } else {
        setMessage({ type: 'error', text: result.error || 'Erreur lors du chargement' })
      }
    } catch (error) {
      setMessage({ type: 'error', text: 'Erreur de connexion' })
    } finally {
      setLoading(false)
    }
  }

  /**
   * Sauvegarde la configuration
   */
  const saveConfig = async () => {
    setSaving(true)
    setMessage(null)
    
    try {
      const response = await fetch('/api/admin/payplug-config', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(config)
      })
      
      const result = await response.json()
      
      if (result.success) {
        setMessage({ type: 'success', text: 'Configuration sauvegardée avec succès ! L\'application redémarre...' })
        setTimeout(() => {
          loadConfig() // Recharger pour vérifier
        }, 3000)
      } else {
        setMessage({ type: 'error', text: result.error || 'Erreur lors de la sauvegarde' })
      }
    } catch (error) {
      setMessage({ type: 'error', text: 'Erreur de connexion' })
    } finally {
      setSaving(false)
    }
  }

  /**
   * Teste la configuration Payplug
   */
  const testConfig = async () => {
    setLoading(true)
    try {
      const response = await fetch('/api/payments/create', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          reservationNumber: 'test-config',
          amount: 100, // 1€ en centimes
          currency: 'EUR',
          customer: {
            email: 'test@admin.com',
            first_name: 'Test',
            last_name: 'Admin'
          },
          metadata: { test: true },
          return_url: 'https://example.com/success',
          cancel_url: 'https://example.com/cancel',
          notification_url: 'https://example.com/webhook'
        })
      })
      
      const result = await response.json()
      
      if (result.success) {
        setMessage({ type: 'success', text: 'Configuration Payplug valide ! Test réussi.' })
      } else {
        setMessage({ type: 'error', text: `Configuration invalide: ${result.error}` })
      }
    } catch (error) {
      setMessage({ type: 'error', text: 'Erreur lors du test de configuration' })
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadConfig()
  }, [])

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-gray-800 rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-2xl font-bold text-white flex items-center">
            <Key className="w-6 h-6 mr-2 text-kaki-500" />
            Configuration Payplug
          </h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-white text-2xl"
          >
            ×
          </button>
        </div>

        {message && (
          <div className={`mb-4 p-4 rounded-lg flex items-center ${
            message.type === 'success' 
              ? 'bg-green-900 border border-green-700 text-green-300' 
              : 'bg-red-900 border border-red-700 text-red-300'
          }`}>
            {message.type === 'success' ? (
              <CheckCircle className="w-5 h-5 mr-2" />
            ) : (
              <AlertCircle className="w-5 h-5 mr-2" />
            )}
            {message.text}
          </div>
        )}

        <div className="space-y-6">
          {/* Mode de fonctionnement */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Mode de fonctionnement
            </label>
            <div className="flex space-x-4">
              <label className="flex items-center">
                <input
                  type="radio"
                  name="mode"
                  value="test"
                  checked={config.mode === 'test'}
                  onChange={(e) => setConfig({ ...config, mode: e.target.value as 'test' | 'live' })}
                  className="mr-2 text-kaki-500"
                />
                <span className="text-white">Test (recommandé pour commencer)</span>
              </label>
              <label className="flex items-center">
                <input
                  type="radio"
                  name="mode"
                  value="live"
                  checked={config.mode === 'live'}
                  onChange={(e) => setConfig({ ...config, mode: e.target.value as 'test' | 'live' })}
                  className="mr-2 text-kaki-500"
                />
                <span className="text-white">Live (production)</span>
              </label>
            </div>
          </div>

          {/* Clé secrète */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Clé secrète <span className="text-red-400">*</span>
            </label>
            <input
              type="password"
              value={config.secretKey}
              onChange={(e) => setConfig({ ...config, secretKey: e.target.value })}
              placeholder="sk_test_... ou sk_live_..."
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-kaki-500"
            />
            <p className="text-xs text-gray-400 mt-1">
              Clé secrète Payplug (obligatoire)
            </p>
          </div>

          {/* Clé publique */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Clé publique
            </label>
            <input
              type="password"
              value={config.publicKey}
              onChange={(e) => setConfig({ ...config, publicKey: e.target.value })}
              placeholder="pk_test_... ou pk_live_..."
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-kaki-500"
            />
            <p className="text-xs text-gray-400 mt-1">
              Clé publique Payplug (optionnelle en mode test)
            </p>
          </div>

          {/* Secret webhook */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Secret webhook
            </label>
            <input
              type="password"
              value={config.webhookSecret}
              onChange={(e) => setConfig({ ...config, webhookSecret: e.target.value })}
              placeholder="whsec_..."
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-kaki-500"
            />
            <p className="text-xs text-gray-400 mt-1">
              Secret pour vérifier les webhooks Payplug (optionnel en mode test)
            </p>
          </div>

          {/* URL webhook */}
          <div className="bg-gray-700 p-4 rounded-lg">
            <h3 className="text-sm font-medium text-gray-300 mb-2 flex items-center">
              <Shield className="w-4 h-4 mr-2" />
              URL du webhook Payplug
            </h3>
            <code className="text-sm text-kaki-300 break-all">
              https://rageroom.usilenziu.com/api/webhooks/payplug
            </code>
            <p className="text-xs text-gray-400 mt-2">
              Configurez cette URL dans votre compte Payplug pour recevoir les notifications de paiement
            </p>
          </div>
        </div>

        {/* Boutons d'action */}
        <div className="flex justify-between mt-8">
          <div className="flex space-x-3">
            <button
              onClick={loadConfig}
              disabled={loading}
              className="btn-kaki-outline flex items-center"
            >
              <RefreshCw className={`w-4 h-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
              Actualiser
            </button>
            <button
              onClick={testConfig}
              disabled={loading || !config.secretKey}
              className="btn-kaki-outline flex items-center"
            >
              <CheckCircle className="w-4 h-4 mr-2" />
              Tester
            </button>
          </div>
          <div className="flex space-x-3">
            <button
              onClick={onClose}
              className="btn-gray-outline"
            >
              Annuler
            </button>
            <button
              onClick={saveConfig}
              disabled={saving || !config.secretKey}
              className="btn-kaki flex items-center"
            >
              <Save className={`w-4 h-4 mr-2 ${saving ? 'animate-spin' : ''}`} />
              {saving ? 'Sauvegarde...' : 'Sauvegarder'}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
