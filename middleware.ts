import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'
import { ADMIN_TOKEN_COOKIE } from '@/lib/auth'

// Middleware d'authentification simple pour les pages admin
export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl
  
  // Routes publiques admin (pas besoin de token)
  const publicAdminPaths = ['/admin/login']
  
  // Protection des routes admin
  if (pathname.startsWith('/admin') && !publicAdminPaths.includes(pathname)) {
    const token = request.cookies.get(ADMIN_TOKEN_COOKIE)
    
    // Rediriger vers la page de connexion si pas de token
    if (!token?.value) {
      const url = request.nextUrl.clone()
      url.pathname = '/admin/login'
      return NextResponse.redirect(url)
    }
    
    // La vérification de la validité du token se fera côté client/API
    return NextResponse.next()
  }

  return NextResponse.next()
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api (API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     */
    '/((?!api|_next/static|_next/image|favicon.ico).*)',
  ],
}
