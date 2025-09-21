#!/bin/bash

echo "=== CORRECTION URGENTE PAGES LÉGALES ==="
echo ""

# 1. Pull du code mis à jour
echo "1. 📥 PULL CODE :"
echo "================"
git pull origin main

# 2. Sauvegarde préventive
echo ""
echo "2. 💾 SAUVEGARDE :"
echo "=================="
docker exec u-silenziu-postgres pg_dump -U usilenzio_user -d usilenzio -t legal_pages > backup_legal_pages_$(date +%Y%m%d_%H%M%S).sql
echo "✅ Sauvegarde créée : backup_legal_pages_$(date +%Y%m%d_%H%M%S).sql"

# 3. Appliquer la migration SQL
echo ""
echo "3. 🔧 MIGRATION SCHEMA :"
echo "======================="
docker exec -i u-silenziu-postgres psql -U usilenzio_user -d usilenzio < fix-legal-pages-schema.sql

# 4. Vérifier la structure
echo ""
echo "4. ✅ VÉRIFICATION STRUCTURE :"
echo "=============================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'legal_pages' 
ORDER BY ordinal_position;
"

# 5. Vérifier les données
echo ""
echo "5. 🧪 VÉRIFICATION DONNÉES :"
echo "============================"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  page_type,
  title,
  meta_description,
  seo_title,
  array_length(keywords, 1) as keywords_count,
  last_updated_by
FROM legal_pages 
ORDER BY page_type;
"

# 6. Redémarrer l'application
echo ""
echo "6. 🔄 RESTART APP :"
echo "=================="
docker compose -f docker-compose.prod.yml restart u-silenziu

# 7. Attendre stabilisation
echo ""
echo "7. ⏳ ATTENTE STABILISATION :"
echo "============================"
sleep 10

# 8. Test API GET
echo ""
echo "8. 🧪 TEST API GET :"
echo "==================="
echo "Test GET toutes les pages :"
curl -s "https://rageroom.usilenziu.com/api/admin/legal-pages" | head -c 300

# 9. Test API PUT (simulation)
echo ""
echo ""
echo "9. 🧪 TEST API PUT :"
echo "==================="
FIRST_PAGE_ID=$(docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -t -c "SELECT id FROM legal_pages LIMIT 1;" | xargs)
if [ ! -z "$FIRST_PAGE_ID" ]; then
  echo "Test PUT avec ID: $FIRST_PAGE_ID"
  curl -s -X PUT "https://rageroom.usilenziu.com/api/admin/legal-pages/$FIRST_PAGE_ID" \
    -H "Content-Type: application/json" \
    -d '{
      "title": "Test Update",
      "content": "Contenu test...",
      "meta_description": "Description test",
      "seo_title": "SEO Title test",
      "keywords": ["test", "legal"],
      "last_updated_by": "admin",
      "is_published": true
    }' | head -c 300
else
  echo "❌ Aucune page trouvée pour le test PUT"
fi

echo ""
echo ""
echo "=== CORRECTION TERMINÉE ==="
echo ""
echo "✅ Actions effectuées :"
echo "• Migration schema database"
echo "• Ajout colonnes manquantes (meta_description, seo_title, keywords, last_updated_by)"
echo "• Migration données existantes"
echo "• Restart application"
echo "• Tests API"
echo ""
echo "🧪 Tests à faire :"
echo "• Modifier une page légale dans l'admin"
echo "• Vérifier sauvegarde OK"
echo "• Vérifier affichage public"
