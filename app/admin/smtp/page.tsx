'use client'

import { useState, useEffect } from 'react'
import { Save, TestTube, Mail, Server, Lock, Shield, AlertCircle } from 'lucide-react'

interface SmtpConfig {
  host: string
  port: number
  secure: boolean
  username: string
  password: string
  tlsRejectUnauthorized: boolean
  tlsMinVersion: string
}

interface TestEmail {
  to: string
}

export default function SmtpConfigPage() {
  const [config, setConfig] = useState<SmtpConfig>({
    host: 'smtp-mail.outlook.com', // Serveur correct selon Microsoft
    port: 587,
    secure: false,
    username: '',
    password: '',
    tlsRejectUnauthorized: true,
    tlsMinVersion: 'TLSv1.2'
  })
  
  const [isLoading, setIsLoading] = useState(false)
  const [testResult, setTestResult] = useState<{ success: boolean; message: string } | null>(null)
  const [saveResult, setSaveResult] = useState<{ success: boolean; message: string } | null>(null)
  const [connectionStatus, setConnectionStatus] = useState<'unknown' | 'connected' | 'error'>('unknown')
  const [testEmail, setTestEmail] = useState<TestEmail>({ to: '' })
  const [emailTestResult, setEmailTestResult] = useState<{ success: boolean; message: string } | null>(null)

  // Charger la configuration existante
  useEffect(() => {
    loadConfig()
  }, [])

  const loadConfig = async () => {
    try {
      const response = await fetch('/api/admin/smtp/config/edit')
      if (response.ok) {
        const data = await response.json()
        if (data.config) {
          setConfig({
            ...data.config,
            password: data.config.password || '' // Garder le mot de passe déchiffré
          })
        }
      }
    } catch (error) {
      console.error('Erreur lors du chargement de la configuration:', error)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    setSaveResult(null)

    try {
      // Créer un objet avec toutes les valeurs, y compris les booléens
      const configToSend = {
        host: config.host,
        port: config.port,
        secure: Boolean(config.secure), // Conversion explicite en booléen
        username: config.username,
        password: config.password,
        tlsRejectUnauthorized: Boolean(config.tlsRejectUnauthorized), // Conversion explicite en booléen
        tlsMinVersion: config.tlsMinVersion
      }

      console.log('Envoi de la configuration:', configToSend) // Debug

      const response = await fetch('/api/admin/smtp/save', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(configToSend),
      })

      const result = await response.json()
      setSaveResult(result)
      
      if (result.success) {
        // Recharger la configuration pour vérifier le statut de connexion
        setTimeout(() => {
          checkConnectionStatus()
        }, 1000)
      }
    } catch (error) {
      setSaveResult({
        success: false,
        message: 'Erreur lors de la sauvegarde'
      })
    } finally {
      setIsLoading(false)
    }
  }

  const handleTestConnection = async () => {
    setIsLoading(true)
    setTestResult(null)

    try {
      // Créer un objet avec toutes les valeurs, y compris les booléens
      const configToSend = {
        host: config.host,
        port: config.port,
        secure: Boolean(config.secure), // Conversion explicite en booléen
        username: config.username,
        password: config.password,
        tlsRejectUnauthorized: Boolean(config.tlsRejectUnauthorized), // Conversion explicite en booléen
        tlsMinVersion: config.tlsMinVersion
      }

      console.log('Test de connexion avec:', configToSend) // Debug

      const response = await fetch('/api/admin/smtp/test', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(configToSend),
      })

      const result = await response.json()
      setTestResult(result)
      
      if (result.success) {
        setConnectionStatus('connected')
      } else {
        setConnectionStatus('error')
      }
    } catch (error) {
      setTestResult({
        success: false,
        message: 'Erreur lors du test de connexion'
      })
      setConnectionStatus('error')
    } finally {
      setIsLoading(false)
    }
  }

  const handleSendTestEmail = async () => {
    if (!testEmail.to) {
      setEmailTestResult({
        success: false,
        message: 'Veuillez saisir une adresse email de test'
      })
      return
    }

    setIsLoading(true)
    setEmailTestResult(null)

    try {
      console.log('Envoi d\'email de test à:', testEmail.to)
      
      const response = await fetch('/api/notifications/send', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          testEmail: testEmail.to,
          message: `Ceci est un email de test pour vérifier la configuration SMTP d'U Silenziu. Envoyé le ${new Date().toLocaleString('fr-FR')}`
        }),
      })

      const result = await response.json()
      console.log('Résultat de l\'envoi:', result)
      
      if (result.success) {
        setEmailTestResult({
          success: true,
          message: `Email de test envoyé avec succès ! Message ID: ${result.messageId}. Vérifiez votre boîte de réception et vos spams.`
        })
      } else {
        setEmailTestResult(result)
      }
    } catch (error) {
      console.error('Erreur lors de l\'envoi:', error)
      setEmailTestResult({
        success: false,
        message: 'Erreur lors de l\'envoi de l\'email de test'
      })
    } finally {
      setIsLoading(false)
    }
  }

  const checkConnectionStatus = async () => {
    try {
      const response = await fetch('/api/admin/smtp/status')
      if (response.ok) {
        const result = await response.json()
        setConnectionStatus(result.success ? 'connected' : 'error')
      }
    } catch (error) {
      setConnectionStatus('error')
    }
  }

  // Vérifier le statut de connexion au chargement
  useEffect(() => {
    checkConnectionStatus()
  }, [])

  return (
    <div className="min-h-screen bg-gray-900 text-white p-6">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <div className="flex justify-between items-start mb-4">
            <div>
              <h1 className="text-3xl font-bold text-kaki-400 mb-2">Configuration SMTP</h1>
              <p className="text-gray-400">
                Configurez les paramètres SMTP pour l'envoi automatique d'emails de rappel
              </p>
            </div>
            <a
              href="/admin"
              className="inline-flex items-center px-4 py-2 border border-gray-600 rounded-md shadow-sm text-sm font-medium text-gray-300 bg-gray-700 hover:bg-gray-600 transition-colors"
            >
              ← Retour au dashboard
            </a>
          </div>
        </div>

        {/* Statut de connexion */}
        <div className="mb-6">
          <div className={`inline-flex items-center px-4 py-2 rounded-lg ${
            connectionStatus === 'connected' 
              ? 'bg-green-900/20 border border-green-500 text-green-400'
              : connectionStatus === 'error'
              ? 'bg-red-900/20 border border-red-500 text-red-400'
              : 'bg-yellow-900/20 border border-yellow-500 text-yellow-400'
          }`}>
            <Server className="w-4 h-4 mr-2" />
            <span>
              {connectionStatus === 'connected' && 'SMTP connecté'}
              {connectionStatus === 'error' && 'Erreur de connexion SMTP'}
              {connectionStatus === 'unknown' && 'Statut de connexion inconnu'}
            </span>
          </div>
        </div>

        {/* Formulaire de configuration */}
        <div className="bg-gray-800 rounded-lg p-6 mb-6">
          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Hôte et Port */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  Hôte SMTP
                </label>
                <input
                  type="text"
                  value={config.host}
                  onChange={(e) => setConfig({ ...config, host: e.target.value })}
                  placeholder="ex: smtp.office365.com"
                  className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-kaki-500"
                  required
                />
              </div>
                           <div>
               <label className="block text-sm font-medium text-gray-300 mb-2">
                 Port
               </label>
               <select
                 value={config.port}
                 onChange={(e) => {
                   const port = parseInt(e.target.value);
                   const secure = port === 465; // Port 465 = SSL, autres = STARTTLS
                   setConfig({ ...config, port, secure });
                 }}
                 className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-kaki-500"
               >
                 <option value={25}>25 (Non sécurisé)</option>
                 <option value={465}>465 (SSL)</option>
                 <option value={587}>587 (STARTTLS)</option>
               </select>
             </div>
            </div>

            {/* Sécurité */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                           <div>
               <label className="flex items-center">
                 <input
                   type="checkbox"
                   checked={config.secure}
                   onChange={(e) => setConfig({ ...config, secure: e.target.checked })}
                   className="mr-2"
                   disabled={config.port === 465} // Désactiver pour le port 465 (toujours SSL)
                 />
                                   <span className={`text-sm font-medium ${config.port === 465 ? 'text-gray-500' : 'text-gray-300'}`}>
                    Connexion sécurisée (SSL/TLS) {config.port === 465 && '(Automatique pour port 465)'}
                    {config.port === 587 && ' - Décochez pour Office 365'}
                  </span>
               </label>
             </div>
                           <div>
               <label className="flex items-center">
                 <input
                   type="checkbox"
                   checked={config.tlsRejectUnauthorized}
                   onChange={(e) => setConfig({ ...config, tlsRejectUnauthorized: e.target.checked })}
                   className="mr-2"
                 />
                 <span className="text-sm font-medium text-gray-300">
                   Rejeter les certificats non autorisés
                 </span>
               </label>
               <p className="text-xs text-gray-500 mt-1">
                 Décochez cette option si vous rencontrez des erreurs SSL/TLS
               </p>
             </div>
            </div>

            {/* Version TLS */}
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-2">
                Version TLS minimale
              </label>
              <select
                value={config.tlsMinVersion}
                onChange={(e) => setConfig({ ...config, tlsMinVersion: e.target.value })}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-kaki-500"
              >
                <option value="TLSv1.0">TLSv1.0</option>
                <option value="TLSv1.1">TLSv1.1</option>
                <option value="TLSv1.2">TLSv1.2</option>
                <option value="TLSv1.3">TLSv1.3</option>
              </select>
            </div>

            {/* Identifiants */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  Nom d'utilisateur
                </label>
                <input
                  type="text"
                  value={config.username}
                  onChange={(e) => setConfig({ ...config, username: e.target.value })}
                  placeholder="votre@email.com"
                  className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-kaki-500"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-300 mb-2">
                  Mot de passe
                </label>
                <input
                  type="password"
                  value={config.password}
                  onChange={(e) => setConfig({ ...config, password: e.target.value })}
                  placeholder="••••••••"
                  className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-kaki-500"
                  required
                />
              </div>
            </div>

            {/* Boutons d'action */}
            <div className="flex flex-col sm:flex-row gap-4 pt-4">
              <button
                type="submit"
                disabled={isLoading}
                className="flex items-center justify-center px-6 py-3 bg-kaki-600 hover:bg-kaki-700 disabled:bg-gray-600 rounded-lg font-medium transition-colors"
              >
                <Save className="w-4 h-4 mr-2" />
                {isLoading ? 'Sauvegarde...' : 'Sauvegarder la configuration'}
              </button>
              
              <button
                type="button"
                onClick={handleTestConnection}
                disabled={isLoading}
                className="flex items-center justify-center px-6 py-3 bg-blue-600 hover:bg-blue-700 disabled:bg-gray-600 rounded-lg font-medium transition-colors"
              >
                <TestTube className="w-4 h-4 mr-2" />
                {isLoading ? 'Test en cours...' : 'Tester la connexion'}
              </button>
            </div>

            {/* Email de test */}
            <div className="border-t border-gray-700 pt-6 mt-6">
              <h3 className="text-lg font-medium text-gray-200 mb-4">Email de test</h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 items-end">
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-2">
                    Adresse email de test
                  </label>
                  <input
                    type="email"
                    value={testEmail.to}
                    onChange={(e) => setTestEmail({ ...testEmail, to: e.target.value })}
                    placeholder="test@example.com"
                    className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md focus:outline-none focus:ring-2 focus:ring-kaki-500"
                  />
                </div>
                <div className="md:col-span-2">
                  <button
                    type="button"
                    onClick={handleSendTestEmail}
                    disabled={isLoading || !testEmail.to}
                    className="flex items-center justify-center px-6 py-2 bg-purple-600 hover:bg-purple-700 disabled:bg-gray-600 rounded-lg font-medium transition-colors w-full"
                  >
                    <Mail className="w-4 h-4 mr-2" />
                    {isLoading ? 'Envoi...' : 'Envoyer un email de test'}
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>

        {/* Messages de résultat */}
        {saveResult && (
          <div className={`mb-4 p-4 rounded-lg ${
            saveResult.success 
              ? 'bg-green-900/20 border border-green-500 text-green-400'
              : 'bg-red-900/20 border border-red-500 text-red-400'
          }`}>
            {saveResult.message}
          </div>
        )}

        {testResult && (
          <div className={`mb-4 p-4 rounded-lg ${
            testResult.success 
              ? 'bg-green-900/20 border border-green-500 text-green-400'
              : 'bg-red-900/20 border border-red-500 text-red-400'
          }`}>
            {testResult.message}
          </div>
        )}

        {emailTestResult && (
          <div className={`mb-4 p-4 rounded-lg ${
            emailTestResult.success 
              ? 'bg-green-900/20 border border-green-500 text-green-400'
              : 'bg-red-900/20 border border-red-500 text-red-400'
          }`}>
            {emailTestResult.message}
          </div>
        )}

        {/* Informations et exemples */}
        <div className="bg-gray-800 rounded-lg p-6">
          <h3 className="text-lg font-semibold text-kaki-400 mb-4">Configuration recommandée</h3>
          
                     <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
             <div>
               <h4 className="font-medium text-gray-300 mb-2">Office 365 / Outlook</h4>
                               <div className="text-sm text-gray-400 space-y-1">
                  <p>Hôte: <strong>smtp-mail.outlook.com</strong></p>
                  <p>Port: 587</p>
                  <p>Sécurisé: <strong>Non</strong> (STARTTLS automatique)</p>
                  <p>TLS: Rejeter certificats non autorisés</p>
                  <p className="text-yellow-400">⚠️ Décochez "Connexion sécurisée"</p>
                  <p className="text-blue-400">ℹ️ Utilisez votre mot de passe principal ou un mot de passe d'application</p>
                </div>
             </div>
             
             <div>
               <h4 className="font-medium text-gray-300 mb-2">Gmail</h4>
               <div className="text-sm text-gray-400 space-y-1">
                 <p>Hôte: smtp.gmail.com</p>
                 <p>Port: 587</p>
                 <p>Sécurisé: Non (STARTTLS automatique)</p>
                 <p>TLS: Rejeter certificats non autorisés</p>
                 <p>⚠️ Utilisez un mot de passe d'application</p>
               </div>
             </div>
           </div>

                     <div className="mt-6 p-4 bg-yellow-900/20 border border-yellow-500 rounded-lg">
             <div className="flex items-start">
               <Shield className="w-5 h-5 text-yellow-400 mr-2 mt-0.5" />
               <div>
                 <h4 className="font-medium text-yellow-400 mb-1">Sécurité</h4>
                 <p className="text-sm text-yellow-300">
                   Les mots de passe sont chiffrés en base de données. Pour une sécurité optimale, 
                   utilisez un mot de passe d'application plutôt que votre mot de passe principal.
                 </p>
               </div>
             </div>
           </div>

           {/* Section de dépannage */}
           <div className="mt-4 p-4 bg-red-900/20 border border-red-500 rounded-lg">
             <div className="flex items-start">
               <AlertCircle className="w-5 h-5 text-red-400 mr-2 mt-0.5" />
               <div>
                 <h4 className="font-medium text-red-400 mb-1">Dépannage SSL/TLS</h4>
                 <p className="text-sm text-red-300 mb-2">
                   Si vous rencontrez l'erreur "wrong version number" ou des problèmes SSL :
                 </p>
                                   <ul className="text-sm text-red-300 space-y-1">
                    <li>• <strong>Office 365</strong> : Décochez "Connexion sécurisée" et "Rejeter les certificats non autorisés"</li>
                    <li>• <strong>Gmail</strong> : Décochez "Connexion sécurisée", gardez "Rejeter les certificats non autorisés"</li>
                    <li>• Vérifiez que le port correspond à la sécurité (465 = SSL, 587 = STARTTLS)</li>
                    <li>• Assurez-vous que votre antivirus ne bloque pas les ports SMTP</li>
                    <li>• Vérifiez que votre fournisseur d'accès n'a pas bloqué les ports 25, 465, 587</li>
                  </ul>
               </div>
             </div>
           </div>
        </div>
      </div>
    </div>
  )
}
