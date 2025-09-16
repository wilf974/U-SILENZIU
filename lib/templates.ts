/**
 * Système de templates pour les pages U Silenziu
 * Templates prédéfinis avec variables dynamiques
 */

export interface Template {
  id: string
  name: string
  description: string
  content: string
  variables: TemplateVariable[]
  category: 'page' | 'section' | 'component'
}

export interface TemplateVariable {
  name: string
  type: 'text' | 'number' | 'image' | 'list' | 'boolean'
  label: string
  description: string
  required: boolean
  defaultValue?: any
}

/**
 * Templates prédéfinis pour les pages
 */
export const pageTemplates: Template[] = [
  {
    id: 'about',
    name: 'Page À propos',
    description: 'Template pour une page de présentation avec sections multiples',
    category: 'page',
    content: `<h1>{{title}}</h1>

<section class="hero-section">
  <div class="hero-content">
    <h2>{{hero_title}}</h2>
    <p>{{hero_description}}</p>
    {{#if hero_image}}
    <img src="{{hero_image}}" alt="{{hero_title}}" class="hero-image">
    {{/if}}
  </div>
</section>

<section class="mission-section">
  <h2>Notre Mission</h2>
  <p>{{mission_text}}</p>
</section>

<section class="values-section">
  <h2>Nos Valeurs</h2>
  <div class="values-grid">
    {{#each values}}
    <div class="value-item">
      <h3>{{name}}</h3>
      <p>{{description}}</p>
    </div>
    {{/each}}
  </div>
</section>

<section class="team-section">
  <h2>Notre Équipe</h2>
  <div class="team-grid">
    {{#each team_members}}
    <div class="team-member">
      {{#if photo}}
      <img src="{{photo}}" alt="{{name}}" class="member-photo">
      {{/if}}
      <h3>{{name}}</h3>
      <p class="position">{{position}}</p>
      <p>{{bio}}</p>
    </div>
    {{/each}}
  </div>
</section>

<section class="contact-section">
  <h2>Contactez-nous</h2>
  <p>{{contact_text}}</p>
  <div class="contact-info">
    <p><strong>Adresse :</strong> {{address}}</p>
    <p><strong>Téléphone :</strong> {{phone}}</p>
    <p><strong>Email :</strong> {{email}}</p>
  </div>
</section>`,
    variables: [
      {
        name: 'title',
        type: 'text',
        label: 'Titre de la page',
        description: 'Titre principal de la page',
        required: true,
        defaultValue: 'À propos de U Silenziu'
      },
      {
        name: 'hero_title',
        type: 'text',
        label: 'Titre de la section hero',
        description: 'Titre de la section d\'introduction',
        required: true,
        defaultValue: 'Bienvenue chez U Silenziu'
      },
      {
        name: 'hero_description',
        type: 'text',
        label: 'Description hero',
        description: 'Description de la section d\'introduction',
        required: true,
        defaultValue: 'Votre zone de défoulement sécurisée à Buros'
      },
      {
        name: 'hero_image',
        type: 'image',
        label: 'Image hero',
        description: 'Image de la section d\'introduction',
        required: false
      },
      {
        name: 'mission_text',
        type: 'text',
        label: 'Texte de mission',
        description: 'Description de la mission',
        required: true,
        defaultValue: 'Nous offrons un espace sécurisé et encadré pour vous permettre de vous défouler en toute sécurité.'
      },
      {
        name: 'values',
        type: 'list',
        label: 'Valeurs',
        description: 'Liste des valeurs de l\'entreprise',
        required: false,
        defaultValue: [
          { name: 'Sécurité', description: 'Environnement contrôlé et encadré' },
          { name: 'Bien-être', description: 'Décompression et libération du stress' },
          { name: 'Accessibilité', description: 'Ouvert à tous, débutants et confirmés' }
        ]
      },
      {
        name: 'team_members',
        type: 'list',
        label: 'Membres de l\'équipe',
        description: 'Liste des membres de l\'équipe',
        required: false,
        defaultValue: []
      },
      {
        name: 'contact_text',
        type: 'text',
        label: 'Texte de contact',
        description: 'Texte d\'introduction pour la section contact',
        required: true,
        defaultValue: 'N\'hésitez pas à nous contacter pour plus d\'informations.'
      },
      {
        name: 'address',
        type: 'text',
        label: 'Adresse',
        description: 'Adresse de l\'établissement',
        required: true,
        defaultValue: 'Buros, France'
      },
      {
        name: 'phone',
        type: 'text',
        label: 'Téléphone',
        description: 'Numéro de téléphone',
        required: true,
        defaultValue: '+33 1 23 45 67 89'
      },
      {
        name: 'email',
        type: 'text',
        label: 'Email',
        description: 'Adresse email',
        required: true,
        defaultValue: 'contact@usilenzio.fr'
      }
    ]
  },
  {
    id: 'services',
    name: 'Page Services',
    description: 'Template pour présenter les services et formules',
    category: 'page',
    content: `<h1>{{title}}</h1>

<section class="services-intro">
  <h2>{{intro_title}}</h2>
  <p>{{intro_description}}</p>
</section>

<section class="services-list">
  {{#each services}}
  <div class="service-card">
    <div class="service-header">
      <h3>{{name}}</h3>
      <div class="service-price">{{price}}</div>
    </div>
    <div class="service-content">
      <p>{{description}}</p>
      <ul class="service-features">
        {{#each features}}
        <li>{{this}}</li>
        {{/each}}
      </ul>
      {{#if image}}
      <img src="{{image}}" alt="{{name}}" class="service-image">
      {{/if}}
    </div>
    <div class="service-footer">
      <button class="btn-primary">Réserver maintenant</button>
    </div>
  </div>
  {{/each}}
</section>

<section class="additional-info">
  <h2>{{additional_title}}</h2>
  <div class="info-grid">
    {{#each additional_info}}
    <div class="info-item">
      <h4>{{title}}</h4>
      <p>{{content}}</p>
    </div>
    {{/each}}
  </div>
</section>`,
    variables: [
      {
        name: 'title',
        type: 'text',
        label: 'Titre de la page',
        description: 'Titre principal de la page',
        required: true,
        defaultValue: 'Nos Services'
      },
      {
        name: 'intro_title',
        type: 'text',
        label: 'Titre d\'introduction',
        description: 'Titre de la section d\'introduction',
        required: true,
        defaultValue: 'Découvrez nos services'
      },
      {
        name: 'intro_description',
        type: 'text',
        label: 'Description d\'introduction',
        description: 'Description de la section d\'introduction',
        required: true,
        defaultValue: 'Explorez nos différentes formules adaptées à tous les besoins.'
      },
      {
        name: 'services',
        type: 'list',
        label: 'Services',
        description: 'Liste des services proposés',
        required: true,
        defaultValue: [
          {
            name: 'Formule "Pas Content!"',
            price: '25€',
            description: 'Session douce de 20 minutes pour 1 à 4 personnes.',
            features: ['Durée : 20 minutes', 'Capacité : 1-4 personnes', 'Environnement sécurisé'],
            image: ''
          },
          {
            name: 'Formule "Vraiment pas Content!"',
            price: '45€',
            description: 'Session carnage de 30 minutes pour 1 à 6 personnes.',
            features: ['Durée : 30 minutes', 'Capacité : 1-6 personnes', 'Équipement complet'],
            image: ''
          },
          {
            name: 'Formule "Grosse colère"',
            price: '80€',
            description: 'Session privatisée de 30 minutes pour 1 à 8 personnes.',
            features: ['Durée : 30 minutes', 'Capacité : 1-8 personnes', 'Privatisation complète'],
            image: ''
          }
        ]
      },
      {
        name: 'additional_title',
        type: 'text',
        label: 'Titre section supplémentaire',
        description: 'Titre de la section d\'informations supplémentaires',
        required: true,
        defaultValue: 'Informations importantes'
      },
      {
        name: 'additional_info',
        type: 'list',
        label: 'Informations supplémentaires',
        description: 'Liste d\'informations supplémentaires',
        required: false,
        defaultValue: [
          {
            title: 'Réservation',
            content: 'Réservation obligatoire 24h à l\'avance.'
          },
          {
            title: 'Équipement',
            content: 'Tout l\'équipement de sécurité est fourni.'
          },
          {
            title: 'Âge minimum',
            content: 'Accès réservé aux personnes majeures.'
          }
        ]
      }
    ]
  },
  {
    id: 'contact',
    name: 'Page Contact',
    description: 'Template pour une page de contact complète',
    category: 'page',
    content: `<h1>{{title}}</h1>

<section class="contact-hero">
  <h2>{{hero_title}}</h2>
  <p>{{hero_description}}</p>
</section>

<div class="contact-container">
  <section class="contact-info">
    <h3>Informations de contact</h3>
    <div class="info-grid">
      <div class="info-item">
        <h4>Adresse</h4>
        <p>{{address}}</p>
      </div>
      <div class="info-item">
        <h4>Téléphone</h4>
        <p><a href="tel:{{phone}}">{{phone}}</a></p>
      </div>
      <div class="info-item">
        <h4>Email</h4>
        <p><a href="mailto:{{email}}">{{email}}</a></p>
      </div>
      <div class="info-item">
        <h4>Horaires</h4>
        <p>{{opening_hours}}</p>
      </div>
    </div>
  </section>

  <section class="contact-form">
    <h3>Nous contacter</h3>
    <form class="contact-form-content">
      <div class="form-group">
        <label for="name">Nom complet *</label>
        <input type="text" id="name" name="name" required>
      </div>
      <div class="form-group">
        <label for="email">Email *</label>
        <input type="email" id="email" name="email" required>
      </div>
      <div class="form-group">
        <label for="phone">Téléphone</label>
        <input type="tel" id="phone" name="phone">
      </div>
      <div class="form-group">
        <label for="subject">Sujet *</label>
        <select id="subject" name="subject" required>
          <option value="">Choisissez un sujet</option>
          <option value="reservation">Réservation</option>
          <option value="information">Demande d'information</option>
          <option value="partnership">Partenariat</option>
          <option value="other">Autre</option>
        </select>
      </div>
      <div class="form-group">
        <label for="message">Message *</label>
        <textarea id="message" name="message" rows="5" required></textarea>
      </div>
      <button type="submit" class="btn-primary">Envoyer le message</button>
    </form>
  </section>
</div>

{{#if map_embed}}
<section class="map-section">
  <h3>Localisation</h3>
  <div class="map-container">
    {{{map_embed}}}
  </div>
</section>
{{/if}}`,
    variables: [
      {
        name: 'title',
        type: 'text',
        label: 'Titre de la page',
        description: 'Titre principal de la page',
        required: true,
        defaultValue: 'Contact'
      },
      {
        name: 'hero_title',
        type: 'text',
        label: 'Titre hero',
        description: 'Titre de la section d\'introduction',
        required: true,
        defaultValue: 'Contactez-nous'
      },
      {
        name: 'hero_description',
        type: 'text',
        label: 'Description hero',
        description: 'Description de la section d\'introduction',
        required: true,
        defaultValue: 'N\'hésitez pas à nous contacter pour toute question ou réservation.'
      },
      {
        name: 'address',
        type: 'text',
        label: 'Adresse',
        description: 'Adresse complète',
        required: true,
        defaultValue: '123 Rue de la Défoulement, 64160 Buros, France'
      },
      {
        name: 'phone',
        type: 'text',
        label: 'Téléphone',
        description: 'Numéro de téléphone',
        required: true,
        defaultValue: '+33 1 23 45 67 89'
      },
      {
        name: 'email',
        type: 'text',
        label: 'Email',
        description: 'Adresse email',
        required: true,
        defaultValue: 'contact@usilenzio.fr'
      },
      {
        name: 'opening_hours',
        type: 'text',
        label: 'Horaires d\'ouverture',
        description: 'Horaires d\'ouverture',
        required: true,
        defaultValue: 'Lundi - Samedi : 10h - 22h\nDimanche : 14h - 20h'
      },
      {
        name: 'map_embed',
        type: 'text',
        label: 'Code d\'intégration carte',
        description: 'Code HTML pour intégrer une carte (Google Maps, etc.)',
        required: false
      }
    ]
  }
]

