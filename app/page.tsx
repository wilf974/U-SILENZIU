import type { Metadata } from 'next'
import Header from '@/components/Header'
import Footer from '@/components/Footer'
import HomepageSections from '@/components/HomepageSections'
import JsonLd from '@/components/JsonLd'
import { generatePageMetadata } from '@/lib/metadata'

export const metadata: Metadata = generatePageMetadata(
  'Accueil',
  'Découvrez U Silenziu, votre zone de défoulement à Buros. Cassez, détruisez et libérez votre stress dans nos salles sécurisées. Lancer de haches, shurikens, fléchettes et activités de défoulement.',
  '/',
  ['zone de défoulement', 'Buros', 'défoulement', 'stress', 'lancer de haches', 'shurikens', 'fléchettes', 'color zone', 'bras de fer']
)

export default function Home() {
  return (
    <>
      <JsonLd />
      <main className="min-h-screen bg-dark-bg">
        <Header />
        {/* Toutes les sections dans l'ordre configuré dans le back-office */}
        <HomepageSections />
        <Footer />
      </main>
    </>
  )
}

