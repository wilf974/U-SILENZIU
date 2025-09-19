#!/bin/bash
# Script de correction finale pour la production

echo "=== CORRECTION FINALE PRODUCTION U-SILENZIU ==="

# 1. Arrêt complet et nettoyage
echo "1. Arrêt complet des conteneurs..."
docker compose -f docker-compose.prod.yml down --remove-orphans

# 2. Nettoyage cache Docker et builds
echo "2. Nettoyage cache..."
docker system prune -f
docker builder prune -f

# 3. Correction données en base avant redémarrage
echo "3. Redémarrage PostgreSQL seul pour correction données..."
docker compose -f docker-compose.prod.yml up -d postgres
sleep 10

# 4. Correction des données
echo "4. Correction des données en base..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
-- Corriger legal_pages
UPDATE legal_pages SET is_published = true WHERE is_published IS NOT true;
DELETE FROM legal_pages;
INSERT INTO legal_pages (page_type, title, content, meta_description, is_published) VALUES
('privacy', 'Politique de Confidentialité', 'Contenu politique confidentialité', 'Politique confidentialité U Silenziu', true),
('terms', 'Conditions Générales', 'Contenu CGU', 'Conditions générales U Silenziu', true),
('legal', 'Mentions Légales', 'Mentions légales U Silenziu', 'Mentions légales U Silenziu', true),
('cookies', 'Politique de Cookies', 'Politique cookies', 'Politique cookies U Silenziu', true);

-- Corriger homepage_sections content vides
UPDATE homepage_sections SET content = '{}' WHERE content IS NULL OR content = '' OR content = 'null';

-- Vérifier données
SELECT 'Legal pages:' as info, COUNT(*) as count FROM legal_pages WHERE is_published = true;
SELECT 'Homepage sections:' as info, section_name, LENGTH(content::text) as content_length FROM homepage_sections;
"

# 5. Build complet sans cache
echo "5. Rebuild complet sans cache..."
docker compose -f docker-compose.prod.yml build --no-cache u-silenziu

# 6. Démarrage final
echo "6. Démarrage final..."
docker compose -f docker-compose.prod.yml up -d

# 7. Attente stabilisation
echo "7. Attente stabilisation (60s)..."
sleep 60

# 8. Tests finaux
echo "8. Tests finaux..."
echo "- Legal pages:"
curl -k -s https://rageroom.usilenziu.com/api/legal-pages | head -c 200

echo -e "\n- Homepage sections:"
curl -k -s https://rageroom.usilenziu.com/api/homepage-sections | head -c 200

echo -e "\n- Site principal:"
curl -k -s https://rageroom.usilenziu.com/ | grep -o "Application error" && echo "❌ Erreur présente" || echo "✅ Site OK"

echo -e "\n=== CORRECTION TERMINÉE ==="
echo "Vide le cache navigateur (Ctrl+Shift+R) et teste le site"
