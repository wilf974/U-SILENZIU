'use client'

import { useState, useEffect } from 'react'
import { 
  Home, 
  Edit, 
  Save, 
  X,
  Eye,
  EyeOff,
  ArrowUp,
  ArrowDown,
  Settings,
  Layout,
  Type,
  Image,
  Video,
  Monitor,
  Palette,
  FileText,
  Globe,
  Info,
  Target,
  Plus,
  Link,
  Trash2
} from 'lucide-react'
import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
  DragEndEvent,
} from '@dnd-kit/core'
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  verticalListSortingStrategy,
} from '@dnd-kit/sortable'
import DraggableSection from '@/components/DraggableSection'
import HeaderConfigEditor from '@/components/HeaderConfigEditor'

interface HomepageSection {
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
  created_at: string
  updated_at: string
}

interface HomepageConfig {
  site_title: string
  site_description: string
  site_name: string
  contact_email: string
  contact_phone: string
  address: string
  opening_hours: string
  seo_keywords: string
  seo_description: string
}

interface FooterConfig {
  id?: string
  site_name: string
  site_description?: string
  site_slogan?: string
  contact_phone?: string
  contact_email?: string
  contact_address?: string
  opening_hours_monday?: string
  opening_hours_tuesday?: string
  opening_hours_wednesday?: string
  opening_hours_thursday?: string
  opening_hours_friday?: string
  opening_hours_saturday?: string
  opening_hours_sunday?: string
  cta_title?: string
  cta_subtitle?: string
  cta_button_text?: string
  cta_button_url?: string
  legal_links: any[]
  copyright_text?: string
  created_at?: string
  updated_at?: string
}

interface SectionEditorProps {
  section: HomepageSection
  formData: any
  setFormData: (data: any) => void
}

