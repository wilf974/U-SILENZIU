'use client'

import { useState } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { Menu, X, Phone, Mail, Clock } from 'lucide-react'
import { useContactInfo } from '@/hooks/useContactInfo'
import { useHeaderConfig } from '@/hooks/useHeaderConfig'

interface NavigationItem {
  name: string
  href: string
  onClick?: () => void
}

const Header = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false)
  const router = useRouter()
  const { contactInfo, loading, getFormattedOpeningHours } = useContactInfo()
  const { config: headerConfig, loading: headerLoading } = useHeaderConfig()

  const toggleMenu = () => {
    setIsMenuOpen(!isMenuOpen)
  }

  /**
   * Fonction pour naviguer vers une section de la page d'accueil
   * @param sectionId - ID de la section à atteindre
   */
  const handleSectionClick = (sectionId: string) => {
    setIsMenuOpen(false)
    // Naviguer vers la page d'accueil puis scroll vers la section
    router.push('/')
    setTimeout(() => {
      const section = document.getElementById(sectionId)
      if (section) {
        section.scrollIntoView({ behavior: 'smooth' })
      }
    }, 100)
  }

  const navigation: NavigationItem[] = [
    { name: 'Accueil', href: '/' },
    { name: 'Le concept', href: '#', onClick: () => handleSectionClick('concept') },
    { name: 'Contact', href: '#', onClick: () => handleSectionClick('contact') },
  ]

  return (
    <>
      {/* Top bar */}
      <div className="bg-kaki-600 text-white py-2">
        <div className="section-container">
          <div className="flex flex-col md:flex-row justify-between items-center text-xs">
            {/* Première ligne : Contact */}
            <div className="flex items-center space-x-6 mb-2 md:mb-0">
              {loading ? (
                <div className="flex items-center space-x-6">
                  <div className="flex items-center space-x-1">
                    <Phone size={12} />
                    <span className="animate-pulse">Chargement...</span>
                  </div>
                  <div className="flex items-center space-x-1">
                    <Mail size={12} />
                    <span className="animate-pulse text-xs">Chargement...</span>
                  </div>
                </div>
              ) : (
                <>
                  <a 
                    href={`tel:${contactInfo?.phone?.replace(/\s/g, '') || '+33783836453'}`} 
                    className="flex items-center space-x-1 hover:text-kaki-300 transition-colors"
                  >
                    <Phone size={12} />
                    <span>{contactInfo?.phone || '+33 7 83 83 64 53'}</span>
                  </a>
                  <a 
                    href={`mailto:${contactInfo?.email || 'info@usilenziu.com'}`} 
                    className="flex items-center space-x-1 hover:text-kaki-300 transition-colors"
                  >
                    <Mail size={12} />
                    <span className="text-xs">{contactInfo?.email || 'info@usilenziu.com'}</span>
                  </a>
                </>
              )}
            </div>
            
            {/* Deuxième ligne : Horaires */}
            <div className="flex justify-center items-center">
              <div className="flex items-center space-x-1 text-center">
                <Clock size={10} />
                <span className="text-xs">
                  {loading ? (
                    <span className="animate-pulse">Chargement des horaires...</span>
                  ) : (
                    getFormattedOpeningHours()
                  )}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Main header */}
      <header className="bg-dark-surface border-b border-kaki-800/30 sticky top-0 z-50">
        <div className="section-container">
          <div className="flex justify-between items-center h-16">
            {/* Logo */}
            <div className="flex items-center">
              <Link href="/" className="flex items-center space-x-3">
                <div className="w-10 h-10 bg-gradient-to-br from-kaki-500 to-kaki-700 rounded-lg flex items-center justify-center">
                  {headerLoading ? (
                    <div className="animate-pulse bg-kaki-400/30 w-6 h-6 rounded"></div>
                  ) : headerConfig?.logo_type === 'uploaded' ? (
                    <img
                      src="/api/header-config/logo"
                      alt={headerConfig.logo_alt_text || 'Logo'}
                      className="w-8 h-8 object-contain"
                      onError={(e) => {
                        // Fallback vers le texte si l'image ne charge pas
                        const target = e.target as HTMLImageElement;
                        target.style.display = 'none';
                        const fallback = document.createElement('span');
                        fallback.className = 'text-white font-bold text-xl';
                        fallback.textContent = headerConfig?.logo_text || 'U';
                        target.parentNode?.appendChild(fallback);
                      }}
                    />
                  ) : headerConfig?.logo_type === 'image' && headerConfig?.logo_image_url ? (
                    <img
                      src={headerConfig.logo_image_url}
                      alt={headerConfig.logo_alt_text || 'Logo'}
                      className="w-8 h-8 object-contain"
                      onError={(e) => {
                        // Fallback vers le texte si l'image ne charge pas
                        const target = e.target as HTMLImageElement;
                        target.style.display = 'none';
                        const fallback = document.createElement('span');
                        fallback.className = 'text-white font-bold text-xl';
                        fallback.textContent = headerConfig?.logo_text || 'U';
                        target.parentNode?.appendChild(fallback);
                      }}
                    />
                  ) : (
                    <span className="text-white font-bold text-xl">
                      {headerConfig?.logo_text || 'U'}
                    </span>
                  )}
                </div>
                <span className="text-2xl font-bold text-gradient-kaki">
                  {headerLoading ? (
                    <span className="animate-pulse bg-kaki-400/30 h-8 w-32 rounded"></span>
                  ) : (
                    headerConfig?.site_name || 'U SILENZIU'
                  )}
                </span>
              </Link>
            </div>

            {/* Desktop navigation */}
            <nav className="hidden md:flex items-center space-x-8">
              {navigation.map((item) => (
                item.onClick ? (
                  <button
                    key={item.name}
                    onClick={item.onClick}
                    className="text-white hover:text-kaki-400 transition-colors duration-200 font-medium bg-transparent border-none cursor-pointer"
                  >
                    {item.name}
                  </button>
                ) : (
                  <Link
                    key={item.name}
                    href={item.href}
                    className="text-white hover:text-kaki-400 transition-colors duration-200 font-medium"
                  >
                    {item.name}
                  </Link>
                )
              ))}
              <button
                onClick={() => handleSectionClick('salles')}
                className="text-white hover:text-kaki-400 transition-colors duration-200 font-medium bg-transparent border-none cursor-pointer"
              >
                Nos salles
              </button>
              <Link 
                href="/reservation"
                className="btn-kaki"
              >
                Réservation
              </Link>
            </nav>

            {/* Mobile menu button */}
            <div className="md:hidden">
              <button
                onClick={toggleMenu}
                className="text-white hover:text-kaki-400 transition-colors"
              >
                {isMenuOpen ? <X size={24} /> : <Menu size={24} />}
              </button>
            </div>
          </div>
        </div>

        {/* Mobile navigation */}
        {isMenuOpen && (
          <div className="md:hidden bg-dark-surface border-t border-kaki-800/30">
            <div className="px-4 py-6">
              <div className="space-y-4 mb-6">
                {navigation.map((item) => (
                  item.onClick ? (
                    <button
                      key={item.name}
                      onClick={item.onClick}
                      className="block text-white hover:text-kaki-400 transition-colors duration-200 font-medium py-2 w-full text-left bg-transparent border-none cursor-pointer"
                    >
                      {item.name}
                    </button>
                  ) : (
                    <Link
                      key={item.name}
                      href={item.href}
                      className="block text-white hover:text-kaki-400 transition-colors duration-200 font-medium py-2"
                      onClick={() => setIsMenuOpen(false)}
                    >
                      {item.name}
                    </Link>
                  )
                ))}
                <button
                  onClick={() => handleSectionClick('salles')}
                  className="block text-white hover:text-kaki-400 transition-colors duration-200 font-medium py-2 w-full text-left bg-transparent border-none cursor-pointer"
                >
                  Nos salles
                </button>
              </div>
              <div className="pt-4 border-t border-kaki-800/30">
                <Link 
                  href="/reservation"
                  className="btn-kaki w-full text-center block"
                  onClick={() => setIsMenuOpen(false)}
                >
                  Réservation
                </Link>
              </div>
            </div>
          </div>
        )}
      </header>
    </>
  )
}

export default Header
