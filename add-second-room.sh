#!/bin/bash
# Script pour ajouter la deuxième salle
# U Silenziu - Septembre 2025

echo "🏠 AJOUT DE LA DEUXIÈME SALLE"
echo "============================="
echo ""

# 1. Vérifier les salles existantes
echo "1. Salles existantes :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT name, description, price, is_active 
FROM rooms 
ORDER BY created_at;
"

echo ""

# 2. Ajouter la deuxième salle
echo "2. Ajout de la deuxième salle..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
INSERT INTO rooms (
    name, description, price, duration, max_people,
    objects_to_destroy, included, image_url, is_active
) VALUES (
    'Salle 2',
    'Pour un défoulement en douceur',
    25.00,
    20,
    4,
    ARRAY['Bouteilles', 'Vaisselle', 'Objets en verre'],
    ARRAY['Équipement de protection', 'Matériel de défoulement', 'Zone sécurisée'],
    '/uploads/rooms/salle2-default.jpg',
    true
) ON CONFLICT (name) DO UPDATE SET
    description = EXCLUDED.description,
    price = EXCLUDED.price,
    duration = EXCLUDED.duration,
    max_people = EXCLUDED.max_people,
    objects_to_destroy = EXCLUDED.objects_to_destroy,
    included = EXCLUDED.included,
    is_active = EXCLUDED.is_active;
"

echo ""

# 3. Vérification finale
echo "3. Vérification finale :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT name, description, price, is_active 
FROM rooms 
WHERE is_active = true 
ORDER BY created_at;
"

echo ""

echo "✅ DEUXIÈME SALLE AJOUTÉE !"
