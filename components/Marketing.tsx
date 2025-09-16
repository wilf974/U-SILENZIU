'use client'

import { useEffect } from 'react'
import { useCookieConsent } from '@/hooks/useCookieConsent'

interface MarketingProps {
  children: React.ReactNode
  fallback?: React.ReactNode
}

export default function Marketing({ children, fallback }: MarketingProps) {
  const { canUseMarketing, isLoading } = useCookieConsent()

  // Afficher le fallback si pas de consentement marketing
  if (!isLoading && !canUseMarketing()) {
    return fallback ? <>{fallback}</> : null
  }

  // Afficher le contenu marketing si consentement donné
  if (!isLoading && canUseMarketing()) {
    return <>{children}</>
  }

  // Pendant le chargement, ne rien afficher
  return null
}

// Composant pour les publicités
export function MarketingAd({ adId, fallback }: { adId: string; fallback?: React.ReactNode }) {
  const { canUseMarketing, isLoading } = useCookieConsent()

  useEffect(() => {
    if (isLoading) return

    if (canUseMarketing()) {
      // Initialiser les publicités marketing
      console.log('Initialisation de la publicité marketing:', adId)
      
      // Exemple avec Google AdSense
      // if (typeof window !== 'undefined' && window.adsbygoogle) {
      //   (window.adsbygoogle = window.adsbygoogle || []).push({})
      // }
    }
  }, [canUseMarketing, isLoading, adId])

  if (isLoading) return null

  if (!canUseMarketing()) {
    return fallback ? <>{fallback}</> : null
  }

  return (
    <div className="marketing-ad" data-ad-id={adId}>
      {/* Contenu de la publicité */}
      <div className="text-center p-4 bg-gray-800 rounded-lg">
        <p className="text-gray-400 text-sm">Espace publicitaire</p>
      </div>
    </div>
  )
}
