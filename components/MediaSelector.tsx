'use client'

import { useState, useEffect, useRef } from 'react'
import { Upload, Image as ImageIcon, Video, X, Check, Eye } from 'lucide-react'

interface MediaFile {
  name: string
  url: string
  type: 'image' | 'video'
  size: number
  lastModified: string
}

interface MediaSelectorProps {
  type: 'image' | 'video'
  currentUrl?: string
  onSelect: (url: string) => void
  disabled?: boolean
}

/**
 * Composant de sélection de médias (images/vidéos) pour la page d'entrée
 * Permet de choisir des fichiers depuis un dossier ou d'en uploader de nouveaux
 */
export default function MediaSelector({ type, currentUrl, onSelect, disabled = false }: MediaSelectorProps) {
  const [mediaFiles, setMediaFiles] = useState<MediaFile[]>([])
  const [loading, setLoading] = useState(false)
  const [uploading, setUploading] = useState(false)
  const [selectedFile, setSelectedFile] = useState<string | null>(currentUrl || null)
  const fileInputRef = useRef<HTMLInputElement>(null)

  // Charger la liste des médias disponibles
  useEffect(() => {
    fetchMediaFiles()
  }, [type])

  const fetchMediaFiles = async () => {
    setLoading(true)
    try {
      const response = await fetch(`/api/media/entry/${type}`)
      if (response.ok) {
        const files = await response.json()
        setMediaFiles(files)
      }
    } catch (error) {
      console.error('Erreur lors du chargement des médias:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleFileUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    // Vérifier le type de fichier
    const isValidType = type === 'image' 
      ? file.type.startsWith('image/')
      : file.type.startsWith('video/')

    if (!isValidType) {
      alert(`Veuillez sélectionner un fichier ${type === 'image' ? 'image' : 'vidéo'} valide`)
      return
    }

    // Vérifier la taille (max 10MB)
    if (file.size > 10 * 1024 * 1024) {
      alert('Le fichier ne doit pas dépasser 10MB')
      return
    }

    setUploading(true)
    try {
      const formData = new FormData()
      formData.append('file', file)
      formData.append('type', type)

      const response = await fetch('/api/media/upload', {
        method: 'POST',
        body: formData,
      })

      if (response.ok) {
        const result = await response.json()
        setMediaFiles(prev => [result, ...prev])
        setSelectedFile(result.url)
        onSelect(result.url)
      } else {
        const error = await response.json()
        alert(`Erreur lors de l'upload: ${error.error}`)
      }
    } catch (error) {
      console.error('Erreur lors de l\'upload:', error)
      alert('Erreur lors de l\'upload du fichier')
    } finally {
      setUploading(false)
      if (fileInputRef.current) {
        fileInputRef.current.value = ''
      }
    }
  }

  const handleFileSelect = (url: string) => {
    setSelectedFile(url)
    onSelect(url)
  }

  const handleFileDelete = async (fileName: string) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer ce fichier ?')) return

    try {
      const response = await fetch(`/api/media/delete`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ fileName, type }),
      })

      if (response.ok) {
        setMediaFiles(prev => prev.filter(file => file.name !== fileName))
        if (selectedFile === `/media/entry/${type}/${fileName}`) {
          setSelectedFile(null)
          onSelect('')
        }
      } else {
        alert('Erreur lors de la suppression du fichier')
      }
    } catch (error) {
      console.error('Erreur lors de la suppression:', error)
      alert('Erreur lors de la suppression du fichier')
    }
  }

  const formatFileSize = (bytes: number) => {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }

  return (
    <div className="space-y-4">
      {/* Zone d'upload */}
      <div className="border-2 border-dashed border-kaki-600 rounded-lg p-6 text-center">
        <input
          ref={fileInputRef}
          type="file"
          accept={type === 'image' ? 'image/*' : 'video/*'}
          onChange={handleFileUpload}
          disabled={disabled || uploading}
          className="hidden"
        />
        
        <div className="flex flex-col items-center space-y-3">
          {type === 'image' ? (
            <ImageIcon className="w-12 h-12 text-kaki-400" />
          ) : (
            <Video className="w-12 h-12 text-kaki-400" />
          )}
          
          <div>
            <button
              onClick={() => fileInputRef.current?.click()}
              disabled={disabled || uploading}
              className="flex items-center gap-2 bg-kaki-600 hover:bg-kaki-700 disabled:bg-gray-600 text-white px-4 py-2 rounded-md transition-colors"
            >
              <Upload className="w-4 h-4" />
              {uploading ? 'Upload en cours...' : `Uploader un fichier ${type === 'image' ? 'image' : 'vidéo'}`}
            </button>
          </div>
          
          <p className="text-sm text-gray-400">
            Formats acceptés: {type === 'image' ? 'JPG, PNG, GIF, WebP' : 'MP4, WebM, MOV'}
            <br />
            Taille max: 10MB
          </p>
        </div>
      </div>

      {/* Liste des médias disponibles */}
      <div>
        <h4 className="text-sm font-medium text-gray-300 mb-3">
          Fichiers {type === 'image' ? 'images' : 'vidéos'} disponibles
        </h4>
        
        {loading ? (
          <div className="text-center py-4">
            <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-kaki-500 mx-auto"></div>
            <p className="text-gray-400 mt-2">Chargement...</p>
          </div>
        ) : mediaFiles.length === 0 ? (
          <div className="text-center py-4 text-gray-400">
            Aucun fichier {type === 'image' ? 'image' : 'vidéo'} disponible
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {mediaFiles.map((file) => (
              <div
                key={file.name}
                className={`relative border rounded-lg p-3 cursor-pointer transition-colors ${
                  selectedFile === file.url
                    ? 'border-kaki-500 bg-kaki-500/10'
                    : 'border-gray-600 hover:border-kaki-400'
                }`}
                onClick={() => handleFileSelect(file.url)}
              >
                {/* Indicateur de sélection */}
                {selectedFile === file.url && (
                  <div className="absolute top-2 right-2 bg-kaki-500 text-white rounded-full p-1">
                    <Check className="w-3 h-3" />
                  </div>
                )}

                {/* Bouton de suppression */}
                <button
                  onClick={(e) => {
                    e.stopPropagation()
                    handleFileDelete(file.name)
                  }}
                  className="absolute top-2 left-2 bg-red-600 hover:bg-red-700 text-white rounded-full p-1 opacity-0 group-hover:opacity-100 transition-opacity"
                >
                  <X className="w-3 h-3" />
                </button>

                {/* Aperçu */}
                <div className="aspect-video bg-gray-800 rounded mb-2 flex items-center justify-center">
                  {type === 'image' ? (
                    <img
                      src={file.url}
                      alt={file.name}
                      className="w-full h-full object-cover rounded"
                    />
                  ) : (
                    <video
                      src={file.url}
                      className="w-full h-full object-cover rounded"
                      muted
                    />
                  )}
                </div>

                {/* Informations du fichier */}
                <div className="text-xs text-gray-400">
                  <p className="font-medium text-white truncate">{file.name}</p>
                  <p>{formatFileSize(file.size)}</p>
                  <p>{new Date(file.lastModified).toLocaleDateString('fr-FR')}</p>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Fichier sélectionné */}
      {selectedFile && (
        <div className="bg-kaki-500/10 border border-kaki-500 rounded-lg p-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Check className="w-4 h-4 text-kaki-500" />
              <span className="text-sm text-kaki-300">
                Fichier sélectionné: {selectedFile.split('/').pop()}
              </span>
            </div>
            <button
              onClick={() => {
                setSelectedFile(null)
                onSelect('')
              }}
              className="text-gray-400 hover:text-white"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
