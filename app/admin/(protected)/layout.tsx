import { ReactNode } from 'react'
import { cookies } from 'next/headers'
import { redirect } from 'next/navigation'
import { ADMIN_TOKEN_COOKIE, verifyAdminToken } from '@/lib/auth'

export default function AdminProtectedLayout({ children }: { children: ReactNode }) {
  const token = cookies().get(ADMIN_TOKEN_COOKIE)?.value

  if (!token) {
    redirect('/admin/login')
  }

  try {
    verifyAdminToken(token)
  } catch (error) {
    console.error('Token admin invalide:', error)
    redirect('/admin/login?error=expired')
  }

  return <>{children}</>
}
