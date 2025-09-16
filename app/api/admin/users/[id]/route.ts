import { NextRequest, NextResponse } from 'next/server'
import { getAdminUserById, updateAdminUser, deleteAdminUser, getAdminUsers } from '@/lib/database'

/**
 * GET /api/admin/users/[id]
 * Récupère un utilisateur administrateur par son ID
 */
export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const userId = params.id
    const user = await getAdminUserById(userId)
    
    if (!user) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Utilisateur non trouvé' 
        },
        { status: 404 }
      )
    }

    return NextResponse.json({
      success: true,
      user: user
    })
  } catch (error) {
    console.error('Erreur lors de la récupération de l\'utilisateur:', error)
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la récupération de l\'utilisateur' 
      },
      { status: 500 }
    )
  }
}

/**
 * PUT /api/admin/users/[id]
 * Met à jour un utilisateur administrateur
 */
export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const userId = params.id
    const body = await request.json()
    const { username, password, role } = body

    // Validation des données - au moins un champ doit être fourni
    if (!username && !password && !role) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Au moins un champ (nom d\'utilisateur, mot de passe ou rôle) doit être fourni' 
        },
        { status: 400 }
      )
    }

    // Validation du rôle si fourni
    if (role && role !== 'admin' && role !== 'super-admin') {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Rôle invalide' 
        },
        { status: 400 }
      )
    }

    // Vérifier si l'utilisateur existe
    const existingUser = await getAdminUserById(userId)
    if (!existingUser) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Utilisateur non trouvé' 
        },
        { status: 404 }
      )
    }

    // Vérifier si le nom d'utilisateur est déjà pris par un autre utilisateur (seulement si username est fourni)
    if (username && username !== existingUser.username) {
      const allUsers = await getAdminUsers()
      const usernameExists = allUsers.some(user => 
        user.username === username && user.id !== userId
      )
      
      if (usernameExists) {
        return NextResponse.json(
          { 
            success: false, 
            error: 'Un utilisateur avec ce nom existe déjà' 
          },
          { status: 409 }
        )
      }
    }

    // Préparer les données de mise à jour - seulement les champs fournis
    const updateData: any = {}

    if (username !== undefined) {
      updateData.username = username
    }

    if (password !== undefined) {
      updateData.password = password
    }

    if (role !== undefined) {
      updateData.role = role
    }

    // Mettre à jour l'utilisateur
    const updatedUser = await updateAdminUser(userId, updateData)

    return NextResponse.json({
      success: true,
      user: updatedUser,
      message: 'Utilisateur modifié avec succès'
    })
  } catch (error) {
    console.error('Erreur lors de la modification de l\'utilisateur:', error)
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la modification de l\'utilisateur' 
      },
      { status: 500 }
    )
  }
}

/**
 * DELETE /api/admin/users/[id]
 * Supprime un utilisateur administrateur
 */
export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const userId = params.id

    // Vérifier si l'utilisateur existe
    const existingUser = await getAdminUserById(userId)
    if (!existingUser) {
      return NextResponse.json(
        { 
          success: false, 
          error: 'Utilisateur non trouvé' 
        },
        { status: 404 }
      )
    }

    // Supprimer l'utilisateur
    await deleteAdminUser(userId)

    return NextResponse.json({
      success: true,
      message: 'Utilisateur supprimé avec succès'
    })
  } catch (error) {
    console.error('Erreur lors de la suppression de l\'utilisateur:', error)
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la suppression de l\'utilisateur' 
      },
      { status: 500 }
    )
  }
}
