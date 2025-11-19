'use client'

import { useState } from 'react'
import { Upload, CheckCircle, AlertCircle, Loader } from 'lucide-react'

interface HeroVideoUploaderProps {
  onSuccess?: (url: string) => void
  onError?: (error: string) => void
  onUploadComplete?: () => Promise<void>
}

export default function HeroVideoUploader({ onSuccess, onError, onUploadComplete }: HeroVideoUploaderProps) {
  const [uploading, setUploading] = useState(false)
  const [message, setMessage] = useState('')
  const [messageType, setMessageType] = useState<'success' | 'error' | ''>('')
  const [fileName, setFileName] = useState('')

  const handleFileSelect = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return

    // Validation du type
    if (!file.type.startsWith('video/')) {
      const errorMsg = 'Le fichier doit être une vidéo'
      setMessage(errorMsg)
      setMessageType('error')
      onError?.(errorMsg)
      return
    }

    // Validation de la taille
    const maxSize = 50 * 1024 * 1024 // 50MB
    if (file.size > maxSize) {
      const errorMsg = 'La vidéo ne doit pas dépasser 50MB'
      setMessage(errorMsg)
      setMessageType('error')
      onError?.(errorMsg)
      return
    }

    await uploadVideo(file)
  }

  const uploadVideo = async (file: File) => {
    try {
      setUploading(true)
      setMessage('')
      setFileName(file.name)

      const formData = new FormData()
      formData.append('video', file)

      const response = await fetch('/api/admin/video/hero/upload', {
        method: 'POST',
        body: formData,
        credentials: 'include'
      })

      // Vérifier si la réponse est du JSON
      const contentType = response.headers.get('content-type')
      let data

      if (contentType && contentType.includes('application/json')) {
        data = await response.json()
      } else {
        // Si ce n'est pas du JSON, c'est une erreur du serveur
        const text = await response.text()
        throw new Error(`Erreur serveur (${response.status}): ${text.substring(0, 100)}`)
      }

      if (!response.ok) {
        throw new Error(data.error || `Erreur lors de l'upload (${response.status})`)
      }

      setMessage(`Vidéo uploadée avec succès${data.data?.backup_created ? ' (backup créé)' : ''}`)
      setMessageType('success')
      onSuccess?.(data.data.public_url)

      // Auto-save la section si une fonction est fournie
      if (onUploadComplete) {
        try {
          await onUploadComplete()
        } catch (saveError) {
          console.error('Erreur lors de la sauvegarde automatique:', saveError)
        }
      }
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : 'Erreur lors de l\'upload'
      setMessage(errorMsg)
      setMessageType('error')
      onError?.(errorMsg)
    } finally {
      setUploading(false)
    }
  }

  return (
    <div className="space-y-3">
      <label className="block text-sm font-medium text-gray-300 mb-2">
        Upload vidéo hero
      </label>

      <div className="relative border-2 border-dashed border-gray-500 rounded-lg p-6 text-center bg-gray-800 hover:border-kaki-500 transition">
        <input
          type="file"
          accept="video/*"
          onChange={handleFileSelect}
          disabled={uploading}
          className="absolute inset-0 w-full h-full opacity-0 cursor-pointer disabled:cursor-not-allowed"
        />

        <div className="pointer-events-none">
          {uploading ? (
            <>
              <Loader className="w-8 h-8 text-kaki-500 mx-auto mb-2 animate-spin" />
              <p className="text-gray-300 text-sm">Upload en cours...</p>
              {fileName && <p className="text-gray-400 text-xs mt-1">{fileName}</p>}
            </>
          ) : (
            <>
              <Upload className="w-8 h-8 text-gray-400 mx-auto mb-2" />
              <p className="text-gray-300 text-sm">
                Cliquez ou glissez une vidéo ici
              </p>
              <p className="text-gray-500 text-xs mt-1">
                MP4, WebM, MOV, AVI... (max 50MB)
              </p>
            </>
          )}
        </div>
      </div>

      {message && (
        <div className={`flex items-center gap-2 p-3 rounded-md ${
          messageType === 'success'
            ? 'bg-green-900 text-green-200'
            : 'bg-red-900 text-red-200'
        }`}>
          {messageType === 'success' ? (
            <CheckCircle className="w-4 h-4 flex-shrink-0" />
          ) : (
            <AlertCircle className="w-4 h-4 flex-shrink-0" />
          )}
          <p className="text-sm">{message}</p>
        </div>
      )}

      <p className="text-xs text-gray-400">
        💡 Le fichier hero-video.mp4 actuel sera automatiquement sauvegardé avant le remplacement
      </p>
    </div>
  )
}
