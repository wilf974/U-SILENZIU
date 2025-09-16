'use client'

import { useState, useEffect } from 'react'
import { ExternalLink, Play, Image as ImageIcon } from 'lucide-react'

interface DynamicSectionProps {
  section: {
    id: string
    section_key: string
    title?: string
    subtitle?: string
    content?: string
    image_url?: string
    video_url?: string
    background_color?: string
    text_color?: string
    order_index: number
    is_active: boolean
  }
}

/**
 * Composant pour afficher dynamiquement les sections créées via le back-office
 * Supporte le texte, les images, les vidéos et les liens
 */
const DynamicSection = ({ section }: DynamicSectionProps) => {
  const [parsedContent, setParsedContent] = useState<any>(null)

  useEffect(() => {
    if (section.content) {
      try {
        // Essayer de parser le contenu JSON
        const parsed = JSON.parse(section.content)
        setParsedContent(parsed)
      } catch {
        // Si ce n'est pas du JSON, traiter comme du texte simple
        setParsedContent({ type: 'text', content: section.content })
      }
    }
  }, [section.content])

  // Déterminer le type de contenu
  const getContentType = () => {
    if (section.video_url) return 'video'
    if (section.image_url) return 'image'
    if (parsedContent?.links) return 'links'
    return 'text'
  }

  const contentType = getContentType()

  // Rendu du contenu selon le type
  const renderContent = () => {
    switch (contentType) {
      case 'video':
        return (
          <div className="relative">
            {section.video_url && (
              <video
                src={section.video_url}
                controls
                className="w-full h-64 md:h-96 object-cover rounded-lg"
                poster={section.image_url}
              >
                Votre navigateur ne supporte pas la lecture de vidéos.
              </video>
            )}
            {parsedContent?.content && (
              <div className="mt-4 text-gray-300">
                {parsedContent.content}
              </div>
            )}
          </div>
        )

      case 'image':
        return (
          <div className="space-y-4">
            {section.image_url && (
              <div className="relative">
                <img
                  src={section.image_url}
                  alt={section.title || 'Image de la section'}
                  className="w-full h-64 md:h-96 object-cover rounded-lg"
                />
                <div className="absolute top-2 right-2 bg-black/50 rounded-full p-2">
                  <ImageIcon className="w-4 h-4 text-white" />
                </div>
              </div>
            )}
            {parsedContent?.content && (
              <div className="text-gray-300">
                {parsedContent.content}
              </div>
            )}
          </div>
        )

      case 'links':
        return (
          <div className="space-y-4">
            {parsedContent?.description && (
              <div className="text-gray-300 mb-4">
                {parsedContent.description}
              </div>
            )}
            {parsedContent?.links && (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {parsedContent.links.map((link: any, index: number) => (
                  <a
                    key={index}
                    href={link.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="block p-4 bg-gray-800 rounded-lg border border-gray-700 hover:border-kaki-500 transition-colors group"
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex-1">
                        <h4 className="font-medium text-white group-hover:text-kaki-400 transition-colors">
                          {link.text}
                        </h4>
                        {link.description && (
                          <p className="text-sm text-gray-400 mt-1">
                            {link.description}
                          </p>
                        )}
                      </div>
                      <ExternalLink className="w-4 h-4 text-gray-400 group-hover:text-kaki-400 transition-colors" />
                    </div>
                  </a>
                ))}
              </div>
            )}
          </div>
        )

      default:
        return (
          <div className="text-gray-300">
            {section.content}
          </div>
        )
    }
  }

  // Styles dynamiques
  const containerStyle = {
    backgroundColor: section.background_color || 'transparent',
    color: section.text_color || 'inherit'
  }

  return (
    <section 
      className="py-16 px-4 sm:px-6 lg:px-8"
      style={containerStyle}
    >
      <div className="max-w-7xl mx-auto">
        {/* En-tête de la section */}
        {(section.title || section.subtitle) && (
          <div className="text-center mb-12">
            {section.title && (
              <h2 className="text-3xl md:text-4xl font-bold mb-4">
                {section.title}
              </h2>
            )}
            {section.subtitle && (
              <p className="text-lg md:text-xl text-gray-300 max-w-3xl mx-auto">
                {section.subtitle}
              </p>
            )}
          </div>
        )}

        {/* Contenu de la section */}
        <div className="max-w-4xl mx-auto">
          {renderContent()}
        </div>
      </div>
    </section>
  )
}

export default DynamicSection
