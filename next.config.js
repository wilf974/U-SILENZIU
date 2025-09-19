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
    ]
  },
}

module.exports = nextConfig
