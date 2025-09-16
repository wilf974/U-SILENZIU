import { NextRequest, NextResponse } from 'next/server'
import { getAdminUsers, createAdminUser } from '@/lib/database'

/**
 * GET /api/admin/users
 * Récupère la liste des utilisateurs administrateurs
 */
export async function GET(request: NextRequest) {
  try {
    // Vérifier l'authentification (sera fait par le middleware ou la protection des routes)
    const users = await getAdminUsers()
    
    return NextResponse.json({
      success: true,
      users: users
    })
  } catch (error) {
    console.error('Erreur lors de la récupération des utilisateurs:', error)
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la récupération des utilisateurs' 
      },
      { status: 500 }
    )
  }
}

/**
 * POST /api/admin/users
 * Crée un nouvel utilisateur administrateur
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { username, password, role } = body

    // Validation des données
    if (!username || !password || !role) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Tous les champs sont requis' 
        },
        { status: 400 }
      )
    }

    if (role !== 'admin' && role !== 'super-admin') {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Rôle invalide' 
        },
        { status: 400 }
      )
    }

    // Vérifier si l'utilisateur existe déjà
    const existingUsers = await getAdminUsers()
    const userExists = existingUsers.some(user => user.username === username)
    
    if (userExists) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Un utilisateur avec ce nom existe déjà' 
        },
        { status: 409 }
      )
    }

    // Créer l'utilisateur
    const newUser = await createAdminUser({
      username,
      password,
      role
    })

    return NextResponse.json({
      success: true,
      user: newUser,
      message: 'Utilisateur créé avec succès'
    })
  } catch (error) {
    console.error('Erreur lors de la création de l\'utilisateur:', error)
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la création de l\'utilisateur' 
      },
      { status: 500 }
    )
  }
}
