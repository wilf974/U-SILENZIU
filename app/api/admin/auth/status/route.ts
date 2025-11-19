import { NextRequest, NextResponse } from 'next/server'
import { verifyAdminToken, ADMIN_TOKEN_COOKIE, TokenPayload } from '@/lib/auth'
import { getAdminUserById } from '@/lib/database'

/**
 * GET /api/admin/auth/status
 * Vérifie le statut d'authentification de l'administrateur
 * et renvoie les informations utilisateur si le token est valide.
 */
export async function GET(request: NextRequest) {
  console.log('[Status API] Requête reçue')
  console.log('[Status API] Tous les cookies reçus:', request.cookies.getAll())
  const tokenCookie = request.cookies.get(ADMIN_TOKEN_COOKIE)
  console.log('[Status API] Token trouvé?', !!tokenCookie)
  console.log('[Status API] Token value:', tokenCookie?.value?.substring(0, 20) + '...')

  if (!tokenCookie) {
    console.error('[Status API] Pas de token, retour 401')
    return NextResponse.json({ isAuthenticated: false, user: null }, { status: 401 })
  }

  try {
    console.log('[Status API] Vérification du token...')
    const token = tokenCookie.value
    const decoded = verifyAdminToken(token) as TokenPayload
    console.log('[Status API] Token valide pour user:', decoded.username)

    const user = await getAdminUserById(decoded.sub)

    if (!user) {
      console.error('[Status API] User non trouvé en base')
      return NextResponse.json({ isAuthenticated: false, user: null }, { status: 404 })
    }

    console.log('[Status API] Retour succès pour user:', user.username)
    return NextResponse.json({
      isAuthenticated: true,
      user: {
        username: user.username,
        role: user.role,
      },
    })
  } catch (error) {
    console.error('[Status API] Erreur de vérification du token:', error)
    return NextResponse.json({ isAuthenticated: false, user: null }, { status: 401 })
  }
}