// Éditeur pour créer une nouvelle section
const NewSectionEditor = ({ onSave, onCancel }: { onSave: (section: any) => void, onCancel: () => void }) => {
  const [formData, setFormData] = useState({
    section_key: '',
    title: '',
    subtitle: '',
    content: '',
    image_url: '',
    video_url: '',
    background_color: '',
    text_color: '',
    order_index: 0,
    is_active: true
  })

  const [contentType, setContentType] = useState<'text' | 'image' | 'video' | 'link'>('text')
  const [links, setLinks] = useState<Array<{text: string, url: string, description?: string}>>([])

  const handleSave = () => {
    if (!formData.section_key.trim()) {
      alert('La clé de section est obligatoire')
      return
    }

    // Préparer le contenu selon le type
    let finalContent = formData.content
    if (contentType === 'link' && links.length > 0) {
      finalContent = JSON.stringify({ links, description: formData.content })
    }

    const newSection = {
      ...formData,
      content: finalContent,
      section_key: formData.section_key.trim().toLowerCase().replace(/\s+/g, '-')
    }

    onSave(newSection)
  }

  const addLink = () => {
    setLinks([...links, { text: '', url: '', description: '' }])
  }

  const removeLink = (index: number) => {
    setLinks(links.filter((_, i) => i !== index))
  }

  const updateLink = (index: number, field: string, value: string) => {
    const newLinks = [...links]
    newLinks[index] = { ...newLinks[index], [field]: value }
    setLinks(newLinks)
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-gray-800 rounded-lg w-full max-w-4xl max-h-[90vh] overflow-y-auto">
        <div className="px-6 py-4 border-b border-gray-700 flex justify-between items-center">
          <div className="flex items-center space-x-3">
            <Plus className="w-5 h-5 text-kaki-400" />
            <h2 className="text-xl font-semibold text-white">Ajouter une nouvelle section</h2>
          </div>
          <button
            onClick={onCancel}
            className="text-gray-400 hover:text-white"
          >
            <X className="w-6 h-6" />
          </button>
        </div>
        
        <div className="p-6 space-y-6">
          {/* Informations de base */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Clé de section *
              </label>
              <input
                type="text"
                value={formData.section_key}
                onChange={(e) => setFormData({ ...formData, section_key: e.target.value })}
                className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                placeholder="ma-nouvelle-section"
              />
              <p className="text-xs text-gray-400 mt-1">Utilisez des tirets, pas d'espaces</p>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Ordre d'affichage
              </label>
              <input
                type="number"
                value={formData.order_index}
                onChange={(e) => setFormData({ ...formData, order_index: parseInt(e.target.value) || 0 })}
                className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                min="0"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Titre de la section
              </label>
              <input
                type="text"
                value={formData.title}
                onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                placeholder="Titre de la section"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Sous-titre
              </label>
              <input
                type="text"
                value={formData.subtitle}
                onChange={(e) => setFormData({ ...formData, subtitle: e.target.value })}
                className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                placeholder="Sous-titre optionnel"
              />
            </div>
          </div>

          {/* Type de contenu */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Type de contenu
            </label>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-2">
              {[
                { key: 'text', label: 'Texte', icon: FileText },
                { key: 'image', label: 'Image', icon: Image },
                { key: 'video', label: 'Vidéo', icon: Video },
                { key: 'link', label: 'Liens', icon: Link }
              ].map(({ key, label, icon: Icon }) => (
                <button
                  key={key}
                  onClick={() => setContentType(key as any)}
                  className={`p-3 rounded-lg border-2 transition-colors ${
                    contentType === key
                      ? 'border-kaki-500 bg-kaki-500/20 text-kaki-400'
                      : 'border-gray-600 bg-gray-700 text-gray-300 hover:border-gray-500'
                  }`}
                >
                  <Icon className="w-5 h-5 mx-auto mb-1" />
                  <span className="text-xs">{label}</span>
                </button>
              ))}
            </div>
          </div>

          {/* Contenu selon le type */}
          {contentType === 'text' && (
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Contenu texte
              </label>
              <textarea
                value={formData.content}
                onChange={(e) => setFormData({ ...formData, content: e.target.value })}
                rows={6}
                className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                placeholder="Contenu de votre section..."
              />
            </div>
          )}

          {contentType === 'image' && (
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                URL de l'image
              </label>
              <input
                type="url"
                value={formData.image_url}
                onChange={(e) => setFormData({ ...formData, image_url: e.target.value })}
                className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                placeholder="https://exemple.com/image.jpg"
              />
              <p className="text-xs text-gray-400 mt-1">URL de l'image à afficher</p>
            </div>
          )}

          {contentType === 'video' && (
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                URL de la vidéo
              </label>
              <input
                type="url"
                value={formData.video_url}
                onChange={(e) => setFormData({ ...formData, video_url: e.target.value })}
                className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                placeholder="https://exemple.com/video.mp4"
              />
              <p className="text-xs text-gray-400 mt-1">URL de la vidéo à afficher</p>
            </div>
          )}

          {contentType === 'link' && (
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <label className="block text-sm font-medium text-gray-300">
                  Liens
                </label>
                <button
                  onClick={addLink}
                  className="flex items-center space-x-2 px-3 py-2 bg-kaki-600 hover:bg-kaki-700 text-white rounded-lg transition-colors"
                >
                  <Plus className="w-4 h-4" />
                  <span>Ajouter un lien</span>
                </button>
              </div>
              
              {links.length === 0 ? (
                <p className="text-gray-400 text-sm">Aucun lien ajouté. Cliquez sur "Ajouter un lien" pour commencer.</p>
              ) : (
                <div className="space-y-3">
                  {links.map((link, index) => (
                    <div key={index} className="grid grid-cols-1 md:grid-cols-3 gap-3 p-3 bg-gray-700 rounded-lg">
                      <input
                        type="text"
                        value={link.text}
                        onChange={(e) => updateLink(index, 'text', e.target.value)}
                        className="px-3 py-2 border border-gray-600 rounded-md bg-gray-600 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                        placeholder="Texte du lien"
                      />
                      <input
                        type="url"
                        value={link.url}
                        onChange={(e) => updateLink(index, 'url', e.target.value)}
                        className="px-3 py-2 border border-gray-600 rounded-md bg-gray-600 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                        placeholder="URL du lien"
                      />
                      <div className="flex items-center space-x-2">
                        <input
                          type="text"
                          value={link.description || ''}
                          onChange={(e) => updateLink(index, 'description', e.target.value)}
                          className="flex-1 px-3 py-2 border border-gray-600 rounded-md bg-gray-600 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                          placeholder="Description (optionnel)"
                        />
                        <button
                          onClick={() => removeLink(index)}
                          className="p-2 text-red-400 hover:text-red-300 hover:bg-red-400/10 rounded-lg transition-colors"
                          title="Supprimer ce lien"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}

              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  Description générale
                </label>
                <textarea
                  value={formData.content}
                  onChange={(e) => setFormData({ ...formData, content: e.target.value })}
                  rows={3}
                  className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                  placeholder="Description générale de la section avec liens..."
                />
              </div>
            </div>
          )}

          {/* Couleurs */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Couleur de fond
              </label>
              <input
                type="text"
                value={formData.background_color}
                onChange={(e) => setFormData({ ...formData, background_color: e.target.value })}
                className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                placeholder="bg-gray-800"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Couleur du texte
              </label>
              <input
                type="text"
                value={formData.text_color}
                onChange={(e) => setFormData({ ...formData, text_color: e.target.value })}
                className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                placeholder="text-white"
              />
            </div>
          </div>

          {/* Statut */}
          <div className="flex items-center">
            <input
              type="checkbox"
              id="is_active_new"
              checked={formData.is_active}
              onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
              className="h-4 w-4 text-kaki-600 focus:ring-kaki-500 border-gray-600 rounded bg-gray-700"
            />
            <label htmlFor="is_active_new" className="ml-2 block text-sm text-gray-300">
              Section active
            </label>
          </div>
        </div>

        <div className="px-6 py-4 border-t border-gray-700 flex justify-end space-x-3">
          <button
            onClick={onCancel}
            className="px-4 py-2 border border-gray-600 rounded-md shadow-sm text-sm font-medium text-white bg-gray-700 hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-kaki-500"
          >
            Annuler
          </button>
          <button
            onClick={handleSave}
            className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-kaki-600 hover:bg-kaki-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-kaki-500"
          >
            <Save className="w-4 h-4 mr-2 inline" />
            Créer la section
          </button>
        </div>
      </div>
    </div>
  )
}

// Éditeur pour la configuration générale de la page d'accueil
const HomepageConfigEditor = () => {
  const [config, setConfig] = useState<HomepageConfig>({
    site_title: '',
    site_description: '',
    site_name: '',
    contact_email: '',
    contact_phone: '',
    address: '',
    opening_hours: '',
    seo_keywords: '',
    seo_description: ''
  })

  const [isEditing, setIsEditing] = useState(false)
  const [isLoading, setIsLoading] = useState(true)
  const [isSaving, setIsSaving] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // Charger la configuration depuis la base de données
  const fetchConfig = async () => {
    try {
      setIsLoading(true)
      setError(null)
      
      const response = await fetch('/api/admin/homepage-config')
      const result = await response.json()
      
      if (result.success) {
        setConfig(result.data)
      } else {
        setError('Erreur lors du chargement de la configuration')
      }
    } catch (error) {
      console.error('Erreur lors du chargement:', error)
      setError('Erreur lors du chargement de la configuration')
    } finally {
      setIsLoading(false)
    }
  }

  // Charger la configuration au montage du composant
  useEffect(() => {
    fetchConfig()
  }, [])

  const handleSave = async () => {
    try {
      setIsSaving(true)
      setError(null)
      
      const response = await fetch('/api/admin/homepage-config', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(config)
      })
      
      const result = await response.json()
      
      if (result.success) {
        setConfig(result.data)
        setIsEditing(false)
        alert('Configuration sauvegardée avec succès !')
      } else {
        setError(result.error || 'Erreur lors de la sauvegarde')
      }
    } catch (error) {
      console.error('Erreur lors de la sauvegarde:', error)
      setError('Erreur lors de la sauvegarde')
    } finally {
      setIsSaving(false)
    }
  }

  const handleCancel = () => {
    // Recharger la configuration depuis la base de données
    fetchConfig()
    setIsEditing(false)
    setError(null)
  }

  // Affichage de l'état de chargement
  if (isLoading) {
    return (
      <div className="bg-gray-900 rounded-lg p-6 mb-6">
        <div className="flex items-center justify-center py-8">
          <div className="text-white">Chargement de la configuration...</div>
        </div>
      </div>
    )
  }

  return (
    <div className="bg-gray-900 rounded-lg p-6 mb-6">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center space-x-2">
          <Globe className="w-5 h-5 text-kaki-400" />
          <h2 className="text-xl font-semibold text-white">Configuration Générale de la Page d'Accueil</h2>
        </div>
        {!isEditing ? (
          <button
            onClick={() => setIsEditing(true)}
            className="flex items-center space-x-2 px-4 py-2 bg-kaki-600 hover:bg-kaki-700 text-white rounded-lg transition-colors"
          >
            <Edit className="w-4 h-4" />
            <span>Modifier</span>
          </button>
        ) : (
          <div className="flex space-x-2">
            <button
              onClick={handleSave}
              disabled={isSaving}
              className="flex items-center space-x-2 px-4 py-2 bg-green-600 hover:bg-green-700 disabled:bg-gray-500 text-white rounded-lg transition-colors"
            >
              <Save className="w-4 h-4" />
              <span>{isSaving ? 'Sauvegarde...' : 'Sauvegarder'}</span>
            </button>
            <button
              onClick={handleCancel}
              disabled={isSaving}
              className="flex items-center space-x-2 px-4 py-2 bg-gray-600 hover:bg-gray-700 disabled:bg-gray-500 text-white rounded-lg transition-colors"
            >
              <X className="w-4 h-4" />
              <span>Annuler</span>
            </button>
          </div>
        )}
      </div>

      {/* Affichage des erreurs */}
      {error && (
        <div className="mb-4 p-3 bg-red-900 border border-red-700 rounded-lg">
          <p className="text-red-200">{error}</p>
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Informations principales */}
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Titre principal du site
            </label>
            {isEditing ? (
              <input
                type="text"
                value={config.site_title}
                onChange={(e) => setConfig({...config, site_title: e.target.value})}
                className="w-full px-3 py-2 bg-gray-800 border border-gray-600 rounded-lg text-white focus:border-kaki-500 focus:outline-none"
              />
            ) : (
              <p className="text-white">{config.site_title}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Description principale
            </label>
            {isEditing ? (
              <textarea
                value={config.site_description}
                onChange={(e) => setConfig({...config, site_description: e.target.value})}
                rows={3}
                className="w-full px-3 py-2 bg-gray-800 border border-gray-600 rounded-lg text-white focus:border-kaki-500 focus:outline-none"
              />
            ) : (
              <p className="text-gray-300">{config.site_description}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Nom du site
            </label>
            {isEditing ? (
              <input
                type="text"
                value={config.site_name}
                onChange={(e) => setConfig({...config, site_name: e.target.value})}
                className="w-full px-3 py-2 bg-gray-800 border border-gray-600 rounded-lg text-white focus:border-kaki-500 focus:outline-none"
              />
            ) : (
              <p className="text-white">{config.site_name}</p>
            )}
          </div>
        </div>

        {/* Informations de contact */}
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Email de contact
            </label>
            {isEditing ? (
              <input
                type="email"
                value={config.contact_email}
                onChange={(e) => setConfig({...config, contact_email: e.target.value})}
                className="w-full px-3 py-2 bg-gray-800 border border-gray-600 rounded-lg text-white focus:border-kaki-500 focus:outline-none"
              />
            ) : (
              <p className="text-white">{config.contact_email}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Téléphone
            </label>
            {isEditing ? (
              <input
                type="text"
                value={config.contact_phone}
                onChange={(e) => setConfig({...config, contact_phone: e.target.value})}
                className="w-full px-3 py-2 bg-gray-800 border border-gray-600 rounded-lg text-white focus:border-kaki-500 focus:outline-none"
              />
            ) : (
              <p className="text-white">{config.contact_phone}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Adresse
            </label>
            {isEditing ? (
              <input
                type="text"
                value={config.address}
                onChange={(e) => setConfig({...config, address: e.target.value})}
                className="w-full px-3 py-2 bg-gray-800 border border-gray-600 rounded-lg text-white focus:border-kaki-500 focus:outline-none"
              />
            ) : (
              <p className="text-gray-300">{config.address}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Horaires d'ouverture
            </label>
            {isEditing ? (
              <textarea
                value={config.opening_hours}
                onChange={(e) => setConfig({...config, opening_hours: e.target.value})}
                rows={2}
                className="w-full px-3 py-2 bg-gray-800 border border-gray-600 rounded-lg text-white focus:border-kaki-500 focus:outline-none"
              />
            ) : (
              <p className="text-gray-300">{config.opening_hours}</p>
            )}
          </div>
        </div>
      </div>

      {/* SEO */}
      <div className="mt-6 pt-6 border-t border-gray-700">
        <h3 className="text-lg font-medium text-white mb-4 flex items-center">
          <Target className="w-5 h-5 text-kaki-400 mr-2" />
          Paramètres SEO
        </h3>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Mots-clés SEO
            </label>
            {isEditing ? (
              <input
                type="text"
                value={config.seo_keywords}
                onChange={(e) => setConfig({...config, seo_keywords: e.target.value})}
                className="w-full px-3 py-2 bg-gray-800 border border-gray-600 rounded-lg text-white focus:border-kaki-500 focus:outline-none"
                placeholder="défoulement, Buros, lancer haches..."
              />
            ) : (
              <p className="text-gray-300">{config.seo_keywords}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Description SEO
            </label>
            {isEditing ? (
              <textarea
                value={config.seo_description}
                onChange={(e) => setConfig({...config, seo_description: e.target.value})}
                rows={2}
                className="w-full px-3 py-2 bg-gray-800 border border-gray-600 rounded-lg text-white focus:border-kaki-500 focus:outline-none"
              />
            ) : (
              <p className="text-gray-300">{config.seo_description}</p>
            )}
          </div>
        </div>
      </div>

      {/* Bouton de prévisualisation */}
      <div className="mt-6 pt-6 border-t border-gray-700">
        <a
          href="/"
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center space-x-2 px-4 py-2 bg-kaki-600 hover:bg-kaki-700 text-white rounded-lg transition-colors"
        >
          <Eye className="w-4 h-4" />
          <span>Voir le site</span>
        </a>
      </div>
    </div>
  )
}

// Éditeur pour la configuration du pied de page
const FooterEditor = () => {
  const [config, setConfig] = useState<FooterConfig>({
    site_name: 'U SILENZIU',
    site_description: 'Votre zone de défoulement à Buros. Libérez votre stress et vos tensions dans un environnement sécurisé et fun.',
    site_slogan: 'Énergie positive garantie !',
    contact_phone: '+33 7 83 83 64 53',
    contact_email: 'info@usilenziu.com',
    contact_address: '18 Rue du Pont Long, 64160 Buros, Zone Berlanne',
    opening_hours_tuesday: '14:00 – 21:00',
    opening_hours_wednesday: '14:00 – 21:00',
    opening_hours_thursday: '14:00 – 21:00',
    opening_hours_friday: '14:00 – 00:00',
    opening_hours_saturday: '14:00 – 00:00',
    opening_hours_sunday: 'Sur réservation uniquement, Minimum 5 personnes',
    cta_title: 'Prêt à libérer votre stress ?',
    cta_button_text: 'Réserver maintenant',
    cta_button_url: '/reservation',
    legal_links: [
      { label: 'CGV', url: '/cgv' },
      { label: 'Politique de confidentialité', url: '/politique-confidentialite' },
      { label: 'Mentions légales', url: '/mentions-legales' },
      { label: 'Paramètres des cookies', url: '/parametres-cookies' }
    ],
    copyright_text: '© 2024 U Silenziu. Tous droits réservés.'
  })

  const [isEditing, setIsEditing] = useState(false)
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    fetchFooterConfig()
  }, [])

  const fetchFooterConfig = async () => {
    try {
      const response = await fetch('/api/admin/footer-config')
      const result = await response.json()
      
      if (result.success) {
        setConfig(result.data)
      }
    } catch (error) {
      console.error('Erreur lors du chargement de la configuration du pied de page:', error)
    }
  }

  const handleSave = async () => {
    try {
      setLoading(true)
      const response = await fetch('/api/admin/footer-config', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(config)
      })

      const result = await response.json()
      
      if (result.success) {
        setIsEditing(false)
        alert('Configuration du pied de page sauvegardée avec succès !')
      } else {
        alert(`Erreur lors de la sauvegarde: ${result.error}`)
      }
    } catch (error) {
      console.error('Erreur lors de la sauvegarde:', error)
      alert('Erreur lors de la sauvegarde')
    } finally {
      setLoading(false)
    }
  }

  const addLegalLink = () => {
    setConfig({
      ...config,
      legal_links: [...config.legal_links, { label: '', url: '' }]
    })
  }

  const removeLegalLink = (index: number) => {
    setConfig({
      ...config,
      legal_links: config.legal_links.filter((_, i) => i !== index)
    })
  }

  const updateLegalLink = (index: number, field: string, value: string) => {
    const updatedLinks = [...config.legal_links]
    updatedLinks[index] = { ...updatedLinks[index], [field]: value }
    setConfig({ ...config, legal_links: updatedLinks })
  }

  return (
    <div className="bg-gray-900 rounded-lg p-6 mb-6">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center space-x-2">
          <Layout className="w-5 h-5 text-kaki-400" />
          <h2 className="text-xl font-semibold text-white">Configuration du Pied de Page</h2>
        </div>
        {!isEditing ? (
          <button
            onClick={() => setIsEditing(true)}
            className="flex items-center space-x-2 px-4 py-2 bg-kaki-600 hover:bg-kaki-700 text-white rounded-lg transition-colors"
          >
            <Edit className="w-4 h-4" />
            <span>Modifier</span>
          </button>
        ) : (
          <div className="flex space-x-2">
            <button
              onClick={handleSave}
              disabled={loading}
              className="flex items-center space-x-2 px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg transition-colors disabled:opacity-50"
            >
              <Save className="w-4 h-4" />
              <span>{loading ? 'Sauvegarde...' : 'Sauvegarder'}</span>
            </button>
            <button
              onClick={() => setIsEditing(false)}
              className="flex items-center space-x-2 px-4 py-2 bg-gray-600 hover:bg-gray-700 text-white rounded-lg transition-colors"
            >
              <X className="w-4 h-4" />
              <span>Annuler</span>
            </button>
          </div>
        )}
      </div>

      {isEditing ? (
        <div className="space-y-6">
          {/* Informations générales */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Nom du site
              </label>
              <input
                type="text"
                value={config.site_name}
                onChange={(e) => setConfig({ ...config, site_name: e.target.value })}
                className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                placeholder="U SILENZIU"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Slogan
              </label>
              <input
                type="text"
                value={config.site_slogan || ''}
                onChange={(e) => setConfig({ ...config, site_slogan: e.target.value })}
                className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                placeholder="Énergie positive garantie !"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Description du site
            </label>
            <textarea
              value={config.site_description || ''}
              onChange={(e) => setConfig({ ...config, site_description: e.target.value })}
              rows={3}
              className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
              placeholder="Description du site..."
            />
          </div>

          {/* Informations de contact */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Téléphone
              </label>
              <input
                type="text"
                value={config.contact_phone || ''}
                onChange={(e) => setConfig({ ...config, contact_phone: e.target.value })}
                className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                placeholder="+33 7 83 83 64 53"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Email
              </label>
              <input
                type="email"
                value={config.contact_email || ''}
                onChange={(e) => setConfig({ ...config, contact_email: e.target.value })}
                className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                placeholder="info@usilenziu.com"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Adresse
              </label>
              <input
                type="text"
                value={config.contact_address || ''}
                onChange={(e) => setConfig({ ...config, contact_address: e.target.value })}
                className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                placeholder="18 Rue du Pont Long, 64160 Buros"
              />
            </div>
          </div>

          {/* Horaires d'ouverture */}
          <div>
            <h3 className="text-lg font-semibold text-white mb-4">Horaires d'ouverture</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {[
                { key: 'opening_hours_monday', label: 'Lundi' },
                { key: 'opening_hours_tuesday', label: 'Mardi' },
                { key: 'opening_hours_wednesday', label: 'Mercredi' },
                { key: 'opening_hours_thursday', label: 'Jeudi' },
                { key: 'opening_hours_friday', label: 'Vendredi' },
                { key: 'opening_hours_saturday', label: 'Samedi' },
                { key: 'opening_hours_sunday', label: 'Dimanche' }
              ].map(({ key, label }) => (
                <div key={key}>
                  <label className="block text-sm font-medium text-gray-300 mb-2">
                    {label}
                  </label>
                  <input
                    type="text"
                    value={config[key as keyof FooterConfig] as string || ''}
                    onChange={(e) => setConfig({ ...config, [key]: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                    placeholder="14:00 – 21:00"
                  />
                </div>
              ))}
            </div>
          </div>

          {/* Call to Action */}
          <div>
            <h3 className="text-lg font-semibold text-white mb-4">Call to Action</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  Titre
                </label>
                <input
                  type="text"
                  value={config.cta_title || ''}
                  onChange={(e) => setConfig({ ...config, cta_title: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                  placeholder="Prêt à libérer votre stress ?"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  Texte du bouton
                </label>
                <input
                  type="text"
                  value={config.cta_button_text || ''}
                  onChange={(e) => setConfig({ ...config, cta_button_text: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                  placeholder="Réserver maintenant"
                />
              </div>
            </div>
            <div className="mt-4">
              <label className="block text-sm font-medium text-gray-300 mb-2">
                URL du bouton
              </label>
              <input
                type="text"
                value={config.cta_button_url || ''}
                onChange={(e) => setConfig({ ...config, cta_button_url: e.target.value })}
                className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                placeholder="/reservation"
              />
            </div>
          </div>

          {/* Liens légaux */}
          <div>
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-white">Liens légaux</h3>
              <button
                onClick={addLegalLink}
                className="flex items-center space-x-2 px-3 py-1 bg-kaki-600 hover:bg-kaki-700 text-white rounded-md transition-colors"
              >
                <Plus className="w-4 h-4" />
                <span>Ajouter</span>
              </button>
            </div>
            <div className="space-y-3">
              {config.legal_links.map((link, index) => (
                <div key={index} className="flex space-x-2">
                  <input
                    type="text"
                    value={link.label}
                    onChange={(e) => updateLegalLink(index, 'label', e.target.value)}
                    className="flex-1 px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                    placeholder="Label du lien"
                  />
                  <input
                    type="text"
                    value={link.url}
                    onChange={(e) => updateLegalLink(index, 'url', e.target.value)}
                    className="flex-1 px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                    placeholder="/url"
                  />
                  <button
                    onClick={() => removeLegalLink(index)}
                    className="px-3 py-2 bg-red-600 hover:bg-red-700 text-white rounded-md transition-colors"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              ))}
            </div>
          </div>

          {/* Copyright */}
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Texte de copyright
            </label>
            <input
              type="text"
              value={config.copyright_text || ''}
              onChange={(e) => setConfig({ ...config, copyright_text: e.target.value })}
              className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
              placeholder="© 2024 U Silenziu. Tous droits réservés."
            />
          </div>
        </div>
      ) : (
        <div className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <h4 className="text-sm font-medium text-gray-400 mb-1">Nom du site</h4>
              <p className="text-white">{config.site_name}</p>
            </div>
            <div>
              <h4 className="text-sm font-medium text-gray-400 mb-1">Slogan</h4>
              <p className="text-white">{config.site_slogan || 'Non défini'}</p>
            </div>
          </div>
          <div>
            <h4 className="text-sm font-medium text-gray-400 mb-1">Description</h4>
            <p className="text-white">{config.site_description || 'Non définie'}</p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <h4 className="text-sm font-medium text-gray-400 mb-1">Téléphone</h4>
              <p className="text-white">{config.contact_phone || 'Non défini'}</p>
            </div>
            <div>
              <h4 className="text-sm font-medium text-gray-400 mb-1">Email</h4>
              <p className="text-white">{config.contact_email || 'Non défini'}</p>
            </div>
            <div>
              <h4 className="text-sm font-medium text-gray-400 mb-1">Adresse</h4>
              <p className="text-white">{config.contact_address || 'Non définie'}</p>
            </div>
          </div>
          <div>
            <h4 className="text-sm font-medium text-gray-400 mb-1">Call to Action</h4>
            <p className="text-white">{config.cta_title || 'Non défini'}</p>
          </div>
          <div>
            <h4 className="text-sm font-medium text-gray-400 mb-1">Liens légaux</h4>
            <p className="text-white">{config.legal_links.length} lien(s) configuré(s)</p>
          </div>
        </div>
      )}

      <div className="mt-6 pt-4 border-t border-gray-700">
        <a
          href="/"
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center space-x-2 text-kaki-400 hover:text-kaki-300 transition-colors"
        >
          <Monitor className="w-4 h-4" />
          <span>Voir le pied de page sur le site</span>
        </a>
      </div>
    </div>
  )
}

// Éditeur spécifique pour la section Hero
const HeroEditor = ({ section, formData, setFormData }: SectionEditorProps) => {
  const [features, setFeatures] = useState(() => {
    try {
      const content = JSON.parse(section.content || '{}')
      return content.features || [
        { icon: 'Shield', title: '100% Sécurisé', description: 'Équipement complet fourni' },
        { icon: 'Zap', title: 'Décompression', description: 'Évacuez votre stress' },
        { icon: 'Clock', title: 'Flexibilité', description: 'Sessions de 20-30 min' }
      ]
    } catch {
      return [
        { icon: 'Shield', title: '100% Sécurisé', description: 'Équipement complet fourni' },
        { icon: 'Zap', title: 'Décompression', description: 'Évacuez votre stress' },
        { icon: 'Clock', title: 'Flexibilité', description: 'Sessions de 20-30 min' }
      ]
    }
  })

  const [ctaPrimary, setCtaPrimary] = useState(() => {
    try {
      const content = JSON.parse(section.content || '{}')
      return content.cta_primary || 'Réserver maintenant'
    } catch {
      return 'Réserver maintenant'
    }
  })

  const [ctaSecondary, setCtaSecondary] = useState(() => {
    try {
      const content = JSON.parse(section.content || '{}')
      return content.cta_secondary || 'Découvrir nos salles'
    } catch {
      return 'Découvrir nos salles'
    }
  })

  const updateContent = () => {
    const newContent = {
      features,
      cta_primary: ctaPrimary,
      cta_secondary: ctaSecondary
    }
    setFormData({ ...formData, content: JSON.stringify(newContent, null, 2) })
  }

  useEffect(() => {
    updateContent()
  }, [features, ctaPrimary, ctaSecondary])

  const addFeature = () => {
    setFeatures([...features, { icon: 'Zap', title: 'Nouvelle fonctionnalité', description: 'Description' }])
  }

  const removeFeature = (index: number) => {
    setFeatures(features.filter((_: any, i: number) => i !== index))
  }

  const updateFeature = (index: number, field: string, value: string) => {
    const newFeatures = [...features]
    newFeatures[index] = { ...newFeatures[index], [field]: value }
    setFeatures(newFeatures)
  }

  return (
    <div className="space-y-6">
      {/* Titre et sous-titre */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Titre principal
          </label>
          <input
            type="text"
            value={formData.title}
            onChange={(e) => setFormData({ ...formData, title: e.target.value })}
            className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
            placeholder="Libérez votre STRESS"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Sous-titre
          </label>
          <textarea
            value={formData.subtitle}
            onChange={(e) => setFormData({ ...formData, subtitle: e.target.value })}
            rows={3}
            className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
            placeholder="Description de la section hero"
          />
        </div>
      </div>

      {/* Boutons CTA */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Bouton principal
          </label>
          <input
            type="text"
            value={ctaPrimary}
            onChange={(e) => setCtaPrimary(e.target.value)}
            className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
            placeholder="Réserver maintenant"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Bouton secondaire
          </label>
          <input
            type="text"
            value={ctaSecondary}
            onChange={(e) => setCtaSecondary(e.target.value)}
            className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
            placeholder="Découvrir nos salles"
          />
        </div>
      </div>

      {/* Fonctionnalités */}
      <div>
        <div className="flex justify-between items-center mb-4">
          <label className="block text-sm font-medium text-gray-300">
            Fonctionnalités (3 max)
          </label>
          {features.length < 3 && (
            <button
              onClick={addFeature}
              className="px-3 py-1 text-sm bg-kaki-600 hover:bg-kaki-700 text-white rounded-md"
            >
              + Ajouter
            </button>
          )}
        </div>
        <div className="space-y-3">
          {features.map((feature: any, index: number) => (
            <div key={index} className="bg-gray-700 p-4 rounded-md border border-gray-600">
              <div className="flex justify-between items-start mb-3">
                <h4 className="text-sm font-medium text-white">Fonctionnalité {index + 1}</h4>
                {features.length > 1 && (
                  <button
                    onClick={() => removeFeature(index)}
                    className="text-red-400 hover:text-red-300"
                  >
                    <X className="w-4 h-4" />
                  </button>
                )}
              </div>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                <div>
                  <label className="block text-xs text-gray-400 mb-1">Icône</label>
                  <select
                    value={feature.icon}
                    onChange={(e) => updateFeature(index, 'icon', e.target.value)}
                    className="w-full px-2 py-1 border border-gray-600 rounded bg-gray-800 text-white text-sm"
                  >
                    <option value="Shield">Shield</option>
                    <option value="Zap">Zap</option>
                    <option value="Clock">Clock</option>
                    <option value="Target">Target</option>
                    <option value="Users">Users</option>
                    <option value="Recycle">Recycle</option>
                    <option value="Music">Music</option>
                  </select>
                </div>
                <div>
                  <label className="block text-xs text-gray-400 mb-1">Titre</label>
                  <input
                    type="text"
                    value={feature.title}
                    onChange={(e) => updateFeature(index, 'title', e.target.value)}
                    className="w-full px-2 py-1 border border-gray-600 rounded bg-gray-800 text-white text-sm"
                    placeholder="Titre de la fonctionnalité"
                  />
                </div>
                <div>
                  <label className="block text-xs text-gray-400 mb-1">Description</label>
                  <input
                    type="text"
                    value={feature.description}
                    onChange={(e) => updateFeature(index, 'description', e.target.value)}
                    className="w-full px-2 py-1 border border-gray-600 rounded bg-gray-800 text-white text-sm"
                    placeholder="Description courte"
                  />
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Médias */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            URL de l'image de fond
          </label>
          <input
            type="text"
            value={formData.image_url}
            onChange={(e) => setFormData({ ...formData, image_url: e.target.value })}
            className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
            placeholder="/images/hero-poster.jpg"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            URL de la vidéo de fond
          </label>
          <input
            type="text"
            value={formData.video_url}
            onChange={(e) => setFormData({ ...formData, video_url: e.target.value })}
            className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
            placeholder="/video/hero-video.mp4"
          />
        </div>
      </div>
    </div>
  )
}

// Éditeur spécifique pour la section Contact
const ContactEditor = ({ section, formData, setFormData }: SectionEditorProps) => {
  const [contactInfo, setContactInfo] = useState(() => {
    try {
      const content = JSON.parse(section.content || '{}')
      return content.contact_info || [
        {
          icon: 'Phone',
          title: 'Téléphone',
          details: '+33 7 83 83 64 53',
          link: 'tel:+33783836453'
        },
        {
          icon: 'Mail',
          title: 'Email',
          details: 'info@usilenziu.com',
          link: 'mailto:info@usilenziu.com'
        },
        {
          icon: 'MapPin',
          title: 'Adresse',
          details: '18 Rue du Pont Long\n64160 Buros\nZone Berlanne',
          link: 'https://maps.google.com/?q=18+Rue+du+Pont+Long+64160+Buros'
        }
      ]
    } catch {
      return [
        {
          icon: 'Phone',
          title: 'Téléphone',
          details: '+33 7 83 83 64 53',
          link: 'tel:+33783836453'
        },
        {
          icon: 'Mail',
          title: 'Email',
          details: 'info@usilenziu.com',
          link: 'mailto:info@usilenziu.com'
        },
        {
          icon: 'MapPin',
          title: 'Adresse',
          details: '18 Rue du Pont Long\n64160 Buros\nZone Berlanne',
          link: 'https://maps.google.com/?q=18+Rue+du+Pont+Long+64160+Buros'
        }
      ]
    }
  })

  const [horaires, setHoraires] = useState(() => {
    try {
      const content = JSON.parse(section.content || '{}')
      return content.horaires || [
        {
          jours: 'Mardi au Jeudi',
          heures: '14:00 – 21:00'
        },
        {
          jours: 'Vendredi au Samedi',
          heures: '14:00 – 00:00'
        },
        {
          jours: 'Dimanche',
          heures: 'Sur réservation uniquement',
          note: 'Minimum 5 personnes - Merci de nous appeler'
        }
      ]
    } catch {
      return [
        {
          jours: 'Mardi au Jeudi',
          heures: '14:00 – 21:00'
        },
        {
          jours: 'Vendredi au Samedi',
          heures: '14:00 – 00:00'
        },
        {
          jours: 'Dimanche',
          heures: 'Sur réservation uniquement',
          note: 'Minimum 5 personnes - Merci de nous appeler'
        }
      ]
    }
  })

  const [formOptions, setFormOptions] = useState(() => {
    try {
      const content = JSON.parse(section.content || '{}')
      return content.form_options || {
        formules: [
          'Pas Content! (20 min)',
          'Vraiment pas Content! (30 min)',
          'Grosse colère (30 min - Privatisé)'
        ],
        nb_personnes: [
          '1 personne',
          '2 personnes',
          '3 personnes',
          '4 personnes',
          '5 personnes',
          'Plus de 5 personnes'
        ],
        submit_text: 'Envoyer ma demande de réservation',
        disclaimer: '* Champs obligatoires. Nous vous recontacterons dans les plus brefs délais pour confirmer votre réservation. Vos données sont protégées conformément au RGPD.'
      }
    } catch {
      return {
        formules: [
          'Pas Content! (20 min)',
          'Vraiment pas Content! (30 min)',
          'Grosse colère (30 min - Privatisé)'
        ],
        nb_personnes: [
          '1 personne',
          '2 personnes',
          '3 personnes',
          '4 personnes',
          '5 personnes',
          'Plus de 5 personnes'
        ],
        submit_text: 'Envoyer ma demande de réservation',
        disclaimer: '* Champs obligatoires. Nous vous recontacterons dans les plus brefs délais pour confirmer votre réservation. Vos données sont protégées conformément au RGPD.'
      }
    }
  })

  const updateContent = () => {
    const newContent = {
      contact_info: contactInfo,
      horaires,
      form_options: formOptions
    }
    setFormData({ ...formData, content: JSON.stringify(newContent, null, 2) })
  }

  useEffect(() => {
    updateContent()
  }, [contactInfo, horaires, formOptions])

  const updateContactInfo = (index: number, field: string, value: string) => {
    const newContactInfo = [...contactInfo]
    newContactInfo[index] = { ...newContactInfo[index], [field]: value }
    setContactInfo(newContactInfo)
  }

  const updateHoraire = (index: number, field: string, value: string) => {
    const newHoraires = [...horaires]
    newHoraires[index] = { ...newHoraires[index], [field]: value }
    setHoraires(newHoraires)
  }

  const updateFormOptions = (field: string, value: any) => {
    setFormOptions({ ...formOptions, [field]: value })
  }

  const addFormule = () => {
    const newFormules = [...formOptions.formules, 'Nouvelle formule']
    updateFormOptions('formules', newFormules)
  }

  const removeFormule = (index: number) => {
    if (formOptions.formules.length > 1) {
      const newFormules = formOptions.formules.filter((_: any, i: number) => i !== index)
      updateFormOptions('formules', newFormules)
    }
  }

  const addNbPersonne = () => {
    const newNbPersonnes = [...formOptions.nb_personnes, 'Nouvelle option']
    updateFormOptions('nb_personnes', newNbPersonnes)
  }

  const removeNbPersonne = (index: number) => {
    if (formOptions.nb_personnes.length > 1) {
      const newNbPersonnes = formOptions.nb_personnes.filter((_: any, i: number) => i !== index)
      updateFormOptions('nb_personnes', newNbPersonnes)
    }
  }

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Titre principal
          </label>
          <input
            type="text"
            value={formData.title}
            onChange={(e) => setFormData({ ...formData, title: e.target.value })}
            className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            placeholder="Nous Contacter"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Sous-titre
          </label>
          <textarea
            value={formData.subtitle}
            onChange={(e) => setFormData({ ...formData, subtitle: e.target.value })}
            className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            rows={3}
            placeholder="Prêt à réserver votre session de défoulement ? Notre équipe est là pour vous accompagner."
          />
        </div>
      </div>

      {/* Informations de contact */}
      <div>
        <h3 className="text-lg font-medium text-white mb-4">Informations de contact</h3>
        <div className="space-y-4">
          {contactInfo.map((info: any, index: number) => (
            <div key={index} className="bg-gray-800 p-4 rounded-lg border border-gray-700">
              <div className="flex justify-between items-start mb-4">
                <h4 className="text-white font-medium">Contact {index + 1}</h4>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-1">
                    Icône
                  </label>
                  <select
                    value={info.icon}
                    onChange={(e) => updateContactInfo(index, 'icon', e.target.value)}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                  >
                    <option value="Phone">Téléphone</option>
                    <option value="Mail">Email</option>
                    <option value="MapPin">Adresse</option>
                    <option value="Clock">Horloge</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-1">
                    Titre
                  </label>
                  <input
                    type="text"
                    value={info.title}
                    onChange={(e) => updateContactInfo(index, 'title', e.target.value)}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-1">
                    Détails
                  </label>
                  <textarea
                    value={info.details}
                    onChange={(e) => updateContactInfo(index, 'details', e.target.value)}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                    rows={3}
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-1">
                    Lien
                  </label>
                  <input
                    type="text"
                    value={info.link}
                    onChange={(e) => updateContactInfo(index, 'link', e.target.value)}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                  />
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Horaires */}
      <div>
        <h3 className="text-lg font-medium text-white mb-4">Horaires d'ouverture</h3>
        <div className="space-y-4">
          {horaires.map((horaire: any, index: number) => (
            <div key={index} className="bg-gray-800 p-4 rounded-lg border border-gray-700">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-1">
                    Jours
                  </label>
                  <input
                    type="text"
                    value={horaire.jours}
                    onChange={(e) => updateHoraire(index, 'jours', e.target.value)}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-1">
                    Heures
                  </label>
                  <input
                    type="text"
                    value={horaire.heures}
                    onChange={(e) => updateHoraire(index, 'heures', e.target.value)}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-1">
                    Note (optionnel)
                  </label>
                  <input
                    type="text"
                    value={horaire.note || ''}
                    onChange={(e) => updateHoraire(index, 'note', e.target.value)}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                  />
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Options du formulaire */}
      <div>
        <h3 className="text-lg font-medium text-white mb-4">Options du formulaire de réservation</h3>
        
        {/* Formules */}
        <div className="bg-gray-800 p-4 rounded-lg border border-gray-700 mb-4">
          <div className="flex justify-between items-center mb-4">
            <h4 className="text-white font-medium">Formules disponibles</h4>
            <button
              onClick={addFormule}
              className="px-3 py-1 bg-kaki-600 hover:bg-kaki-700 text-white rounded-md transition-colors text-sm"
            >
              Ajouter
            </button>
          </div>
          <div className="space-y-2">
            {formOptions.formules.map((formule: any, index: number) => (
              <div key={index} className="flex items-center gap-2">
                <input
                  type="text"
                  value={formule}
                  onChange={(e) => {
                    const newFormules = [...formOptions.formules]
                    newFormules[index] = e.target.value
                    updateFormOptions('formules', newFormules)
                  }}
                  className="flex-1 px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                />
                {formOptions.formules.length > 1 && (
                  <button
                    onClick={() => removeFormule(index)}
                    className="text-red-400 hover:text-red-300 transition-colors"
                  >
                    Supprimer
                  </button>
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Nombre de personnes */}
        <div className="bg-gray-800 p-4 rounded-lg border border-gray-700 mb-4">
          <div className="flex justify-between items-center mb-4">
            <h4 className="text-white font-medium">Options nombre de personnes</h4>
            <button
              onClick={addNbPersonne}
              className="px-3 py-1 bg-kaki-600 hover:bg-kaki-700 text-white rounded-md transition-colors text-sm"
            >
              Ajouter
            </button>
          </div>
          <div className="space-y-2">
            {formOptions.nb_personnes.map((option: any, index: number) => (
              <div key={index} className="flex items-center gap-2">
                <input
                  type="text"
                  value={option}
                  onChange={(e) => {
                    const newNbPersonnes = [...formOptions.nb_personnes]
                    newNbPersonnes[index] = e.target.value
                    updateFormOptions('nb_personnes', newNbPersonnes)
                  }}
                  className="flex-1 px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                />
                {formOptions.nb_personnes.length > 1 && (
                  <button
                    onClick={() => removeNbPersonne(index)}
                    className="text-red-400 hover:text-red-300 transition-colors"
                  >
                    Supprimer
                  </button>
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Texte du bouton et disclaimer */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Texte du bouton
            </label>
            <input
              type="text"
              value={formOptions.submit_text}
              onChange={(e) => updateFormOptions('submit_text', e.target.value)}
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Texte de disclaimer
            </label>
            <textarea
              value={formOptions.disclaimer}
              onChange={(e) => updateFormOptions('disclaimer', e.target.value)}
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
              rows={3}
            />
          </div>
        </div>
      </div>

      {/* Autres champs */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            URL de l'image
          </label>
          <input
            type="text"
            value={formData.image_url}
            onChange={(e) => setFormData({ ...formData, image_url: e.target.value })}
            className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            placeholder="/images/section-image.jpg"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            URL de la vidéo
          </label>
          <input
            type="text"
            value={formData.video_url}
            onChange={(e) => setFormData({ ...formData, video_url: e.target.value })}
            className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            placeholder="/video/section-video.mp4"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Couleur de fond
          </label>
          <input
            type="text"
            value={formData.background_color}
            onChange={(e) => setFormData({ ...formData, background_color: e.target.value })}
            className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            placeholder="bg-dark-bg"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Couleur du texte
          </label>
          <input
            type="text"
            value={formData.text_color}
            onChange={(e) => setFormData({ ...formData, text_color: e.target.value })}
            className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            placeholder="text-white"
          />
        </div>
      </div>

      <div className="flex items-center">
        <input
          type="checkbox"
          id="is_active"
          checked={formData.is_active}
          onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
          className="h-4 w-4 text-kaki-600 focus:ring-kaki-500 border-gray-300 rounded"
        />
        <label htmlFor="is_active" className="ml-2 block text-sm text-gray-300">
          Section active
        </label>
      </div>
    </div>
  )
}

// Éditeur spécifique pour la section FAQ
const FAQEditor = ({ section, formData, setFormData }: SectionEditorProps) => {
  const [questions, setQuestions] = useState(() => {
    try {
      const content = JSON.parse(section.content || '{}')
      return content.questions || [
        {
          question: 'C\'est quoi une salle de défoulement ?',
          answer: 'Une salle de défoulement est exactement ce que son nom indique : un endroit où l\'on peut se défouler en toute liberté. L\'idée est de fournir un environnement sûr et contrôlé où il est permis de casser et briser des objets sans devoir nettoyer après. Non seulement c\'est une excellente thérapie pour soulager le stress, mais c\'est aussi une expérience extrêmement amusante !'
        },
        {
          question: 'Comment m\'habiller pour ma séance de défoulement ?',
          answer: 'Nous vous recommandons une tenue ample et confortable pour vous sentir à l\'aise et libre de vos mouvements, c\'est physique ! Pour votre sécurité, il est OBLIGATOIRE de venir avec des chaussures fermées et plates de type baskets. En complément, nous vous fournissons une combinaison de sécurité complète et des lunettes de sécurité.'
        },
        {
          question: 'Quels types d\'objets puis-je casser ?',
          answer: 'Selon la formule choisie, vous pourrez casser des bouteilles ou tout autre type d\'objets tels que des verres, des objets multimédia (PC, imprimantes, écrans), du petit électroménager comme grille-pain, machine à café... Les objets varient selon notre arrivage.'
        },
        {
          question: 'Tout ça, c\'est du gaspillage quand même ?',
          answer: 'Pas du tout ! Après chaque séance, les objets cassés sont collectés et pris en charge par des sociétés spécialisées qui s\'occupent du tri, du recyclage, ou de l\'élimination dans le respect des normes en vigueur. Nous faisons en sorte de limiter au maximum l\'impact environnemental de nos activités.'
        },
        {
          question: 'Puis-je écouter ma propre musique pendant ma séance ?',
          answer: 'Bien entendu, chaque pièce est équipée d\'enceintes connectées en Bluetooth, vous pouvez donc vous y connecter et profiter de votre musique préférée !'
        },
        {
          question: 'J\'ai effectué une réservation, puis-je annuler et être remboursé ?',
          answer: 'Dans un souci d\'organisation, les séances annulées ne sont pas remboursables, y compris l\'avoir déjà versé. Cependant, nous vous invitons à nous contacter au plus tôt pour toute demande d\'annulation. Soyez assurés que nous ferons notre possible pour trouver une solution adaptée à votre situation.'
        },
        {
          question: 'Est-il obligatoire de réserver ?',
          answer: 'Il est fortement conseillé de réserver votre session à l\'avance. Cela nous permet de garantir que votre salle soit prête dans les meilleures conditions possibles, avec tout le matériel nécessaire et les équipements adaptés à votre expérience, afin que vous puissiez profiter pleinement de votre moment de défoulement dans un cadre sécurisé et bien organisé.'
        },
        {
          question: 'Je suis une personne à mobilité réduite, puis-je venir ?',
          answer: 'Bien sûr ! Tant que vous êtes en mesure de manier une batte de baseball pour casser des objets, notre équipe sera ravie de vous accueillir et de vous faire profiter de l\'expérience en toute sécurité. L\'ensemble de notre établissement et nos différentes activités sont accessibles aux PMR.'
        },
        {
          question: 'Puis-je laisser mes affaires en toute sécurité ?',
          answer: 'Nous mettons à votre disposition des casiers sécurisés où vous pouvez entreposer vos objets de valeur pendant toute la durée de votre séance. Vous pouvez ainsi profiter pleinement de votre activité sans vous soucier de la sécurité de vos effets personnels.'
        }
      ]
    } catch {
      return [
        {
          question: 'C\'est quoi une salle de défoulement ?',
          answer: 'Une salle de défoulement est exactement ce que son nom indique : un endroit où l\'on peut se défouler en toute liberté. L\'idée est de fournir un environnement sûr et contrôlé où il est permis de casser et briser des objets sans devoir nettoyer après. Non seulement c\'est une excellente thérapie pour soulager le stress, mais c\'est aussi une expérience extrêmement amusante !'
        },
        {
          question: 'Comment m\'habiller pour ma séance de défoulement ?',
          answer: 'Nous vous recommandons une tenue ample et confortable pour vous sentir à l\'aise et libre de vos mouvements, c\'est physique ! Pour votre sécurité, il est OBLIGATOIRE de venir avec des chaussures fermées et plates de type baskets. En complément, nous vous fournissons une combinaison de sécurité complète et des lunettes de sécurité.'
        },
        {
          question: 'Quels types d\'objets puis-je casser ?',
          answer: 'Selon la formule choisie, vous pourrez casser des bouteilles ou tout autre type d\'objets tels que des verres, des objets multimédia (PC, imprimantes, écrans), du petit électroménager comme grille-pain, machine à café... Les objets varient selon notre arrivage.'
        },
        {
          question: 'Tout ça, c\'est du gaspillage quand même ?',
          answer: 'Pas du tout ! Après chaque séance, les objets cassés sont collectés et pris en charge par des sociétés spécialisées qui s\'occupent du tri, du recyclage, ou de l\'élimination dans le respect des normes en vigueur. Nous faisons en sorte de limiter au maximum l\'impact environnemental de nos activités.'
        },
        {
          question: 'Puis-je écouter ma propre musique pendant ma séance ?',
          answer: 'Bien entendu, chaque pièce est équipée d\'enceintes connectées en Bluetooth, vous pouvez donc vous y connecter et profiter de votre musique préférée !'
        },
        {
          question: 'J\'ai effectué une réservation, puis-je annuler et être remboursé ?',
          answer: 'Dans un souci d\'organisation, les séances annulées ne sont pas remboursables, y compris l\'avoir déjà versé. Cependant, nous vous invitons à nous contacter au plus tôt pour toute demande d\'annulation. Soyez assurés que nous ferons notre possible pour trouver une solution adaptée à votre situation.'
        },
        {
          question: 'Est-il obligatoire de réserver ?',
          answer: 'Il est fortement conseillé de réserver votre session à l\'avance. Cela nous permet de garantir que votre salle soit prête dans les meilleures conditions possibles, avec tout le matériel nécessaire et les équipements adaptés à votre expérience, afin que vous puissiez profiter pleinement de votre moment de défoulement dans un cadre sécurisé et bien organisé.'
        },
        {
          question: 'Je suis une personne à mobilité réduite, puis-je venir ?',
          answer: 'Bien sûr ! Tant que vous êtes en mesure de manier une batte de baseball pour casser des objets, notre équipe sera ravie de vous accueillir et de vous faire profiter de l\'expérience en toute sécurité. L\'ensemble de notre établissement et nos différentes activités sont accessibles aux PMR.'
        },
        {
          question: 'Puis-je laisser mes affaires en toute sécurité ?',
          answer: 'Nous mettons à votre disposition des casiers sécurisés où vous pouvez entreposer vos objets de valeur pendant toute la durée de votre séance. Vous pouvez ainsi profiter pleinement de votre activité sans vous soucier de la sécurité de vos effets personnels.'
        }
      ]
    }
  })

  const [ctaInfo, setCtaInfo] = useState(() => {
    try {
      const content = JSON.parse(section.content || '{}')
      return content.cta_info || {
        title: 'Vous avez encore des questions ?',
        description: 'Notre équipe est là pour vous aider. N\'hésitez pas à nous contacter pour toute information complémentaire.',
        contact_button: 'Nous contacter',
        reservation_button: 'Réserver maintenant'
      }
    } catch {
      return {
        title: 'Vous avez encore des questions ?',
        description: 'Notre équipe est là pour vous aider. N\'hésitez pas à nous contacter pour toute information complémentaire.',
        contact_button: 'Nous contacter',
        reservation_button: 'Réserver maintenant'
      }
    }
  })

  const updateContent = () => {
    const newContent = {
      questions,
      cta_info: ctaInfo
    }
    setFormData({ ...formData, content: JSON.stringify(newContent, null, 2) })
  }

  useEffect(() => {
    updateContent()
  }, [questions, ctaInfo])

  const updateQuestion = (index: number, field: string, value: string) => {
    const newQuestions = [...questions]
    newQuestions[index] = { ...newQuestions[index], [field]: value }
    setQuestions(newQuestions)
  }

  const addQuestion = () => {
    const newQuestion = {
      question: 'Nouvelle question',
      answer: 'Réponse à la nouvelle question'
    }
    setQuestions([...questions, newQuestion])
  }

  const removeQuestion = (index: number) => {
    if (questions.length > 1) {
      const newQuestions = questions.filter((_: any, i: number) => i !== index)
      setQuestions(newQuestions)
    }
  }

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Titre principal
          </label>
          <input
            type="text"
            value={formData.title}
            onChange={(e) => setFormData({ ...formData, title: e.target.value })}
            className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            placeholder="Questions Fréquentes"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Sous-titre
          </label>
          <textarea
            value={formData.subtitle}
            onChange={(e) => setFormData({ ...formData, subtitle: e.target.value })}
            className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            rows={3}
            placeholder="Trouvez rapidement les réponses à vos questions..."
          />
        </div>
      </div>

      {/* Gestion des questions */}
      <div>
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-lg font-medium text-white">Questions et réponses</h3>
          <button
            onClick={addQuestion}
            className="px-4 py-2 bg-kaki-600 hover:bg-kaki-700 text-white rounded-md transition-colors"
          >
            Ajouter une question
          </button>
        </div>

        <div className="space-y-4">
          {questions.map((question: any, index: number) => (
            <div key={index} className="bg-gray-800 p-4 rounded-lg border border-gray-700">
              <div className="flex justify-between items-start mb-4">
                <h4 className="text-white font-medium">Question {index + 1}</h4>
                {questions.length > 1 && (
                  <button
                    onClick={() => removeQuestion(index)}
                    className="text-red-400 hover:text-red-300 transition-colors"
                  >
                    Supprimer
                  </button>
                )}
              </div>

              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-1">
                    Question
                  </label>
                  <input
                    type="text"
                    value={question.question}
                    onChange={(e) => updateQuestion(index, 'question', e.target.value)}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                    placeholder="Votre question ici..."
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-1">
                    Réponse
                  </label>
                  <textarea
                    value={question.answer}
                    onChange={(e) => updateQuestion(index, 'answer', e.target.value)}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                    rows={4}
                    placeholder="Votre réponse ici..."
                  />
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Section CTA */}
      <div>
        <h3 className="text-lg font-medium text-white mb-4">Section d'appel à l'action</h3>
        <div className="bg-gray-800 p-4 rounded-lg border border-gray-700 space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Titre CTA
            </label>
            <input
              type="text"
              value={ctaInfo.title}
              onChange={(e) => setCtaInfo({ ...ctaInfo, title: e.target.value })}
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Description CTA
            </label>
            <textarea
              value={ctaInfo.description}
              onChange={(e) => setCtaInfo({ ...ctaInfo, description: e.target.value })}
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
              rows={3}
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Bouton Contact
              </label>
              <input
                type="text"
                value={ctaInfo.contact_button}
                onChange={(e) => setCtaInfo({ ...ctaInfo, contact_button: e.target.value })}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Bouton Réservation
              </label>
              <input
                type="text"
                value={ctaInfo.reservation_button}
                onChange={(e) => setCtaInfo({ ...ctaInfo, reservation_button: e.target.value })}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
              />
            </div>
          </div>
        </div>
      </div>

      {/* Autres champs */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            URL de l'image
          </label>
          <input
            type="text"
            value={formData.image_url}
            onChange={(e) => setFormData({ ...formData, image_url: e.target.value })}
            className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            placeholder="/images/section-image.jpg"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            URL de la vidéo
          </label>
          <input
            type="text"
            value={formData.video_url}
            onChange={(e) => setFormData({ ...formData, video_url: e.target.value })}
            className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            placeholder="/video/section-video.mp4"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Couleur de fond
          </label>
          <input
            type="text"
            value={formData.background_color}
            onChange={(e) => setFormData({ ...formData, background_color: e.target.value })}
            className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            placeholder="bg-dark-surface"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Couleur du texte
          </label>
          <input
            type="text"
            value={formData.text_color}
            onChange={(e) => setFormData({ ...formData, text_color: e.target.value })}
            className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            placeholder="text-white"
          />
        </div>
      </div>

      <div className="flex items-center">
        <input
          type="checkbox"
          id="is_active"
          checked={formData.is_active}
          onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
          className="h-4 w-4 text-kaki-600 focus:ring-kaki-500 border-gray-300 rounded"
        />
        <label htmlFor="is_active" className="ml-2 block text-sm text-gray-300">
          Section active
        </label>
      </div>
    </div>
  )
}

const DEFAULT_COMMENT_STEPS = [
  {
    icon: 'check',
    title: 'Accueil des participants',
    description: 'Nos équipes vous accueillent et vérifient vos réservations',
    duration: '5 min'
  },
  {
    icon: 'shield',
    title: "Zone d'équipement",
    description: "Équipement complet de sécurité de la tête aux pieds",
    duration: '10 min'
  },
  {
    icon: 'alert-triangle',
    title: 'Consignes de sécurité',
    description: 'Briefing sécurité et petit échauffement avant la session',
    duration: '5 min'
  },
  {
    icon: 'music',
    title: 'Session de défoulement',
    description: 'La musique commence et la salle est à vous !',
    duration: '20-30 min'
  },
  {
    icon: 'refresh-cw',
    title: "Retrait de l'équipement",
    description: 'Déséquipement et retour au calme',
    duration: '10 min'
  }
]

const COMMENT_ICON_OPTIONS = [
  'check',
  'shield',
  'alert-triangle',
  'music',
  'refresh-cw',
  'clock',
  'target',
  'zap',
  'smile',
  'heart',
  'star'
]

const ensureCommentText = (value: unknown, fallback = ''): string => {
  if (typeof value === 'string') {
    return value
  }
  if (typeof value === 'number' && Number.isFinite(value)) {
    return String(value)
  }
  return fallback
}

const normalizeCommentStep = (step: unknown, index: number) => {
  const defaultStep = DEFAULT_COMMENT_STEPS[index] || DEFAULT_COMMENT_STEPS[0]
  
  // Vérifier que step est un objet
  const stepObj = step && typeof step === 'object' ? step as Record<string, unknown> : {}
  
  const rawIcon = ensureCommentText(stepObj?.icon).trim().toLowerCase()
  const icon = COMMENT_ICON_OPTIONS.includes(rawIcon) ? rawIcon : COMMENT_ICON_OPTIONS[0]

  const durationValue = stepObj?.duration
  let duration = defaultStep.duration
  if (typeof durationValue === 'number' && Number.isFinite(durationValue)) {
    duration = `${durationValue} min`
  } else if (typeof durationValue === 'string') {
    const trimmed = durationValue.trim()
    duration = trimmed.length > 0 ? trimmed : defaultStep.duration
  }

  return {
    icon,
    title: ensureCommentText(stepObj?.title, defaultStep.title),
    description: ensureCommentText(stepObj?.description, defaultStep.description),
    duration
  }
}

const loadCommentSteps = (content?: string) => {
  if (!content) {
    return DEFAULT_COMMENT_STEPS.map(step => ({ ...step }))
  }

  try {
    const parsed = JSON.parse(content)
    if (Array.isArray(parsed?.steps) && parsed.steps.length > 0) {
      return parsed.steps.map((step: unknown, index: number) => normalizeCommentStep(step, index))
    }
  } catch (error) {
    console.warn('Impossible de parser le contenu comment-ca-marche:', error)
  }

  return DEFAULT_COMMENT_STEPS.map(step => ({ ...step }))
}

const CommentCaMarcheEditor = ({ section, formData, setFormData }: SectionEditorProps) => {
  const [steps, setSteps] = useState(() => loadCommentSteps(section.content))

  useEffect(() => {
    setSteps(loadCommentSteps(section.content))
  }, [section.id, section.content])

  useEffect(() => {
    const sanitizedSteps = steps.map((step: unknown, index: number) => normalizeCommentStep(step, index))
    const serialized = JSON.stringify({ steps: sanitizedSteps }, null, 2)
    setFormData({ ...formData, content: serialized })
  }, [steps])

  const updateStep = (index: number, field: 'title' | 'description' | 'icon' | 'duration', value: string) => {
    setSteps((prev: unknown) => {
      const next = [...(prev as any[])]
      next[index] = { ...next[index], [field]: value }
      return next
    })
  }

  const addStep = () => {
    setSteps((prev: unknown) => [
      ...(prev as any[]),
      {
        icon: COMMENT_ICON_OPTIONS[0],
        title: 'Nouvelle étape',
        description: "Description de l'étape",
        duration: '5 min'
      }
    ])
  }

  const removeStep = (index: number) => {
    setSteps((prev: unknown) => {
      const prevArray = prev as any[]
      return prevArray.length > 1 ? prevArray.filter((_, i) => i !== index) : prevArray
    })
  }

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Titre principal
          </label>
          <input
            type="text"
            value={formData.title}
            onChange={(e) => setFormData({ ...formData, title: e.target.value })}
            className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            placeholder="Comment fonctionne une séance ?"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Sous-titre
          </label>
          <textarea
            value={formData.subtitle}
            onChange={(e) => setFormData({ ...formData, subtitle: e.target.value })}
            className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            rows={3}
            placeholder="Découvrez le déroulement type d'une session..."
          />
        </div>
      </div>

      <div className="flex justify-between items-center mb-4">
        <h3 className="text-lg font-medium text-white">Étapes de la séance</h3>
        <button
          onClick={addStep}
          className="px-4 py-2 bg-kaki-600 hover:bg-kaki-700 text-white rounded-md transition-colors"
        >
          Ajouter une étape
        </button>
      </div>

      <div className="space-y-4">
        {steps.map((step: unknown, index: number) => {
          const stepData = step as { icon: string; title: string; description: string; duration: string }
          return (
          <div key={index} className="bg-gray-800 p-4 rounded-lg border border-gray-700 space-y-4">
            <div className="flex items-center justify-between">
              <h4 className="text-white font-medium">Étape {index + 1}</h4>
              {steps.length > 1 && (
                <button
                  onClick={() => removeStep(index)}
                  className="text-red-400 hover:text-red-300 transition-colors"
                >
                  Supprimer
                </button>
              )}
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-1">
                  Icône
                </label>
                <select
                  value={stepData.icon}
                  onChange={(e) => updateStep(index, 'icon', e.target.value)}
                  className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                >
                  {COMMENT_ICON_OPTIONS.map(icon => (
                    <option key={icon} value={icon}>{icon}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-300 mb-1">
                  Durée
                </label>
                <input
                  type="text"
                  value={stepData.duration}
                  onChange={(e) => updateStep(index, 'duration', e.target.value)}
                  className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                  placeholder="5 min"
                />
              </div>

              <div className="md:col-span-2 lg:col-span-2">
                <label className="block text-sm font-medium text-gray-300 mb-1">
                  Titre
                </label>
                <input
                  type="text"
                  value={stepData.title}
                  onChange={(e) => updateStep(index, 'title', e.target.value)}
                  className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-300 mb-1">
                Description
              </label>
              <textarea
                value={stepData.description}
                onChange={(e) => updateStep(index, 'description', e.target.value)}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                rows={2}
              />
            </div>
          </div>
          )
        })}
      </div>
    </div>
  )
}


// Éditeur spécifique pour la section Process
const ProcessEditor = ({ section, formData, setFormData }: SectionEditorProps) => {
  const [steps, setSteps] = useState(() => {
    try {
      const content = JSON.parse(section.content || '{}')
      return content.steps || [
        {
          number: 1,
          icon: 'UserCheck',
          title: 'Accueil des participants',
          duration: '5 min',
          description: 'Nos équipes vous accueillent et vérifient vos réservations',
          color: 'from-kaki-400 to-kaki-600'
        },
        {
          number: 2,
          icon: 'Shield',
          title: 'Zone d\'équipement',
          duration: '10 min',
          description: 'Équipement complet de sécurité de la tête aux pieds',
          color: 'from-kaki-500 to-kaki-700'
        },
        {
          number: 3,
          icon: 'AlertTriangle',
          title: 'Consignes de sécurité',
          duration: '5 min',
          description: 'Briefing sécurité et petit échauffement avant la session',
          color: 'from-kaki-600 to-kaki-800'
        },
        {
          number: 4,
          icon: 'Music',
          title: 'Session de défoulement',
          duration: '20-30 min',
          description: 'La musique commence et la salle est à vous !',
          color: 'from-kaki-700 to-kaki-900'
        },
        {
          number: 5,
          icon: 'RotateCcw',
          title: 'Retrait de l\'équipement',
          duration: '10 min',
          description: 'Déséquipement et retour au calme',
          color: 'from-kaki-500 to-kaki-700'
        }
      ]
    } catch {
      return [
        {
          number: 1,
          icon: 'UserCheck',
          title: 'Accueil des participants',
          duration: '5 min',
          description: 'Nos équipes vous accueillent et vérifient vos réservations',
          color: 'from-kaki-400 to-kaki-600'
        },
        {
          number: 2,
          icon: 'Shield',
          title: 'Zone d\'équipement',
          duration: '10 min',
          description: 'Équipement complet de sécurité de la tête aux pieds',
          color: 'from-kaki-500 to-kaki-700'
        },
        {
          number: 3,
          icon: 'AlertTriangle',
          title: 'Consignes de sécurité',
          duration: '5 min',
          description: 'Briefing sécurité et petit échauffement avant la session',
          color: 'from-kaki-600 to-kaki-800'
        },
        {
          number: 4,
          icon: 'Music',
          title: 'Session de défoulement',
          duration: '20-30 min',
          description: 'La musique commence et la salle est à vous !',
          color: 'from-kaki-700 to-kaki-900'
        },
        {
          number: 5,
          icon: 'RotateCcw',
          title: 'Retrait de l\'équipement',
          duration: '10 min',
          description: 'Déséquipement et retour au calme',
          color: 'from-kaki-500 to-kaki-700'
        }
      ]
    }
  })

  const [ctaInfo, setCtaInfo] = useState(() => {
    try {
      const content = JSON.parse(section.content || '{}')
      return content.cta_info || {
        title: 'U Silenziu - Énergie positive',
        description: 'Repartez détendu et libéré de vos tensions. Nos sessions sont conçues pour vous procurer une sensation de bien-être durable.',
        button_text: 'Réserver une salle de défoulement'
      }
    } catch {
      return {
        title: 'U Silenziu - Énergie positive',
        description: 'Repartez détendu et libéré de vos tensions. Nos sessions sont conçues pour vous procurer une sensation de bien-être durable.',
        button_text: 'Réserver une salle de défoulement'
      }
    }
  })

  const updateContent = () => {
    const newContent = {
      steps,
      cta_info: ctaInfo
    }
    setFormData({ ...formData, content: JSON.stringify(newContent, null, 2) })
  }

  useEffect(() => {
    updateContent()
  }, [steps, ctaInfo])

  const updateStep = (index: number, field: string, value: string) => {
    const newSteps = [...steps]
    newSteps[index] = { ...newSteps[index], [field]: value }
    setSteps(newSteps)
  }

  const addStep = () => {
    const newStep = {
      number: steps.length + 1,
      icon: 'UserCheck',
      title: 'Nouvelle étape',
      duration: '5 min',
      description: 'Description de l\'étape',
      color: 'from-kaki-400 to-kaki-600'
    }
    setSteps([...steps, newStep])
  }

  const removeStep = (index: number) => {
    if (steps.length > 1) {
      const newSteps = steps.filter((_: any, i: number) => i !== index)
      // Réajuster les numéros
      newSteps.forEach((step: any, i: number) => {
        step.number = i + 1
      })
      setSteps(newSteps)
    }
  }

  const iconOptions = [
    'UserCheck', 'Shield', 'AlertTriangle', 'Music', 'RotateCcw', 'Clock', 'Zap', 'Target', 'Heart', 'Star'
  ]

  const colorOptions = [
    'from-kaki-400 to-kaki-600',
    'from-kaki-500 to-kaki-700',
    'from-kaki-600 to-kaki-800',
    'from-kaki-700 to-kaki-900',
    'from-kaki-400 to-kaki-600',
    'from-green-400 to-green-600',
    'from-purple-400 to-purple-600',
    'from-red-400 to-red-600'
  ]

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Titre principal
          </label>
          <input
            type="text"
            value={formData.title}
            onChange={(e) => setFormData({ ...formData, title: e.target.value })}
            className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            placeholder="Comment fonctionne une séance ?"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Sous-titre
          </label>
          <textarea
            value={formData.subtitle}
            onChange={(e) => setFormData({ ...formData, subtitle: e.target.value })}
            className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            rows={3}
            placeholder="Découvrez le déroulement type d'une session chez U Silenziu..."
          />
        </div>
      </div>

      {/* Gestion des étapes */}
      <div>
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-lg font-medium text-white">Étapes du processus</h3>
          <button
            onClick={addStep}
            className="px-4 py-2 bg-kaki-600 hover:bg-kaki-700 text-white rounded-md transition-colors"
          >
            Ajouter une étape
          </button>
        </div>

        <div className="space-y-4">
          {steps.map((step: any, index: number) => (
            <div key={index} className="bg-gray-800 p-4 rounded-lg border border-gray-700">
              <div className="flex justify-between items-start mb-4">
                <h4 className="text-white font-medium">Étape {step.number}</h4>
                {steps.length > 1 && (
                  <button
                    onClick={() => removeStep(index)}
                    className="text-red-400 hover:text-red-300 transition-colors"
                  >
                    Supprimer
                  </button>
                )}
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-1">
                    Icône
                  </label>
                  <select
                    value={step.icon}
                    onChange={(e) => updateStep(index, 'icon', e.target.value)}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                  >
                    {iconOptions.map(icon => (
                      <option key={icon} value={icon}>{icon}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-1">
                    Titre
                  </label>
                  <input
                    type="text"
                    value={step.title}
                    onChange={(e) => updateStep(index, 'title', e.target.value)}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-1">
                    Durée
                  </label>
                  <input
                    type="text"
                    value={step.duration}
                    onChange={(e) => updateStep(index, 'duration', e.target.value)}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                    placeholder="5 min"
                  />
                </div>

                <div className="md:col-span-2 lg:col-span-3">
                  <label className="block text-sm font-medium text-gray-300 mb-1">
                    Description
                  </label>
                  <textarea
                    value={step.description}
                    onChange={(e) => updateStep(index, 'description', e.target.value)}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                    rows={2}
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-1">
                    Couleur
                  </label>
                  <select
                    value={step.color}
                    onChange={(e) => updateStep(index, 'color', e.target.value)}
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
                  >
                    {colorOptions.map(color => (
                      <option key={color} value={color}>{color}</option>
                    ))}
                  </select>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Section CTA */}
      <div>
        <h3 className="text-lg font-medium text-white mb-4">Section d'appel à l'action</h3>
        <div className="bg-gray-800 p-4 rounded-lg border border-gray-700 space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Titre CTA
            </label>
            <input
              type="text"
              value={ctaInfo.title}
              onChange={(e) => setCtaInfo({ ...ctaInfo, title: e.target.value })}
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Description CTA
            </label>
            <textarea
              value={ctaInfo.description}
              onChange={(e) => setCtaInfo({ ...ctaInfo, description: e.target.value })}
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
              rows={3}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-300 mb-2">
              Texte du bouton
            </label>
            <input
              type="text"
              value={ctaInfo.button_text}
              onChange={(e) => setCtaInfo({ ...ctaInfo, button_text: e.target.value })}
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            />
          </div>
        </div>
      </div>

      {/* Autres champs */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            URL de l'image
          </label>
          <input
            type="text"
            value={formData.image_url}
            onChange={(e) => setFormData({ ...formData, image_url: e.target.value })}
            className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            placeholder="/images/section-image.jpg"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            URL de la vidéo
          </label>
          <input
            type="text"
            value={formData.video_url}
            onChange={(e) => setFormData({ ...formData, video_url: e.target.value })}
            className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            placeholder="/video/section-video.mp4"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Couleur de fond
          </label>
          <input
            type="text"
            value={formData.background_color}
            onChange={(e) => setFormData({ ...formData, background_color: e.target.value })}
            className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            placeholder="bg-dark-surface"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Couleur du texte
          </label>
          <input
            type="text"
            value={formData.text_color}
            onChange={(e) => setFormData({ ...formData, text_color: e.target.value })}
            className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-kaki-500"
            placeholder="text-white"
          />
        </div>
      </div>

      <div className="flex items-center">
        <input
          type="checkbox"
          id="is_active"
          checked={formData.is_active}
          onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
          className="h-4 w-4 text-kaki-600 focus:ring-kaki-500 border-gray-300 rounded"
        />
        <label htmlFor="is_active" className="ml-2 block text-sm text-gray-300">
          Section active
        </label>
      </div>
    </div>
  )
}

// Éditeur spécifique pour la section Concept
const ConceptEditor = ({ section, formData, setFormData }: SectionEditorProps) => {
  const [features, setFeatures] = useState(() => {
    try {
      const content = JSON.parse(section.content || '{}')
      return content.features || [
        { icon: 'Target', title: 'Environnement Sécurisé', description: 'Un espace contrôlé où vous pouvez casser et briser des objets en toute sécurité.' },
        { icon: 'Users', title: 'Pour Tous', description: 'Que vous ayez passé une mauvaise journée ou envie de vous défouler entre amis.' },
        { icon: 'Recycle', title: 'Éco-Responsable', description: 'Tous les objets cassés sont collectés et recyclés par des sociétés spécialisées.' },
        { icon: 'Music', title: 'Ambiance Personnalisée', description: 'Connectez votre musique en Bluetooth et défoulez-vous sur vos morceaux préférés.' }
      ]
    } catch {
      return [
        { icon: 'Target', title: 'Environnement Sécurisé', description: 'Un espace contrôlé où vous pouvez casser et briser des objets en toute sécurité.' },
        { icon: 'Users', title: 'Pour Tous', description: 'Que vous ayez passé une mauvaise journée ou envie de vous défouler entre amis.' },
        { icon: 'Recycle', title: 'Éco-Responsable', description: 'Tous les objets cassés sont collectés et recyclés par des sociétés spécialisées.' },
        { icon: 'Music', title: 'Ambiance Personnalisée', description: 'Connectez votre musique en Bluetooth et défoulez-vous sur vos morceaux préférés.' }
      ]
    }
  })

  const [additionalInfo, setAdditionalInfo] = useState(() => {
    try {
      const content = JSON.parse(section.content || '{}')
      return content.additional_info || {
        title: 'C\'est quoi une salle de défoulement ?',
        content: 'Une salle de défoulement est exactement ce que son nom indique : un endroit où l\'on peut se défouler en toute liberté.'
      }
    } catch {
      return {
        title: 'C\'est quoi une salle de défoulement ?',
        content: 'Une salle de défoulement est exactement ce que son nom indique : un endroit où l\'on peut se défouler en toute liberté.'
      }
    }
  })

  const updateContent = () => {
    const newContent = {
      features,
      additional_info: additionalInfo
    }
    setFormData({ ...formData, content: JSON.stringify(newContent, null, 2) })
  }

  useEffect(() => {
    updateContent()
  }, [features, additionalInfo])

  const updateFeature = (index: number, field: string, value: string) => {
    const newFeatures = [...features]
    newFeatures[index] = { ...newFeatures[index], [field]: value }
    setFeatures(newFeatures)
  }

  return (
    <div className="space-y-6">
      {/* Titre et sous-titre */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Titre principal
          </label>
          <input
            type="text"
            value={formData.title}
            onChange={(e) => setFormData({ ...formData, title: e.target.value })}
            className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
            placeholder="Le Concept"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Sous-titre
          </label>
          <textarea
            value={formData.subtitle}
            onChange={(e) => setFormData({ ...formData, subtitle: e.target.value })}
            rows={3}
            className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
            placeholder="Description du concept"
          />
        </div>
      </div>

      {/* Fonctionnalités */}
      <div>
        <label className="block text-sm font-medium text-gray-300 mb-4">
          Fonctionnalités du concept (4 max)
        </label>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {features.map((feature: any, index: number) => (
            <div key={index} className="bg-gray-700 p-4 rounded-md border border-gray-600">
              <h4 className="text-sm font-medium text-white mb-3">Fonctionnalité {index + 1}</h4>
              <div className="space-y-3">
                <div>
                  <label className="block text-xs text-gray-400 mb-1">Icône</label>
                  <select
                    value={feature.icon}
                    onChange={(e) => updateFeature(index, 'icon', e.target.value)}
                    className="w-full px-2 py-1 border border-gray-600 rounded bg-gray-800 text-white text-sm"
                  >
                    <option value="Target">Target</option>
                    <option value="Users">Users</option>
                    <option value="Recycle">Recycle</option>
                    <option value="Music">Music</option>
                    <option value="Shield">Shield</option>
                    <option value="Zap">Zap</option>
                    <option value="Clock">Clock</option>
                  </select>
                </div>
                <div>
                  <label className="block text-xs text-gray-400 mb-1">Titre</label>
                  <input
                    type="text"
                    value={feature.title}
                    onChange={(e) => updateFeature(index, 'title', e.target.value)}
                    className="w-full px-2 py-1 border border-gray-600 rounded bg-gray-800 text-white text-sm"
                    placeholder="Titre de la fonctionnalité"
                  />
                </div>
                <div>
                  <label className="block text-xs text-gray-400 mb-1">Description</label>
                  <textarea
                    value={feature.description}
                    onChange={(e) => updateFeature(index, 'description', e.target.value)}
                    rows={2}
                    className="w-full px-2 py-1 border border-gray-600 rounded bg-gray-800 text-white text-sm"
                    placeholder="Description détaillée"
                  />
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Informations supplémentaires */}
      <div>
        <label className="block text-sm font-medium text-gray-300 mb-4">
          Informations supplémentaires
        </label>
        <div className="bg-gray-700 p-4 rounded-md border border-gray-600">
          <div className="space-y-3">
            <div>
              <label className="block text-xs text-gray-400 mb-1">Titre</label>
              <input
                type="text"
                value={additionalInfo.title}
                onChange={(e) => setAdditionalInfo({ ...additionalInfo, title: e.target.value })}
                className="w-full px-3 py-2 border border-gray-600 rounded bg-gray-800 text-white"
                placeholder="Titre de la section supplémentaire"
              />
            </div>
            <div>
              <label className="block text-xs text-gray-400 mb-1">Contenu</label>
              <textarea
                value={additionalInfo.content}
                onChange={(e) => setAdditionalInfo({ ...additionalInfo, content: e.target.value })}
                rows={4}
                className="w-full px-3 py-2 border border-gray-600 rounded bg-gray-800 text-white"
                placeholder="Contenu détaillé de la section"
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

// Éditeur générique pour les autres sections
const GenericEditor = ({ section, formData, setFormData }: SectionEditorProps) => {
  return (
    <div className="space-y-6">
      {/* Titre et sous-titre */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Titre principal
          </label>
          <input
            type="text"
            value={formData.title}
            onChange={(e) => setFormData({ ...formData, title: e.target.value })}
            className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
            placeholder="Titre de la section"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Sous-titre
          </label>
          <textarea
            value={formData.subtitle}
            onChange={(e) => setFormData({ ...formData, subtitle: e.target.value })}
            rows={3}
            className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
            placeholder="Description de la section"
          />
        </div>
      </div>

      {/* Contenu JSON */}
      <div>
        <label className="block text-sm font-medium text-gray-300 mb-2">
          Contenu (JSON)
        </label>
        <textarea
          value={formData.content}
          onChange={(e) => setFormData({ ...formData, content: e.target.value })}
          rows={8}
          className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500 font-mono text-sm"
          placeholder='{"features": [...], "cta_primary": "..."}'
        />
        <p className="text-sm text-gray-400 mt-1">
          Contenu au format JSON pour les données dynamiques de la section
        </p>
      </div>

      {/* URLs des médias */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            URL de l'image
          </label>
          <input
            type="text"
            value={formData.image_url}
            onChange={(e) => setFormData({ ...formData, image_url: e.target.value })}
            className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
            placeholder="/images/section-image.jpg"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            URL de la vidéo
          </label>
          <input
            type="text"
            value={formData.video_url}
            onChange={(e) => setFormData({ ...formData, video_url: e.target.value })}
            className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
            placeholder="/video/section-video.mp4"
          />
        </div>
      </div>
    </div>
  )
}

export default function HomepageAdminPage() {
  const [sections, setSections] = useState<HomepageSection[]>([])
  const [loading, setLoading] = useState(true)
  const [editingSection, setEditingSection] = useState<HomepageSection | null>(null)
  const [showNewSectionEditor, setShowNewSectionEditor] = useState(false)
  const [formData, setFormData] = useState({
    title: '',
    subtitle: '',
    content: '',
    image_url: '',
    video_url: '',
    background_color: '',
    text_color: '',
    is_active: true
  })

  // Configuration des capteurs pour le drag and drop
  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 8,
      },
    }),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  )

  useEffect(() => {
    fetchSections()
  }, [])

  const fetchSections = async () => {
    try {
      setLoading(true)
      const response = await fetch('/api/admin/homepage-sections')
      const result = await response.json()
      
      if (result.success) {
        setSections(result.data)
      } else {
        console.error('Erreur lors du chargement des sections:', result.error)
      }
    } catch (error) {
      console.error('Erreur lors du chargement des sections:', error)
    } finally {
      setLoading(false)
    }
  }

  const openEditor = (section: HomepageSection) => {
    const rawContent = section.content
    let normalizedContent = ''

    if (typeof rawContent === 'string') {
      normalizedContent = rawContent.trim()
    } else if (rawContent && typeof rawContent === 'object') {
      try {
        normalizedContent = JSON.stringify(rawContent, null, 2)
      } catch (error) {
        console.warn('Impossible de sérialiser le contenu de la section', section.section_key, error)
        normalizedContent = ''
      }
    }

    setEditingSection(section)
    setFormData({
      title: section.title || '',
      subtitle: section.subtitle || '',
      content: normalizedContent,
      image_url: section.image_url || '',
      video_url: section.video_url || '',
      background_color: section.background_color || '',
      text_color: section.text_color || '',
      is_active: section.is_active
    })
  }

  const closeEditor = () => {
    setEditingSection(null)
  }

  const handleSave = async () => {
    if (!editingSection) return

    try {
      const response = await fetch(`/api/admin/homepage-sections/${editingSection.id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData)
      })

      const result = await response.json()
      
      if (result.success) {
        await fetchSections()
        closeEditor()
      } else {
        console.error('Erreur lors de la sauvegarde:', result.error)
        alert(`Erreur lors de la sauvegarde: ${result.error}`)
      }
    } catch (error) {
      console.error('Erreur lors de la sauvegarde:', error)
      alert('Erreur lors de la sauvegarde')
    }
  }

  const handleCreateSection = async (newSectionData: any) => {
    try {
      const response = await fetch('/api/admin/homepage-sections', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(newSectionData)
      })

      const result = await response.json()
      
      if (result.success) {
        await fetchSections()
        setShowNewSectionEditor(false)
        alert('Section créée avec succès !')
      } else {
        console.error('Erreur lors de la création:', result.error)
        alert(`Erreur lors de la création: ${result.error}`)
      }
    } catch (error) {
      console.error('Erreur lors de la création:', error)
      alert('Erreur lors de la création de la section')
    }
  }

  const toggleSectionStatus = async (section: HomepageSection) => {
    try {
      const response = await fetch(`/api/admin/homepage-sections/${section.id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          is_active: !section.is_active
        })
      })

      const result = await response.json()
      
      if (result.success) {
        await fetchSections()
      } else {
        console.error('Erreur lors du changement de statut:', result.error)
        alert(`Erreur lors du changement de statut: ${result.error}`)
      }
    } catch (error) {
      console.error('Erreur lors du changement de statut:', error)
      alert('Erreur lors du changement de statut')
    }
  }

  /**
   * Supprime une section après confirmation
   * @param section - La section à supprimer
   */
  const deleteSection = async (section: HomepageSection) => {
    // Protection des sections critiques
    const criticalSections = ['hero', 'concept', 'salles', 'process', 'faq', 'contact']
    if (criticalSections.includes(section.section_key)) {
      alert(`Impossible de supprimer la section "${section.title || section.section_key}" car elle est critique pour le fonctionnement du site.\n\nVous pouvez la désactiver à la place.`)
      return
    }

    // Confirmation avant suppression
    const isConfirmed = window.confirm(
      `Êtes-vous sûr de vouloir supprimer la section "${section.title || section.section_key}" ?\n\nCette action est irréversible.`
    )
    
    if (!isConfirmed) return

    try {
      const response = await fetch(`/api/admin/homepage-sections/${section.id}`, {
        method: 'DELETE',
        headers: {
          'Content-Type': 'application/json',
        }
      })

      const result = await response.json()
      
      if (result.success) {
        await fetchSections()
        alert('Section supprimée avec succès !')
      } else {
        console.error('Erreur lors de la suppression:', result.error)
        alert(`Erreur lors de la suppression: ${result.error}`)
      }
    } catch (error) {
      console.error('Erreur lors de la suppression:', error)
      alert('Erreur lors de la suppression de la section')
    }
  }

  /**
   * Gère la fin du drag and drop et met à jour l'ordre des sections
   * @param event - L'événement de fin de drag and drop
   */
  const handleDragEnd = async (event: DragEndEvent) => {
    const { active, over } = event

    if (active.id !== over?.id) {
      const oldIndex = sections.findIndex(section => section.id === active.id)
      const newIndex = sections.findIndex(section => section.id === over?.id)

      if (oldIndex !== -1 && newIndex !== -1) {
        // Mettre à jour l'ordre localement
        const newSections = arrayMove(sections, oldIndex, newIndex)
        setSections(newSections)

        // Préparer les données pour la mise à jour en masse
        const sectionsToUpdate = newSections.map((section: HomepageSection, index: number) => ({
          id: section.id,
          order_index: index + 1
        }))

        // Mettre à jour l'ordre de toutes les sections dans la base de données
        try {
          const response = await fetch('/api/admin/homepage-sections/reorder', {
            method: 'PUT',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              sections: sectionsToUpdate
            })
          })

          const result = await response.json()
          
          if (!result.success) {
            console.error('Erreur lors de la mise à jour de l\'ordre:', result.error)
            // Restaurer l'ordre original en cas d'erreur
            await fetchSections()
          } else {
            // Mettre à jour l'état local avec les données de la base
            setSections(result.data)
          }
        } catch (error) {
          console.error('Erreur lors de la mise à jour de l\'ordre:', error)
          // Restaurer l'ordre original en cas d'erreur
          await fetchSections()
        }
      }
    }
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

  const renderEditor = () => {
    if (!editingSection) return null

    switch (editingSection.section_key) {
      case 'hero':
        return <HeroEditor section={editingSection} formData={formData} setFormData={setFormData} />
      case 'concept':
        return <ConceptEditor section={editingSection} formData={formData} setFormData={setFormData} />
      case 'comment-ca-marche':
        return <CommentCaMarcheEditor section={editingSection} formData={formData} setFormData={setFormData} />
      case 'process':
        return <ProcessEditor section={editingSection} formData={formData} setFormData={setFormData} />
      case 'faq':
        return <FAQEditor section={editingSection} formData={formData} setFormData={setFormData} />
      case 'contact':
        return <ContactEditor section={editingSection} formData={formData} setFormData={setFormData} />
      default:
        return <GenericEditor section={editingSection} formData={formData} setFormData={setFormData} />
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-900 flex items-center justify-center">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-kaki-500"></div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-900 text-white">
      {/* Header */}
      <div className="bg-gray-800 border-b border-gray-700">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div>
              <h1 className="text-3xl font-bold text-white">Gestion de la Page d'Accueil</h1>
              <p className="text-gray-400 mt-1">Modifiez le contenu de votre page d'accueil de manière intuitive</p>
            </div>
            <div className="flex items-center space-x-4">
              <a
                href="/admin"
                className="inline-flex items-center px-4 py-2 border border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-300 bg-gray-700 hover:bg-gray-600 transition-colors"
              >
                ← Retour au dashboard
              </a>
              <a 
                href="/" 
                target="_blank" 
                className="flex items-center space-x-2 px-4 py-2 bg-kaki-600 hover:bg-kaki-700 text-white rounded-md transition-colors"
              >
                <Monitor className="w-4 h-4" />
                <span>Voir le site</span>
              </a>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Configuration générale de la page d'accueil */}
        <HomepageConfigEditor />

        {/* Configuration de l'en-tête */}
        <HeaderConfigEditor />

        {/* Configuration du pied de page */}
        <FooterEditor />

        {/* Statistiques */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
            <div className="flex items-center">
              <div className="p-2 bg-kaki-600 rounded-lg">
                <Layout className="w-6 h-6 text-white" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-400">Total Sections</p>
                <p className="text-2xl font-bold text-white">{sections.length}</p>
              </div>
            </div>
          </div>

          <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
            <div className="flex items-center">
              <div className="p-2 bg-green-600 rounded-lg">
                <Eye className="w-6 h-6 text-white" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-400">Actives</p>
                <p className="text-2xl font-bold text-white">
                  {sections.filter(s => s.is_active).length}
                </p>
              </div>
            </div>
          </div>

          <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
            <div className="flex items-center">
              <div className="p-2 bg-yellow-600 rounded-lg">
                <EyeOff className="w-6 h-6 text-white" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-400">Inactives</p>
                <p className="text-2xl font-bold text-white">
                  {sections.filter(s => !s.is_active).length}
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Liste des sections */}
        <div className="bg-gray-800 rounded-lg border border-gray-700">
          <div className="px-6 py-4 border-b border-gray-700 flex justify-between items-center">
                         <div>
               <h3 className="text-lg font-medium text-white">
                 Sections de la Page d'Accueil ({sections.length})
               </h3>
               <p className="text-sm text-gray-400 mt-1">
                 Cliquez sur "Modifier" pour éditer le contenu de chaque section
               </p>
               <p className="text-xs text-kaki-400 mt-1 flex items-center">
                 <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                   <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4" />
                 </svg>
                 Glissez les sections pour réorganiser leur ordre d'affichage
               </p>
             </div>
            <button
              onClick={() => setShowNewSectionEditor(true)}
              className="flex items-center space-x-2 px-4 py-2 bg-kaki-600 hover:bg-kaki-700 text-white rounded-lg transition-colors"
            >
              <Plus className="w-4 h-4" />
              <span>Ajouter une section</span>
            </button>
          </div>
                     <DndContext
             sensors={sensors}
             collisionDetection={closestCenter}
             onDragEnd={handleDragEnd}
           >
             <SortableContext
               items={sections.map(section => section.id)}
               strategy={verticalListSortingStrategy}
             >
               <div className="divide-y divide-gray-700">
                 {sections.map((section) => (
                   <DraggableSection
                     key={section.id}
                     section={section}
                     onEdit={() => openEditor(section)}
                     onToggleStatus={() => toggleSectionStatus(section)}
                     onDelete={() => deleteSection(section)}
                     isDeletable={!['hero', 'concept', 'salles', 'process', 'faq', 'contact'].includes(section.section_key)}
                   />
                 ))}
               </div>
             </SortableContext>
           </DndContext>
        </div>
      </div>

      {/* Éditeur de section */}
      {editingSection && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-gray-800 rounded-lg w-full max-w-6xl max-h-[90vh] overflow-y-auto">
            <div className="px-6 py-4 border-b border-gray-700 flex justify-between items-center">
              <div className="flex items-center space-x-3">
                {getSectionIcon(editingSection.section_key)}
                <h2 className="text-xl font-semibold text-white">
                  Modifier {getSectionName(editingSection.section_key)}
                </h2>
              </div>
              <button
                onClick={closeEditor}
                className="text-gray-400 hover:text-white"
              >
                <X className="w-6 h-6" />
              </button>
            </div>
            
            <div className="p-6">
              {renderEditor()}

              {/* Couleurs */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-6">
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-2">
                    Couleur de fond
                  </label>
                  <input
                    type="text"
                    value={formData.background_color}
                    onChange={(e) => setFormData({ ...formData, background_color: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                    placeholder="bg-dark-surface"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-2">
                    Couleur du texte
                  </label>
                  <input
                    type="text"
                    value={formData.text_color}
                    onChange={(e) => setFormData({ ...formData, text_color: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                    placeholder="text-white"
                  />
                </div>
              </div>

              {/* Statut */}
              <div className="flex items-center mt-6">
                <input
                  type="checkbox"
                  id="is_active"
                  checked={formData.is_active}
                  onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
                  className="h-4 w-4 text-kaki-600 focus:ring-kaki-500 border-gray-600 rounded bg-gray-700"
                />
                <label htmlFor="is_active" className="ml-2 block text-sm text-gray-300">
                  Section active
                </label>
              </div>
            </div>

            <div className="px-6 py-4 border-t border-gray-700 flex justify-end space-x-3">
              <button
                onClick={closeEditor}
                className="px-4 py-2 border border-gray-600 rounded-md shadow-sm text-sm font-medium text-white bg-gray-700 hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-kaki-500"
              >
                Annuler
              </button>
              <button
                onClick={handleSave}
                className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-kaki-600 hover:bg-kaki-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-kaki-500"
              >
                <Save className="w-4 h-4 mr-2 inline" />
                Sauvegarder
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Éditeur de nouvelle section */}
      {showNewSectionEditor && (
        <NewSectionEditor
          onSave={handleCreateSection}
          onCancel={() => setShowNewSectionEditor(false)}
        />
      )}
    </div>
  )
}
