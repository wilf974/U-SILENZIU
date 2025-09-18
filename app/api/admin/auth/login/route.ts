import { NextRequest, NextResponse } from 'next/server'
import { getAdminUserByUsername, updateLastLogin, updateAdminUser } from '@/lib/database'
import { verifyPassword, createAdminToken, ADMIN_TOKEN_COOKIE } from '@/lib/auth'

const COOKIE_MAX_AGE_SECONDS = 60 * 60 // 1 hour
const BCRYPT_PREFIX = '$2'

function isBcryptHash(value: string): boolean {
  return value.startsWith(BCRYPT_PREFIX)
}

async function upgradePasswordHashIfNeeded(userId: string, password: string) {
  try {
    await updateAdminUser(userId, { password })
  } catch (error) {
    console.error("Erreur lors de la mise à niveau du hash de mot de passe:", error)
  }
}

/**
 * POST /api/admin/auth/login
 * Authentifie un utilisateur administrateur
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json().catch(() => null)

    if (!body || typeof body !== 'object') {
      return NextResponse.json(
        {
          success: false,
          error: 'Corps de requête invalide'
        },
        { status: 400 }
      )
    }

    const username = typeof body.username === 'string' ? body.username.trim() : ''
    const password = typeof body.password === 'string' ? body.password : ''

    if (!username || !password) {
      return NextResponse.json(
        {
          success: false,
          error: 'Nom d\'utilisateur et mot de passe requis'
        },
        { status: 400 }
      )
    }

    const user = await getAdminUserByUsername(username)

    if (!user || !user.password_hash) {
      return NextResponse.json(
        {
          success: false,
          error: 'Identifiants incorrects'
        },
        { status: 401 }
      )
    }

    let passwordIsValid = false

    if (isBcryptHash(user.password_hash)) {
      passwordIsValid = await verifyPassword(password, user.password_hash)
    } else {
      passwordIsValid = user.password_hash === password

      if (passwordIsValid) {
        // Mettre à niveau le mot de passe vers un hash sécurisé
        await upgradePasswordHashIfNeeded(user.id, password)
      }
    }

    if (!passwordIsValid) {
      return NextResponse.json(
        {
          success: false,
          error: 'Identifiants incorrects'
        },
        { status: 401 }
      )
    }

    await updateLastLogin(user.username)

    const token = createAdminToken({
      sub: user.id,
      username: user.username,
      role: user.role,
    })

    const response = NextResponse.json({
      success: true,
      user: {
        id: user.id,
        username: user.username,
        role: user.role,
        created_at: user.created_at,
        updated_at: user.updated_at,
        last_login: user.last_login,
      },
      token,
    })

    response.cookies.set({
      name: ADMIN_TOKEN_COOKIE,
      value: token,
      httpOnly: true,
      secure: false, // Désactivé pour permettre HTTP en production sur VPS
      sameSite: 'lax',
      maxAge: COOKIE_MAX_AGE_SECONDS,
      path: '/',
    })

    return response
  } catch (error) {
    console.error('Erreur lors de l\'authentification:', error)

    if (error instanceof Error && error.message.includes('JWT_SECRET')) {
      return NextResponse.json(
        {
          success: false,
          error: 'Configuration du serveur incomplète'
        },
        { status: 500 }
      )
    }

    return NextResponse.json(
      {
        success: false,
        error: 'Erreur interne du serveur'
      },
      { status: 500 }
    )
  }
}
