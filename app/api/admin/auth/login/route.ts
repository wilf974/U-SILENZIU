import { NextRequest, NextResponse } from 'next/server'
import { getAdminUserByUsername } from '@/lib/database'

/**
 * POST /api/admin/auth/login
 * Authentifie un utilisateur administrateur
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { username, password } = body

    // Validation des données
    if (!username || !password) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Nom d\'utilisateur et mot de passe requis' 
        },
        { status: 400 }
      )
    }

    // Récupérer l'utilisateur depuis la base de données
    const user = await getAdminUserByUsername(username)
    
    if (!user) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Identifiants incorrects' 
        },
        { status: 401 }
      )
    }

    // Vérifier le mot de passe
    // En production, utiliser bcrypt.compare(password, user.password_hash)
    // Pour l'instant, comparaison en texte brut
    if (password !== user.password_hash) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Identifiants incorrects' 
        },
        { status: 401 }
      )
    }

    // Mettre à jour la dernière connexion
    // await updateLastLogin(username)

    // Générer un token (en production, utiliser JWT)
    const token = user.role === 'super-admin' 
      ? 'super-admin-token-2025' 
      : 'admin-token-2025'

    return NextResponse.json({
      success: true,
      user: {
        id: user.id,
        username: user.username,
        role: user.role,
        created_at: user.created_at,
        updated_at: user.updated_at,
        last_login: user.last_login
      },
      token
    })

  } catch (error) {
    console.error('Erreur lors de l\'authentification:', error)
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur interne du serveur' 
      },
      { status: 500 }
    )
  }
}
