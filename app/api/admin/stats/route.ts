import { NextRequest, NextResponse } from 'next/server'
import { getDashboardStats, getRecentReservations, getReservationStatsByStatus, getRevenueByPeriod } from '@/lib/database'

/**
 * API Route pour récupérer les statistiques du dashboard admin
 * GET - Récupère toutes les statistiques nécessaires au dashboard
 */

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const period = searchParams.get('period') as 'today' | 'week' | 'month' | 'year' | null
    const includeRecent = searchParams.get('includeRecent') === 'true'

    // Récupérer les statistiques principales du dashboard
    const dashboardStats = await getDashboardStats()
    
    // Récupérer les statistiques par statut
    const statusStats = await getReservationStatsByStatus()
    
    // Récupérer les revenus par période si spécifié
    let periodRevenue = null
    if (period) {
      periodRevenue = await getRevenueByPeriod(period)
    }
    
    // Récupérer les réservations récentes si demandé
    let recentReservations = null
    if (includeRecent) {
      recentReservations = await getRecentReservations(5)
    }

    // Vérifier le statut du système
    const systemStatus = {
      smtp: true, // TODO: Vérifier la configuration SMTP
      notifications: true, // TODO: Vérifier le statut des notifications
      database: true // La base de données fonctionne si on arrive ici
    }

    return NextResponse.json({
      success: true,
      data: {
        dashboard: dashboardStats,
        status: statusStats,
        system: systemStatus,
        ...(periodRevenue !== null && { periodRevenue }),
        ...(recentReservations && { recentReservations })
      },
      timestamp: new Date().toISOString()
    })

  } catch (error) {
    console.error('Erreur lors de la récupération des statistiques:', error)
    return NextResponse.json(
      { 
        success: false,
        error: 'Erreur lors de la récupération des statistiques',
        details: error instanceof Error ? error.message : 'Erreur inconnue'
      },
      { status: 500 }
    )
  }
}
