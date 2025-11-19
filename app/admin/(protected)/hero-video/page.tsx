'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { ArrowLeft, Video } from 'lucide-react'
import HeroVideoUploader from '@/components/HeroVideoUploader'

export default function HeroVideoPage() {
  const router = useRouter()
  const [lastUpload, setLastUpload] = useState('')

  return (
    <div className="min-h-screen bg-gray-900 p-8">
      <div className="max-w-2xl mx-auto">
        {/* Header */}
        <div className="flex items-center gap-4 mb-8">
          <button
            onClick={() => router.back()}
            className="p-2 hover:bg-gray-800 rounded-lg transition"
          >
            <ArrowLeft className="w-5 h-5 text-gray-400" />
          </button>
          <div className="flex items-center gap-3">
            <Video className="w-8 h-8 text-kaki-500" />
            <h1 className="text-3xl font-bold text-white">Vidéo Hero</h1>
          </div>
        </div>

        {/* Card */}
        <div className="bg-gray-800 rounded-lg border border-gray-700 p-8">
          <div className="mb-6">
            <h2 className="text-xl font-semibold text-white mb-2">
              Mettre à jour la vidéo hero
            </h2>
            <p className="text-gray-400">
              Uploadez une nouvelle vidéo pour la section hero du site (max 50MB)
            </p>
          </div>

          <HeroVideoUploader
            onSuccess={(url) => {
              setLastUpload(url)
            }}
          />

          {lastUpload && (
            <div className="mt-6 p-4 bg-green-900 rounded-lg">
              <p className="text-sm text-green-200">
                ✅ Vidéo uploadée avec succès!
              </p>
              <p className="text-sm text-gray-300 mt-2">
                URL: <code className="text-kaki-500">{lastUpload}</code>
              </p>
            </div>
          )}
        </div>

        {/* Info */}
        <div className="mt-8 p-4 bg-gray-800 rounded-lg border border-gray-700">
          <h3 className="text-sm font-semibold text-white mb-2">ℹ️ Informations</h3>
          <ul className="text-sm text-gray-400 space-y-1">
            <li>• Formats supportés: MP4, WebM, MOV, AVI</li>
            <li>• Taille maximale: 50 MB</li>
            <li>• L'ancienne vidéo sera automatiquement sauvegardée en backup</li>
            <li>• Les 3 derniers backups sont conservés</li>
          </ul>
        </div>
      </div>
    </div>
  )
}
