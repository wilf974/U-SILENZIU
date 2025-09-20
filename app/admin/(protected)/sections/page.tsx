'use client'

import { useState, useEffect } from 'react'
import { 
  Home, 
  Edit, 
  Save, 
  X,
  Eye,
  EyeOff,
  Settings,
  Layout,
  Type,
  Image,
  Video,
  Monitor,
  Palette,
  FileText,
  Globe,
  Plus,
  Search,
  Filter
} from 'lucide-react'

interface GlobalSection {
  id: string
  section_key: string
  section_name: string
  title?: string
  subtitle?: string
  content?: string
  image_url?: string
  video_url?: string
  background_color?: string
  text_color?: string
  order_index: number
  is_active: boolean
  page_identifier: string
  created_at: string
  updated_at: string
}

interface SectionEditorProps {
  section: GlobalSection
  formData: any
  setFormData: (data: any) => void
}

// Éditeur générique pour toutes les sections
const GenericSectionEditor = ({ section, formData, setFormData }: SectionEditorProps) => {
  return (
    <div className="space-y-6">
      {/* Informations de base */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Clé de section
          </label>
          <input
            type="text"
            value={formData.section_key}
            onChange={(e) => setFormData({ ...formData, section_key: e.target.value })}
            className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
            placeholder="hero, concept, contact..."
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Nom de la section
          </label>
          <input
            type="text"
            value={formData.section_name}
            onChange={(e) => setFormData({ ...formData, section_name: e.target.value })}
            className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
            placeholder="Section Hero, Le Concept..."
          />
        </div>
      </div>

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

      {/* Ordre et page */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Ordre d'affichage
          </label>
          <input
            type="number"
            value={formData.order_index}
            onChange={(e) => setFormData({ ...formData, order_index: parseInt(e.target.value) || 0 })}
            className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
            placeholder="1"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-300 mb-2">
            Page d'appartenance
          </label>
          <select
            value={formData.page_identifier}
            onChange={(e) => setFormData({ ...formData, page_identifier: e.target.value })}
            className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
          >
            <option value="homepage">Page d'accueil</option>
            <option value="concept">Le Concept</option>
            <option value="contact">Contact</option>
            <option value="salles">Nos Salles</option>
          </select>
        </div>
      </div>
    </div>
  )
}

export default function GlobalSectionsAdminPage() {
  const [sections, setSections] = useState<GlobalSection[]>([])
  const [loading, setLoading] = useState(true)
  const [editingSection, setEditingSection] = useState<GlobalSection | null>(null)
  const [searchTerm, setSearchTerm] = useState('')
  const [filterPage, setFilterPage] = useState('all')
  const [formData, setFormData] = useState({
    section_key: '',
    section_name: '',
    title: '',
    subtitle: '',
    content: '',
    image_url: '',
    video_url: '',
    background_color: '',
    text_color: '',
    order_index: 0,
    is_active: true,
    page_identifier: 'homepage'
  })

  useEffect(() => {
    fetchSections()
  }, [])

  const fetchSections = async () => {
    try {
      setLoading(true)
      const response = await fetch('/api/admin/global-sections')
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

  const openEditor = (section: GlobalSection) => {
    setEditingSection(section)
    setFormData({
      section_key: section.section_key,
      section_name: section.section_name,
      title: section.title || '',
      subtitle: section.subtitle || '',
      content: section.content || '',
      image_url: section.image_url || '',
      video_url: section.video_url || '',
      background_color: section.background_color || '',
      text_color: section.text_color || '',
      order_index: section.order_index,
      is_active: section.is_active,
      page_identifier: section.page_identifier
    })
  }

  const closeEditor = () => {
    setEditingSection(null)
  }

  const handleSave = async () => {
    if (!editingSection) return

    try {
      const response = await fetch(`/api/admin/global-sections/${editingSection.id}`, {
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

  const toggleSectionStatus = async (section: GlobalSection) => {
    try {
      const response = await fetch(`/api/admin/global-sections/${section.id}`, {
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

  const getPageIcon = (pageIdentifier: string) => {
    switch (pageIdentifier) {
      case 'homepage': return <Home className="w-5 h-5" />
      case 'concept': return <Layout className="w-5 h-5" />
      case 'contact': return <Type className="w-5 h-5" />
      case 'salles': return <Settings className="w-5 h-5" />
      default: return <Globe className="w-5 h-5" />
    }
  }

  const getPageName = (pageIdentifier: string) => {
    switch (pageIdentifier) {
      case 'homepage': return 'Page d\'accueil'
      case 'concept': return 'Le Concept'
      case 'contact': return 'Contact'
      case 'salles': return 'Nos Salles'
      default: return pageIdentifier
    }
  }

  // Filtrage des sections
  const filteredSections = sections.filter(section => {
    const matchesSearch = section.section_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         section.title?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         section.section_key.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesPage = filterPage === 'all' || section.page_identifier === filterPage
    return matchesSearch && matchesPage
  })

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
              <h1 className="text-3xl font-bold text-white">Gestion des Sections Globales</h1>
              <p className="text-gray-400 mt-1">Modifiez le contenu de toutes les sections du site</p>
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
        {/* Statistiques */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
            <div className="flex items-center">
              <div className="p-2 bg-kaki-600 rounded-lg">
                <Globe className="w-6 h-6 text-white" />
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

          <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
            <div className="flex items-center">
              <div className="p-2 bg-purple-600 rounded-lg">
                <Layout className="w-6 h-6 text-white" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-400">Pages</p>
                <p className="text-2xl font-bold text-white">
                  {new Set(sections.map(s => s.page_identifier)).size}
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Filtres */}
        <div className="bg-gray-800 rounded-lg p-6 border border-gray-700 mb-8">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Rechercher
              </label>
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
                <input
                  type="text"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="w-full pl-10 pr-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                  placeholder="Rechercher par nom, titre ou clé..."
                />
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Filtrer par page
              </label>
              <select
                value={filterPage}
                onChange={(e) => setFilterPage(e.target.value)}
                className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
              >
                <option value="all">Toutes les pages</option>
                <option value="homepage">Page d'accueil</option>
                <option value="concept">Le Concept</option>
                <option value="contact">Contact</option>
                <option value="salles">Nos Salles</option>
              </select>
            </div>
          </div>
        </div>

        {/* Liste des sections */}
        <div className="bg-gray-800 rounded-lg border border-gray-700">
          <div className="px-6 py-4 border-b border-gray-700">
            <h3 className="text-lg font-medium text-white">
              Sections Globales ({filteredSections.length})
            </h3>
            <p className="text-sm text-gray-400 mt-1">
              Cliquez sur "Modifier" pour éditer le contenu de chaque section
            </p>
          </div>
          <div className="divide-y divide-gray-700">
            {filteredSections.map((section) => (
              <div key={section.id} className="p-6 hover:bg-gray-700 transition-colors">
                <div className="flex items-center justify-between">
                  <div className="flex items-center space-x-4">
                    <div className="flex-shrink-0">
                      {getPageIcon(section.page_identifier)}
                    </div>
                    <div className="flex-1">
                      <h4 className="text-lg font-medium text-white">
                        {section.section_name}
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
                          Clé: {section.section_key}
                        </span>
                        <span className="text-xs text-gray-500">
                          Page: {getPageName(section.page_identifier)}
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
                  <div className="flex items-center space-x-2">
                    <button 
                      onClick={() => toggleSectionStatus(section)}
                      className={`p-2 rounded-lg transition-colors ${
                        section.is_active 
                          ? 'text-yellow-400 hover:text-yellow-300 hover:bg-yellow-400/10' 
                          : 'text-green-400 hover:text-green-300 hover:bg-green-400/10'
                      }`}
                      title={section.is_active ? 'Désactiver' : 'Activer'}
                    >
                      {section.is_active ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                    </button>
                    <button 
                      onClick={() => openEditor(section)}
                      className="p-2 text-kaki-400 hover:text-kaki-300 hover:bg-kaki-400/10 rounded-lg transition-colors"
                      title="Modifier"
                    >
                      <Edit className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Éditeur de section */}
      {editingSection && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-gray-800 rounded-lg w-full max-w-6xl max-h-[90vh] overflow-y-auto">
            <div className="px-6 py-4 border-b border-gray-700 flex justify-between items-center">
              <div className="flex items-center space-x-3">
                {getPageIcon(editingSection.page_identifier)}
                <h2 className="text-xl font-semibold text-white">
                  Modifier {editingSection.section_name}
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
              <GenericSectionEditor 
                section={editingSection} 
                formData={formData} 
                setFormData={setFormData} 
              />

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
    </div>
  )
}
