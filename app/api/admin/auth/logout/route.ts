import { NextResponse } from 'next/server'
import { ADMIN_TOKEN_COOKIE } from '@/lib/auth'

/**
 * POST /api/admin/auth/logout
 * Déconnecte l'utilisateur en supprimant le cookie d'authentification
 */
export async function POST() {
  const response = NextResponse.json({
    success: true,
    message: 'Déconnexion réussie'
  })

  // Supprimer le cookie
  response.cookies.set({
    name: ADMIN_TOKEN_COOKIE,
    value: '',
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    maxAge: -1, // Expire le cookie immédiatement
    path: '/',
  })

  return response
}
