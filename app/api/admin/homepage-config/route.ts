import { NextRequest, NextResponse } from 'next/server';
import { getHomepageConfig, updateMultipleHomepageConfigs, getAllHomepageConfigs } from '@/lib/database';

/**
 * API Route pour gérer la configuration de la page d'accueil
 * GET: Récupère la configuration actuelle
 * PUT: Met à jour la configuration
 */

// GET - Récupère la configuration de la page d'accueil
export async function GET() {
  try {
    const config = await getHomepageConfig();
    
    return NextResponse.json({
      success: true,
      data: config
    });
  } catch (error) {
    console.error('Erreur lors de la récupération de la configuration:', error);
    return NextResponse.json({
      success: false,
      error: 'Erreur lors de la récupération de la configuration'
    }, { status: 500 });
  }
}

// PUT - Met à jour la configuration de la page d'accueil
export async function PUT(request: NextRequest) {
  try {
    const body = await request.json();
    
    // Validation des données
    if (!body || typeof body !== 'object') {
      return NextResponse.json({
        success: false,
        error: 'Données de configuration invalides'
      }, { status: 400 });
    }

    // Mise à jour de la configuration
    const success = await updateMultipleHomepageConfigs(body);
    
    if (success) {
      // Récupérer la configuration mise à jour
      const updatedConfig = await getHomepageConfig();
      
      return NextResponse.json({
        success: true,
        message: 'Configuration mise à jour avec succès',
        data: updatedConfig
      });
    } else {
      return NextResponse.json({
        success: false,
        error: 'Erreur lors de la mise à jour de la configuration'
      }, { status: 500 });
    }
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la configuration:', error);
    return NextResponse.json({
      success: false,
      error: 'Erreur lors de la mise à jour de la configuration'
    }, { status: 500 });
  }
}

// GET - Récupère toutes les configurations (pour l'administration)
export async function POST() {
  try {
    const configs = await getAllHomepageConfigs();
    
    return NextResponse.json({
      success: true,
      data: configs
    });
  } catch (error) {
    console.error('Erreur lors de la récupération des configurations:', error);
    return NextResponse.json({
      success: false,
      error: 'Erreur lors de la récupération des configurations'
    }, { status: 500 });
  }
}

