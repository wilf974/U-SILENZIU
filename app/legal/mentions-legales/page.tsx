import React from 'react'
import { getLegalPageByType } from '@/lib/database'
import { Metadata } from 'next'

/**
 * Page des Mentions Légales
 * @returns JSX.Element
 */
export default async function MentionsLegalesPage() {
  // Récupérer le contenu depuis la base de données
  const legalPage = await getLegalPageByType('legal')
  
  // Si pas de page en base, afficher le contenu par défaut
  if (!legalPage) {
  return (
    <div className="min-h-screen bg-gray-900 text-white">
      <div className="container mx-auto px-4 py-8 max-w-4xl">
        <h1 className="text-3xl font-bold mb-8 text-center">Mentions Légales</h1>
        
        <div className="space-y-6">
          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">1. Éditeur du site</h2>
            <div className="text-gray-300 leading-relaxed space-y-2">
              <p><strong>Raison sociale :</strong> U Silenziu</p>
              <p><strong>Forme juridique :</strong> [À compléter]</p>
              <p><strong>Capital social :</strong> [À compléter]</p>
              <p><strong>RCS :</strong> [À compléter]</p>
              <p><strong>SIRET :</strong> [À compléter]</p>
              <p><strong>Code APE :</strong> [À compléter]</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">2. Siège social</h2>
            <div className="text-gray-300 leading-relaxed space-y-2">
              <p>18 Rue du Pont Long</p>
              <p>Zone Berlanne</p>
              <p>64160 Buros</p>
              <p>France</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">3. Contact</h2>
            <div className="text-gray-300 leading-relaxed space-y-2">
              <p><strong>Téléphone :</strong> +33 7 83 83 64 53</p>
              <p><strong>Email :</strong> info@usilenziu.com</p>
              <p><strong>Site web :</strong> https://rageroom.usilenziu.com</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">4. Directeur de publication</h2>
            <p className="text-gray-300 leading-relaxed">
              [Nom du directeur de publication à compléter]
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">5. Hébergement</h2>
            <div className="text-gray-300 leading-relaxed space-y-2">
              <p><strong>Hébergeur :</strong> [Nom de l'hébergeur à compléter]</p>
              <p><strong>Adresse :</strong> [Adresse de l'hébergeur à compléter]</p>
              <p><strong>Téléphone :</strong> [Téléphone de l'hébergeur à compléter]</p>
            </div>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">6. Propriété intellectuelle</h2>
            <p className="text-gray-300 leading-relaxed">
              L'ensemble du contenu du site (textes, images, vidéos, logos, etc.) est protégé par le droit d'auteur. 
              Toute reproduction, distribution, modification ou utilisation sans autorisation expresse est interdite.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">7. Responsabilité</h2>
            <p className="text-gray-300 leading-relaxed">
              U Silenziu s'efforce de fournir des informations exactes et à jour. Cependant, nous ne pouvons 
              garantir l'exactitude, la précision ou l'exhaustivité des informations mises à disposition sur le site.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">8. Cookies</h2>
            <p className="text-gray-300 leading-relaxed">
              Ce site utilise des cookies pour améliorer l'expérience utilisateur et analyser le trafic. 
              En continuant à naviguer sur ce site, vous acceptez l'utilisation de cookies.
            </p>
          </section>

          <section>
            <h2 className="text-2xl font-semibold mb-4 text-kaki-400">9. Droit applicable</h2>
            <p className="text-gray-300 leading-relaxed">
              Les présentes mentions légales sont soumises au droit français. En cas de litige, les tribunaux 
              français seront compétents.
            </p>
          </section>

          <section className="pt-6 border-t border-gray-700">
            <p className="text-sm text-gray-400">
              Dernière mise à jour : {new Date().toLocaleDateString('fr-FR')}
            </p>
          </section>
        </div>
      </div>
    </div>
  )
  }

  // Afficher le contenu depuis la base de données
  return (
    <div className="min-h-screen bg-gray-900 text-white">
      <div className="container mx-auto px-4 py-8 max-w-4xl">
        <h1 className="text-3xl font-bold mb-8 text-center">{legalPage.title}</h1>
        
        <div 
          className="prose prose-invert max-w-none"
          dangerouslySetInnerHTML={{ __html: legalPage.content }}
        />
        
        <section className="pt-6 border-t border-gray-700">
          <p className="text-sm text-gray-400">
            Dernière mise à jour : {new Date(legalPage.updated_at).toLocaleDateString('fr-FR')}
            {legalPage.last_updated_by && ` par ${legalPage.last_updated_by}`}
          </p>
        </section>
      </div>
    </div>
  )
}

/**
 * Métadonnées SEO pour la page Mentions Légales
 */
export async function generateMetadata(): Promise<Metadata> {
  const legalPage = await getLegalPageByType('legal')
  
  if (legalPage) {
    return {
      title: legalPage.seo_title || legalPage.title,
      description: legalPage.meta_description || 'Mentions légales de U Silenziu',
      keywords: legalPage.keywords?.join(', ') || 'mentions légales, U Silenziu, Buros'
    }
  }
  
  return {
    title: 'Mentions Légales - U Silenziu',
    description: 'Mentions légales de U Silenziu, zone de défoulement à Buros'
  }
}
