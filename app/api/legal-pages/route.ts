import { NextRequest, NextResponse } from 'next/server'
import { getPublishedLegalPages } from '@/lib/database'

/**
 * Route publique pour récupérer toutes les pages légales publiées
 * Utilisée par le footer pour afficher les liens légaux
 */
export async function GET(request: NextRequest) {
  try {
    const pages = await getPublishedLegalPages()
    
    return NextResponse.json({
      success: true,
      data: pages
    })
  } catch (error) {
    console.error('Erreur lors de la récupération des pages légales:', error)
    return NextResponse.json(
      { 
        success: false, 
        error: 'Erreur lors de la récupération des pages légales' 
      },
      { status: 500 }
    )
  }
}
