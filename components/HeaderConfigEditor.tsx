'use client'

import { useState, useEffect } from 'react'
import { HeaderConfig } from '@/lib/database'

interface HeaderConfigEditorProps {
  onConfigUpdate?: (config: HeaderConfig) => void
}

/**
 * Composant pour éditer la configuration de l'en-tête (nom et logo)
 */
export default function HeaderConfigEditor({ onConfigUpdate = () => {} }: HeaderConfigEditorProps) {
  const [config, setConfig] = useState<HeaderConfig | null>(null)
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [isEditing, setIsEditing] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)

  // État local pour l'édition
  const [editData, setEditData] = useState({
    site_name: '',
    logo_type: 'text' as 'text' | 'image' | 'uploaded',
    logo_text: '',
    logo_image_url: '',
    logo_alt_text: ''
  })

  // État pour l'upload de fichier
  const [selectedFile, setSelectedFile] = useState<File | null>(null)
  const [uploading, setUploading] = useState(false)

  /**
   * Charge la configuration actuelle
   */
  const loadConfig = async () => {
    try {
      setLoading(true)
      const response = await fetch('/api/admin/header-config')
      
      if (response.ok) {
        const data = await response.json()
        
        // L'API retourne directement la config ou un objet avec error
        if (data.error) {
          setError(data.error)
        } else {
          setConfig(data)
          setEditData({
            site_name: data.site_name || '',
            logo_type: data.logo_type || 'text',
            logo_text: data.logo_text || '',
            logo_image_url: data.logo_image_url || '',
            logo_alt_text: data.logo_alt_text || ''
          })
        }
      } else {
        const errorData = await response.json()
        setError(errorData.error || 'Erreur lors du chargement de la configuration')
      }
    } catch (error) {
      console.error('Erreur:', error)
      setError('Erreur lors du chargement de la configuration')
    } finally {
      setLoading(false)
    }
  }

  /**
   * Sauvegarde la configuration
   */
  const saveConfig = async () => {
    try {
      setSaving(true)
      setError(null)
      setSuccess(null)

      // Si c'est un logo uploadé, utiliser l'API d'upload
      if (editData.logo_type === 'uploaded' && selectedFile) {
        const formData = new FormData()
        formData.append('logo', selectedFile)
        formData.append('site_name', editData.site_name)
        formData.append('logo_alt_text', editData.logo_alt_text)

        const response = await fetch('/api/admin/header-config/upload', {
          method: 'POST',
          body: formData,
        })

        if (response.ok) {
          const result = await response.json()
          setConfig(result.config)
          setSuccess('Logo uploadé et sauvegardé avec succès')
          setIsEditing(false)
          setSelectedFile(null)
          
          if (onConfigUpdate) {
            onConfigUpdate(result.config)
          }
        } else {
          const errorData = await response.json()
          setError(errorData.error || 'Erreur lors de l\'upload du logo')
        }
      } else {
        // Configuration normale (texte ou image URL)
        const response = await fetch('/api/admin/header-config', {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(editData),
        })

        if (response.ok) {
          const result = await response.json()
          setConfig(result.config)
          setSuccess('Configuration de l\'en-tête mise à jour avec succès')
          setIsEditing(false)
          
          if (onConfigUpdate) {
            onConfigUpdate(result.config)
          }
        } else {
          const errorData = await response.json()
          setError(errorData.error || 'Erreur lors de la sauvegarde')
        }
      }
    } catch (error) {
      console.error('Erreur:', error)
      setError('Erreur lors de la sauvegarde')
    } finally {
      setSaving(false)
    }
  }

  /**
   * Annule les modifications
   */
  const cancelEdit = () => {
    if (config) {
      setEditData({
        site_name: config.site_name || '',
        logo_type: config.logo_type || 'text',
        logo_text: config.logo_text || '',
        logo_image_url: config.logo_image_url || '',
        logo_alt_text: config.logo_alt_text || ''
      })
    }
    setIsEditing(false)
    setError(null)
    setSuccess(null)
    setSelectedFile(null)
  }

  /**
   * Gère la sélection d'un fichier
   */
  const handleFileSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (file) {
      setSelectedFile(file)
      setEditData({ ...editData, logo_type: 'uploaded' })
    }
  }

  useEffect(() => {
    loadConfig()
  }, [])

  if (loading) {
    return (
      <div className="bg-gray-800 border border-gray-700 rounded-lg p-6">
        <div className="animate-pulse">
          <div className="h-6 bg-gray-700 rounded mb-4"></div>
          <div className="h-4 bg-gray-700 rounded mb-2"></div>
          <div className="h-4 bg-gray-700 rounded mb-2"></div>
          <div className="h-4 bg-gray-700 rounded"></div>
        </div>
      </div>
    )
  }

  return (
    <div className="bg-gray-800 border border-gray-700 rounded-lg p-6">
      <div className="flex items-center justify-between mb-6">
        <h3 className="text-xl font-semibold text-white">Configuration de l'En-tête</h3>
        {!isEditing && (
          <button
            onClick={() => setIsEditing(true)}
            className="flex items-center space-x-2 px-4 py-2 bg-kaki-600 hover:bg-kaki-700 text-white rounded-lg transition-colors"
          >
            <span>Modifier</span>
          </button>
        )}
      </div>

      {error && (
        <div className="mb-4 p-3 bg-red-900/20 border border-red-500/30 rounded-lg">
          <p className="text-red-400 text-sm">{error}</p>
        </div>
      )}

      {success && (
        <div className="mb-4 p-3 bg-green-900/20 border border-green-500/30 rounded-lg">
          <p className="text-green-400 text-sm">{success}</p>
        </div>
      )}

      {isEditing ? (
        <div className="space-y-6">
          {/* Nom du site */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Nom du site *
            </label>
            <input
              type="text"
              value={editData.site_name}
              onChange={(e) => setEditData({ ...editData, site_name: e.target.value })}
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
              placeholder="U SILENZIU"
              required
            />
          </div>

          {/* Type de logo */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Type de logo *
            </label>
            <div className="flex space-x-4">
              <label className="flex items-center">
                <input
                  type="radio"
                  value="text"
                  checked={editData.logo_type === 'text'}
                  onChange={(e) => setEditData({ ...editData, logo_type: e.target.value as 'text' | 'image' | 'uploaded' })}
                  className="mr-2 text-kaki-500"
                />
                <span className="text-white">Texte</span>
              </label>
              <label className="flex items-center">
                <input
                  type="radio"
                  value="image"
                  checked={editData.logo_type === 'image'}
                  onChange={(e) => setEditData({ ...editData, logo_type: e.target.value as 'text' | 'image' | 'uploaded' })}
                  className="mr-2 text-kaki-500"
                />
                <span className="text-white">Image URL</span>
              </label>
              <label className="flex items-center">
                <input
                  type="radio"
                  value="uploaded"
                  checked={editData.logo_type === 'uploaded'}
                  onChange={(e) => setEditData({ ...editData, logo_type: e.target.value as 'text' | 'image' | 'uploaded' })}
                  className="mr-2 text-kaki-500"
                />
                <span className="text-white">Fichier uploadé</span>
              </label>
            </div>
          </div>

          {/* Texte du logo (si type = text) */}
          {editData.logo_type === 'text' && (
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Texte du logo *
              </label>
              <input
                type="text"
                value={editData.logo_text}
                onChange={(e) => setEditData({ ...editData, logo_text: e.target.value })}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                placeholder="U"
                maxLength={10}
                required
              />
              <p className="text-xs text-gray-400 mt-1">Maximum 10 caractères</p>
            </div>
          )}

          {/* URL de l'image du logo (si type = image) */}
          {editData.logo_type === 'image' && (
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                URL de l'image du logo *
              </label>
              <input
                type="url"
                value={editData.logo_image_url}
                onChange={(e) => setEditData({ ...editData, logo_image_url: e.target.value })}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                placeholder="https://example.com/logo.png"
                required
              />
            </div>
          )}

          {/* Sélection de fichier (si type = uploaded) */}
          {editData.logo_type === 'uploaded' && (
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Fichier du logo *
              </label>
              <input
                type="file"
                accept="image/png,image/jpeg,image/jpg,image/gif,image/webp"
                onChange={handleFileSelect}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-medium file:bg-kaki-600 file:text-white hover:file:bg-kaki-700 focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                required
              />
              {selectedFile && (
                <div className="mt-2 p-3 bg-gray-700 border border-gray-600 rounded-md">
                  <p className="text-sm text-gray-300">
                    <span className="font-medium">Fichier sélectionné:</span> {selectedFile.name}
                  </p>
                  <p className="text-xs text-gray-400">
                    Taille: {(selectedFile.size / 1024).toFixed(1)} KB
                  </p>
                </div>
              )}
              <p className="text-xs text-gray-400 mt-1">
                Formats acceptés: PNG, JPEG, JPG, GIF, WebP (max 2MB)
              </p>
            </div>
          )}

          {/* Texte alternatif pour l'image */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Texte alternatif pour l'image
            </label>
            <input
              type="text"
              value={editData.logo_alt_text}
              onChange={(e) => setEditData({ ...editData, logo_alt_text: e.target.value })}
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
              placeholder="Logo du site"
            />
            <p className="text-xs text-gray-400 mt-1">Pour l'accessibilité</p>
          </div>

          {/* Boutons d'action */}
          <div className="flex space-x-3 pt-4">
            <button
              onClick={saveConfig}
              disabled={saving}
              className="flex items-center space-x-2 px-4 py-2 bg-green-600 hover:bg-green-700 disabled:bg-gray-500 text-white rounded-lg transition-colors"
            >
              <span>{saving ? 'Sauvegarde...' : 'Sauvegarder'}</span>
            </button>
            <button
              onClick={cancelEdit}
              className="px-4 py-2 border border-gray-600 text-gray-300 rounded-lg hover:bg-gray-700 transition-colors"
            >
              Annuler
            </button>
          </div>
        </div>
      ) : (
        <div className="space-y-4">
          {/* Affichage de la configuration actuelle */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-1">
                Nom du site
              </label>
              <p className="text-white">{config?.site_name || 'Non défini'}</p>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-1">
                Type de logo
              </label>
              <p className="text-white capitalize">{config?.logo_type || 'Non défini'}</p>
            </div>
            {config?.logo_type === 'text' && (
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-1">
                  Texte du logo
                </label>
                <p className="text-white">{config?.logo_text || 'Non défini'}</p>
              </div>
            )}
            {config?.logo_type === 'image' && (
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-1">
                  URL de l'image
                </label>
                <p className="text-white break-all">{config?.logo_image_url || 'Non défini'}</p>
              </div>
            )}
            {config?.logo_type === 'uploaded' && (
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-1">
                  Fichier uploadé
                </label>
                <p className="text-white">{config?.logo_uploaded_filename || 'Non défini'}</p>
                <p className="text-xs text-gray-400">
                  Taille: {config?.logo_uploaded_size ? `${(config.logo_uploaded_size / 1024).toFixed(1)} KB` : 'Non défini'}
                </p>
              </div>
            )}
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-1">
                Texte alternatif
              </label>
              <p className="text-white">{config?.logo_alt_text || 'Non défini'}</p>
            </div>
          </div>

          {/* Prévisualisation du logo */}
          <div className="mt-6 p-4 bg-gray-700 border border-gray-600 rounded-lg">
            <h4 className="text-sm font-medium text-gray-300 mb-3">Prévisualisation</h4>
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-br from-kaki-500 to-kaki-700 rounded-lg flex items-center justify-center">
                {config?.logo_type === 'text' ? (
                  <span className="text-white font-bold text-xl">{config?.logo_text || 'U'}</span>
                ) : config?.logo_type === 'uploaded' ? (
                  <img
                    src="/api/header-config/logo"
                    alt={config?.logo_alt_text || 'Logo'}
                    className="w-8 h-8 object-contain"
                    onError={(e) => {
                      // Fallback vers le texte si l'image ne charge pas
                      const target = e.target as HTMLImageElement;
                      target.style.display = 'none';
                      const fallback = document.createElement('span');
                      fallback.className = 'text-white font-bold text-xl';
                      fallback.textContent = config?.logo_text || 'U';
                      target.parentNode?.appendChild(fallback);
                    }}
                  />
                ) : (
                  <img
                    src={config?.logo_image_url}
                    alt={config?.logo_alt_text || 'Logo'}
                    className="w-8 h-8 object-contain"
                    onError={(e) => {
                      // Fallback vers le texte si l'image ne charge pas
                      const target = e.target as HTMLImageElement;
                      target.style.display = 'none';
                      const fallback = document.createElement('span');
                      fallback.className = 'text-white font-bold text-xl';
                      fallback.textContent = config?.logo_text || 'U';
                      target.parentNode?.appendChild(fallback);
                    }}
                  />
                )}
              </div>
              <span className="text-2xl font-bold text-gradient-kaki">{config?.site_name || 'U SILENZIU'}</span>
            </div>
          </div>

          {/* Lien vers le site */}
          <div className="pt-4 border-t border-gray-700">
            <a
              href="/"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center text-kaki-400 hover:text-kaki-300 transition-colors"
            >
              <span className="mr-2">Voir sur le site</span>
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
              </svg>
            </a>
          </div>
        </div>
      )}
    </div>
  )
}
