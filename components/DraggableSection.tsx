'use client'

import { useSortable } from '@dnd-kit/sortable'
import { CSS } from '@dnd-kit/utilities'
import { GripVertical, Home, Layout, Settings, ArrowUp, Type, Image } from 'lucide-react'

interface DraggableSectionProps {
  section: {
    id: string
    section_key: string
    title?: string
    subtitle?: string
    order_index: number
    is_active: boolean
    updated_at: string
  }
  onEdit: () => void
  onToggleStatus: () => void
  onDelete: () => void
  isDeletable: boolean
}

/**
 * Composant de section avec support du drag and drop
 * Permet de réorganiser les sections en les glissant avec la souris
 */
const DraggableSection = ({ 
  section, 
  onEdit, 
  onToggleStatus, 
  onDelete, 
  isDeletable 
}: DraggableSectionProps) => {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: section.id })

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    opacity: isDragging ? 0.5 : 1,
  }

  const getSectionIcon = (sectionKey: string) => {
    switch (sectionKey) {
      case 'hero': return <Home className="w-5 h-5" />
      case 'concept': return <Layout className="w-5 h-5" />
      case 'salles': return <Settings className="w-5 h-5" />
      case 'process': return <ArrowUp className="w-5 h-5" />
      case 'faq': return <Type className="w-5 h-5" />
      case 'contact': return <Image className="w-5 h-5" />
      default: return <Layout className="w-5 h-5" />
    }
  }

  const getSectionName = (sectionKey: string) => {
    switch (sectionKey) {
      case 'hero': return 'Section Hero'
      case 'concept': return 'Le Concept'
      case 'salles': return 'Nos Salles'
      case 'process': return 'Comment ça marche'
      case 'faq': return 'Questions Fréquentes'
      case 'contact': return 'Contact'
      default: return sectionKey
    }
  }

  return (
    <div
      ref={setNodeRef}
      style={style}
      className={`p-6 hover:bg-gray-700 transition-colors ${
        isDragging ? 'bg-gray-700 shadow-lg' : ''
      }`}
    >
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-4">
          {/* Handle de drag and drop */}
          <div
            {...attributes}
            {...listeners}
            className="flex-shrink-0 cursor-grab active:cursor-grabbing p-1 hover:bg-gray-600 rounded transition-colors"
            title="Glisser pour réorganiser"
          >
            <GripVertical className="w-5 h-5 text-gray-400 hover:text-gray-300" />
          </div>

          {/* Icône de la section */}
          <div className="flex-shrink-0">
            {getSectionIcon(section.section_key)}
          </div>

          {/* Informations de la section */}
          <div className="flex-1">
            <h4 className="text-lg font-medium text-white">
              {getSectionName(section.section_key)}
            </h4>
            <p className="text-sm text-gray-400">
              {section.title || 'Aucun titre défini'}
            </p>
            <div className="flex items-center space-x-4 mt-2">
              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                section.is_active 
                  ? 'text-green-500 bg-green-500/10' 
                  : 'text-yellow-500 bg-yellow-500/10'
              }`}>
                {section.is_active ? 'Active' : 'Inactive'}
              </span>
              <span className="text-xs text-gray-500">
                Ordre: {section.order_index}
              </span>
              <span className="text-xs text-gray-500">
                Modifiée: {new Date(section.updated_at).toLocaleDateString('fr-FR')}
              </span>
            </div>
          </div>
        </div>

        {/* Actions */}
        <div className="flex items-center space-x-2">
          <button 
            onClick={onToggleStatus}
            className={`p-2 rounded-lg transition-colors ${
              section.is_active 
                ? 'text-yellow-400 hover:text-yellow-300 hover:bg-yellow-400/10' 
                : 'text-green-400 hover:text-green-300 hover:bg-green-400/10'
            }`}
            title={section.is_active ? 'Désactiver' : 'Activer'}
          >
            {section.is_active ? (
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.878 9.878L3 3m6.878 6.878L21 21" />
              </svg>
            ) : (
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
              </svg>
            )}
          </button>
          
          <button 
            onClick={onEdit}
            className="p-2 text-blue-400 hover:text-blue-300 hover:bg-blue-400/10 rounded-lg transition-colors"
            title="Modifier"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
            </svg>
          </button>
          
          <button 
            onClick={onDelete}
            disabled={!isDeletable}
            className={`p-2 rounded-lg transition-colors ${
              isDeletable
                ? 'text-red-400 hover:text-red-300 hover:bg-red-400/10'
                : 'text-gray-500 cursor-not-allowed opacity-50'
            }`}
            title={isDeletable ? 'Supprimer' : 'Section critique - Impossible de supprimer'}
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
            </svg>
          </button>
        </div>
      </div>
    </div>
  )
}

export default DraggableSection
