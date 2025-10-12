

'use client'

import { useState, useEffect } from 'react'
import { 
  FileText, 
  Plus, 
  Edit, 
  Trash2, 
  Eye, 
  Save, 
  X,
  Globe,
  Search,
  Filter,
  Calendar,
  User,
  Image
} from 'lucide-react'
import MediaUpload from '@/components/MediaUpload'
import TemplateSelector from '@/components/TemplateSelector'

interface Page {
  id: string
  title: string
  slug: string
  content: string
  metaDescription: string
  isPublished: boolean
  createdAt: string
  updatedAt: string
  author: string
  seoTitle: string
  keywords: string[]
}

export default function PagesPage() {
  const [pages, setPages] = useState<Page[]>([])
  const [filteredPages, setFilteredPages] = useState<Page[]>([])
  const [loading, setLoading] = useState(true)
  const [showEditor, setShowEditor] = useState(false)
  const [showMediaUpload, setShowMediaUpload] = useState(false)
  const [showTemplateSelector, setShowTemplateSelector] = useState(false)
  const [editingPage, setEditingPage] = useState<Page | null>(null)
  const [filters, setFilters] = useState({
    status: '',
    search: ''
  })

  // État du formulaire d'édition
  const [formData, setFormData] = useState({
    title: '',
    slug: '',
    content: '',
    metaDescription: '',
    seoTitle: '',
    keywords: '',
    isPublished: false
  })

  useEffect(() => {
    fetchPages()
  }, [])

  useEffect(() => {
    applyFilters()
  }, [pages, filters])

  const fetchPages = async () => {
    try {
      setLoading(true)
      const response = await fetch('/api/admin/pages')
      const result = await response.json()
      
      if (result.success) {
        // Conversion des données de la base vers l'interface frontend
        const convertedPages: Page[] = result.data.map((page: any) => ({
          id: page.id,
          title: page.title,
          slug: page.slug,
          content: page.content,
          metaDescription: page.meta_description || '',
          isPublished: page.is_published,
          createdAt: page.created_at,
          updatedAt: page.updated_at,
          author: 'Admin', // Pour l'instant, on garde Admin par défaut
          seoTitle: page.seo_title || page.title,
          keywords: page.keywords || []
        }))
        setPages(convertedPages)
      } else {
        console.error('Erreur lors du chargement des pages:', result.error)
      }
    } catch (error) {
      console.error('Erreur lors du chargement des pages:', error)
    } finally {
      setLoading(false)
    }
  }

  const applyFilters = () => {
    let filtered = [...pages]

    if (filters.status) {
      filtered = filtered.filter(p => {
        if (filters.status === 'published') return p.isPublished
        if (filters.status === 'draft') return !p.isPublished
        return true
      })
    }

    if (filters.search) {
      const searchLower = filters.search.toLowerCase()
      filtered = filtered.filter(p => 
        p.title.toLowerCase().includes(searchLower) ||
        p.slug.toLowerCase().includes(searchLower) ||
        p.content.toLowerCase().includes(searchLower)
      )
    }

    setFilteredPages(filtered)
  }

  const openEditor = (page?: Page) => {
    if (page) {
      setEditingPage(page)
      setFormData({
        title: page.title,
        slug: page.slug,
        content: page.content,
        metaDescription: page.metaDescription,
        seoTitle: page.seoTitle,
        keywords: page.keywords.join(', '),
        isPublished: page.isPublished
      })
    } else {
      setEditingPage(null)
      setFormData({
        title: '',
        slug: '',
        content: '',
        metaDescription: '',
        seoTitle: '',
        keywords: '',
        isPublished: false
      })
    }
    setShowEditor(true)
  }

  const closeEditor = () => {
    setShowEditor(false)
    setEditingPage(null)
  }

  const openMediaUpload = (page: Page) => {
    setEditingPage(page)
    setShowMediaUpload(true)
  }

  const closeMediaUpload = () => {
    setShowMediaUpload(false)
    setEditingPage(null)
  }

  const openTemplateSelector = () => {
    setShowTemplateSelector(true)
  }

  const closeTemplateSelector = () => {
    setShowTemplateSelector(false)
  }

  const handleTemplateSelect = (template: any, previewContent: string) => {
    setFormData({
      ...formData,
      content: previewContent
    })
    closeTemplateSelector()
  }

  const handleSave = async () => {
    try {
      const pageData = {
        title: formData.title,
        slug: formData.slug,
        content: formData.content,
        metaDescription: formData.metaDescription,
        seoTitle: formData.seoTitle,
        keywords: formData.keywords.split(',').map(k => k.trim()).filter(Boolean),
        isPublished: formData.isPublished
      }

      let response
      if (editingPage) {
        // Mise à jour
        response = await fetch(`/api/admin/pages/${editingPage.id}`, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(pageData)
        })
      } else {
        // Création
        response = await fetch('/api/admin/pages', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(pageData)
        })
      }

      const result = await response.json()
      
      if (result.success) {
        // Recharger les pages après sauvegarde
        await fetchPages()
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

  const deletePage = async (id: string) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cette page ?')) {
      return
    }

    try {
      const response = await fetch(`/api/admin/pages/${id}`, {
        method: 'DELETE'
      })
      
      const result = await response.json()
      
      if (result.success) {
        // Recharger les pages après suppression
        await fetchPages()
      } else {
        console.error('Erreur lors de la suppression:', result.error)
        alert(`Erreur lors de la suppression: ${result.error}`)
      }
    } catch (error) {
      console.error('Erreur lors de la suppression:', error)
      alert('Erreur lors de la suppression')
    }
  }

  const togglePublishStatus = async (id: string) => {
    try {
      const page = pages.find(p => p.id === id)
      if (!page) return

      const response = await fetch(`/api/admin/pages/${id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          title: page.title,
          slug: page.slug,
          content: page.content,
          metaDescription: page.metaDescription,
          seoTitle: page.seoTitle,
          keywords: page.keywords,
          isPublished: !page.isPublished
        })
      })
      
      const result = await response.json()
      
      if (result.success) {
        // Recharger les pages après mise à jour
        await fetchPages()
      } else {
        console.error('Erreur lors du changement de statut:', result.error)
        alert(`Erreur lors du changement de statut: ${result.error}`)
      }
    } catch (error) {
      console.error('Erreur lors du changement de statut:', error)
      alert('Erreur lors du changement de statut')
    }
  }

  const generateSlug = (title: string) => {
    return title
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-z0-9\s-]/g, '')
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-')
      .trim()
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
              <h1 className="text-3xl font-bold text-white">Gestion des Pages</h1>
              <p className="text-gray-400 mt-1">Créez et gérez les pages de votre site</p>
            </div>
            <div className="flex space-x-3">
              <a
                href="/admin"
                className="inline-flex items-center px-4 py-2 border border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-300 bg-gray-700 hover:bg-gray-600 transition-colors"
              >
                ← Retour au dashboard
              </a>
               <button
                 onClick={openTemplateSelector}
                 className="inline-flex items-center px-4 py-2 border border-gray-600 rounded-md shadow-sm text-sm font-medium text-white bg-gray-700 hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-kaki-500"
               >
                 <FileText className="w-4 h-4 mr-2" />
                 Utiliser un template
               </button>
               <button
                 onClick={() => openEditor()}
                 className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-kaki-600 hover:bg-kaki-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-kaki-500"
               >
                 <Plus className="w-4 h-4 mr-2" />
                 Nouvelle Page
               </button>
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
                <FileText className="w-6 h-6 text-white" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-400">Total Pages</p>
                <p className="text-2xl font-bold text-white">{pages.length}</p>
              </div>
            </div>
          </div>

          <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
            <div className="flex items-center">
              <div className="p-2 bg-green-600 rounded-lg">
                <Globe className="w-6 h-6 text-white" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-400">Publiées</p>
                <p className="text-2xl font-bold text-white">
                  {pages.filter(p => p.isPublished).length}
                </p>
              </div>
            </div>
          </div>

          <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
            <div className="flex items-center">
              <div className="p-2 bg-yellow-600 rounded-lg">
                <FileText className="w-6 h-6 text-white" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-400">Brouillons</p>
                <p className="text-2xl font-bold text-white">
                  {pages.filter(p => !p.isPublished).length}
                </p>
              </div>
            </div>
          </div>

          <div className="bg-gray-800 rounded-lg p-6 border border-gray-700">
            <div className="flex items-center">
              <div className="p-2 bg-purple-600 rounded-lg">
                <User className="w-6 h-6 text-white" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-400">Auteur</p>
                <p className="text-2xl font-bold text-white">Admin</p>
              </div>
            </div>
          </div>
        </div>

        {/* Filtres */}
        <div className="bg-gray-800 rounded-lg border border-gray-700 mb-8">
          <div className="px-6 py-4 border-b border-gray-700">
            <h3 className="text-lg font-medium text-white flex items-center">
              <Filter className="w-5 h-5 mr-2" />
              Filtres
            </h3>
          </div>
          <div className="px-6 py-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-1">
                  Statut
                </label>
                <select
                  value={filters.status}
                  onChange={(e) => setFilters({ ...filters, status: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                >
                  <option value="">Tous les statuts</option>
                  <option value="published">Publiées</option>
                  <option value="draft">Brouillons</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-1">
                  Recherche
                </label>
                <div className="relative">
                  <Search className="absolute left-3 top-2.5 h-4 w-4 text-gray-400" />
                  <input
                    type="text"
                    placeholder="Titre, contenu..."
                    value={filters.search}
                    onChange={(e) => setFilters({ ...filters, search: e.target.value })}
                    className="w-full pl-10 pr-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Liste des pages */}
        <div className="bg-gray-800 rounded-lg border border-gray-700">
          <div className="px-6 py-4 border-b border-gray-700">
            <h3 className="text-lg font-medium text-white">
              Pages ({filteredPages.length})
            </h3>
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-700">
              <thead className="bg-gray-700">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                    Page
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                    Slug
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                    Statut
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                    Modifiée
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-300 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-gray-800 divide-y divide-gray-700">
                {filteredPages.map((page) => (
                  <tr key={page.id} className="hover:bg-gray-700">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-white">
                        {page.title}
                      </div>
                      <div className="text-sm text-gray-400">
                        {page.metaDescription ? page.metaDescription.substring(0, 60) + '...' : 'Aucune description'}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-300">
                        /{page.slug}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        page.isPublished 
                          ? 'text-green-500 bg-green-500/10' 
                          : 'text-yellow-500 bg-yellow-500/10'
                      }`}>
                        {page.isPublished ? 'Publiée' : 'Brouillon'}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-300">
                        {new Date(page.updatedAt).toLocaleDateString('fr-FR')}
                      </div>
                    </td>
                                         <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                       <div className="flex space-x-2">
                         <button 
                           onClick={() => openEditor(page)}
                           className="text-kaki-400 hover:text-kaki-300"
                           title="Modifier"
                         >
                           <Edit className="w-4 h-4" />
                         </button>
                         <button 
                           onClick={() => openMediaUpload(page)}
                           className="text-purple-400 hover:text-purple-300"
                           title="Gérer les médias"
                         >
                           <Image className="w-4 h-4" />
                         </button>
                         <button 
                           onClick={() => togglePublishStatus(page.id)}
                           className={`${page.isPublished ? 'text-yellow-400 hover:text-yellow-300' : 'text-green-400 hover:text-green-300'}`}
                           title={page.isPublished ? 'Dépublier' : 'Publier'}
                         >
                           <Eye className="w-4 h-4" />
                         </button>
                         <button 
                           onClick={() => deletePage(page.id)}
                           className="text-red-400 hover:text-red-300"
                           title="Supprimer"
                         >
                           <Trash2 className="w-4 h-4" />
                         </button>
                       </div>
                     </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          {filteredPages.length === 0 && (
            <div className="text-center py-12">
              <FileText className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-300">Aucune page</h3>
              <p className="mt-1 text-sm text-gray-400">
                Aucune page ne correspond aux critères sélectionnés.
              </p>
            </div>
          )}
        </div>
      </div>

      {/* Éditeur de page */}
      {showEditor && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-gray-800 rounded-lg w-full max-w-4xl max-h-[90vh] overflow-y-auto">
            <div className="px-6 py-4 border-b border-gray-700 flex justify-between items-center">
              <h2 className="text-xl font-semibold text-white">
                {editingPage ? 'Modifier la page' : 'Nouvelle page'}
              </h2>
              <button
                onClick={closeEditor}
                className="text-gray-400 hover:text-white"
              >
                <X className="w-6 h-6" />
              </button>
            </div>
            
            <div className="p-6 space-y-6">
              {/* Titre */}
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  Titre de la page
                </label>
                <input
                  type="text"
                  value={formData.title}
                  onChange={(e) => {
                    setFormData({ ...formData, title: e.target.value })
                    if (!editingPage) {
                      setFormData(prev => ({ ...prev, slug: generateSlug(e.target.value) }))
                    }
                  }}
                  className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                  placeholder="Titre de la page"
                />
              </div>

              {/* Slug */}
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  URL (slug)
                </label>
                <input
                  type="text"
                  value={formData.slug}
                  onChange={(e) => setFormData({ ...formData, slug: e.target.value })}
                  className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                  placeholder="url-de-la-page"
                />
              </div>

              {/* Contenu */}
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  Contenu
                </label>
                <textarea
                  value={formData.content}
                  onChange={(e) => setFormData({ ...formData, content: e.target.value })}
                  rows={10}
                  className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                  placeholder="Contenu de la page (HTML autorisé)"
                />
                <p className="text-sm text-gray-400 mt-1">
                  Vous pouvez utiliser du HTML pour formater le contenu
                </p>
              </div>

              {/* SEO */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-2">
                    Titre SEO
                  </label>
                  <input
                    type="text"
                    value={formData.seoTitle}
                    onChange={(e) => setFormData({ ...formData, seoTitle: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                    placeholder="Titre pour les moteurs de recherche"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-2">
                    Mots-clés
                  </label>
                  <input
                    type="text"
                    value={formData.keywords}
                    onChange={(e) => setFormData({ ...formData, keywords: e.target.value })}
                    className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                    placeholder="mot-clé1, mot-clé2, mot-clé3"
                  />
                </div>
              </div>

              {/* Description */}
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  Description (meta description)
                </label>
                <textarea
                  value={formData.metaDescription}
                  onChange={(e) => setFormData({ ...formData, metaDescription: e.target.value })}
                  rows={3}
                  className="w-full px-3 py-2 border border-gray-600 rounded-md shadow-sm bg-gray-700 text-white focus:outline-none focus:ring-2 focus:ring-kaki-500 focus:border-kaki-500"
                  placeholder="Description de la page pour les moteurs de recherche"
                />
              </div>

              {/* Statut */}
              <div className="flex items-center">
                <input
                  type="checkbox"
                  id="isPublished"
                  checked={formData.isPublished}
                  onChange={(e) => setFormData({ ...formData, isPublished: e.target.checked })}
                  className="h-4 w-4 text-kaki-600 focus:ring-kaki-500 border-gray-600 rounded bg-gray-700"
                />
                <label htmlFor="isPublished" className="ml-2 block text-sm text-gray-300">
                  Publier immédiatement
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

       {/* Modal d'upload de médias */}
       {showMediaUpload && editingPage && (
         <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
           <div className="bg-gray-800 rounded-lg w-full max-w-2xl max-h-[90vh] overflow-y-auto">
             <div className="px-6 py-4 border-b border-gray-700 flex justify-between items-center">
               <h2 className="text-xl font-semibold text-white">
                 Gérer les médias - {editingPage.title}
               </h2>
               <button
                 onClick={closeMediaUpload}
                 className="text-gray-400 hover:text-white"
               >
                 <X className="w-6 h-6" />
               </button>
             </div>
             
             <div className="p-6">
               <MediaUpload 
                 pageId={editingPage.id}
                 onUploadSuccess={(media) => {
                   console.log('Média uploadé:', media)
                 }}
                 onUploadError={(error) => {
                   console.error('Erreur upload:', error)
                   alert(`Erreur lors de l'upload: ${error}`)
                 }}
               />
             </div>
           </div>
         </div>
       )}

       {/* Sélecteur de templates */}
       {showTemplateSelector && (
         <TemplateSelector
           onTemplateSelect={handleTemplateSelect}
           onClose={closeTemplateSelector}
         />
       )}
     </div>
   )
 }
