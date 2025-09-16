'use client'

import { useState } from 'react'
import { useCookieConsent } from '@/hooks/useCookieConsent'
import { Shield, CheckCircle, XCircle, AlertTriangle } from 'lucide-react'

export default function GDPRTest() {
  const { preferences, hasConsent, canUseAnalytics, canUseMarketing } = useCookieConsent()
  const [showDetails, setShowDetails] = useState(false)

  const tests = [
    {
      name: 'Consentement aux cookies',
      status: hasConsent ? 'success' : 'error',
      description: 'L\'utilisateur doit donner son consentement avant l\'utilisation de cookies non essentiels',
      details: hasConsent ? 'Consentement enregistré' : 'Aucun consentement détecté'
    },
    {
      name: 'Cookies essentiels',
      status: preferences.essential ? 'success' : 'error',
      description: 'Les cookies essentiels doivent toujours être activés',
      details: preferences.essential ? 'Activés' : 'Désactivés'
    },
    {
      name: 'Analytics conditionnels',
      status: canUseAnalytics() ? 'success' : 'warning',
      description: 'Les analytics ne doivent être chargés qu\'avec consentement',
      details: canUseAnalytics() ? 'Analytics autorisés' : 'Analytics bloqués'
    },
    {
      name: 'Marketing conditionnel',
      status: canUseMarketing() ? 'success' : 'warning',
      description: 'Le marketing ne doit être chargé qu\'avec consentement',
      details: canUseMarketing() ? 'Marketing autorisé' : 'Marketing bloqué'
    }
  ]

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'success':
        return <CheckCircle className="text-green-500" size={20} />
      case 'error':
        return <XCircle className="text-red-500" size={20} />
      case 'warning':
        return <AlertTriangle className="text-yellow-500" size={20} />
      default:
        return <AlertTriangle className="text-gray-500" size={20} />
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'success':
        return 'border-green-500 bg-green-500/10'
      case 'error':
        return 'border-red-500 bg-red-500/10'
      case 'warning':
        return 'border-yellow-500 bg-yellow-500/10'
      default:
        return 'border-gray-500 bg-gray-500/10'
    }
  }

  return (
    <div className="fixed top-4 right-4 z-50">
      <div className="bg-dark-surface border border-kaki-800/30 rounded-lg p-4 max-w-sm">
        <div className="flex items-center space-x-2 mb-4">
          <Shield className="text-kaki-500" size={20} />
          <h3 className="text-lg font-semibold text-white">Test RGPD</h3>
          <button
            onClick={() => setShowDetails(!showDetails)}
            className="ml-auto text-kaki-400 hover:text-kaki-300 text-sm"
          >
            {showDetails ? 'Masquer' : 'Détails'}
          </button>
        </div>

        <div className="space-y-3">
          {tests.map((test, index) => (
            <div
              key={index}
              className={`border rounded-lg p-3 ${getStatusColor(test.status)}`}
            >
              <div className="flex items-center space-x-2">
                {getStatusIcon(test.status)}
                <span className="text-white font-medium">{test.name}</span>
              </div>
              
              {showDetails && (
                <div className="mt-2 text-sm">
                  <p className="text-gray-300 mb-1">{test.description}</p>
                  <p className="text-gray-400">{test.details}</p>
                </div>
              )}
            </div>
          ))}
        </div>

        <div className="mt-4 pt-4 border-t border-kaki-800/30">
          <p className="text-xs text-gray-400">
            Ce composant est à retirer en production. Il sert uniquement à tester la conformité RGPD.
          </p>
        </div>
      </div>
    </div>
  )
}
