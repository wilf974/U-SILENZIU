import { NextRequest, NextResponse } from 'next/server';
import { getLegalPageById, updateLegalPage, deleteLegalPage } from '@/lib/database';

/**
 * API Route d'administration pour la gestion d'une page légale spécifique
 * GET /api/admin/legal-pages/[id] - Récupérer une page légale par ID
 * PUT /api/admin/legal-pages/[id] - Modifier une page légale
 * DELETE /api/admin/legal-pages/[id] - Supprimer une page légale
 */

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params;
    
    if (!id) {
      return NextResponse.json(
        { success: false, error: 'ID de la page légale requis' },
        { status: 400 }
      );
    }

    const page = await getLegalPageById(id);

    if (!page) {
      return NextResponse.json(
        { success: false, error: 'Page légale non trouvée' },
        { status: 404 }
      );
    }

    return NextResponse.json({ success: true, data: page });
  } catch (error) {
    console.error('Erreur lors de la récupération de la page légale:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la récupération de la page légale' },
      { status: 500 }
    );
  }
}

export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params;
    const body = await request.json();
    const { title, content, meta_description, seo_title, keywords, is_published, last_updated_by } = body;

    if (!id) {
      return NextResponse.json(
        { success: false, error: 'ID de la page légale requis' },
        { status: 400 }
      );
    }

    // Vérifier que la page existe
    const existingPage = await getLegalPageById(id);
    if (!existingPage) {
      return NextResponse.json(
        { success: false, error: 'Page légale non trouvée' },
        { status: 404 }
      );
    }

    const updateData = {
      title: title || existingPage.title,
      content: content || existingPage.content,
      meta_description: meta_description !== undefined ? meta_description : existingPage.meta_description,
      seo_title: seo_title !== undefined ? seo_title : existingPage.seo_title,
      keywords: keywords || existingPage.keywords,
      is_published: is_published !== undefined ? is_published : existingPage.is_published
    };

    const updatedPage = await updateLegalPage(id, updateData, last_updated_by);

    if (!updatedPage) {
      return NextResponse.json(
        { success: false, error: 'Erreur lors de la mise à jour de la page légale' },
        { status: 500 }
      );
    }

    return NextResponse.json({ success: true, data: updatedPage });
  } catch (error) {
    console.error('Erreur lors de la mise à jour de la page légale:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la mise à jour de la page légale' },
      { status: 500 }
    );
  }
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params;

    if (!id) {
      return NextResponse.json(
        { success: false, error: 'ID de la page légale requis' },
        { status: 400 }
      );
    }

    // Vérifier que la page existe
    const existingPage = await getLegalPageById(id);
    if (!existingPage) {
      return NextResponse.json(
        { success: false, error: 'Page légale non trouvée' },
        { status: 404 }
      );
    }

    const success = await deleteLegalPage(id);

    if (!success) {
      return NextResponse.json(
        { success: false, error: 'Erreur lors de la suppression de la page légale' },
        { status: 500 }
      );
    }

    return NextResponse.json({ success: true, message: 'Page légale supprimée avec succès' });
  } catch (error) {
    console.error('Erreur lors de la suppression de la page légale:', error);
    return NextResponse.json(
      { success: false, error: 'Erreur lors de la suppression de la page légale' },
      { status: 500 }
    );
  }
}
