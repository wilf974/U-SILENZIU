import type { Metadata } from 'next'
import './globals.css'
import { Providers } from './providers'

// Using system fonts to avoid Google Fonts network dependency
const inter = { variable: '--font-inter' }

export const metadata: Metadata = {
  title: 'U Silenziu - Zone de défoulement à Buros',
  description: 'Découvrez U Silenziu, votre zone de défoulement à Buros. Cassez, détruisez et libérez votre stress dans nos salles sécurisées. Lancer de haches, shurikens, fléchettes et activités de défoulement.',
  keywords: ['zone de défoulement', 'Buros', 'défoulement', 'stress', 'lancer de haches', 'shurikens', 'fléchettes', 'color zone', 'bras de fer'],
  authors: [{ name: 'U Silenziu' }],
  creator: 'U Silenziu',
  publisher: 'U Silenziu',
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  metadataBase: new URL('https://usilenziu.com'),
  alternates: {
    canonical: '/',
  },
  openGraph: {
    title: 'U Silenziu - Zone de défoulement à Buros',
    description: 'Découvrez U Silenziu, votre zone de défoulement à Buros. Cassez, détruisez et libérez votre stress dans nos salles sécurisées.',
    url: 'https://usilenziu.com',
    siteName: 'U Silenziu',
    locale: 'fr_FR',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'U Silenziu - Zone de défoulement à Buros',
    description: 'Découvrez U Silenziu, votre zone de défoulement à Buros. Cassez, détruisez et libérez votre stress dans nos salles sécurisées.',
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="fr" data-scroll-behavior="smooth">
      <body className={`bg-dark-bg text-white antialiased`} style={{ fontFamily: 'system-ui, -apple-system, sans-serif' }}>
        <Providers>
          {children}
        </Providers>
      </body>
    </html>
  )
}
