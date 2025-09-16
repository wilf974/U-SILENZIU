'use client'

export default function JsonLd() {
  // Fonction pour créer les données JSON-LD de manière sécurisée
  const createOrganizationData = () => {
    try {
      const data = {
        "@context": "https://schema.org",
        "@type": "LocalBusiness",
        "@id": "https://usilenziu.com/#organization",
        "name": "U Silenziu",
        "url": "https://usilenziu.com",
        "logo": "https://usilenziu.com/logo.png",
        "description": "Zone de défoulement à Buros - Cassez, détruisez et libérez votre stress dans nos salles sécurisées",
        "address": {
          "@type": "PostalAddress",
          "streetAddress": "Adresse à compléter",
          "addressLocality": "Buros",
          "addressRegion": "Nouvelle-Aquitaine",
          "postalCode": "64160",
          "addressCountry": "FR"
        },
        "contactPoint": [
          {
            "@type": "ContactPoint",
            "telephone": "+33-5-XX-XX-XX-XX",
            "contactType": "customer service",
            "email": "contact@usilenziu.com",
            "areaServed": "FR",
            "availableLanguage": ["French"]
          }
        ],
        "sameAs": [
          "https://www.facebook.com/usilenziu",
          "https://www.instagram.com/usilenziu"
        ]
      }
      
      // Test de sérialisation avant de retourner
      JSON.stringify(data)
      return data
    } catch (error) {
      console.error('Erreur lors de la création des données organisation:', error)
      return null
    }
  }

  const createBusinessData = () => {
    try {
      const data = {
        "@context": "https://schema.org",
        "@type": "SportsActivityLocation",
        "@id": "https://usilenziu.com/#business",
        "name": "U Silenziu",
        "description": "Zone de défoulement à Buros - Cassez, détruisez et libérez votre stress dans nos salles sécurisées",
        "url": "https://usilenziu.com",
        "telephone": "+33-5-XX-XX-XX-XX",
        "address": {
          "@type": "PostalAddress",
          "streetAddress": "Adresse à compléter",
          "addressLocality": "Buros",
          "addressRegion": "Nouvelle-Aquitaine",
          "postalCode": "64160",
          "addressCountry": "FR"
        },
        "geo": {
          "@type": "GeoCoordinates",
          "latitude": "43.XXXXX",
          "longitude": "-0.XXXXX"
        },
        "image": [
          "https://usilenziu.com/og-image.jpg"
        ],
        "priceRange": "€€",
        "openingHours": [
          {
            "@type": "OpeningHoursSpecification",
            "opens": "14:00",
            "closes": "21:00",
            "dayOfWeek": ["Tuesday", "Wednesday", "Thursday"]
          },
          {
            "@type": "OpeningHoursSpecification",
            "opens": "14:00",
            "closes": "00:00",
            "dayOfWeek": ["Friday", "Saturday"]
          }
        ],
        "hasOfferCatalog": {
          "@type": "OfferCatalog",
          "name": "Formules de défoulement",
          "itemListElement": [
            {
              "@type": "Offer",
              "itemOffered": {
                "@type": "Service",
                "name": "Pas Content! - Session douce",
                "description": "Session de défoulement douce de 20 minutes"
              }
            },
            {
              "@type": "Offer",
              "itemOffered": {
                "@type": "Service",
                "name": "Vraiment pas Content! - Session carnage",
                "description": "Session de défoulement intense de 30 minutes"
              }
            },
            {
              "@type": "Offer",
              "itemOffered": {
                "@type": "Service",
                "name": "Grosse colère - Session privatisée",
                "description": "Session de défoulement privatisée de 30 minutes"
              }
            }
          ]
        }
      }
      
      // Test de sérialisation avant de retourner
      JSON.stringify(data)
      return data
    } catch (error) {
      console.error('Erreur lors de la création des données business:', error)
      return null
    }
  }

  // Création sécurisée des données avec gestion d'erreur
  let organizationData = null
  let businessData = null

  try {
    organizationData = createOrganizationData()
    businessData = createBusinessData()
  } catch (error) {
    console.error('Erreur lors de la création des données JSON-LD:', error)
    return null
  }

  // Ne rien rendre si les données ne peuvent pas être créées
  if (!organizationData || !businessData) {
    return null
  }

  // Rendu sécurisé avec gestion d'erreur
  try {
    return (
      <>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify(organizationData)
          }}
        />
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify(businessData)
          }}
        />
      </>
    )
  } catch (error) {
    console.error('Erreur lors du rendu JSON-LD:', error)
    return null
  }
}
