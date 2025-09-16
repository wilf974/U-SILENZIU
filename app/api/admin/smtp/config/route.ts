import { NextRequest, NextResponse } from 'next/server'
import { getSmtpConfigForDisplay } from '@/lib/database'

export async function GET(request: NextRequest) {
  try {
    const config = await getSmtpConfigForDisplay()
    
    return NextResponse.json({
      success: true,
      config: config
    })
  } catch (error) {
    console.error('Erreur lors de la récupération de la configuration SMTP:', error)
    return NextResponse.json(
      {
        success: false,
        message: 'Erreur lors de la récupération de la configuration'
      },
      { status: 500 }
    )
  }
}
