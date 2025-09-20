'use client'

import { useState, useEffect } from 'react'
import { ArrowLeft, Save, Eye, Upload, Play, Image as ImageIcon } from 'lucide-react'
import Link from 'next/link'

// Interface pour la configuration de la page d'entrée
interface EntryPageConfig {
  id: number
  title: string
  subtitle: string
  description: string
  button_text: string
  background_type: 'image' | 'video'
  background_url?: string
  background_image_url?: string
  background_video_url?: string
  is_active: boolean
  created_at: string
  updated_at: string
}

/**
 * Interface d'administration pour la configuration de la page d'entrée
 * Permet de modifier le contenu et l'arrière-plan de la page d'entrée
 */
export default function EntryPageAdmin() {
  const [config, setConfig] = useState<EntryPageConfig | null>(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)
  const [isEditing, setIsEditing] = useState(false)

  // Charger la configuration
  useEffect(() => {
    fetchConfig()
  }, [])

  const fetchConfig = async () => {
    try {
      const response = await fetch('/api/admin/entry-page-config')
      if (response.ok) {
        const data = await response.json()
        setConfig(data)
      } else {
        setError('Erreur lors du chargement de la configuration')
      }
    } catch (err) {
      setError('Erreur de connexion')
    } finally {
      setLoading(false)
    }
  }

  const handleSave = async () => {
    if (!config) return

    setSaving(true)
    setError(null)
    setSuccess(null)

    try {
      const response = await fetch('/api/admin/entry-page-config', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(config),
      })

      if (response.ok) {
        setSuccess('Configuration sauvegardée avec succès')
        setIsEditing(false)
      } else {
        const errorData = await response.json()
        setError(errorData.error || 'Erreur lors de la sauvegarde')
      }
    } catch (err) {
      setError('Erreur de connexion')
    } finally {
      setSaving(false)
    }
  }

  const handleInputChange = (field: keyof EntryPageConfig, value: any) => {
    if (config) {
      setConfig({ ...config, [field]: value })
    }
  }

  const handleImageUpload = async (event: React.ChangeEvent<HTMLInputElement>, field: string) => {
    const file = event.target.files?.[0]
    if (!file) return

    // Vérifier le type de fichier
    if (!file.type.startsWith('image/')) {
      alert('Veuillez sélectionner un fichier image valide')
      return
    }

    // Vérifier la taille (max 10MB)
    if (file.size > 10 * 1024 * 1024) {
      alert('Le fichier ne doit pas dépasser 10MB')
      return
    }

    try {
      const formData = new FormData()
      formData.append('file', file)
      formData.append('type', 'image')

      const response = await fetch('/api/media/upload', {
        method: 'POST',
        body: formData,
      })

      if (response.ok) {
        const result = await response.json()
        handleInputChange(field as keyof EntryPageConfig, result.url)
        setSuccess('Image uploadée et configuration mise à jour avec succès')
        // Recharger la configuration depuis la base de données
        await fetchConfig()
      } else {
        const error = await response.json()
        setError(`Erreur lors de l'upload: ${error.error}`)
      }
    } catch (error) {
      console.error('Erreur lors de l\'upload:', error)
      setError('Erreur lors de l\'upload du fichier')
    }
  }

  const handleVideoUpload = async (event: React.ChangeEvent<HTMLInputElement>, field: string) => {
    const file = event.target.files?.[0]
    if (!file) return

    // Vérifier le type de fichier
    if (!file.type.startsWith('video/')) {
      alert('Veuillez sélectionner un fichier vidéo valide')
      return
    }

    // Vérifier la taille (max 10MB)
    if (file.size > 10 * 1024 * 1024) {
      alert('Le fichier ne doit pas dépasser 10MB')
      return
    }

    try {
      const formData = new FormData()
      formData.append('file', file)
      formData.append('type', 'video')

      const response = await fetch('/api/media/upload', {
        method: 'POST',
        body: formData,
      })

      if (response.ok) {
        const result = await response.json()
        handleInputChange(field as keyof EntryPageConfig, result.url)
        setSuccess('Vidéo uploadée et configuration mise à jour avec succès')
        // Recharger la configuration depuis la base de données
        await fetchConfig()
      } else {
        const error = await response.json()
        setError(`Erreur lors de l'upload: ${error.error}`)
      }
    } catch (error) {
      console.error('Erreur lors de l\'upload:', error)
      setError('Erreur lors de l\'upload du fichier')
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-dark-bg p-6">
        <div className="max-w-4xl mx-auto">
          <div className="animate-pulse">
            <div className="h-8 bg-dark-surface rounded mb-6"></div>
            <div className="h-64 bg-dark-surface rounded"></div>
          </div>
        </div>
      </div>
    )
  }

  if (!config) {
    return (
      <div className="min-h-screen bg-dark-bg p-6">
        <div className="max-w-4xl mx-auto">
          <div className="text-center">
            <h1 className="text-2xl font-bold text-white mb-4">Configuration de la Page d'Entrée</h1>
            <p className="text-gray-400">Erreur lors du chargement de la configuration</p>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-dark-bg p-6">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="flex items-center justify-between mb-8">
          <div className="flex items-center gap-4">
            <Link
              href="/admin"
              className="flex items-center gap-2 text-kaki-400 hover:text-kaki-300 transition-colors"
            >
              <ArrowLeft className="w-5 h-5" />
              Retour au dashboard
            </Link>
            <h1 className="text-3xl font-bold text-white">Configuration de la Page d'Entrée</h1>
          </div>
          <div className="flex gap-3">
            <Link
              href="/entry"
              target="_blank"
              className="flex items-center gap-2 bg-kaki-600 hover:bg-kaki-700 text-white px-4 py-2 rounded-md transition-colors"
            >
              <Eye className="w-4 h-4" />
              Prévisualiser
            </Link>
            {!isEditing ? (
              <button
                onClick={() => setIsEditing(true)}
                className="flex items-center gap-2 bg-kaki-600 hover:bg-kaki-700 text-white px-4 py-2 rounded-md transition-colors"
              >
                Modifier
              </button>
            ) : (
              <button
                onClick={handleSave}
                disabled={saving}
                className="flex items-center gap-2 bg-green-600 hover:bg-green-700 disabled:bg-gray-600 text-white px-4 py-2 rounded-md transition-colors"
              >
                <Save className="w-4 h-4" />
                {saving ? 'Sauvegarde...' : 'Sauvegarder'}
              </button>
            )}
          </div>
        </div>

        {/* Messages */}
        {error && (
          <div className="bg-red-900/50 border border-red-500 text-red-200 px-4 py-3 rounded-md mb-6">
            {error}
          </div>
        )}
        {success && (
          <div className="bg-green-900/50 border border-green-500 text-green-200 px-4 py-3 rounded-md mb-6">
            {success}
          </div>
        )}

        {/* Configuration */}
        <div className="bg-dark-surface border border-kaki-800/30 rounded-lg p-6">
          <h2 className="text-xl font-semibold text-white mb-6">Contenu de la Page d'Entrée</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Titre principal */}
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Titre principal
              </label>
              <input
                type="text"
                value={config.title}
                onChange={(e) => handleInputChange('title', e.target.value)}
                disabled={!isEditing}
                className="w-full px-3 py-2 bg-dark-bg border border-kaki-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 disabled:opacity-50"
              />
            </div>

            {/* Sous-titre */}
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Sous-titre
              </label>
              <input
                type="text"
                value={config.subtitle}
                onChange={(e) => handleInputChange('subtitle', e.target.value)}
                disabled={!isEditing}
                className="w-full px-3 py-2 bg-dark-bg border border-kaki-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 disabled:opacity-50"
              />
            </div>

            {/* Description */}
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Description
              </label>
              <textarea
                value={config.description}
                onChange={(e) => handleInputChange('description', e.target.value)}
                disabled={!isEditing}
                rows={3}
                className="w-full px-3 py-2 bg-dark-bg border border-kaki-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 disabled:opacity-50"
              />
            </div>

            {/* Texte du bouton */}
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Texte du bouton
              </label>
              <input
                type="text"
                value={config.button_text}
                onChange={(e) => handleInputChange('button_text', e.target.value)}
                disabled={!isEditing}
                className="w-full px-3 py-2 bg-dark-bg border border-kaki-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 disabled:opacity-50"
              />
            </div>

            {/* Type d'arrière-plan */}
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Type d'arrière-plan
              </label>
              <select
                value={config.background_type}
                onChange={(e) => handleInputChange('background_type', e.target.value)}
                disabled={!isEditing}
                className="w-full px-3 py-2 bg-dark-bg border border-kaki-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 disabled:opacity-50"
              >
                <option value="image">Image</option>
                <option value="video">Vidéo</option>
              </select>
            </div>
          </div>

          {/* Sélection des médias */}
          <div className="mt-6">
            <h3 className="text-lg font-medium text-white mb-4">Médias d'Arrière-plan</h3>
            <div className="grid grid-cols-1 gap-6">
              {/* Sélecteur d'image */}
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  <ImageIcon className="w-4 h-4 inline mr-2" />
                  Image d'arrière-plan
                </label>
                <div className="space-y-4">
                  {/* Zone d'upload d'image */}
                  <div className="border-2 border-dashed border-kaki-600 rounded-lg p-4 text-center">
                    <input
                      type="file"
                      accept="image/*"
                      onChange={(e) => handleImageUpload(e, 'background_image_url')}
                      disabled={!isEditing}
                      className="hidden"
                      id="image-upload"
                    />
                    <label
                      htmlFor="image-upload"
                      className={`cursor-pointer flex flex-col items-center space-y-2 ${
                        !isEditing ? 'opacity-50 cursor-not-allowed' : ''
                      }`}
                    >
                      <ImageIcon className="w-8 h-8 text-kaki-400" />
                      <span className="text-kaki-300">
                        {!isEditing ? 'Cliquez sur Modifier pour uploader' : 'Cliquez pour uploader une image'}
                      </span>
                      <span className="text-xs text-gray-400">JPG, PNG, GIF, WebP (max 10MB)</span>
                    </label>
                  </div>
                  
                  {/* URL manuelle */}
                  <div>
                    <label className="block text-xs text-gray-400 mb-1">Ou saisissez une URL manuellement :</label>
                    <input
                      type="url"
                      value={config.background_image_url || ''}
                      onChange={(e) => handleInputChange('background_image_url', e.target.value)}
                      disabled={!isEditing}
                      placeholder="/images/entry-bg.jpg"
                      className="w-full px-3 py-2 bg-dark-bg border border-kaki-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 disabled:opacity-50"
                    />
                  </div>
                </div>
              </div>

              {/* Sélecteur de vidéo */}
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  <Play className="w-4 h-4 inline mr-2" />
                  Vidéo d'arrière-plan
                </label>
                <div className="space-y-4">
                  {/* Zone d'upload de vidéo */}
                  <div className="border-2 border-dashed border-kaki-600 rounded-lg p-4 text-center">
                    <input
                      type="file"
                      accept="video/*"
                      onChange={(e) => handleVideoUpload(e, 'background_video_url')}
                      disabled={!isEditing}
                      className="hidden"
                      id="video-upload"
                    />
                    <label
                      htmlFor="video-upload"
                      className={`cursor-pointer flex flex-col items-center space-y-2 ${
                        !isEditing ? 'opacity-50 cursor-not-allowed' : ''
                      }`}
                    >
                      <Play className="w-8 h-8 text-kaki-400" />
                      <span className="text-kaki-300">
                        {!isEditing ? 'Cliquez sur Modifier pour uploader' : 'Cliquez pour uploader une vidéo'}
                      </span>
                      <span className="text-xs text-gray-400">MP4, WebM, MOV, AVI (max 10MB)</span>
                    </label>
                  </div>
                  
                  {/* URL manuelle */}
                  <div>
                    <label className="block text-xs text-gray-400 mb-1">Ou saisissez une URL manuellement :</label>
                    <input
                      type="url"
                      value={config.background_video_url || ''}
                      onChange={(e) => handleInputChange('background_video_url', e.target.value)}
                      disabled={!isEditing}
                      placeholder="/videos/entry-bg.mp4"
                      className="w-full px-3 py-2 bg-dark-bg border border-kaki-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 disabled:opacity-50"
                    />
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Statut */}
          <div className="mt-6">
            <label className="flex items-center gap-3">
              <input
                type="checkbox"
                checked={config.is_active}
                onChange={(e) => handleInputChange('is_active', e.target.checked)}
                disabled={!isEditing}
                className="w-4 h-4 text-kaki-600 bg-dark-bg border-kaki-600 rounded focus:ring-kaki-500 disabled:opacity-50"
              />
              <span className="text-sm font-medium text-gray-300">
                Page d'entrée active
              </span>
            </label>
          </div>
        </div>

        {/* Informations */}
        <div className="mt-6 bg-dark-surface border border-kaki-800/30 rounded-lg p-6">
          <h3 className="text-lg font-medium text-white mb-4">Informations</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm text-gray-400">
            <div>
              <span className="font-medium">Créé le :</span> {new Date(config.created_at).toLocaleString('fr-FR')}
            </div>
            <div>
              <span className="font-medium">Modifié le :</span> {new Date(config.updated_at).toLocaleString('fr-FR')}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
