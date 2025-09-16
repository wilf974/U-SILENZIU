'use client'

import { useState, useEffect } from 'react'
import { X, Settings, Shield } from 'lucide-react'
import { setCookie, getCookie, deleteCookie } from 'cookies-next'

const CookieConsent = () => {
  const [showBanner, setShowBanner] = useState(false)
  const [showSettings, setShowSettings] = useState(false)
  const [preferences, setPreferences] = useState({
    essential: true,
    analytics: false,
    marketing: false
  })

  useEffect(() => {
    // Vérifier si le consentement a déjà été donné
    const consent = getCookie('cookie-consent')
    if (!consent) {
      setShowBanner(true)
    } else {
      // Charger les préférences existantes
      const savedPreferences = getCookie('cookie-preferences')
      if (savedPreferences) {
        try {
          const parsed = JSON.parse(savedPreferences as string)
          setPreferences(parsed)
        } catch (e) {
          console.error('Erreur lors du chargement des préférences:', e)
        }
      }
    }
  }, [])

  const saveConsent = (consentType: string, prefs?: typeof preferences) => {
    const finalPreferences = prefs || preferences
    
    // Sauvegarder le type de consentement
    setCookie('cookie-consent', consentType, {
      maxAge: 365 * 24 * 60 * 60, // 1 an
      path: '/',
      sameSite: 'lax'
    })
    
    // Sauvegarder les préférences détaillées
    setCookie('cookie-preferences', JSON.stringify(finalPreferences), {
      maxAge: 365 * 24 * 60 * 60, // 1 an
      path: '/',
      sameSite: 'lax'
    })
    
    setShowBanner(false)
    setShowSettings(false)
  }

  const acceptAll = () => {
    const allPreferences = {
      essential: true,
      analytics: true,
      marketing: true
    }
    setPreferences(allPreferences)
    saveConsent('all', allPreferences)
  }

  const acceptEssential = () => {
    const essentialPreferences = {
      essential: true,
      analytics: false,
      marketing: false
    }
    setPreferences(essentialPreferences)
    saveConsent('essential', essentialPreferences)
  }

  const openSettings = () => {
    setShowSettings(true)
  }

  const closeSettings = () => {
    setShowSettings(false)
  }

  const handlePreferenceChange = (type: keyof typeof preferences) => {
    setPreferences(prev => ({
      ...prev,
      [type]: !prev[type]
    }))
  }

  const savePreferences = () => {
    const consentType = preferences.analytics && preferences.marketing ? 'all' 
      : preferences.analytics ? 'analytics' 
      : 'essential'
    saveConsent(consentType, preferences)
  }

  if (!showBanner && !showSettings) return null

  return (
    <>
      {/* Bannière principale */}
      {showBanner && (
        <div className="fixed bottom-0 left-0 right-0 bg-dark-surface border-t border-kaki-800/30 p-4 z-50">
          <div className="section-container">
            <div className="flex flex-col lg:flex-row items-start lg:items-center justify-between gap-4">
              <div className="flex items-start space-x-3">
                <Shield className="text-kaki-500 mt-1 flex-shrink-0" size={20} />
                <div className="text-sm text-gray-300">
                  <p className="mb-2">
                    Nous utilisons des cookies pour améliorer votre expérience sur notre site. 
                    En continuant à naviguer, vous acceptez notre utilisation des cookies.
                  </p>
                  <p className="text-xs text-gray-400">
                    Pour plus d'informations, consultez notre{' '}
                    <a href="/politique-confidentialite" className="text-kaki-400 hover:text-kaki-300 underline">
                      politique de confidentialité
                    </a>
                  </p>
                </div>
              </div>
              
              <div className="flex flex-col sm:flex-row gap-2 w-full lg:w-auto">
                <button
                  onClick={openSettings}
                  className="btn-kaki-outline text-sm px-4 py-2"
                >
                  <Settings className="mr-2" size={16} />
                  Personnaliser
                </button>
                <button
                  onClick={acceptEssential}
                  className="btn-kaki-outline text-sm px-4 py-2"
                >
                  Cookies essentiels uniquement
                </button>
                <button
                  onClick={acceptAll}
                  className="btn-kaki text-sm px-4 py-2"
                >
                  Accepter tous les cookies
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Modal des paramètres */}
      {showSettings && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-dark-surface border border-kaki-800/30 rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-2xl font-bold text-white flex items-center">
                  <Settings className="text-kaki-500 mr-3" size={24} />
                  Paramètres des cookies
                </h2>
                <button
                  onClick={closeSettings}
                  className="text-gray-400 hover:text-white transition-colors"
                >
                  <X size={24} />
                </button>
              </div>

              <div className="space-y-6">
                {/* Cookies essentiels */}
                <div className="border border-kaki-800/30 rounded-lg p-4">
                  <div className="flex items-center justify-between mb-3">
                    <div>
                      <h3 className="text-lg font-semibold text-white">Cookies essentiels</h3>
                      <p className="text-sm text-gray-400">Nécessaires au fonctionnement du site</p>
                    </div>
                    <div className="flex items-center">
                      <input
                        type="checkbox"
                        checked={preferences.essential}
                        disabled
                        className="w-4 h-4 text-kaki-600 bg-dark-bg border-kaki-600 rounded focus:ring-kaki-500"
                      />
                    </div>
                  </div>
                  <p className="text-sm text-gray-300">
                    Ces cookies sont nécessaires au bon fonctionnement du site web. Ils incluent les cookies de session 
                    et les cookies de sécurité. Ils ne peuvent pas être désactivés.
                  </p>
                </div>

                {/* Cookies analytiques */}
                <div className="border border-kaki-800/30 rounded-lg p-4">
                  <div className="flex items-center justify-between mb-3">
                    <div>
                      <h3 className="text-lg font-semibold text-white">Cookies analytiques</h3>
                      <p className="text-sm text-gray-400">Nous aident à améliorer le site</p>
                    </div>
                    <div className="flex items-center">
                      <input
                        type="checkbox"
                        checked={preferences.analytics}
                        onChange={() => handlePreferenceChange('analytics')}
                        className="w-4 h-4 text-kaki-600 bg-dark-bg border-kaki-600 rounded focus:ring-kaki-500"
                      />
                    </div>
                  </div>
                  <p className="text-sm text-gray-300">
                    Ces cookies nous permettent de mesurer le trafic et d'analyser la façon dont vous utilisez notre site 
                    pour améliorer nos services.
                  </p>
                </div>

                {/* Cookies marketing */}
                <div className="border border-kaki-800/30 rounded-lg p-4">
                  <div className="flex items-center justify-between mb-3">
                    <div>
                      <h3 className="text-lg font-semibold text-white">Cookies marketing</h3>
                      <p className="text-sm text-gray-400">Pour des publicités personnalisées</p>
                    </div>
                    <div className="flex items-center">
                      <input
                        type="checkbox"
                        checked={preferences.marketing}
                        onChange={() => handlePreferenceChange('marketing')}
                        className="w-4 h-4 text-kaki-600 bg-dark-bg border-kaki-600 rounded focus:ring-kaki-500"
                      />
                    </div>
                  </div>
                  <p className="text-sm text-gray-300">
                    Ces cookies sont utilisés pour vous proposer des contenus et publicités adaptés à vos centres d'intérêt.
                  </p>
                </div>
              </div>

              <div className="flex flex-col sm:flex-row gap-3 mt-8">
                <button
                  onClick={savePreferences}
                  className="btn-kaki flex-1"
                >
                  Enregistrer mes préférences
                </button>
                <button
                  onClick={closeSettings}
                  className="btn-kaki-outline flex-1"
                >
                  Annuler
                </button>
              </div>

              <p className="text-xs text-gray-400 mt-4 text-center">
                Vous pouvez modifier vos préférences à tout moment en cliquant sur "Paramètres des cookies" 
                dans le pied de page de notre site.
              </p>
            </div>
          </div>
        </div>
      )}
    </>
  )
}

export default CookieConsent
