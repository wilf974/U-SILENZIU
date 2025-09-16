'use client'

import Image from 'next/image'
import { useState } from 'react'

interface RoomImageProps {
  src: string | null | undefined
  alt: string
  className?: string
  width?: number
  height?: number
  priority?: boolean
  quality?: number
  placeholder?: 'blur' | 'empty'
  blurDataURL?: string
  sizes?: string
  fallbackIcon?: React.ReactNode
  onError?: () => void
  onLoad?: () => void
}

export default function RoomImage({
  src,
  alt,
  className = "w-full h-full object-cover",
  width = 400,
  height = 300,
  priority = false,
  quality = 85,
  placeholder = "blur",
  blurDataURL = "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=",
  sizes = "(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw",
  fallbackIcon,
  onError,
  onLoad
}: RoomImageProps) {
  const [hasError, setHasError] = useState(false)
  const [isLoading, setIsLoading] = useState(true)

  // Fonction pour détecter si l'image est une data URL (base64)
  const isDataUrl = (src: string) => {
    return src && src.startsWith('data:')
  }

  // Gestion des erreurs
  const handleError = () => {
    setHasError(true)
    setIsLoading(false)
    onError?.()
  }

  // Gestion du chargement réussi
  const handleLoad = () => {
    setIsLoading(false)
    onLoad?.()
  }

  // Si pas d'image ou erreur, afficher le fallback
  if (!src || hasError) {
    return (
      <div className={`${className} bg-kaki-900/20 flex items-center justify-center`}>
        {fallbackIcon || (
          <div className="text-kaki-600 text-center">
            <div className="text-4xl mb-2">🏠</div>
            <div className="text-sm">Zone de défoulement</div>
          </div>
        )}
      </div>
    )
  }

  // Pour les images base64, utiliser la balise img standard avec object-fit
  if (isDataUrl(src)) {
    return (
      <div className="relative w-full h-full">
        <img
          src={src}
          alt={alt}
          className={className}
          loading={priority ? "eager" : "lazy"}
          onError={handleError}
          onLoad={handleLoad}
          style={{
            objectFit: 'cover',
            objectPosition: 'center'
          }}
        />
        {isLoading && (
          <div className="absolute inset-0 bg-kaki-900/20 flex items-center justify-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-kaki-400"></div>
          </div>
        )}
      </div>
    )
  }

  // Pour les URLs externes, utiliser Next.js Image avec fill et object-fit
  return (
    <div className="relative w-full h-full">
      <Image
        src={src}
        alt={alt}
        fill
        className={className}
        priority={priority}
        quality={quality}
        placeholder={placeholder}
        blurDataURL={blurDataURL}
        sizes={sizes}
        onError={handleError}
        onLoad={handleLoad}
        style={{
          objectFit: 'cover',
          objectPosition: 'center'
        }}
      />
      {isLoading && (
        <div className="absolute inset-0 bg-kaki-900/20 flex items-center justify-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-kaki-400"></div>
        </div>
      )}
    </div>
  )
}
