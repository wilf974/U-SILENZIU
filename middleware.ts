import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

// Middleware d'authentification simple pour les pages admin
export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl

  // Vérifier si c'est une route admin
  if (pathname.startsWith('/admin')) {
    // Pour le développement, on autorise tout l'accès
    // En production, il faudrait vérifier un token d'authentification
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
