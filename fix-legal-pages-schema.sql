-- Migration de la table legal_pages vers la nouvelle structure
-- Corriger l'erreur "column meta_description of relation legal_pages does not exist"

BEGIN;

-- 1. Ajouter les colonnes manquantes
ALTER TABLE legal_pages 
ADD COLUMN IF NOT EXISTS meta_description TEXT,
ADD COLUMN IF NOT EXISTS seo_title VARCHAR(255),
ADD COLUMN IF NOT EXISTS keywords TEXT[], -- Array pour les mots-clés
ADD COLUMN IF NOT EXISTS last_updated_by VARCHAR(255);

-- 2. Valeurs par défaut pour les nouvelles colonnes
UPDATE legal_pages 
SET 
  meta_description = COALESCE(meta_description, 'Page légale - ' || title),
  seo_title = COALESCE(seo_title, title),
  keywords = COALESCE(keywords, ARRAY[]::TEXT[]), -- Array vide par défaut
  last_updated_by = COALESCE(last_updated_by, 'admin')
WHERE meta_description IS NULL OR seo_title IS NULL OR keywords IS NULL OR last_updated_by IS NULL;

-- 3. Créer des index pour les nouvelles colonnes
CREATE INDEX IF NOT EXISTS idx_legal_pages_meta_description ON legal_pages USING gin(to_tsvector('french', meta_description));
CREATE INDEX IF NOT EXISTS idx_legal_pages_keywords ON legal_pages USING gin(keywords);

-- 4. Vérifier la structure finale
SELECT 
  column_name, 
  data_type, 
  is_nullable, 
  column_default
FROM information_schema.columns 
WHERE table_name = 'legal_pages' 
ORDER BY ordinal_position;

COMMIT;

-- Afficher les pages mises à jour
SELECT 
  id,
  page_type,
  title,
  meta_description,
  seo_title,
  array_length(keywords, 1) as keywords_count,
  last_updated_by,
  is_published
FROM legal_pages 
ORDER BY page_type;
