'use client'

interface VideoPlayerProps {
  src: string
  poster?: string
  title?: string
  className?: string
  autoPlay?: boolean
  loop?: boolean
  muted?: boolean
  controls?: boolean
  width?: string | number
  height?: string | number
}

const VideoPlayer = ({
  src,
  poster,
  title,
  className = '',
  autoPlay = false,
  loop = false,
  muted = false,
  controls = true,
  width = '100%',
  height = 'auto'
}: VideoPlayerProps) => {
  // Validation des props pour éviter les problèmes de sérialisation
  const safeSrc = typeof src === 'string' ? src : ''
  const safePoster = typeof poster === 'string' ? poster : undefined
  const safeTitle = typeof title === 'string' ? title : ''
  const safeClassName = typeof className === 'string' ? className : ''
  const safeWidth = typeof width === 'string' || typeof width === 'number' ? width : '100%'
  const safeHeight = typeof height === 'string' || typeof height === 'number' ? height : 'auto'

  return (
    <div className={`relative ${safeClassName}`}>
      <video
        src={safeSrc}
        poster={safePoster}
        autoPlay={autoPlay}
        loop={loop}
        muted={muted}
        controls={controls}
        width={safeWidth}
        height={safeHeight}
        className="w-full h-auto rounded-lg"
        preload="metadata"
        title={safeTitle}
        aria-label={safeTitle || "Vidéo de présentation U Silenziu"}
      >
        Votre navigateur ne supporte pas la lecture de vidéos.
      </video>

      {/* Title overlay - seulement si title est fourni */}
      {safeTitle && (
        <div className="absolute top-4 left-4 bg-black/60 text-white px-3 py-1 rounded-md text-sm">
          {safeTitle}
        </div>
      )}
    </div>
  )
}

export default VideoPlayer
