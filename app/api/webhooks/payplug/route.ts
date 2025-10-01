import { NextRequest, NextResponse } from 'next/server'

/**
 * Webhook Payplug - DÉSACTIVÉ
 * Les paiements sont maintenant gérés manuellement
 * POST /api/webhooks/payplug
 */
export async function POST(request: NextRequest) {
  console.log('Webhook Payplug reçu - Webhook désactivé, vérification manuelle uniquement')

  return NextResponse.json(
    {
      success: true,
      message: 'Webhook désactivé - vérification manuelle des paiements',
      status: 'disabled'
    },
    { status: 200 }
  )
}
