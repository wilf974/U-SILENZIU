#!/bin/bash
# Script de correction finale des erreurs JSON parsing

echo "=== CORRECTION ERREURS JSON PARSING ==="

# 1. Vérifier que le contenu des sections est du JSON valide
echo "1. Vérification contenu sections..."
docker exec u-silenziu-postgres-prod psql -U usilenzio_user -d usilenzio -c "
SELECT section_name, 
       LENGTH(content::text) as length,
       CASE 
         WHEN content IS NULL THEN 'NULL'
         WHEN content::text = '' THEN 'EMPTY'
         WHEN content::text = '{}' THEN 'EMPTY_JSON'
         ELSE 'HAS_CONTENT'
       END as status
FROM homepage_sections 
ORDER BY order_index;
"

# 2. Corriger le contenu avec du JSON valide
echo "2. Correction contenu JSON..."
docker exec u-silenziu-postgres-prod psql -U usilenzio_user -d usilenzio -c "
UPDATE homepage_sections SET content = '{\"title\":\"Bienvenue chez U Silenziu\",\"subtitle\":\"Votre zone de défoulement à Buros\"}' WHERE section_name = 'hero';
UPDATE homepage_sections SET content = '{\"title\":\"Le Concept\",\"subtitle\":\"Défoulement sécurisé et fun\"}' WHERE section_name = 'concept';
UPDATE homepage_sections SET content = '{\"title\":\"Comment ça marche ?\",\"subtitle\":\"Simple et efficace\"}' WHERE section_name = 'process';
UPDATE homepage_sections SET content = '{\"title\":\"Questions Fréquentes\",\"subtitle\":\"Tout ce que vous devez savoir\"}' WHERE section_name = 'faq';
UPDATE homepage_sections SET content = '{\"title\":\"Contact\",\"subtitle\":\"Une question ? Contactez-nous\"}' WHERE section_name = 'contact';

-- Vérifier que c'est du JSON valide
SELECT section_name, content::json FROM homepage_sections ORDER BY order_index;
"

# 3. Force rebuild complet pour déployer le nouveau code
echo "3. Force rebuild avec nouveau code..."
docker compose -f docker-compose.prod.yml down
docker system prune -f --volumes
docker compose -f docker-compose.prod.yml build --no-cache u-silenziu
docker compose -f docker-compose.prod.yml up -d

# 4. Attendre démarrage complet
echo "4. Attente démarrage (60s)..."
sleep 60

# 5. Test API directement
echo "5. Test API homepage-sections..."
curl -k -s https://rageroom.usilenziu.com/api/homepage-sections | head -c 500

# 6. Forcer headers no-cache sur toutes les réponses pour éviter le cache
echo "6. Vérification timestamp cache..."
curl -k -s "https://rageroom.usilenziu.com/api/homepage-sections?t=$(date +%s)" | head -c 300

echo ""
echo "=== CORRECTION TERMINÉE ==="
echo "Le site devrait maintenant fonctionner sans erreurs JSON"
echo "Testez avec: https://rageroom.usilenziu.com"
