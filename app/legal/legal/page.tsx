import { Metadata } from 'next'
import { getLegalPageByType } from '@/lib/database'
import Header from '@/components/Header'
import Footer from '@/components/Footer'

export const dynamic = 'force-dynamic'

export const metadata: Metadata = {
  title: 'Mentions Légales - U Silenziu',
  description: 'Consultez les mentions légales et informations sur U Silenziu.',
  keywords: ['mentions légales', 'informations', 'entreprise', 'U Silenziu'],
  openGraph: {
    title: 'Mentions Légales - U Silenziu',
    description: 'Consultez les mentions légales et informations sur U Silenziu.',
    type: 'website',
  },
}

export default async function LegalPage() {
  const page = await getLegalPageByType('legal')

  if (!page) {
    return (
      <main className="min-h-screen bg-dark-bg">
        <Header />
        <div className="py-12">
          <div className="max-w-4xl mx-auto px-4">
            <div className="bg-dark-surface rounded-lg shadow-lg border border-kaki-800/30 p-8">
              <div className="flex items-center space-x-3 mb-6">
                <div className="w-10 h-10 bg-gradient-to-br from-kaki-500 to-kaki-700 rounded-lg flex items-center justify-center">
                  <span className="text-white font-bold text-xl">U</span>
                </div>
                <h1 className="text-3xl font-bold text-white">
                  Mentions Légales
                </h1>
              </div>
              <p className="text-kaki-300">
                Cette page est temporairement indisponible.
              </p>
            </div>
          </div>
        </div>
        <Footer />
      </main>
    )
  }

  return (
    <main className="min-h-screen bg-dark-bg">
      <Header />
      <div className="py-12">
        <div className="max-w-4xl mx-auto px-4">
          <div className="bg-dark-surface rounded-lg shadow-lg border border-kaki-800/30 p-8">
            <div className="flex items-center space-x-3 mb-6">
              <div className="w-10 h-10 bg-gradient-to-br from-kaki-500 to-kaki-700 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-xl">U</span>
              </div>
              <h1 className="text-3xl font-bold text-white">
                {page.title}
              </h1>
            </div>
            
            <div 
              className="prose prose-lg max-w-none prose-invert"
              style={{
                color: '#e5e7eb',
                lineHeight: '1.6'
              }}
              dangerouslySetInnerHTML={{ __html: page.content }}
            />
            
            <div className="mt-8 pt-6 border-t border-kaki-800/30">
              <p className="text-sm text-kaki-300">
                Dernière mise à jour : {new Date(page.updated_at).toLocaleDateString('fr-FR')}
              </p>
            </div>
          </div>
        </div>
      </div>
      <Footer />
    </main>
  )
}
