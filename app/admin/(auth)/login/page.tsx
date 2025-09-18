'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { Lock, Eye, EyeOff, Shield, Crown } from 'lucide-react'
import { useAuth } from '@/hooks/useAuth'

export default function AdminLogin() {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const router = useRouter()
  const { login } = useAuth()

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')
    const result = await login({ username, password })
    if (result.success) {
      router.push('/admin')
    } else {
      setError(result.error || 'Identifiants incorrects')
      setLoading(false)
    }
  }

  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-900">
      <div className="w-full max-w-md p-8 space-y-8 bg-gray-800 rounded-lg shadow-lg border border-gray-700">
        <div className="text-center">
          <div className="flex justify-center mb-4">
            <div className="p-3 bg-kaki-600 rounded-full">
              <Lock className="w-8 h-8 text-white" />
            </div>
          </div>
          <h1 className="text-3xl font-bold text-white">Administration</h1>
          <p className="text-gray-400">Connexion au back-office</p>
        </div>

        <form onSubmit={handleLogin} className="space-y-6">
          <div className="relative">
            <input
              type="text"
              placeholder="Nom d'utilisateur"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              required
              className="w-full px-4 py-3 text-lg text-white bg-gray-700 border border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-kaki-500"
            />
          </div>

          <div className="relative">
            <input
              type={showPassword ? 'text' : 'password'}
              placeholder="Mot de passe"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              className="w-full px-4 py-3 text-lg text-white bg-gray-700 border border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-kaki-500"
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              className="absolute inset-y-0 right-0 px-4 text-gray-400 hover:text-white"
            >
              {showPassword ? <EyeOff /> : <Eye />}
            </button>
          </div>

          {error && (
            <div className="p-3 text-center text-white bg-red-500 rounded-lg">
              {error}
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full px-4 py-3 text-lg font-semibold text-white bg-kaki-600 rounded-lg hover:bg-kaki-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-kaki-500 disabled:opacity-50"
          >
            {loading ? 'Connexion en cours...' : 'Se connecter'}
          </button>
        </form>

        <div className="text-center text-gray-500 text-sm">
          <p>
            Accès réservé aux utilisateurs autorisés.
          </p>
          <div className="flex items-center justify-center space-x-4 mt-2">
            <div className="flex items-center space-x-1">
              <Shield size={14} />
              <span>Admin</span>
            </div>
            <div className="flex items-center space-x-1">
              <Crown size={14} />
              <span>Super Admin</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
