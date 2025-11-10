/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  images: {
    domains: ['localhost', 'rageroom.usilenziu.com', 'usilenziu.com'],
    unoptimized: true
  },
  // Configuration pour HTTPS en production
  experimental: {
    serverComponentsExternalPackages: []
  },
  // Headers de sécurité pour la production
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block',
          },
        ],
      },
      // Augmenter les limites pour les uploads d'images
      {
        source: '/api/admin/upload',
        headers: [
          {
            key: 'Content-Length-Max',
            value: '10485760', // 10MB
          },
        ],
      },
    ]
  },
  // Augmenter les limites de taille des requêtes
  api: {
    bodyParser: {
      sizeLimit: '10mb',
    },
  },
}

module.exports = nextConfig
