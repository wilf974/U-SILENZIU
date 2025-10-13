'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { Clock, Save, RefreshCw, Check, X } from 'lucide-react'
import { useAuth } from '@/hooks/useAuth'

interface OpeningHoursConfig {
  id?: string
  opening_hours_monday?: string
  opening_hours_tuesday?: string
  opening_hours_wednesday?: string
  opening_hours_thursday?: string
  opening_hours_friday?: string
  opening_hours_saturday?: string
  opening_hours_sunday?: string
}

const daysOfWeek = [
  { key: 'monday', label: 'Lundi', field: 'opening_hours_monday' },
  { key: 'tuesday', label: 'Mardi', field: 'opening_hours_tuesday' },
  { key: 'wednesday', label: 'Mercredi', field: 'opening_hours_wednesday' },
  { key: 'thursday', label: 'Jeudi', field: 'opening_hours_thursday' },
  { key: 'friday', label: 'Vendredi', field: 'opening_hours_friday' },
  { key: 'saturday', label: 'Samedi', field: 'opening_hours_saturday' },
  { key: 'sunday', label: 'Dimanche', field: 'opening_hours_sunday' }
]

export default function OpeningHoursAdminPage() {
  const router = useRouter()
  const { isAuthenticated, loading: authLoading, requireAuth } = useAuth()
  
  const [config, setConfig] = useState<OpeningHoursConfig>({})
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)

  useEffect(() => {
    requireAuth()
    if (isAuthenticated) {
      fetchOpeningHours()
    }
  }, [isAuthenticated, requireAuth])

  /**
   * Récupère la configuration actuelle des horaires d'ouverture
   */
  const fetchOpeningHours = async () => {
    try {
      setLoading(true)
      setError(null)

      const response = await fetch('/api/footer-config')
      const result = await response.json()

      if (result.success && result.data) {
        setConfig(result.data)
      } else {
        setError('Erreur lors du chargement de la configuration')
      }
    } catch (err) {
      console.error('Erreur lors de la récupération des horaires:', err)
      setError('Erreur de connexion')
    } finally {
      setLoading(false)
    }
  }

  /**
   * Sauvegarde la configuration des horaires d'ouverture
   */
  const saveOpeningHours = async () => {
    try {
      setSaving(true)
      setError(null)
      setSuccess(null)

      const response = await fetch('/api/footer-config', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(config),
      })

      const result = await response.json()

      if (result.success) {
        setSuccess('Horaires d\'ouverture mis à jour avec succès !')
        setTimeout(() => setSuccess(null), 3000)
      } else {
        setError(result.error || 'Erreur lors de la sauvegarde')
      }
    } catch (err) {
      console.error('Erreur lors de la sauvegarde:', err)
      setError('Erreur de connexion')
    } finally {
      setSaving(false)
    }
  }

  /**
   * Met à jour la valeur d'un jour
   */
  const updateDayHours = (field: string, value: string) => {
    setConfig(prev => ({
      ...prev,
      [field]: value
    }))
  }

  /**
   * Formate les horaires pour l'affichage dans le bandeau
   */
  const getFormattedPreview = () => {
    const groups: Array<{ days: string; hours: string }> = []
    
    // Vérifier si tous les jours de la semaine (lundi-samedi) ont les mêmes horaires
    const weekdays = [
      config.opening_hours_monday,
      config.opening_hours_tuesday,
      config.opening_hours_wednesday,
      config.opening_hours_thursday,
      config.opening_hours_friday,
      config.opening_hours_saturday
    ]
    
    const allWeekdaysSame = weekdays.every(hours => 
      hours && 
      !hours.includes('Fermé') && 
      !hours.includes('réservation') && 
      hours === weekdays[0]
    )
    
    if (allWeekdaysSame && config.opening_hours_monday) {
      // Tous les jours de la semaine ont les mêmes horaires
      groups.push({
        days: 'Lundi-Samedi',
        hours: config.opening_hours_monday.replace(/(\d{1,2}):(\d{2})/g, '$1h$2').replace(':00', 'h')
      })
    } else {
      // Horaires différents, grouper intelligemment
      
      // Lundi (si ouvert et différent)
      const mondayHours = config.opening_hours_monday
      if (mondayHours && !mondayHours.includes('Fermé') && !mondayHours.includes('réservation')) {
        groups.push({
          days: 'Lundi',
          hours: mondayHours.replace(/(\d{1,2}):(\d{2})/g, '$1h$2').replace(':00', 'h')
        })
      }
      
      // Mardi au Jeudi
      const tuesdayHours = config.opening_hours_tuesday
      const wednesdayHours = config.opening_hours_wednesday
      const thursdayHours = config.opening_hours_thursday
      
      if (tuesdayHours && wednesdayHours && thursdayHours &&
          tuesdayHours === wednesdayHours && wednesdayHours === thursdayHours &&
          !tuesdayHours.includes('Fermé') && !tuesdayHours.includes('réservation')) {
        groups.push({
          days: 'Mardi-Jeudi',
          hours: tuesdayHours.replace(/(\d{1,2}):(\d{2})/g, '$1h$2').replace(':00', 'h')
        })
      }
      
      // Vendredi au Samedi
      const fridayHours = config.opening_hours_friday
      const saturdayHours = config.opening_hours_saturday
      
      if (fridayHours && saturdayHours &&
          fridayHours === saturdayHours &&
          !fridayHours.includes('Fermé') && !fridayHours.includes('réservation')) {
        groups.push({
          days: 'Vendredi-Samedi',
          hours: fridayHours.replace(/(\d{1,2}):(\d{2})/g, '$1h$2').replace(':00', 'h')
        })
      }
    }
    
    // Dimanche (si différent)
    const sundayHours = config.opening_hours_sunday
    if (sundayHours && !sundayHours.includes('Fermé')) {
      groups.push({
        days: 'Dimanche',
        hours: sundayHours.replace(/(\d{1,2}):(\d{2})/g, '$1h$2').replace(':00', 'h')
      })
    }
    
    return groups.length > 0 
      ? groups.map(group => `${group.days}: ${group.hours}`).join(' | ')
      : 'Horaires sur demande'
  }

  if (authLoading || loading) {
    return (
      <div className="min-h-screen bg-dark-bg flex items-center justify-center">
        <div className="text-center">
          <RefreshCw className="animate-spin mx-auto mb-4 text-kaki-500" size={32} />
          <p className="text-white">Chargement...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-dark-bg">
      {/* Header */}
      <div className="bg-dark-surface border-b border-kaki-800/30">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
              <button
                onClick={() => router.back()}
                className="text-kaki-400 hover:text-kaki-300 mr-4"
              >
                <X size={20} />
              </button>
              <h1 className="text-2xl font-bold text-white flex items-center">
                <Clock className="mr-3 text-kaki-500" size={24} />
                Gestion des Horaires d'Ouverture
              </h1>
            </div>
            <button
              onClick={saveOpeningHours}
              disabled={saving}
              className="btn-kaki flex items-center"
            >
              {saving ? (
                <RefreshCw className="animate-spin mr-2" size={16} />
              ) : (
                <Save className="mr-2" size={16} />
              )}
              {saving ? 'Sauvegarde...' : 'Sauvegarder'}
            </button>
          </div>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Messages */}
        {error && (
          <div className="mb-6 bg-red-900/20 border border-red-500/30 rounded-lg p-4">
            <div className="flex items-center">
              <X className="text-red-500 mr-2" size={20} />
              <p className="text-red-300">{error}</p>
            </div>
          </div>
        )}

        {success && (
          <div className="mb-6 bg-green-900/20 border border-green-500/30 rounded-lg p-4">
            <div className="flex items-center">
              <Check className="text-green-500 mr-2" size={20} />
              <p className="text-green-300">{success}</p>
            </div>
          </div>
        )}

        {/* Aperçu du bandeau */}
        <div className="mb-8 bg-kaki-600 text-white p-4 rounded-lg">
          <h3 className="text-sm font-medium mb-2">Aperçu du bandeau :</h3>
          <div className="flex items-center text-xs">
            <Clock size={10} className="mr-1" />
            <span>{getFormattedPreview()}</span>
          </div>
        </div>

        {/* Formulaire des horaires */}
        <div className="bg-dark-surface rounded-lg border border-kaki-800/30 p-6">
          <h2 className="text-xl font-semibold text-white mb-6">Horaires par jour</h2>
          
          <div className="space-y-4">
            {daysOfWeek.map((day) => (
              <div key={day.key} className="flex items-center justify-between">
                <label className="text-white font-medium w-24">
                  {day.label}
                </label>
                <div className="flex-1 max-w-md">
                  <input
                    type="text"
                    value={config[day.field as keyof OpeningHoursConfig] || ''}
                    onChange={(e) => updateDayHours(day.field, e.target.value)}
                    placeholder="Ex: 14:00 – 21:00 ou Fermé ou Sur réservation uniquement"
                    className="w-full px-3 py-2 bg-dark-bg border border-kaki-800/50 rounded-lg text-white focus:border-kaki-500 focus:outline-none"
                  />
                </div>
              </div>
            ))}
          </div>

          {/* Exemples */}
          <div className="mt-8 p-4 bg-kaki-900/20 rounded-lg">
            <h3 className="text-kaki-300 font-medium mb-3">Exemples de formats :</h3>
            <ul className="text-sm text-kaki-400 space-y-1">
              <li>• <code className="bg-kaki-800/50 px-1 rounded">14:00 – 21:00</code> - Ouvert de 14h à 21h</li>
              <li>• <code className="bg-kaki-800/50 px-1 rounded">14:00-00:00</code> - Ouvert de 14h à minuit</li>
              <li>• <code className="bg-kaki-800/50 px-1 rounded">Fermé</code> - Jour de fermeture</li>
              <li>• <code className="bg-kaki-800/50 px-1 rounded">Sur réservation uniquement</code> - Ouvert sur réservation</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  )
}
