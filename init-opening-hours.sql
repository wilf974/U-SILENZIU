-- Script d'initialisation des horaires d'ouverture
-- Ce script met à jour la configuration du footer avec les horaires par défaut

-- Vérifier si la configuration existe
INSERT INTO footer_config (
  id,
  site_name,
  site_description,
  site_slogan,
  contact_phone,
  contact_email,
  contact_address,
  opening_hours_monday,
  opening_hours_tuesday,
  opening_hours_wednesday,
  opening_hours_thursday,
  opening_hours_friday,
  opening_hours_saturday,
  opening_hours_sunday,
  cta_title,
  cta_subtitle,
  cta_button_text,
  cta_button_url,
  legal_links,
  copyright_text,
  created_at,
  updated_at
) VALUES (
  'default',
  'U SILENZIU',
  'Votre zone de défoulement à Buros. Libérez votre stress et vos tensions dans un environnement sécurisé et fun.',
  'Énergie positive garantie !',
  '+33 7 83 83 64 53',
  'info@usilenziu.com',
  '18 Rue du Pont Long, 64160 Buros, Zone Berlanne',
  'Fermé',
  '14:00 – 21:00',
  '14:00 – 21:00',
  '14:00 – 21:00',
  '14:00 – 00:00',
  '14:00 – 00:00',
  'Sur réservation uniquement, Minimum 5 personnes',
  'Prêt à libérer votre stress ?',
  'Réservez votre session de défoulement dès maintenant',
  'Réserver maintenant',
  '/reservation',
  '[]',
  '© 2024 U Silenziu. Tous droits réservés.',
  NOW(),
  NOW()
) ON CONFLICT (id) DO UPDATE SET
  opening_hours_monday = EXCLUDED.opening_hours_monday,
  opening_hours_tuesday = EXCLUDED.opening_hours_tuesday,
  opening_hours_wednesday = EXCLUDED.opening_hours_wednesday,
  opening_hours_thursday = EXCLUDED.opening_hours_thursday,
  opening_hours_friday = EXCLUDED.opening_hours_friday,
  opening_hours_saturday = EXCLUDED.opening_hours_saturday,
  opening_hours_sunday = EXCLUDED.opening_hours_sunday,
  updated_at = NOW();

-- Commentaire pour expliquer l'utilisation
COMMENT ON TABLE footer_config IS 'Configuration du pied de page incluant les horaires d''ouverture dynamiques';
