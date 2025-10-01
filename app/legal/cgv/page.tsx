import { Metadata } from 'next'
import { getLegalPageByType } from '@/lib/database'
import LegalPageLayout from '@/components/LegalPageLayout'

export const dynamic = 'force-dynamic'

export const metadata: Metadata = {
  title: 'Conditions Générales de Vente - U Silenziu',
  description: 'Consultez nos conditions générales de vente pour les réservations de salles à U Silenziu.',
  keywords: ['conditions générales', 'vente', 'réservation', 'salle', 'U Silenziu'],
  openGraph: {
    title: 'Conditions Générales de Vente - U Silenziu',
    description: 'Consultez nos conditions générales de vente pour les réservations de salles à U Silenziu.',
    type: 'website',
  },
}

export default async function CGVPage() {
  const page = await getLegalPageByType('cgv')

  return (
    <LegalPageLayout
      title={page?.title || 'Conditions Générales de Vente'}
      content={page?.content}
      updatedAt={page?.updated_at}
      notFound={!page}
    />
  )
}
