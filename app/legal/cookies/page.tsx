import { Metadata } from 'next'
import { getLegalPageByType } from '@/lib/database'
import LegalPageLayout from '@/components/LegalPageLayout'

export const dynamic = 'force-dynamic'

export const metadata: Metadata = {
  title: 'Paramètres des Cookies - U Silenziu',
  description: 'Gérez vos préférences de cookies sur le site U Silenziu.',
  keywords: ['cookies', 'paramètres', 'préférences', 'U Silenziu'],
  openGraph: {
    title: 'Paramètres des Cookies - U Silenziu',
    description: 'Gérez vos préférences de cookies sur le site U Silenziu.',
    type: 'website',
  },
}

export default async function CookiesPage() {
  const page = await getLegalPageByType('cookies')

  return (
    <LegalPageLayout
      title={page?.title || 'Paramètres des Cookies'}
      content={page?.content}
      updatedAt={page?.updated_at}
      notFound={!page}
    />
  )
}
