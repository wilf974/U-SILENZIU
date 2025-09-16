import { NextRequest, NextResponse } from 'next/server';
import { getWeeklyReservations } from '@/lib/database';

/**
 * API pour récupérer les réservations d'une semaine spécifique
 * GET /api/admin/reservations/weekly?week=2025-01-06
 */
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const weekParam = searchParams.get('week');
    
    if (!weekParam) {
      return NextResponse.json(
        { error: 'Le paramètre week est requis (format: YYYY-MM-DD)' },
        { status: 400 }
      );
    }

    // Valider le format de la date
    const weekDate = new Date(weekParam);
    if (isNaN(weekDate.getTime())) {
      return NextResponse.json(
        { error: 'Format de date invalide. Utilisez YYYY-MM-DD' },
        { status: 400 }
      );
    }

    // Récupérer les réservations hebdomadaires
    const weeklyData = await getWeeklyReservations(weekDate);

    return NextResponse.json(weeklyData);

  } catch (error) {
    console.error('Erreur lors de la récupération des réservations hebdomadaires:', error);
    return NextResponse.json(
      { error: 'Erreur interne du serveur' },
      { status: 500 }
    );
  }
}
