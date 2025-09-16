'use client'

import { useEffect } from 'react'
import { useCookieConsent } from '@/hooks/useCookieConsent'

interface AnalyticsProps {
  trackingId?: string
}

export default function Analytics({ trackingId }: AnalyticsProps) {
  const { canUseAnalytics, isLoading } = useCookieConsent()

  useEffect(() => {
    // Attendre que le consentement soit chargé
    if (isLoading) return

    // Vérifier si l'utilisateur a donné son consentement pour les analytics
    if (!canUseAnalytics()) {
      console.log('Analytics désactivés - consentement non donné')
      return
    }

    // Ici vous pouvez initialiser vos analytics (Google Analytics, Plausible, etc.)
    if (trackingId) {
      console.log('Initialisation des analytics avec ID:', trackingId)
      
      // Exemple avec Google Analytics 4
      // if (typeof window !== 'undefined' && window.gtag) {
      //   window.gtag('config', trackingId, {
      //     page_title: document.title,
      //     page_location: window.location.href,
      //   })
      // }
    }
  }, [canUseAnalytics, isLoading, trackingId])

  // Ne rien rendre si pas de consentement ou en cours de chargement
  if (isLoading || !canUseAnalytics()) {
    return null
  }

  return null
}
