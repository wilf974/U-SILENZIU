import { Metadata } from 'next'
import { getLegalPageByType } from '@/lib/database'
import LegalPageLayout from '@/components/LegalPageLayout'

export const dynamic = 'force-dynamic'

export const metadata: Metadata = {
  title: 'Politique de Confidentialité - U Silenziu',
  description: 'Découvrez comment U Silenziu protège et utilise vos données personnelles.',
  keywords: ['confidentialité', 'données personnelles', 'RGPD', 'protection', 'U Silenziu'],
  openGraph: {
    title: 'Politique de Confidentialité - U Silenziu',
    description: 'Découvrez comment U Silenziu protège et utilise vos données personnelles.',
    type: 'website',
  },
}

export default async function PrivacyPage() {
  const page = await getLegalPageByType('privacy')

  return (
    <LegalPageLayout
      title={page?.title || 'Politique de Confidentialité'}
      content={page?.content}
      updatedAt={page?.updated_at}
      notFound={!page}
    />
  )
}
