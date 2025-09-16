import { Metadata } from 'next'

export const siteConfig = {
  name: 'U Silenziu',
  description: 'Zone de défoulement à Buros - Cassez, détruisez et libérez votre stress',
  url: 'https://usilenziu.com',
  ogImage: 'https://usilenziu.com/og-image.jpg',
  links: {
    facebook: 'https://www.facebook.com/usilenziu',
    instagram: 'https://www.instagram.com/usilenziu',
  },
  contact: {
    phone: '+33-5-XX-XX-XX-XX',
    email: 'contact@usilenziu.com',
  },
  address: {
    street: 'Adresse à compléter',
    city: 'Buros',
    region: 'Nouvelle-Aquitaine',
    postalCode: '64160',
    country: 'FR',
  },
  coordinates: {
    latitude: '43.XXXXX',
    longitude: '-0.XXXXX',
  },
  openingHours: {
    tuesday: { opens: '14:00', closes: '21:00' },
    wednesday: { opens: '14:00', closes: '21:00' },
    thursday: { opens: '14:00', closes: '21:00' },
    friday: { opens: '14:00', closes: '00:00' },
    saturday: { opens: '14:00', closes: '00:00' },
  },
}

export const defaultMetadata: Metadata = {
  metadataBase: new URL(siteConfig.url),
  title: {
    default: `${siteConfig.name} - Zone de Défoulement à Buros`,
    template: `%s | ${siteConfig.name}`,
  },
  description: siteConfig.description,
  keywords: [
    'défoulement',
    'stress',
    'détruire',
    'casser',
    'thérapie',
    'loisir',
    'activité',
    'Buros',
    'haches',
    'shurikens',
    'fléchettes',
    'color zone',
    'bras de fer',
    'zone de défoulement',
    'salle de défoulement',
  ],
  authors: [{ name: siteConfig.name }],
  creator: siteConfig.name,
  publisher: siteConfig.name,
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  openGraph: {
    type: 'website',
    locale: 'fr_FR',
    url: siteConfig.url,
    siteName: siteConfig.name,
    title: `${siteConfig.name} - Zone de Défoulement à Buros`,
    description: siteConfig.description,
    images: [
      {
        url: siteConfig.ogImage,
        width: 1200,
        height: 630,
        alt: `${siteConfig.name} - Zone de défoulement à Buros`,
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: `${siteConfig.name} - Zone de Défoulement à Buros`,
    description: siteConfig.description,
    images: [siteConfig.ogImage],
    creator: '@usilenziu',
  },
  robots: {
    index: true,
    follow: true,
    nocache: false,
    googleBot: {
      index: true,
      follow: true,
      noimageindex: false,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  verification: {
    google: 'your-google-verification-code',
  },
  alternates: {
    canonical: siteConfig.url,
  },
  category: 'Loisirs et Activités',
}

export function generatePageMetadata(
  title: string,
  description: string,
  path: string,
  keywords?: string[]
): Metadata {
  const url = `${siteConfig.url}${path}`
  
  return {
    title,
    description,
    keywords: keywords || defaultMetadata.keywords,
    openGraph: {
      ...defaultMetadata.openGraph,
      title,
      description,
      url,
    },
    twitter: {
      ...defaultMetadata.twitter,
      title,
      description,
    },
    alternates: {
      canonical: url,
    },
  }
}
