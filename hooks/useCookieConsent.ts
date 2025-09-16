'use client'

import { useState, useEffect } from 'react'
import { setCookie, getCookie, deleteCookie } from 'cookies-next'

export interface CookiePreferences {
  essential: boolean
  analytics: boolean
  marketing: boolean
}

export type ConsentType = 'essential' | 'analytics' | 'all'

export function useCookieConsent() {
  const [preferences, setPreferences] = useState<CookiePreferences>({
    essential: true,
    analytics: false,
    marketing: false
  })
  const [hasConsent, setHasConsent] = useState<boolean>(false)
  const [isLoading, setIsLoading] = useState<boolean>(true)

  useEffect(() => {
    // Charger les préférences existantes
    const consent = getCookie('cookie-consent')
    const savedPreferences = getCookie('cookie-preferences')
    
    if (consent) {
      setHasConsent(true)
      
      if (savedPreferences) {
        try {
          const parsed = JSON.parse(savedPreferences as string)
          setPreferences(parsed)
        } catch (e) {
          console.error('Erreur lors du chargement des préférences:', e)
        }
      }
    }
    
    setIsLoading(false)
  }, [])

  const saveConsent = (consentType: ConsentType, prefs?: CookiePreferences) => {
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
    
    setPreferences(finalPreferences)
    setHasConsent(true)
  }

  const acceptAll = () => {
    const allPreferences: CookiePreferences = {
      essential: true,
      analytics: true,
      marketing: true
    }
    saveConsent('all', allPreferences)
  }

  const acceptEssential = () => {
    const essentialPreferences: CookiePreferences = {
      essential: true,
      analytics: false,
      marketing: false
    }
    saveConsent('essential', essentialPreferences)
  }

  const updatePreferences = (newPreferences: CookiePreferences) => {
    setPreferences(newPreferences)
  }

  const resetConsent = () => {
    deleteCookie('cookie-consent')
    deleteCookie('cookie-preferences')
    setHasConsent(false)
    setPreferences({
      essential: true,
      analytics: false,
      marketing: false
    })
  }

  const canUseAnalytics = () => {
    return hasConsent && (preferences.analytics || preferences.marketing)
  }

  const canUseMarketing = () => {
    return hasConsent && preferences.marketing
  }

  return {
    preferences,
    hasConsent,
    isLoading,
    saveConsent,
    acceptAll,
    acceptEssential,
    updatePreferences,
    resetConsent,
    canUseAnalytics,
    canUseMarketing
  }
}
