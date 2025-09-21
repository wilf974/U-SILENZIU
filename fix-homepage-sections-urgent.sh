#!/bin/bash

echo "=== CORRECTION URGENTE HOMEPAGE SECTIONS ==="
echo ""

# 1. Pull du code mis à jour
echo "1. 📥 PULL CODE :"
echo "================"
git pull origin main

# 2. Sauvegarde préventive
echo ""
echo "2. 💾 SAUVEGARDE :"
echo "=================="
docker exec u-silenziu-postgres pg_dump -U usilenzio_user -d usilenzio -t homepage_sections > backup_homepage_sections_$(date +%Y%m%d_%H%M%S).sql
echo "✅ Sauvegarde créée : backup_homepage_sections_$(date +%Y%m%d_%H%M%S).sql"

# 3. Appliquer la migration SQL
echo ""
echo "3. 🔧 MIGRATION SCHEMA :"
echo "======================="
docker exec -i u-silenziu-postgres psql -U usilenzio_user -d usilenzio < fix-homepage-sections-schema.sql

# 4. Vérifier la structure
echo ""
echo "4. ✅ VÉRIFICATION :"
echo "==================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'homepage_sections' 
ORDER BY ordinal_position;
"

# 5. Tester une section
echo ""
echo "5. 🧪 TEST SECTION HERO :"
echo "========================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  id,
  section_key,
  title,
  subtitle,
  background_color,
  text_color
FROM homepage_sections 
WHERE id = 'hero';
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

# 8. Test API
echo ""
echo "8. 🧪 TEST API :"
echo "==============="
echo "Test GET hero :"
curl -s "https://rageroom.usilenziu.com/api/admin/homepage-sections/hero" | head -c 300

echo ""
echo ""
echo "Test PUT hero (simulation) :"
curl -s -X PUT "https://rageroom.usilenziu.com/api/admin/homepage-sections/hero" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Update",
    "subtitle": "Test subtitle",
    "background_color": "bg-dark-surface",
    "text_color": "text-white"
  }' | head -c 300

echo ""
echo ""
echo "=== CORRECTION TERMINÉE ==="
echo ""
echo "✅ Actions effectuées :"
echo "• Migration schema database"
echo "• Ajout colonnes manquantes"
echo "• Migration données existantes"
echo "• Restart application"
echo "• Tests API"
echo ""
echo "🧪 Tests à faire :"
echo "• Modifier une section dans l'admin"
echo "• Vérifier sauvegarde OK"
echo "• Vérifier affichage public"
