#!/bin/bash
# Script pour vérifier et ajouter les données des salles
# U Silenziu - Septembre 2025

echo "🔍 VÉRIFICATION DES DONNÉES SALLES"
echo "================================="
echo ""

# 1. Vérifier les salles existantes
echo "1. Salles existantes dans la base :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, name, description, price, duration, max_people, is_active
FROM rooms 
ORDER BY created_at;
"

echo ""

# 2. Compter les salles
echo "2. Nombre de salles :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT COUNT(*) as total_rooms,
       COUNT(CASE WHEN is_active = true THEN 1 END) as active_rooms
FROM rooms;
"

echo ""

# 3. Ajouter une deuxième salle si nécessaire
echo "3. Ajout d'une deuxième salle si nécessaire..."
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
) ON CONFLICT (name) DO NOTHING;
"

echo ""

# 4. Vérification finale
echo "4. Vérification finale des salles :"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, name, description, price, duration, max_people, is_active
FROM rooms 
WHERE is_active = true
ORDER BY created_at;
"

echo ""

echo "✅ VÉRIFICATION TERMINÉE !"
