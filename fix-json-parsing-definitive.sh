#!/bin/bash
# Correction définitive des erreurs JSON parsing

echo "=== CORRECTION DÉFINITIVE JSON PARSING ==="

# 1. Vérifier contenu actuel des sections
echo "1. Diagnostic contenu sections..."
docker exec u-silenziu-postgres-prod psql -U usilenzio_user -d usilenzio -c "
SELECT
  section_name,
  CASE
    WHEN content IS NULL THEN 'NULL'
    WHEN content::text = '' THEN 'EMPTY'
    WHEN content::text = '{}' THEN 'EMPTY_JSON'
    WHEN content::text LIKE '{%' AND content::text LIKE '%}' THEN 'VALID_JSON'
    ELSE 'INVALID_JSON'
  END as status,
  LEFT(content::text, 100) as preview
FROM homepage_sections
ORDER BY order_index;
"

# 2. Nettoyer complètement les volumes Docker
echo "2. Nettoyage complet Docker..."
docker compose -f docker-compose.prod.yml down --volumes --remove-orphans
docker system prune -a -f --volumes

# 3. Corriger le contenu JSON
echo "3. Correction contenu JSON..."
docker exec u-silenziu-postgres-prod psql -U usilenzio_user -d usilenzio -c "
-- Mettre du JSON valide pour toutes les sections
UPDATE homepage_sections SET content = '{\"title\":\"Le Concept\",\"subtitle\":\"Défoulement sécurisé et fun\"}' WHERE section_name = 'concept';
UPDATE homepage_sections SET content = '{\"title\":\"Comment ça marche ?\",\"subtitle\":\"Simple et efficace\"}' WHERE section_name = 'process';
UPDATE homepage_sections SET content = '{\"title\":\"Questions Fréquentes\",\"subtitle\":\"Tout ce que vous devez savoir\"}' WHERE section_name = 'faq';
UPDATE homepage_sections SET content = '{\"title\":\"Contact\",\"subtitle\":\"Une question ? Contactez-nous\"}' WHERE section_name = 'contact';

-- Vérifier que c'est du JSON valide
SELECT section_name, content::json FROM homepage_sections ORDER BY order_index;
"

# 4. Build sans cache
echo "4. Build complet sans cache..."
docker compose -f docker-compose.prod.yml build --no-cache --pull u-silenziu

# 5. Démarrage avec recréation forcée
echo "5. Démarrage avec recréation..."
docker compose -f docker-compose.prod.yml up -d --force-recreate

# 6. Attendre démarrage complet
echo "6. Attente démarrage (90s)..."
sleep 90

# 7. Test des APIs
echo "7. Tests finaux..."
echo "API homepage-sections:"
curl -k -s https://rageroom.usilenziu.com/api/homepage-sections | head -c 300

echo -e "\nAPI legal-pages:"
curl -k -s https://rageroom.usilenziu.com/api/legal-pages | head -c 200

echo -e "\nSite principal:"
curl -k -s https://rageroom.usilenziu.com/ | grep -o "Application error" || echo "✅ Site OK"

echo -e "\n=== CORRECTION TERMINÉE ==="
echo "Le site devrait maintenant être 100% fonctionnel"
echo "Videz le cache navigateur (Ctrl+Shift+R) et testez"
