'use client'

import { useEffect } from 'react'

export default function CronInitializer() {
  useEffect(() => {
    // Initialiser le service CRON au démarrage de l'application
    const initializeCron = () => {
      fetch('/api/admin/cron/start', { method: 'POST' })
        .then(response => {
          if (response.ok) {
            console.log('Service CRON initialisé')
          } else {
            console.log('Service CRON non initialisé')
          }
        })
        .catch(error => {
          console.log('Erreur CRON:', error)
        })
    }

    // Initialiser après un délai pour laisser l'application se charger
    const timer = setTimeout(initializeCron, 5000)
    
    return () => {
      if (timer) clearTimeout(timer)
    }
  }, [])

  // Ce composant ne rend rien visuellement
  return null
}
