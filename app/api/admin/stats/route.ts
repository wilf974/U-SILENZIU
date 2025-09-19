import { NextRequest, NextResponse } from 'next/server'
import { getAllReservations, getAllRooms } from '@/lib/database'
import { Pool } from 'pg'

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://usilenzio_user:usilenzio_password_2024@postgres:5432/usilenzio',
})

// Fonction pour vérifier la configuration SMTP
async function checkSmtpConfig(): Promise<boolean> {
  const client = await pool.connect()
  try {
    const result = await client.query(`
      SELECT COUNT(*) as count 
      FROM smtp_config 
      WHERE is_active = true 
      AND host IS NOT NULL 
      AND username IS NOT NULL 
      AND password_encrypted IS NOT NULL
    `)
    return parseInt(result.rows[0].count) > 0
  } catch (error) {
    console.error('Erreur lors de la vérification SMTP:', error)
    return false
  } finally {
    client.release()
  }
}

// Fonction pour vérifier le statut de la base de données
async function checkDatabaseStatus(): Promise<boolean> {
  const client = await pool.connect()
  try {
    await client.query('SELECT 1')
    return true
  } catch (error) {
    console.error('Erreur de connexion à la base de données:', error)
    return false
  } finally {
    client.release()
  }
}

// Fonction pour vérifier le statut des notifications (basé sur SMTP)
async function checkNotificationsStatus(): Promise<boolean> {
  // Les notifications dépendent de la configuration SMTP
  return await checkSmtpConfig()
}

/**
 * GET /api/admin/stats
 * Récupère les statistiques du dashboard admin
 */
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const includeRecent = searchParams.get('includeRecent') === 'true'

    // Récupérer toutes les réservations
    const reservations = await getAllReservations()
    
    // Récupérer toutes les salles
    const rooms = await getAllRooms()
    
    // Calculer les statistiques du dashboard
    const today = new Date().toISOString().split('T')[0]
    const todayReservations = reservations.filter(r => r.date === today)
    
    const confirmedReservations = reservations.filter(r => r.status === 'confirmed')
    const totalRevenue = confirmedReservations.reduce((sum, r) => {
      const amount = typeof r.amount === 'string' ? parseFloat(r.amount) : (r.amount || 0)
      return sum + amount
    }, 0)

    const activeRooms = rooms.filter(r => r.is_active)

    const dashboardStats = {
      totalReservations: reservations.length,
      todayReservations: todayReservations.length,
      totalRevenue: Math.round(totalRevenue * 100) / 100, // Arrondir à 2 décimales
      activeRooms: activeRooms.length,
      pendingReservations: reservations.filter(r => r.status === 'pending').length,
      confirmedReservations: confirmedReservations.length,
      cancelledReservations: reservations.filter(r => r.status === 'cancelled').length
    }

    // Vérifier le statut du système
    const [smtpStatus, dbStatus, notificationsStatus] = await Promise.all([
      checkSmtpConfig(),
      checkDatabaseStatus(),
      checkNotificationsStatus()
    ])

    const systemStatus = {
      smtp: smtpStatus,
      notifications: notificationsStatus,
      database: dbStatus
    }

    // Préparer les données de réponse
    const responseData: any = {
      dashboard: dashboardStats,
      system: systemStatus
    }

    // Inclure les réservations récentes si demandé
    if (includeRecent) {
      const recentReservations = reservations
        .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
        .slice(0, 10) // Les 10 plus récentes

      responseData.recentReservations = recentReservations
    }

    return NextResponse.json({
      success: true,
      data: responseData,
      timestamp: new Date().toISOString()
    })

  } catch (error) {
    console.error('Erreur lors de la récupération des statistiques:', error)
    
    return NextResponse.json({
      success: false,
      error: 'Erreur lors de la récupération des statistiques',
      details: error instanceof Error ? error.message : 'Erreur inconnue'
    }, { status: 500 })
  }
}