/**
 * Fonction pour récupérer un template par ID
 */
export function getTemplateById(id: string): Template | undefined {
  return pageTemplates.find(template => template.id === id)
}

/**
 * Fonction pour récupérer tous les templates
 */
export function getAllTemplates(): Template[] {
  return pageTemplates
}

/**
 * Fonction pour récupérer les templates par catégorie
 */
export function getTemplatesByCategory(category: Template['category']): Template[] {
  return pageTemplates.filter(template => template.category === category)
}

/**
 * Fonction pour prévisualiser un template avec des données
 */
export function previewTemplate(templateId: string, data: Record<string, any>): string {
  const template = getTemplateById(templateId)
  if (!template) {
    throw new Error(`Template ${templateId} non trouvé`)
  }

  let content = template.content

  // Remplacement des variables simples
  Object.entries(data).forEach(([key, value]) => {
    const regex = new RegExp(`{{${key}}}`, 'g')
    content = content.replace(regex, String(value || ''))
  })

  // Gestion des boucles {{#each}}
  const eachRegex = /\{\{#each\s+(\w+)\}\}([\s\S]*?)\{\{\/each\}\}/g
  content = content.replace(eachRegex, (match, arrayKey, templateContent) => {
    const array = data[arrayKey]
    if (!Array.isArray(array)) return ''

    return array.map(item => {
      let itemContent = templateContent
      Object.entries(item).forEach(([key, value]) => {
        const regex = new RegExp(`{{${key}}}`, 'g')
        itemContent = itemContent.replace(regex, String(value || ''))
      })
      return itemContent
    }).join('')
  })

  // Gestion des conditions {{#if}}
  const ifRegex = /\{\{#if\s+(\w+)\}\}([\s\S]*?)\{\{\/if\}\}/g
  content = content.replace(ifRegex, (match, conditionKey, templateContent) => {
    const condition = data[conditionKey]
    if (condition) {
      let conditionalContent = templateContent
      Object.entries(data).forEach(([key, value]) => {
        const regex = new RegExp(`{{${key}}}`, 'g')
        conditionalContent = conditionalContent.replace(regex, String(value || ''))
      })
      return conditionalContent
    }
    return ''
  })

  return content
}
