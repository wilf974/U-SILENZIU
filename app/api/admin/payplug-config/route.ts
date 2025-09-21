import { NextRequest, NextResponse } from 'next/server'
import { getClient } from '@/lib/database'
import { writeFileSync, readFileSync, existsSync } from 'fs'
import { join } from 'path'

/**
 * API pour gérer la configuration Payplug
 * GET /api/admin/payplug-config - Récupérer la configuration
 * POST /api/admin/payplug-config - Sauvegarder la configuration
 */

interface PayplugConfig {
  secretKey: string
  publicKey: string
  webhookSecret: string
  mode: 'test' | 'live'
}

/**
 * Récupère la configuration Payplug actuelle
 */
export async function GET() {
  try {
    const envPath = join(process.cwd(), 'env.prod')
    
    if (!existsSync(envPath)) {
      return NextResponse.json({ 
        success: false, 
        error: 'Fichier de configuration non trouvé' 
      }, { status: 404 })
    }

    const envContent = readFileSync(envPath, 'utf-8')
    const lines = envContent.split('\n')
    
    const config: Partial<PayplugConfig> = {}
    
    lines.forEach(line => {
      if (line.startsWith('PAYPLUG_')) {
        const [key, value] = line.split('=')
        if (key && value) {
          switch (key) {
            case 'PAYPLUG_SECRET_KEY':
              config.secretKey = value
              break
            case 'PAYPLUG_PUBLIC_KEY':
              config.publicKey = value
              break
            case 'PAYPLUG_WEBHOOK_SECRET':
              config.webhookSecret = value
              break
            case 'PAYPLUG_MODE':
              config.mode = value as 'test' | 'live'
              break
          }
        }
      }
    })

    return NextResponse.json({ 
      success: true, 
      config: {
        secretKey: config.secretKey || '',
        publicKey: config.publicKey || '',
        webhookSecret: config.webhookSecret || '',
        mode: config.mode || 'test'
      }
    })
  } catch (error: any) {
    console.error('Erreur lors de la récupération de la config Payplug:', error)
    return NextResponse.json({ 
      success: false, 
      error: error.message || 'Erreur lors de la récupération de la configuration' 
    }, { status: 500 })
  }
}

/**
 * Sauvegarde la configuration Payplug
 */
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { secretKey, publicKey, webhookSecret, mode }: PayplugConfig = body

    // Validation des données
    if (!secretKey) {
      return NextResponse.json({ 
        success: false, 
        error: 'Clé secrète requise' 
      }, { status: 400 })
    }

    if (!mode || !['test', 'live'].includes(mode)) {
      return NextResponse.json({ 
        success: false, 
        error: 'Mode invalide (test ou live requis)' 
      }, { status: 400 })
    }

    const envPath = join(process.cwd(), 'env.prod')
    
    // Lire le fichier existant
    let envContent = ''
    if (existsSync(envPath)) {
      envContent = readFileSync(envPath, 'utf-8')
    }

    // Supprimer les anciennes variables Payplug
    const lines = envContent.split('\n')
    const filteredLines = lines.filter(line => !line.startsWith('PAYPLUG_'))

    // Ajouter les nouvelles variables
    const newPayplugConfig = [
      '',
      '# Configuration Payplug',
      `PAYPLUG_SECRET_KEY=${secretKey}`,
      `PAYPLUG_PUBLIC_KEY=${publicKey || ''}`,
      `PAYPLUG_WEBHOOK_SECRET=${webhookSecret || ''}`,
      `PAYPLUG_MODE=${mode}`
    ]

    const updatedContent = [...filteredLines, ...newPayplugConfig].join('\n')

    // Sauvegarder le fichier
    writeFileSync(envPath, updatedContent, 'utf-8')

    // Redémarrer l'application Docker
    const { exec } = require('child_process')
    exec('docker restart u-silenziu-app', (error: any, stdout: any, stderr: any) => {
      if (error) {
        console.error('Erreur lors du redémarrage:', error)
      } else {
        console.log('Application redémarrée avec succès')
      }
    })

    return NextResponse.json({ 
      success: true, 
      message: 'Configuration Payplug sauvegardée et application redémarrée' 
    })
  } catch (error: any) {
    console.error('Erreur lors de la sauvegarde de la config Payplug:', error)
    return NextResponse.json({ 
      success: false, 
      error: error.message || 'Erreur lors de la sauvegarde de la configuration' 
    }, { status: 500 })
  }
}
