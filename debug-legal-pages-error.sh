#!/bin/bash

echo "=== DIAGNOSTIC ERREUR PAGES LÉGALES ==="
echo ""

# 1. Vérifier les logs de l'erreur
echo "1. 🔍 LOGS ERREUR PAGES LÉGALES :"
echo "================================"
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=50 | grep -A5 -B5 -i "legal-pages\|erreur.*page.*légale\|legal_pages"

# 2. Vérifier la structure de la table legal_pages
echo ""
echo "2. 🔍 STRUCTURE TABLE LEGAL_PAGES :"
echo "==================================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "\d legal_pages;"

# 3. Vérifier les pages légales existantes
echo ""
echo "3. 🔍 PAGES LÉGALES EXISTANTES :"
echo "==============================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  id,
  page_type,
  title,
  is_published,
  created_at,
  updated_at
FROM legal_pages 
ORDER BY page_type;
"

# 4. Vérifier les contraintes de la table
echo ""
echo "4. 🔍 CONTRAINTES TABLE :"
echo "========================"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  tc.constraint_name, 
  tc.constraint_type,
  kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
  ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_name = 'legal_pages';
"

# 5. Test API direct GET
echo ""
echo "5. 🧪 TEST API GET PAGES LÉGALES :"
echo "=================================="
curl -s "https://rageroom.usilenziu.com/api/admin/legal-pages" | head -c 500

# 6. Test API GET page spécifique (première page trouvée)
echo ""
echo ""
echo "6. 🧪 TEST API GET PAGE SPÉCIFIQUE :"
echo "==================================="
FIRST_PAGE_ID=$(docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -t -c "SELECT id FROM legal_pages LIMIT 1;" | xargs)
if [ ! -z "$FIRST_PAGE_ID" ]; then
  echo "Test avec ID: $FIRST_PAGE_ID"
  curl -s "https://rageroom.usilenziu.com/api/admin/legal-pages/$FIRST_PAGE_ID" | head -c 500
else
  echo "❌ Aucune page légale trouvée pour le test"
fi

# 7. Vérifier les colonnes de la table vs interface
echo ""
echo ""
echo "7. 🔍 COLONNES DE LA TABLE :"
echo "============================"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  column_name, 
  data_type, 
  is_nullable, 
  column_default
FROM information_schema.columns 
WHERE table_name = 'legal_pages' 
ORDER BY ordinal_position;
"

echo ""
echo "=== DIAGNOSTIC TERMINÉ ==="
echo ""
echo "🔍 ANALYSES :"
echo "1. Vérifier si la table legal_pages existe"
echo "2. Vérifier la structure des colonnes"
echo "3. Vérifier les contraintes"
echo "4. Vérifier l'existence des pages"
echo ""
echo "💡 CAUSES POSSIBLES :"
echo "• Table manquante ou corrompue"
echo "• Colonnes manquantes (meta_description, seo_title, etc.)"
echo "• Contrainte de clé unique violée"
echo "• Problème de permissions PostgreSQL"
echo "• Format JSON invalide"
