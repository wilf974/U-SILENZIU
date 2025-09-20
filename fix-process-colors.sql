-- Script pour corriger les couleurs bleues dans la section process
-- Remplacer les couleurs bleues par kaki dans les données JSON

UPDATE homepage_sections 
SET content = REPLACE(
  REPLACE(
    REPLACE(
      REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(
              REPLACE(
                REPLACE(
                  REPLACE(
                    content,
                    'from-blue-400 to-blue-600', 'from-kaki-400 to-kaki-600'
                  ),
                  'from-blue-500 to-blue-700', 'from-kaki-500 to-kaki-700'
                ),
                'from-blue-600 to-blue-800', 'from-kaki-600 to-kaki-800'
              ),
              'from-blue-700 to-blue-900', 'from-kaki-700 to-kaki-900'
            ),
            'bg-blue-600', 'bg-kaki-600'
          ),
          'bg-blue-500', 'bg-kaki-500'
        ),
        'text-blue-400', 'text-kaki-400'
      ),
      'text-blue-500', 'text-kaki-500'
    ),
    'hover:bg-blue-700', 'hover:bg-kaki-700'
  ),
  'hover:bg-blue-600', 'hover:bg-kaki-600'
)
WHERE section_key = 'process' 
AND content LIKE '%blue%';

-- Vérifier les résultats
SELECT id, section_key, content 
FROM homepage_sections 
WHERE section_key = 'process';
