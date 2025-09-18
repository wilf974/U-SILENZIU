import { NextRequest, NextResponse } from 'next/server'
import { verifyAdminToken, ADMIN_TOKEN_COOKIE, TokenPayload } from '@/lib/auth'
import { getAdminUserById } from '@/lib/database'

/**
 * GET /api/admin/auth/status
 * Vérifie le statut d'authentification de l'administrateur
 * et renvoie les informations utilisateur si le token est valide.
 */
export async function GET(request: NextRequest) {
  const tokenCookie = request.cookies.get(ADMIN_TOKEN_COOKIE)

  if (!tokenCookie) {
    return NextResponse.json({ isAuthenticated: false, user: null }, { status: 401 })
  }

  try {
    const token = tokenCookie.value
    const decoded = verifyAdminToken(token) as TokenPayload

    const user = await getAdminUserById(decoded.sub)

    if (!user) {
      return NextResponse.json({ isAuthenticated: false, user: null }, { status: 404 })
    }

    return NextResponse.json({
      isAuthenticated: true,
      user: {
        username: user.username,
        role: user.role,
      },
    })
  } catch (error) {
    console.error('Erreur de vérification du token:', error)
    return NextResponse.json({ isAuthenticated: false, user: null }, { status: 401 })
  }
}
