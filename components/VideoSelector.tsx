'use client'

import { useEffect, useState } from 'react'
import { ChevronDown, Video, AlertCircle, Loader } from 'lucide-react'

interface VideoFile {
  filename: string
  path: string
  size: number
  sizeKB: number
  sizeMB: string
  createdAt: string
  modifiedAt: string
}

interface VideoSelectorProps {
  value: string
  onChange: (value: string) => void
  label?: string
  placeholder?: string
  error?: string
}

export default function VideoSelector({
  value,
  onChange,
  label = 'Sélectionner une vidéo',
  placeholder = 'Choisir une vidéo...',
  error,
}: VideoSelectorProps) {
  const [videos, setVideos] = useState<VideoFile[]>([])
  const [loading, setLoading] = useState(true)
  const [isOpen, setIsOpen] = useState(false)
  const [apiError, setApiError] = useState<string | null>(null)

  useEffect(() => {
    fetchVideos()
  }, [])

  const fetchVideos = async () => {
    try {
      setLoading(true)
      setApiError(null)

      const response = await fetch('/api/admin/videos')
      const data = await response.json()

      if (data.success) {
        setVideos(data.videos)
      } else {
        setApiError(data.error || 'Erreur lors de la récupération des vidéos')
      }
    } catch (err) {
      console.error('Erreur:', err)
      setApiError('Erreur de connexion à l\'API')
    } finally {
      setLoading(false)
    }
  }

  const selectedVideo = videos.find(v => v.path === value)

  return (
    <div className="space-y-2">
      {label && (
        <label className="block text-sm font-medium text-gray-300">
          {label}
        </label>
      )}

      {apiError && (
        <div className="p-3 bg-red-500/10 border border-red-500/30 rounded-lg flex gap-2 items-start">
          <AlertCircle className="text-red-400 flex-shrink-0 mt-0.5" size={18} />
          <p className="text-sm text-red-400">{apiError}</p>
        </div>
      )}

      <div className="relative">
        <button
          onClick={() => setIsOpen(!isOpen)}
          disabled={loading}
          className="w-full px-4 py-3 bg-gray-700 border border-gray-600 rounded-lg text-left flex items-center justify-between hover:border-kaki-500 transition disabled:opacity-50 disabled:cursor-not-allowed text-gray-200"
        >
          <div className="flex items-center gap-2 flex-1 min-w-0">
            <Video size={18} className="text-gray-400 flex-shrink-0" />
            <span className="truncate">
              {loading ? (
                <div className="flex items-center gap-2">
                  <Loader size={16} className="animate-spin" />
                  <span>Chargement...</span>
                </div>
              ) : selectedVideo ? (
                <div>
                  <div className="font-medium">{selectedVideo.filename}</div>
                  <div className="text-xs text-gray-500">{selectedVideo.sizeMB} MB</div>
                </div>
              ) : (
                <span className="text-gray-500">{placeholder}</span>
              )}
            </span>
          </div>
          <ChevronDown
            size={18}
            className={`text-gray-400 flex-shrink-0 transition ${isOpen ? 'rotate-180' : ''}`}
          />
        </button>

        {/* Dropdown */}
        {isOpen && !loading && (
          <div className="absolute top-full left-0 right-0 mt-2 bg-gray-700 border border-gray-600 rounded-lg shadow-lg z-50 max-h-80 overflow-y-auto">
            {videos.length === 0 ? (
              <div className="p-4 text-center text-gray-400">
                <p className="text-sm">Aucune vidéo disponible</p>
              </div>
            ) : (
              videos.map((video) => (
                <button
                  key={video.path}
                  onClick={() => {
                    onChange(video.path)
                    setIsOpen(false)
                  }}
                  className={`w-full px-4 py-3 text-left border-b border-gray-600 last:border-b-0 hover:bg-gray-600 transition flex items-center justify-between ${
                    value === video.path ? 'bg-kaki-600/20 border-l-4 border-l-kaki-500' : ''
                  }`}
                >
                  <div className="flex-1 min-w-0">
                    <div className={`font-medium truncate ${value === video.path ? 'text-kaki-400' : 'text-gray-200'}`}>
                      {video.filename}
                    </div>
                    <div className="text-xs text-gray-500">
                      {video.sizeMB} MB • Modifié{' '}
                      {new Date(video.modifiedAt).toLocaleDateString('fr-FR')}
                    </div>
                  </div>
                  {value === video.path && (
                    <div className="text-kaki-400 font-bold ml-2 flex-shrink-0">✓</div>
                  )}
                </button>
              ))
            )}
          </div>
        )}
      </div>

      {error && (
        <p className="text-xs text-red-400">{error}</p>
      )}

      {/* Info */}
      <p className="text-xs text-gray-500">
        💡 Uploadez des vidéos dans le dossier <code className="bg-gray-800 px-1 rounded">public/video/</code>
      </p>
    </div>
  )
}
