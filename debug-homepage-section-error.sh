#!/bin/bash

echo "=== DIAGNOSTIC ERREUR SECTION HOMEPAGE ==="
echo ""

# 1. Vérifier les logs de l'erreur
echo "1. 🔍 LOGS ERREUR 500 :"
echo "======================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=50 | grep -A5 -B5 -i "homepage-sections\|erreur.*section\|500"

# 2. Vérifier la structure de la table homepage_sections
echo ""
echo "2. 🔍 STRUCTURE TABLE :"
echo "======================"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\d homepage_sections;"

# 3. Vérifier les sections existantes
echo ""
echo "3. 🔍 SECTIONS EXISTANTES :"
echo "=========================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  id,
  section_key,
  title,
  is_active,
  order_index
FROM homepage_sections 
ORDER BY order_index;
"

# 4. Vérifier spécifiquement la section 'hero'
echo ""
echo "4. 🔍 SECTION 'HERO' :"
echo "====================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT * FROM homepage_sections 
WHERE section_key = 'hero' OR id = 'hero';
"

# 5. Test API direct
echo ""
echo "5. 🧪 TEST API GET SECTION HERO :"
echo "================================="
curl -s "https://rageroom.usilenziu.com/api/admin/homepage-sections/hero" | head -c 500

# 6. Vérifier les contraintes de la table
echo ""
echo ""
echo "6. 🔍 CONTRAINTES TABLE :"
echo "========================"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  tc.constraint_name, 
  tc.constraint_type,
  kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
  ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_name = 'homepage_sections';
"

# 7. Créer une section de test pour reproduire l'erreur
echo ""
echo "7. 🧪 TEST CRÉATION SECTION :"
echo "============================="
curl -s -X POST "https://rageroom.usilenziu.com/api/admin/homepage-sections" \
  -H "Content-Type: application/json" \
  -d '{
    "section_key": "test-debug",
    "title": "Test Debug",
    "subtitle": "Test pour diagnostiquer erreur",
    "content": "Contenu de test",
    "is_active": true,
    "order_index": 999
  }'

echo ""
echo ""
echo "=== DIAGNOSTIC TERMINÉ ==="
echo ""
echo "🔍 ANALYSES :"
echo "1. Vérifier si la table homepage_sections existe"
echo "2. Vérifier la structure des colonnes"
echo "3. Vérifier les contraintes (clé primaire, unique, etc.)"
echo "4. Vérifier l'existence de la section 'hero'"
echo ""
echo "💡 CAUSES POSSIBLES :"
echo "• Table manquante ou corrompue"
echo "• Contrainte de clé unique violée"
echo "• Problème de permissions PostgreSQL"
echo "• Fonction updateHomepageSection incorrecte"
echo "• Format JSON invalide envoyé par le frontend"
