#!/bin/bash

echo "=== CORRECTION SALLE 1 - AJOUT INCLUDED ==="
echo ""

# 1. Mettre à jour Salle 1 avec des éléments included
echo "1. 🔧 MISE À JOUR SALLE 1 :"
echo "==========================="
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
UPDATE rooms 
SET included = '{\"Équipements de protection\", \"Matériel de destruction\", \"Instructions de sécurité\"}',
    updated_at = NOW()
WHERE name = 'Salle 1';
"

# 2. Vérifier la mise à jour
echo ""
echo "2. ✅ VÉRIFICATION MISE À JOUR :"
echo "================================"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
  name, 
  description, 
  included, 
  objects_to_destroy,
  updated_at
FROM rooms 
WHERE name = 'Salle 1';
"

# 3. Test API pour vérifier l'affichage
echo ""
echo "3. 🧪 TEST API SALLES :"
echo "======================"
curl -s "https://rageroom.usilenziu.com/api/rooms" | jq '.data[] | {name, description, included}' 2>/dev/null || echo "Erreur jq"

echo ""
echo "=== CORRECTION TERMINÉE ==="
echo ""
echo "✅ Salle 1 devrait maintenant afficher la section 'Inclus' !"
echo "🔄 Rafraîchissez la page du site pour voir les changements."
