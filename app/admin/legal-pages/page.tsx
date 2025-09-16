'use client'

import { useState, useEffect } from 'react'
import { 
  FileText, 
  Edit, 
  Save, 
  X,
  Eye,
  EyeOff,
  Globe,
  Search,
  Filter,
  Calendar,
  User,
  Shield,
  Scale,
  Cookie,
  Lock,
  Plus,
  Trash2
} from 'lucide-react'

interface LegalPage {
  id: string
  page_type: 'cgv' | 'privacy' | 'legal' | 'cookies'
  title: string
  content: string
  meta_description?: string
  seo_title?: string
  keywords?: string[]
  is_published: boolean
  last_updated_by?: string
  created_at: string
  updated_at: string
}

const pageTypeIcons = {
  cgv: Scale,
  privacy: Lock,
  legal: Shield,
  cookies: Cookie
}

const pageTypeLabels = {
  cgv: 'Conditions Générales de Vente',
  privacy: 'Politique de Confidentialité',
  legal: 'Mentions Légales',
  cookies: 'Paramètres des Cookies'
}

export default function LegalPagesAdmin() {
  const [pages, setPages] = useState<LegalPage[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [editingPage, setEditingPage] = useState<LegalPage | null>(null)
  const [searchTerm, setSearchTerm] = useState('')
  const [filterType, setFilterType] = useState<string>('all')

  // Charger les pages légales
  const fetchPages = async () => {
    try {
      setLoading(true)
      const response = await fetch('/api/admin/legal-pages')
      const data = await response.json()
      
      if (data.success) {
        setPages(data.data)
      } else {
        setError(data.error || 'Erreur lors du chargement des pages')
      }
    } catch (err) {
      setError('Erreur de connexion')
    } finally {
      setLoading(false)
    }
  }

  // Sauvegarder une page
  const savePage = async (pageData: Partial<LegalPage>) => {
    try {
      const url = editingPage?.id 
        ? `/api/admin/legal-pages/${editingPage.id}`
        : '/api/admin/legal-pages'
      
      const method = editingPage?.id ? 'PUT' : 'POST'
      
      const response = await fetch(url, {
        method,
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          ...pageData,
          last_updated_by: 'Administrateur'
        }),
      })
      
      const data = await response.json()
      
      if (data.success) {
        await fetchPages()
        setEditingPage(null)
      } else {
        setError(data.error || 'Erreur lors de la sauvegarde')
      }
    } catch (err) {
      setError('Erreur de connexion')
    }
  }

  // Supprimer une page
  const deletePage = async (id: string) => {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cette page ?')) {
      return
    }

    try {
      const response = await fetch(`/api/admin/legal-pages/${id}`, {
        method: 'DELETE',
      })
      
      const data = await response.json()
      
      if (data.success) {
        await fetchPages()
      } else {
        setError(data.error || 'Erreur lors de la suppression')
      }
    } catch (err) {
      setError('Erreur de connexion')
    }
  }

  // Basculer le statut de publication
  const togglePublish = async (page: LegalPage) => {
    await savePage({
      ...page,
      is_published: !page.is_published
    })
  }

  useEffect(() => {
    fetchPages()
  }, [])

  // Filtrer les pages
  const filteredPages = pages.filter(page => {
    const matchesSearch = page.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         page.page_type.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesFilter = filterType === 'all' || page.page_type === filterType
    return matchesSearch && matchesFilter
  })

  if (loading) {
    return (
      <div className="min-h-screen bg-dark-bg flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-kaki-600 mx-auto"></div>
          <p className="mt-4 text-kaki-300">Chargement des pages légales...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-dark-bg">
      {/* Header */}
      <div className="bg-dark-surface border-b border-kaki-800/30">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-br from-kaki-500 to-kaki-700 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-xl">U</span>
              </div>
              <div>
                <h1 className="text-3xl font-bold text-white">Gestion des Pages Légales</h1>
                <p className="mt-1 text-sm text-kaki-300">
                  Gérez le contenu des pages légales de votre site
                </p>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              <a
                href="/admin"
                className="inline-flex items-center px-4 py-2 border border-kaki-600 rounded-md shadow-sm text-sm font-medium text-kaki-300 bg-dark-surface hover:bg-kaki-800/20 transition-colors"
              >
                ← Retour au dashboard
              </a>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {error && (
          <div className="mb-6 bg-red-900/20 border border-red-800/30 rounded-md p-4">
            <div className="flex">
              <div className="flex-shrink-0">
                <X className="h-5 w-5 text-red-400" />
              </div>
              <div className="ml-3">
                <h3 className="text-sm font-medium text-red-300">Erreur</h3>
                <div className="mt-2 text-sm text-red-200">
                  <p>{error}</p>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Filtres et recherche */}
        <div className="mb-6 bg-dark-surface rounded-lg shadow border border-kaki-800/30 p-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label htmlFor="search" className="block text-sm font-medium text-kaki-300 mb-2">
                Rechercher
              </label>
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-kaki-400" />
                <input
                  type="text"
                  id="search"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10 block w-full bg-dark-bg border-kaki-600 text-white rounded-md shadow-sm focus:ring-kaki-500 focus:border-kaki-500"
                  placeholder="Rechercher par titre ou type..."
                />
              </div>
            </div>
            <div>
              <label htmlFor="filter" className="block text-sm font-medium text-kaki-300 mb-2">
                Filtrer par type
              </label>
              <select
                id="filter"
                value={filterType}
                onChange={(e) => setFilterType(e.target.value)}
                className="block w-full bg-dark-bg border-kaki-600 text-white rounded-md shadow-sm focus:ring-kaki-500 focus:border-kaki-500"
              >
                <option value="all">Tous les types</option>
                <option value="cgv">CGV</option>
                <option value="privacy">Confidentialité</option>
                <option value="legal">Mentions légales</option>
                <option value="cookies">Cookies</option>
              </select>
            </div>
          </div>
        </div>

        {/* Liste des pages */}
        <div className="bg-dark-surface shadow rounded-lg overflow-hidden border border-kaki-800/30">
          <div className="px-6 py-4 border-b border-kaki-800/30">
            <h2 className="text-lg font-medium text-white">
              Pages légales ({filteredPages.length})
            </h2>
          </div>
          
          {filteredPages.length === 0 ? (
            <div className="text-center py-12">
              <FileText className="mx-auto h-12 w-12 text-kaki-400" />
              <h3 className="mt-2 text-sm font-medium text-white">Aucune page trouvée</h3>
              <p className="mt-1 text-sm text-kaki-300">
                {searchTerm || filterType !== 'all' 
                  ? 'Aucune page ne correspond à vos critères de recherche.'
                  : 'Commencez par créer votre première page légale.'
                }
              </p>
            </div>
          ) : (
            <div className="divide-y divide-kaki-800/30">
              {filteredPages.map((page) => {
                const IconComponent = pageTypeIcons[page.page_type]
                return (
                  <div key={page.id} className="px-6 py-4 hover:bg-kaki-800/10 transition-colors">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center space-x-4">
                        <div className="flex-shrink-0">
                          <IconComponent className="h-8 w-8 text-kaki-600" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center space-x-2">
                            <h3 className="text-lg font-medium text-white truncate">
                              {page.title}
                            </h3>
                            <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                              page.is_published 
                                ? 'bg-green-900/30 text-green-300 border border-green-800/30' 
                                : 'bg-kaki-900/30 text-kaki-300 border border-kaki-800/30'
                            }`}>
                              {page.is_published ? 'Publié' : 'Brouillon'}
                            </span>
                          </div>
                          <p className="text-sm text-kaki-300">
                            {pageTypeLabels[page.page_type]} • 
                            Dernière mise à jour : {new Date(page.updated_at).toLocaleDateString('fr-FR')}
                            {page.last_updated_by && ` par ${page.last_updated_by}`}
                          </p>
                        </div>
                      </div>
                      
                      <div className="flex items-center space-x-2">
                        <button
                          onClick={() => togglePublish(page)}
                          className={`inline-flex items-center px-3 py-1.5 border border-transparent text-xs font-medium rounded-md ${
                            page.is_published
                              ? 'text-kaki-300 bg-kaki-800/20 hover:bg-kaki-800/30 border border-kaki-600/30'
                              : 'text-white bg-kaki-600 hover:bg-kaki-700'
                          }`}
                        >
                          {page.is_published ? (
                            <>
                              <EyeOff className="h-3 w-3 mr-1" />
                              Dépublier
                            </>
                          ) : (
                            <>
                              <Eye className="h-3 w-3 mr-1" />
                              Publier
                            </>
                          )}
                        </button>
                        
                        <a
                          href={`/legal/${page.page_type}`}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="inline-flex items-center px-3 py-1.5 border border-kaki-600 text-xs font-medium rounded-md text-kaki-300 bg-dark-surface hover:bg-kaki-800/20"
                        >
                          <Globe className="h-3 w-3 mr-1" />
                          Voir
                        </a>
                        
                        <button
                          onClick={() => setEditingPage(page)}
                          className="inline-flex items-center px-3 py-1.5 border border-transparent text-xs font-medium rounded-md text-white bg-kaki-600 hover:bg-kaki-700"
                        >
                          <Edit className="h-3 w-3 mr-1" />
                          Modifier
                        </button>
                      </div>
                    </div>
                  </div>
                )
              })}
            </div>
          )}
        </div>
      </div>

      {/* Modal d'édition */}
      {editingPage && (
        <div className="fixed inset-0 bg-black bg-opacity-75 overflow-y-auto h-full w-full z-50">
          <div className="relative top-20 mx-auto p-5 border border-kaki-800/30 w-11/12 max-w-4xl shadow-lg rounded-md bg-dark-surface">
            <div className="mt-3">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-medium text-white">
                  {editingPage.id ? 'Modifier la page' : 'Nouvelle page légale'}
                </h3>
                <button
                  onClick={() => setEditingPage(null)}
                  className="text-kaki-400 hover:text-kaki-300"
                >
                  <X className="h-6 w-6" />
                </button>
              </div>
              
              <LegalPageEditor
                page={editingPage}
                onSave={savePage}
                onCancel={() => setEditingPage(null)}
              />
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

// Composant d'édition des pages légales
function LegalPageEditor({ 
  page, 
  onSave, 
  onCancel 
}: { 
  page: LegalPage
  onSave: (data: Partial<LegalPage>) => void
  onCancel: () => void
}) {
  const [formData, setFormData] = useState({
    page_type: page.page_type || 'cgv',
    title: page.title || '',
    content: page.content || '',
    meta_description: page.meta_description || '',
    seo_title: page.seo_title || '',
    keywords: page.keywords?.join(', ') || '',
    is_published: page.is_published !== undefined ? page.is_published : true
  })

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    onSave({
      ...formData,
      keywords: formData.keywords.split(',').map(k => k.trim()).filter(k => k)
    })
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <label htmlFor="page_type" className="block text-sm font-medium text-kaki-300 mb-2">
            Type de page
          </label>
          <select
            id="page_type"
            value={formData.page_type}
            onChange={(e) => setFormData({ ...formData, page_type: e.target.value as any })}
            className="block w-full bg-dark-bg border-kaki-600 text-white rounded-md shadow-sm focus:ring-kaki-500 focus:border-kaki-500"
            required
          >
            <option value="cgv">Conditions Générales de Vente</option>
            <option value="privacy">Politique de Confidentialité</option>
            <option value="legal">Mentions Légales</option>
            <option value="cookies">Paramètres des Cookies</option>
          </select>
        </div>
        
        <div>
          <label htmlFor="is_published" className="block text-sm font-medium text-kaki-300 mb-2">
            Statut
          </label>
          <select
            id="is_published"
            value={formData.is_published ? 'true' : 'false'}
            onChange={(e) => setFormData({ ...formData, is_published: e.target.value === 'true' })}
            className="block w-full bg-dark-bg border-kaki-600 text-white rounded-md shadow-sm focus:ring-kaki-500 focus:border-kaki-500"
          >
            <option value="true">Publié</option>
            <option value="false">Brouillon</option>
          </select>
        </div>
      </div>

      <div>
        <label htmlFor="title" className="block text-sm font-medium text-kaki-300 mb-2">
          Titre
        </label>
        <input
          type="text"
          id="title"
          value={formData.title}
          onChange={(e) => setFormData({ ...formData, title: e.target.value })}
          className="block w-full bg-dark-bg border-kaki-600 text-white rounded-md shadow-sm focus:ring-kaki-500 focus:border-kaki-500"
          required
        />
      </div>

      <div>
        <label htmlFor="seo_title" className="block text-sm font-medium text-kaki-300 mb-2">
          Titre SEO (optionnel)
        </label>
        <input
          type="text"
          id="seo_title"
          value={formData.seo_title}
          onChange={(e) => setFormData({ ...formData, seo_title: e.target.value })}
          className="block w-full bg-dark-bg border-kaki-600 text-white rounded-md shadow-sm focus:ring-kaki-500 focus:border-kaki-500"
        />
      </div>

      <div>
        <label htmlFor="meta_description" className="block text-sm font-medium text-kaki-300 mb-2">
          Description SEO (optionnel)
        </label>
        <textarea
          id="meta_description"
          value={formData.meta_description}
          onChange={(e) => setFormData({ ...formData, meta_description: e.target.value })}
          rows={3}
          className="block w-full bg-dark-bg border-kaki-600 text-white rounded-md shadow-sm focus:ring-kaki-500 focus:border-kaki-500"
        />
      </div>

      <div>
        <label htmlFor="keywords" className="block text-sm font-medium text-kaki-300 mb-2">
          Mots-clés (séparés par des virgules)
        </label>
        <input
          type="text"
          id="keywords"
          value={formData.keywords}
          onChange={(e) => setFormData({ ...formData, keywords: e.target.value })}
          className="block w-full bg-dark-bg border-kaki-600 text-white rounded-md shadow-sm focus:ring-kaki-500 focus:border-kaki-500"
          placeholder="cgv, conditions générales, vente, réservation"
        />
      </div>

      <div>
        <label htmlFor="content" className="block text-sm font-medium text-kaki-300 mb-2">
          Contenu (HTML)
        </label>
        <textarea
          id="content"
          value={formData.content}
          onChange={(e) => setFormData({ ...formData, content: e.target.value })}
          rows={15}
          className="block w-full bg-dark-bg border-kaki-600 text-white rounded-md shadow-sm focus:ring-kaki-500 focus:border-kaki-500 font-mono text-sm"
          required
        />
        <p className="mt-1 text-sm text-kaki-300">
          Vous pouvez utiliser du HTML pour formater le contenu. Utilisez les classes CSS existantes pour le style.
        </p>
      </div>

      <div className="flex justify-end space-x-3 pt-6 border-t border-kaki-800/30">
        <button
          type="button"
          onClick={onCancel}
          className="inline-flex items-center px-4 py-2 border border-kaki-600 rounded-md shadow-sm text-sm font-medium text-kaki-300 bg-dark-surface hover:bg-kaki-800/20"
        >
          <X className="h-4 w-4 mr-2" />
          Annuler
        </button>
        <button
          type="submit"
          className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-kaki-600 hover:bg-kaki-700"
        >
          <Save className="h-4 w-4 mr-2" />
          Sauvegarder
        </button>
      </div>
    </form>
  )
}
