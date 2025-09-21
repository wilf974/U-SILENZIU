-- Migration de la table homepage_sections vers la nouvelle structure
-- Corriger l'erreur 500 "column subtitle/section_key does not exist"

BEGIN;

-- 1. Ajouter les colonnes manquantes
ALTER TABLE homepage_sections 
ADD COLUMN IF NOT EXISTS section_key VARCHAR(100),
ADD COLUMN IF NOT EXISTS subtitle VARCHAR(255),
ADD COLUMN IF NOT EXISTS image_url TEXT,
ADD COLUMN IF NOT EXISTS video_url TEXT,
ADD COLUMN IF NOT EXISTS background_color VARCHAR(50),
ADD COLUMN IF NOT EXISTS text_color VARCHAR(50);

-- 2. Migrer section_type vers section_key si pas déjà fait
UPDATE homepage_sections 
SET section_key = section_type 
WHERE section_key IS NULL AND section_type IS NOT NULL;

-- 3. Migrer le subtitle depuis data.subtitle si existe
UPDATE homepage_sections 
SET subtitle = (data->>'subtitle')
WHERE subtitle IS NULL 
  AND data IS NOT NULL 
  AND data->>'subtitle' IS NOT NULL;

-- 4. Valeurs par défaut pour les nouvelles colonnes
UPDATE homepage_sections 
SET 
  background_color = COALESCE(background_color, 'bg-dark-surface'),
  text_color = COALESCE(text_color, 'text-white'),
  image_url = COALESCE(image_url, ''),
  video_url = COALESCE(video_url, ''),
  section_key = COALESCE(section_key, 'section-' || id)
WHERE section_key IS NULL OR background_color IS NULL OR text_color IS NULL;

-- 5. Créer l'index sur section_key
CREATE INDEX IF NOT EXISTS idx_homepage_sections_section_key ON homepage_sections(section_key);

-- 6. Vérifier la structure finale
SELECT 
  column_name, 
  data_type, 
  is_nullable, 
  column_default
FROM information_schema.columns 
WHERE table_name = 'homepage_sections' 
ORDER BY ordinal_position;

COMMIT;

-- Afficher les sections mises à jour
SELECT 
  id,
  section_key,
  title,
  subtitle,
  background_color,
  text_color,
  is_active
FROM homepage_sections 
ORDER BY order_index;
