import { ReactNode } from 'react'
import { cookies } from 'next/headers'
import { redirect } from 'next/navigation'
import { ADMIN_TOKEN_COOKIE, verifyAdminToken } from '@/lib/auth'

export default function AdminAuthLayout({ children }: { children: ReactNode }) {
  const token = cookies().get(ADMIN_TOKEN_COOKIE)?.value

  if (token) {
    try {
      verifyAdminToken(token)
      redirect('/admin')
    } catch (error) {
      console.warn('Token admin invalide sur /admin/login:', error)
    }
  }

  return <>{children}</>
}
