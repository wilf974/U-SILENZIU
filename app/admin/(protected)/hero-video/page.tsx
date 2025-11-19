'use client'

import { useState, useRef, useEffect } from 'react'
import { ArrowLeft, Upload, Play, AlertCircle, CheckCircle, Save } from 'lucide-react'
import Link from 'next/link'

export default function HeroVideoAdmin() {
  const [videoUrl, setVideoUrl] = useState<string>('/video/hero-video.mp4')
  const [savedVideoUrl, setSavedVideoUrl] = useState<string>('/video/hero-video.mp4')
  const [loading, setLoading] = useState(false)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)
  const [uploadProgress, setUploadProgress] = useState(0)
  const fileInputRef = useRef<HTMLInputElement>(null)
  const videoPreviewRef = useRef<HTMLVideoElement>(null)

  // Charger la vidéo sauvegardée au démarrage
  useEffect(() => {
    fetchSavedVideoUrl()
  }, [])

  const fetchSavedVideoUrl = async () => {
    try {
      const response = await fetch('/api/admin/hero-video/save', {
        credentials: 'include'
      })
      if (response.ok) {
        const data = await response.json()
        setSavedVideoUrl(data.videoUrl)
        setVideoUrl(data.videoUrl)
      }
    } catch (err) {
      console.error('Erreur lors du chargement:', err)
    }
  }

  const handleVideoSelect = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    // Réinitialiser les messages
    setError(null)
    setSuccess(null)

    // Vérifier le type de fichier
    if (!file.type.startsWith('video/')) {
      setError('Veuillez sélectionner un fichier vidéo valide (MP4, WebM, Ogg, etc.)')
      return
    }

    // Vérifier la taille (max 100MB pour une vidéo)
    if (file.size > 100 * 1024 * 1024) {
      setError('Le fichier ne doit pas dépasser 100MB')
      return
    }

    // Uploader le fichier
    await uploadVideo(file)
  }

  const uploadVideo = async (file: File) => {
    setLoading(true)
    setUploadProgress(0)

    try {
      const formData = new FormData()
      formData.append('file', file)
      formData.append('type', 'video')

      const response = await fetch('/api/admin/hero-video/upload', {
        method: 'POST',
        body: formData,
        credentials: 'include'
      })

      const contentType = response.headers.get('content-type')
      const isJson = contentType && contentType.includes('application/json')

      if (response.ok) {
        if (!isJson) {
          throw new Error('La réponse n\'est pas du JSON valide')
        }
        const result = await response.json()
        setVideoUrl(result.url)
        setSuccess('Vidéo hero mise à jour avec succès!')

        // Recharger la vidéo dans la preview
        if (videoPreviewRef.current) {
          videoPreviewRef.current.src = result.url
          videoPreviewRef.current.load()
        }

        // Nettoyer l'input
        if (fileInputRef.current) {
          fileInputRef.current.value = ''
        }
      } else {
        let errorMessage = `Erreur HTTP ${response.status}`
        if (isJson) {
          try {
            const errorData = await response.json()
            errorMessage = errorData.error || errorMessage
          } catch (parseErr) {
            console.error('Impossible de parser la réponse d\'erreur:', parseErr)
          }
        } else {
          const text = await response.text()
          console.error('Réponse d\'erreur:', text)
          errorMessage = `Erreur serveur: ${text.substring(0, 100)}`
        }
        setError(errorMessage)
      }
    } catch (err) {
      console.error('Erreur lors de l\'upload:', err)
      setError('Erreur lors de l\'upload du fichier')
    } finally {
      setLoading(false)
      setUploadProgress(0)
    }
  }

  const triggerFileInput = () => {
    fileInputRef.current?.click()
  }

  const handleSaveVideo = async () => {
    setSaving(true)
    setError(null)
    setSuccess(null)

    try {
      const response = await fetch('/api/admin/hero-video/save', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ videoUrl }),
        credentials: 'include'
      })

      if (response.ok) {
        const data = await response.json()
        setSavedVideoUrl(videoUrl)
        setSuccess('Vidéo hero appliquée au site avec succès! 🎬')
      } else {
        const errorData = await response.json()
        setError(errorData.error || 'Erreur lors de la sauvegarde')
      }
    } catch (err) {
      console.error('Erreur:', err)
      setError('Erreur lors de la sauvegarde du fichier')
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="min-h-screen bg-gray-900 text-white">
      {/* Header */}
      <div className="bg-gray-800 border-b border-gray-700 p-6">
        <div className="max-w-6xl mx-auto flex items-center gap-4">
          <Link
            href="/admin"
            className="flex items-center gap-2 text-gray-400 hover:text-white transition"
          >
            <ArrowLeft size={20} />
            <span>Retour</span>
          </Link>
          <h1 className="text-2xl font-bold ml-4">Gestion de la Vidéo Hero</h1>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-6xl mx-auto p-6">
        <div className="grid lg:grid-cols-2 gap-8">
          {/* Upload Section */}
          <div className="space-y-6">
            <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
              <h2 className="text-xl font-semibold mb-4">Importer une nouvelle vidéo</h2>

              {/* Messages */}
              {error && (
                <div className="mb-4 p-4 bg-red-500/10 border border-red-500/30 rounded-lg flex gap-3">
                  <AlertCircle className="text-red-400 flex-shrink-0" size={20} />
                  <p className="text-red-400">{error}</p>
                </div>
              )}

              {success && (
                <div className="mb-4 p-4 bg-green-500/10 border border-green-500/30 rounded-lg flex gap-3">
                  <CheckCircle className="text-green-400 flex-shrink-0" size={20} />
                  <p className="text-green-400">{success}</p>
                </div>
              )}

              {/* Upload Area */}
              <div
                onClick={triggerFileInput}
                className="border-2 border-dashed border-gray-600 rounded-lg p-8 text-center cursor-pointer hover:border-kaki-500 transition"
              >
                <input
                  ref={fileInputRef}
                  type="file"
                  accept="video/*"
                  onChange={handleVideoSelect}
                  className="hidden"
                  disabled={loading}
                />

                <div className="flex flex-col items-center gap-3">
                  <div className="w-12 h-12 bg-kaki-600/20 rounded-lg flex items-center justify-center">
                    <Upload className="text-kaki-400" size={24} />
                  </div>
                  <div>
                    <p className="font-semibold">Cliquez pour importer une vidéo</p>
                    <p className="text-sm text-gray-400 mt-1">
                      Formats acceptés: MP4, WebM, Ogg
                    </p>
                    <p className="text-xs text-gray-500 mt-1">
                      Taille maximale: 100 MB
                    </p>
                  </div>
                </div>

                {loading && (
                  <div className="mt-4">
                    <div className="w-full bg-gray-700 rounded-full h-2">
                      <div
                        className="bg-kaki-600 h-2 rounded-full transition-all"
                        style={{ width: `${uploadProgress}%` }}
                      ></div>
                    </div>
                    <p className="text-sm text-gray-400 mt-2">Upload en cours...</p>
                  </div>
                )}
              </div>

              {/* Info */}
              <div className="mt-6 p-4 bg-blue-500/10 border border-blue-500/30 rounded-lg">
                <p className="text-sm text-blue-400">
                  💡 <strong>Conseil:</strong> Utilisez une vidéo courte (5-10 secondes)
                  pour une meilleure performance. La vidéo doit être en boucle et sans son.
                </p>
              </div>
            </div>
          </div>

          {/* Preview Section */}
          <div className="space-y-6">
            <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
              <h2 className="text-xl font-semibold mb-4">Aperçu</h2>

              <div className="relative w-full bg-gray-900 rounded-lg overflow-hidden aspect-video border border-gray-700">
                <video
                  ref={videoPreviewRef}
                  src={videoUrl}
                  autoPlay
                  loop
                  muted
                  playsInline
                  className="w-full h-full object-cover"
                />

                {/* Play button overlay */}
                <div className="absolute inset-0 flex items-center justify-center opacity-0 hover:opacity-100 transition bg-black/30">
                  <div className="w-16 h-16 bg-kaki-600 rounded-full flex items-center justify-center">
                    <Play className="text-white fill-white" size={24} />
                  </div>
                </div>
              </div>

              <div className="mt-4 text-sm text-gray-400">
                <p><strong>URL actuelle:</strong></p>
                <p className="font-mono text-xs text-gray-500 mt-1 break-all">{videoUrl}</p>
              </div>

              {/* Status */}
              <div className="mt-4 p-4 rounded-lg" style={{
                backgroundColor: videoUrl === savedVideoUrl ? 'rgba(34, 197, 94, 0.1)' : 'rgba(251, 146, 60, 0.1)',
                borderColor: videoUrl === savedVideoUrl ? 'rgba(34, 197, 94, 0.3)' : 'rgba(251, 146, 60, 0.3)',
                borderWidth: '1px'
              }}>
                <p className="text-sm" style={{ color: videoUrl === savedVideoUrl ? '#86efac' : '#fed7aa' }}>
                  {videoUrl === savedVideoUrl ? (
                    <>✓ Cette vidéo est appliquée au site</>
                  ) : (
                    <>⚠ Cette vidéo n'est pas encore appliquée au site</>
                  )}
                </p>
              </div>

              {/* Save Button */}
              <button
                onClick={handleSaveVideo}
                disabled={saving || videoUrl === savedVideoUrl}
                className={`w-full mt-4 py-3 rounded-lg font-medium transition-colors flex items-center justify-center gap-2 ${
                  videoUrl === savedVideoUrl
                    ? 'bg-gray-700 text-gray-400 cursor-not-allowed'
                    : 'bg-kaki-600 hover:bg-kaki-700 text-white'
                }`}
              >
                <Save size={20} />
                {saving ? 'Application en cours...' : 'Appliquer cette vidéo au site'}
              </button>
            </div>

            {/* Technical Info */}
            <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
              <h3 className="font-semibold mb-3">Recommandations techniques</h3>
              <ul className="text-sm text-gray-400 space-y-2">
                <li className="flex gap-2">
                  <span>•</span>
                  <span><strong>Format:</strong> MP4 (H.264 codec)</span>
                </li>
                <li className="flex gap-2">
                  <span>•</span>
                  <span><strong>Résolution:</strong> 1920x1080 ou plus</span>
                </li>
                <li className="flex gap-2">
                  <span>•</span>
                  <span><strong>Bitrate:</strong> 5-8 Mbps recommandé</span>
                </li>
                <li className="flex gap-2">
                  <span>•</span>
                  <span><strong>Son:</strong> Sans son ou très discret</span>
                </li>
                <li className="flex gap-2">
                  <span>•</span>
                  <span><strong>Durée:</strong> 5-10 secondes (boucle)</span>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
