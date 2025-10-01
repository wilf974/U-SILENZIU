import { Metadata } from 'next'
import { getLegalPageByType } from '@/lib/database'
import LegalPageLayout from '@/components/LegalPageLayout'

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

  return (
    <LegalPageLayout
      title={page?.title || 'Mentions Légales'}
      content={page?.content}
      updatedAt={page?.updated_at}
      notFound={!page}
    />
  )
}
