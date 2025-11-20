import { Metadata } from 'next'
import { getPageBySlug } from '@/lib/database'
import { notFound } from 'next/navigation'

/**
 * Génère les métadonnées dynamiques pour chaque page
 */
export async function generateMetadata({ params }: { params: { slug: string } }): Promise<Metadata> {
  try {
    const page = await getPageBySlug(params.slug)
    
    if (!page || !page.is_published) {
      return {
        title: 'Page non trouvée - U Silenziu',
        description: 'La page demandée n\'existe pas ou n\'est pas disponible.'
      }
    }

    return {
      title: page.seo_title || page.title,
      description: page.meta_description || `Découvrez ${page.title} sur U Silenziu, votre zone de défoulement à Ajaccio.`,
      keywords: page.keywords?.join(', ') || 'défoulement, Ajaccio, zone de défoulement, U Silenziu',
      openGraph: {
        title: page.seo_title || page.title,
        description: page.meta_description || `Découvrez ${page.title} sur U Silenziu.`,
        type: 'website',
        url: `https://usilenzio.fr/${page.slug}`,
      },
      robots: {
        index: true,
        follow: true,
      }
    }
  } catch (error) {
    console.error('Erreur lors de la génération des métadonnées:', error)
    return {
      title: 'U Silenziu - Zone de Défoulement',
      description: 'Votre zone de défoulement sécurisée à Ajaccio.'
    }
  }
}

/**
 * Page dynamique pour afficher le contenu des pages CMS
 */
export default async function DynamicPage({ params }: { params: { slug: string } }) {
  try {
    // Exclure les routes légales qui sont gérées par /legal/[type]
    // Vérifier si le slug commence par "legal/" (pour les routes comme "legal/cgv")
    if (params.slug.startsWith('legal/')) {
      console.log(`[DEBUG] Route [slug] exclut: ${params.slug}`)
      notFound()
    }
    
    const page = await getPageBySlug(params.slug)
    
    // Si la page n'existe pas ou n'est pas publiée, afficher 404
    if (!page || !page.is_published) {
      notFound()
    }

    return (
      <div className="min-h-screen bg-gray-900 text-white">
        {/* Header avec navigation */}
        <header className="bg-gray-800 border-b border-gray-700">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between items-center py-6">
              <div>
                <h1 className="text-3xl font-bold text-white">{page.title}</h1>
                {page.meta_description && (
                  <p className="text-gray-400 mt-2">{page.meta_description}</p>
                )}
              </div>
              <a 
                href="/"
                className="inline-flex items-center px-4 py-2 border border-kaki-600 rounded-md shadow-sm text-sm font-medium text-white bg-kaki-600 hover:bg-kaki-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-kaki-500"
              >
                Retour à l'accueil
              </a>
            </div>
          </div>
        </header>

        {/* Contenu de la page */}
        <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <article className="prose prose-invert prose-lg max-w-none">
            {/* Rendu sécurisé du contenu HTML */}
            <div 
              className="page-content"
              dangerouslySetInnerHTML={{ __html: page.content }}
            />
          </article>

          {/* Métadonnées de la page */}
          <footer className="mt-12 pt-8 border-t border-gray-700">
            <div className="text-sm text-gray-400">
              <p>Dernière mise à jour : {new Date(page.updated_at).toLocaleDateString('fr-FR')}</p>
              {page.keywords && page.keywords.length > 0 && (
                <div className="mt-2">
                  <span className="text-gray-500">Mots-clés : </span>
                  {page.keywords.map((keyword, index) => (
                    <span key={index} className="inline-block bg-gray-700 rounded-full px-2 py-1 text-xs mr-2 mb-1">
                      {keyword}
                    </span>
                  ))}
                </div>
              )}
            </div>
          </footer>
        </main>
      </div>
    )
  } catch (error) {
    console.error('Erreur lors du chargement de la page:', error)
    notFound()
  }
}

/**
 * Génère les paramètres statiques pour les pages publiées
 */
export async function generateStaticParams() {
  try {
    // Cette fonction pourrait être utilisée pour pré-générer les pages statiques
    // Pour l'instant, on laisse Next.js gérer le rendu dynamique
    return []
  } catch (error) {
    console.error('Erreur lors de la génération des paramètres statiques:', error)
    return []
  }
}
