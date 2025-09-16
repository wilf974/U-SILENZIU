import { NextRequest, NextResponse } from 'next/server';
import { getAllLegalPages, createLegalPage } from '@/lib/database';

/**
 * API Route d'administration pour la gestion des pages légales
 * GET /api/admin/legal-pages - Récupérer toutes les pages légales
 * POST /api/admin/legal-pages - Créer une nouvelle page légale
 */

export async function GET() {
  try {
    const pages = await getAllLegalPages();
    return NextResponse.json({ success: true, data: pages });
  } catch (error) {
    console.error('Erreur lors de la récupération des pages légales:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la récupération des pages légales' },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { page_type, title, content, meta_description, seo_title, keywords, is_published, last_updated_by } = body;

    // Validation des champs obligatoires
    if (!page_type || !title || !content) {
      return NextResponse.json(
        { success: false, error: 'Les champs page_type, title et content sont obligatoires' },
        { status: 400 }
      );
    }

    // Validation du type de page
    const validTypes = ['cgv', 'privacy', 'legal', 'cookies'];
    if (!validTypes.includes(page_type)) {
      return NextResponse.json(
        { success: false, error: 'Type de page légale invalide' },
        { status: 400 }
      );
    }

    const pageData = {
      page_type,
      title,
      content,
      meta_description: meta_description || null,
      seo_title: seo_title || null,
      keywords: keywords || [],
      is_published: is_published !== undefined ? is_published : true
    };

    const newPage = await createLegalPage(pageData, last_updated_by);

    if (!newPage) {
      return NextResponse.json(
        { success: false, error: 'Erreur lors de la création de la page légale' },
        { status: 500 }
      );
    }

    return NextResponse.json({ success: true, data: newPage }, { status: 201 });
  } catch (error) {
    console.error('Erreur lors de la création de la page légale:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la création de la page légale' },
      { status: 500 }
    );
  }
}
