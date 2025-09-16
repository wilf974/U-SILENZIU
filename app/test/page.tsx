'use client'

import { useState, useEffect } from 'react'
import { CheckCircle, XCircle, AlertCircle, RefreshCw, Play, Database, Mail, Calendar, Users, Settings, Globe, Shield, FileText, Image, Video } from 'lucide-react'

interface TestResult {
  name: string
  status: 'success' | 'error' | 'warning' | 'pending'
  message: string
  details?: string
  duration?: number
  timestamp: Date
}

interface TestCategory {
  name: string
  icon: React.ReactNode
  tests: TestResult[]
}

export default function TestPage() {
  const [testResults, setTestResults] = useState<TestCategory[]>([])
  const [isRunning, setIsRunning] = useState(false)
  const [lastRun, setLastRun] = useState<Date | null>(null)

  const runAllTests = async () => {
    setIsRunning(true)
    setLastRun(new Date())
    
    const results: TestCategory[] = []
    
    // Tests de base de données
    const dbTests = await runDatabaseTests()
    results.push({
      name: 'Base de données',
      icon: <Database className="w-5 h-5" />,
      tests: dbTests
    })

    // Tests des API
    const apiTests = await runApiTests()
    results.push({
      name: 'API Routes',
      icon: <Globe className="w-5 h-5" />,
      tests: apiTests
    })

    // Tests SMTP
    const smtpTests = await runSmtpTests()
    results.push({
      name: 'Configuration SMTP',
      icon: <Mail className="w-5 h-5" />,
      tests: smtpTests
    })

    // Tests CRON
    const cronTests = await runCronTests()
    results.push({
      name: 'Notifications CRON',
      icon: <Calendar className="w-5 h-5" />,
      tests: cronTests
    })

    // Tests des pages
    const pageTests = await runPageTests()
    results.push({
      name: 'Pages du site',
      icon: <FileText className="w-5 h-5" />,
      tests: pageTests
    })

    // Tests des médias
    const mediaTests = await runMediaTests()
    results.push({
      name: 'Médias',
      icon: <Image className="w-5 h-5" />,
      tests: mediaTests
    })

    // Tests de sécurité
    const securityTests = await runSecurityTests()
    results.push({
      name: 'Sécurité',
      icon: <Shield className="w-5 h-5" />,
      tests: securityTests
    })

    // Tests d'administration
    const adminTests = await runAdminTests()
    results.push({
      name: 'Interface Admin',
      icon: <Settings className="w-5 h-5" />,
      tests: adminTests
    })

    setTestResults(results)
    setIsRunning(false)
  }

  const runDatabaseTests = async (): Promise<TestResult[]> => {
    const tests: TestResult[] = []
    
    // Test de connexion à la base de données
    const startTime = Date.now()
    try {
      const response = await fetch('/api/reservations')
      const duration = Date.now() - startTime
      
      if (response.ok) {
        const data = await response.json()
        tests.push({
          name: 'Connexion PostgreSQL',
          status: 'success',
          message: `Base de données accessible (${data.length} réservations)`,
          details: `Temps de réponse: ${duration}ms`,
          duration,
          timestamp: new Date()
        })
      } else {
        tests.push({
          name: 'Connexion PostgreSQL',
          status: 'error',
          message: `Erreur ${response.status}: ${response.statusText}`,
          details: `Impossible d'accéder à la base de données`,
          duration,
          timestamp: new Date()
        })
      }
    } catch (error) {
      tests.push({
        name: 'Connexion PostgreSQL',
        status: 'error',
        message: 'Erreur de connexion',
        details: error instanceof Error ? error.message : 'Erreur inconnue',
        duration: Date.now() - startTime,
        timestamp: new Date()
      })
    }

    // Test des salles
    try {
      const response = await fetch('/api/admin/rooms')
      if (response.ok) {
        const data = await response.json()
        const activeRooms = data.filter((room: any) => room.isActive)
        tests.push({
          name: 'Données des salles',
          status: 'success',
          message: `${data.length} salles trouvées (${activeRooms.length} actives)`,
          details: `Salles actives: ${activeRooms.map((r: any) => r.name).join(', ')}`,
          timestamp: new Date()
        })
      } else {
        tests.push({
          name: 'Données des salles',
          status: 'error',
          message: `Erreur ${response.status}`,
          details: 'Impossible de récupérer les salles',
          timestamp: new Date()
        })
      }
    } catch (error) {
      tests.push({
        name: 'Données des salles',
        status: 'error',
        message: 'Erreur de récupération',
        details: error instanceof Error ? error.message : 'Erreur inconnue',
        timestamp: new Date()
      })
    }

    return tests
  }

  const runApiTests = async (): Promise<TestResult[]> => {
    const tests: TestResult[] = []
    const apis = [
      { name: 'Réservations', url: '/api/reservations', method: 'GET' },
      { name: 'Salles', url: '/api/admin/rooms', method: 'GET' },
      { name: 'Upload', url: '/api/admin/upload', method: 'POST' },
      { name: 'Notifications', url: '/api/notifications/send', method: 'POST' }
    ]

    for (const api of apis) {
      try {
        const response = await fetch(api.url, {
          method: api.method,
          headers: api.method === 'POST' ? { 'Content-Type': 'application/json' } : undefined,
          body: api.method === 'POST' ? JSON.stringify({ test: true }) : undefined
        })
        
        if (response.ok) {
          tests.push({
            name: `API ${api.name}`,
            status: 'success',
            message: `Status ${response.status} OK`,
            details: `Endpoint accessible (${api.method})`,
            timestamp: new Date()
          })
        } else {
          tests.push({
            name: `API ${api.name}`,
            status: response.status === 401 ? 'warning' : 'error',
            message: `Status ${response.status}`,
            details: response.status === 401 
              ? 'Authentification requise' 
              : response.status === 405 
                ? `Méthode ${api.method} non autorisée` 
                : 'Endpoint non accessible',
            timestamp: new Date()
          })
        }
      } catch (error) {
        tests.push({
          name: `API ${api.name}`,
          status: 'error',
          message: 'Erreur de connexion',
          details: error instanceof Error ? error.message : 'Erreur inconnue',
          timestamp: new Date()
        })
      }
    }

    return tests
  }

  const runSmtpTests = async (): Promise<TestResult[]> => {
    const tests: TestResult[] = []

    try {
      const response = await fetch('/api/admin/smtp/status')
      if (response.ok) {
        const data = await response.json()
        if (data.configured) {
          tests.push({
            name: 'Configuration SMTP',
            status: 'success',
            message: 'Configuration SMTP présente',
            details: `Hôte: ${data.host}, Port: ${data.port}`,
            timestamp: new Date()
          })
        } else {
          tests.push({
            name: 'Configuration SMTP',
            status: 'warning',
            message: 'Configuration SMTP manquante',
            details: 'Aucune configuration SMTP trouvée',
            timestamp: new Date()
          })
        }
      } else {
        tests.push({
          name: 'Configuration SMTP',
          status: 'error',
          message: 'Erreur de vérification',
          details: 'Impossible de vérifier la configuration SMTP',
          timestamp: new Date()
        })
      }
    } catch (error) {
      tests.push({
        name: 'Configuration SMTP',
        status: 'error',
        message: 'Erreur de connexion',
        details: error instanceof Error ? error.message : 'Erreur inconnue',
        timestamp: new Date()
      })
    }

    return tests
  }

  const runCronTests = async (): Promise<TestResult[]> => {
    const tests: TestResult[] = []

    try {
      const response = await fetch('/api/admin/cron/status')
      if (response.ok) {
        const data = await response.json()
        tests.push({
          name: 'Service CRON',
          status: data.active ? 'success' : 'warning',
          message: data.active ? 'Service CRON actif' : 'Service CRON inactif',
          details: data.active ? 'Notifications automatiques activées' : 'Notifications automatiques désactivées',
          timestamp: new Date()
        })
      } else {
        tests.push({
          name: 'Service CRON',
          status: 'error',
          message: 'Erreur de vérification',
          details: 'Impossible de vérifier le statut CRON',
          timestamp: new Date()
        })
      }
    } catch (error) {
      tests.push({
        name: 'Service CRON',
        status: 'error',
        message: 'Erreur de connexion',
        details: error instanceof Error ? error.message : 'Erreur inconnue',
        timestamp: new Date()
      })
    }

    return tests
  }

  const runPageTests = async (): Promise<TestResult[]> => {
    const tests: TestResult[] = []
    const pages = [
      { name: 'Accueil', url: '/' },
      { name: 'Salles', url: '/rooms' },
      { name: 'Concept', url: '/concept' },
      { name: 'Contact', url: '/contact' },
      { name: 'Réservation', url: '/reservation' },
      { name: 'Admin', url: '/admin' }
    ]

    for (const page of pages) {
      try {
        const response = await fetch(page.url)
        if (response.ok) {
          tests.push({
            name: `Page ${page.name}`,
            status: 'success',
            message: `Status ${response.status} OK`,
            details: `Page accessible`,
            timestamp: new Date()
          })
        } else {
          tests.push({
            name: `Page ${page.name}`,
            status: response.status === 401 ? 'warning' : 'error',
            message: `Status ${response.status}`,
            details: response.status === 401 ? 'Authentification requise' : 'Page non accessible',
            timestamp: new Date()
          })
        }
      } catch (error) {
        tests.push({
          name: `Page ${page.name}`,
          status: 'error',
          message: 'Erreur de connexion',
          details: error instanceof Error ? error.message : 'Erreur inconnue',
          timestamp: new Date()
        })
      }
    }

    return tests
  }

  const runMediaTests = async (): Promise<TestResult[]> => {
    const tests: TestResult[] = []

    // Test des images
    const images = [
      '/images/hero-poster.jpg',
      '/images/salle-douce.jpg',
      '/images/salle-carnage.jpg',
      '/images/salle-privatisee.jpg'
    ]

    for (const image of images) {
      try {
        const response = await fetch(image)
        if (response.ok) {
          tests.push({
            name: `Image ${image.split('/').pop()}`,
            status: 'success',
            message: 'Image accessible',
            details: `Taille: ${response.headers.get('content-length')} bytes`,
            timestamp: new Date()
          })
        } else {
          tests.push({
            name: `Image ${image.split('/').pop()}`,
            status: 'warning',
            message: 'Image manquante',
            details: 'Fichier non trouvé (normal si placeholder)',
            timestamp: new Date()
          })
        }
      } catch (error) {
        tests.push({
          name: `Image ${image.split('/').pop()}`,
          status: 'error',
          message: 'Erreur de chargement',
          details: error instanceof Error ? error.message : 'Erreur inconnue',
          timestamp: new Date()
        })
      }
    }

    // Test de la vidéo
    try {
      const response = await fetch('/video/hero-video.mp4')
      if (response.ok) {
        tests.push({
          name: 'Vidéo Hero',
          status: 'success',
          message: 'Vidéo accessible',
          details: `Taille: ${response.headers.get('content-length')} bytes`,
          timestamp: new Date()
        })
      } else {
        tests.push({
          name: 'Vidéo Hero',
          status: 'warning',
          message: 'Vidéo manquante',
          details: 'Fichier non trouvé (normal si placeholder)',
          timestamp: new Date()
        })
      }
    } catch (error) {
      tests.push({
        name: 'Vidéo Hero',
        status: 'error',
        message: 'Erreur de chargement',
        details: error instanceof Error ? error.message : 'Erreur inconnue',
        timestamp: new Date()
      })
    }

    return tests
  }

  const runSecurityTests = async (): Promise<TestResult[]> => {
    const tests: TestResult[] = []

    // Test des en-têtes de sécurité
    try {
      const response = await fetch('/')
      const headers = response.headers
      
      const securityHeaders = [
        { name: 'X-Frame-Options', header: 'x-frame-options' },
        { name: 'X-Content-Type-Options', header: 'x-content-type-options' },
        { name: 'Referrer-Policy', header: 'referrer-policy' }
      ]

      for (const { name, header } of securityHeaders) {
        const value = headers.get(header)
        if (value) {
          tests.push({
            name: `En-tête ${name}`,
            status: 'success',
            message: 'En-tête présent',
            details: `Valeur: ${value}`,
            timestamp: new Date()
          })
        } else {
          tests.push({
            name: `En-tête ${name}`,
            status: 'warning',
            message: 'En-tête manquant',
            details: 'En-tête de sécurité non configuré',
            timestamp: new Date()
          })
        }
      }
    } catch (error) {
      tests.push({
        name: 'En-têtes de sécurité',
        status: 'error',
        message: 'Erreur de vérification',
        details: error instanceof Error ? error.message : 'Erreur inconnue',
        timestamp: new Date()
      })
    }

    return tests
  }

  const runAdminTests = async (): Promise<TestResult[]> => {
    const tests: TestResult[] = []

    // Test de l'authentification admin
    try {
      const response = await fetch('/admin')
      if (response.status === 401) {
        tests.push({
          name: 'Authentification Admin',
          status: 'success',
          message: 'Authentification requise',
          details: 'Protection Basic Auth active - Interface sécurisée',
          timestamp: new Date()
        })
      } else if (response.status === 200) {
        tests.push({
          name: 'Authentification Admin',
          status: 'warning',
          message: 'Authentification non requise',
          details: 'L\'interface admin est accessible sans authentification - Vérifier la configuration du middleware',
          timestamp: new Date()
        })
      } else {
        tests.push({
          name: 'Authentification Admin',
          status: 'error',
          message: `Status inattendu: ${response.status}`,
          details: 'L\'interface admin retourne un status inattendu',
          timestamp: new Date()
        })
      }
    } catch (error) {
      tests.push({
        name: 'Authentification Admin',
        status: 'error',
        message: 'Erreur de vérification',
        details: error instanceof Error ? error.message : 'Erreur inconnue',
        timestamp: new Date()
      })
    }

    // Test de l'accessibilité de l'interface admin avec authentification
    try {
      const response = await fetch('/admin', {
        headers: {
          'Authorization': 'Basic ' + btoa('admin:admin123')
        }
      })
      if (response.status === 200) {
        tests.push({
          name: 'Accès Admin avec Auth',
          status: 'success',
          message: 'Interface admin accessible avec authentification',
          details: 'Les identifiants admin/admin123 fonctionnent correctement',
          timestamp: new Date()
        })
      } else {
        tests.push({
          name: 'Accès Admin avec Auth',
          status: 'warning',
          message: `Accès refusé avec authentification (${response.status})`,
          details: 'Vérifier les identifiants ou la configuration',
          timestamp: new Date()
        })
      }
    } catch (error) {
      tests.push({
        name: 'Accès Admin avec Auth',
        status: 'error',
        message: 'Erreur lors du test d\'authentification',
        details: error instanceof Error ? error.message : 'Erreur inconnue',
        timestamp: new Date()
      })
    }

    return tests
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'success':
        return <CheckCircle className="w-5 h-5 text-green-500" />
      case 'error':
        return <XCircle className="w-5 h-5 text-red-500" />
      case 'warning':
        return <AlertCircle className="w-5 h-5 text-yellow-500" />
      default:
        return <RefreshCw className="w-5 h-5 text-gray-500 animate-spin" />
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'success':
        return 'border-green-500 bg-green-50 dark:bg-green-900/20'
      case 'error':
        return 'border-red-500 bg-red-50 dark:bg-red-900/20'
      case 'warning':
        return 'border-yellow-500 bg-yellow-50 dark:bg-yellow-900/20'
      default:
        return 'border-gray-500 bg-gray-50 dark:bg-gray-900/20'
    }
  }

  const getSummary = () => {
    let total = 0
    let success = 0
    let error = 0
    let warning = 0

    testResults.forEach(category => {
      category.tests.forEach(test => {
        total++
        switch (test.status) {
          case 'success':
            success++
            break
          case 'error':
            error++
            break
          case 'warning':
            warning++
            break
        }
      })
    })

    return { total, success, error, warning }
  }

  const summary = getSummary()

  return (
    <div className="min-h-screen bg-dark-bg p-6">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-white mb-4">Tests du Site U Silenziu</h1>
          <p className="text-gray-300 mb-6">
            Page de test complète pour vérifier tous les éléments du site et afficher les détails des erreurs.
          </p>
          
          {/* Boutons d'action */}
          <div className="flex gap-4 mb-6">
            <button
              onClick={runAllTests}
              disabled={isRunning}
              className="btn-kaki flex items-center gap-2"
            >
              {isRunning ? (
                <>
                  <RefreshCw className="w-4 h-4 animate-spin" />
                  Tests en cours...
                </>
              ) : (
                <>
                  <Play className="w-4 h-4" />
                  Lancer tous les tests
                </>
              )}
            </button>
            
            {lastRun && (
              <div className="text-gray-400 text-sm">
                Dernière exécution: {lastRun.toLocaleString('fr-FR')}
              </div>
            )}
          </div>

          {/* Résumé */}
          {testResults.length > 0 && (
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
              <div className="bg-gray-800 rounded-lg p-4 border border-gray-700">
                <div className="flex items-center gap-2">
                  <Users className="w-5 h-5 text-blue-500" />
                  <span className="text-white font-semibold">Total</span>
                </div>
                <div className="text-2xl font-bold text-white mt-2">{summary.total}</div>
              </div>
              
              <div className="bg-green-900/20 rounded-lg p-4 border border-green-500">
                <div className="flex items-center gap-2">
                  <CheckCircle className="w-5 h-5 text-green-500" />
                  <span className="text-white font-semibold">Succès</span>
                </div>
                <div className="text-2xl font-bold text-green-400 mt-2">{summary.success}</div>
              </div>
              
              <div className="bg-yellow-900/20 rounded-lg p-4 border border-yellow-500">
                <div className="flex items-center gap-2">
                  <AlertCircle className="w-5 h-5 text-yellow-500" />
                  <span className="text-white font-semibold">Avertissements</span>
                </div>
                <div className="text-2xl font-bold text-yellow-400 mt-2">{summary.warning}</div>
              </div>
              
              <div className="bg-red-900/20 rounded-lg p-4 border border-red-500">
                <div className="flex items-center gap-2">
                  <XCircle className="w-5 h-5 text-red-500" />
                  <span className="text-white font-semibold">Erreurs</span>
                </div>
                <div className="text-2xl font-bold text-red-400 mt-2">{summary.error}</div>
              </div>
            </div>
          )}
        </div>

        {/* Résultats des tests */}
        {testResults.length > 0 && (
          <div className="space-y-6">
            {testResults.map((category, categoryIndex) => (
              <div key={categoryIndex} className="bg-gray-900 rounded-lg border border-gray-700">
                <div className="p-4 border-b border-gray-700">
                  <div className="flex items-center gap-3">
                    {category.icon}
                    <h2 className="text-xl font-semibold text-white">{category.name}</h2>
                    <span className="text-gray-400 text-sm">
                      {category.tests.filter(t => t.status === 'success').length}/{category.tests.length} succès
                    </span>
                  </div>
                </div>
                
                <div className="p-4">
                  <div className="space-y-3">
                    {category.tests.map((test, testIndex) => (
                      <div
                        key={testIndex}
                        className={`p-4 rounded-lg border ${getStatusColor(test.status)}`}
                      >
                        <div className="flex items-start gap-3">
                          {getStatusIcon(test.status)}
                          <div className="flex-1">
                            <div className="flex items-center gap-2 mb-1">
                              <h3 className="font-semibold text-white">{test.name}</h3>
                              {test.duration && (
                                <span className="text-xs text-gray-400">
                                  ({test.duration}ms)
                                </span>
                              )}
                            </div>
                            <p className="text-gray-300 mb-1">{test.message}</p>
                            {test.details && (
                              <p className="text-sm text-gray-400">{test.details}</p>
                            )}
                            <div className="text-xs text-gray-500 mt-2">
                              {test.timestamp.toLocaleString('fr-FR')}
                            </div>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* État vide */}
        {testResults.length === 0 && !isRunning && (
          <div className="text-center py-12">
            <div className="text-gray-400 mb-4">
              <Settings className="w-16 h-16 mx-auto mb-4" />
              <h3 className="text-xl font-semibold text-white mb-2">Aucun test exécuté</h3>
              <p className="text-gray-400">
                Cliquez sur "Lancer tous les tests" pour commencer la vérification du site.
              </p>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
