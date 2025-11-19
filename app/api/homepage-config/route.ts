import { NextResponse } from 'next/server';
import { getHomepageConfig } from '@/lib/database';

/**
 * API Route publique pour récupérer la configuration de la page d'accueil
 * GET: Récupère la configuration publique (sans données sensibles)
 */

// GET - Récupère la configuration publique de la page d'accueil
export async function GET() {
  try {
    const config = await getHomepageConfig();
    
    // Filtrer les données sensibles pour l'API publique
    const publicConfig = {
      site_title: config.site_title,
      site_description: config.site_description,
      site_name: config.site_name,
      contact_email: config.contact_email,
      contact_phone: config.contact_phone,
      address: config.address,
      opening_hours: config.opening_hours,
      seo_keywords: config.seo_keywords,
      seo_description: config.seo_description,
      video_url: config.video_url || '/video/hero-video.mp4'
    };
    
    return NextResponse.json({
      success: true,
      data: publicConfig
    });
  } catch (error) {
    console.error('Erreur lors de la récupération de la configuration publique:', error);
    return NextResponse.json({
      success: false,
      error: 'Erreur lors de la récupération de la configuration'
    }, { status: 500 });
  }
}

