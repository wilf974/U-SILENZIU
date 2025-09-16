import { NextRequest, NextResponse } from 'next/server';
import { getLegalPageByType } from '@/lib/database';

/**
 * API Route publique pour récupérer une page légale par son type
 * GET /api/legal-pages/[type] - Récupérer une page légale publiée par type
 */

export async function GET(
  request: NextRequest,
  { params }: { params: { type: string } }
) {
  try {
    const { type } = params;
    
    if (!type) {
      return NextResponse.json(
        { success: false, error: 'Type de page légale requis' },
        { status: 400 }
      );
    }

    // Validation du type de page
    const validTypes = ['cgv', 'privacy', 'legal', 'cookies'];
    if (!validTypes.includes(type)) {
      return NextResponse.json(
        { success: false, error: 'Type de page légale invalide' },
        { status: 400 }
      );
    }

    const page = await getLegalPageByType(type);

    if (!page) {
      return NextResponse.json(
        { success: false, error: 'Page légale non trouvée ou non publiée' },
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
