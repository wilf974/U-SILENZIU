import { ReactNode } from 'react'
import { cookies } from 'next/headers'
import { redirect } from 'next/navigation'
import { ADMIN_TOKEN_COOKIE, verifyAdminToken } from '@/lib/auth'

export default function AdminProtectedLayout({ children }: { children: ReactNode }) {
  console.log('[AdminProtectedLayout] Loading layout')
  const token = cookies().get(ADMIN_TOKEN_COOKIE)?.value
  console.log('[AdminProtectedLayout] Token found:', !!token)
  console.log('[AdminProtectedLayout] All cookies:', cookies().getAll())

  if (!token) {
    console.error('[AdminProtectedLayout] No token found, redirecting to login')
    redirect('/admin/login')
  }

  try {
    console.log('[AdminProtectedLayout] Verifying token...')
    verifyAdminToken(token)
    console.log('[AdminProtectedLayout] Token verified successfully')
  } catch (error) {
    console.error('[AdminProtectedLayout] Token admin invalide:', error)
    redirect('/admin/login?error=expired')
  }

  return <>{children}</>
}
