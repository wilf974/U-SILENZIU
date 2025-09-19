#!/bin/bash
# Correction affichage des salles
# U Silenziu - Septembre 2025

echo "🔧 CORRECTION AFFICHAGE DES SALLES"
echo "=================================="
echo ""

# 1. Vérifier l'état actuel
echo "1. Vérification des données actuelles..."
echo "   - homepage_sections:"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "SELECT COUNT(*) FROM homepage_sections;"

echo "   - rooms:"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "SELECT COUNT(*) FROM rooms;"

echo ""
echo "2. Insertion des données homepage_sections..."

# Insérer les sections de la page d'accueil
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
INSERT INTO homepage_sections (id, section_type, title, content, data, order_index, is_visible, is_active) 
VALUES 
('hero', 'hero', 'U SILENZIU', 'Votre zone de défoulement à Buros. Libérez votre stress et vos tensions dans un environnement sécurisé et fun.', '{\"subtitle\": \"Énergie positive garantie !\"}', 1, true, true),
('rooms', 'rooms', 'Nos Salles', 'Découvrez nos différentes salles de défoulement', '{}', 2, true, true),
('contact', 'contact', 'Contact', 'Contactez-nous pour réserver', '{}', 3, true, true)
ON CONFLICT (id) DO UPDATE SET 
    title = EXCLUDED.title,
    content = EXCLUDED.content,
    data = EXCLUDED.data,
    is_visible = EXCLUDED.is_visible,
    is_active = EXCLUDED.is_active;
"

echo ""
echo "3. Vérification des salles dans la table rooms..."

# Vérifier et ajouter les salles si nécessaire
room_count=$(docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -t -c "SELECT COUNT(*) FROM rooms;" 2>/dev/null | tr -d ' ')

if [ "$room_count" = "0" ]; then
    echo "   Ajout des salles..."
    docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
    INSERT INTO rooms (name, description, price, duration, max_people, objects_to_destroy, included, is_active) 
    VALUES 
    ('Salle Douce', 'Pour un défoulement en douceur', 50.00, 60, 4, ARRAY['Assiettes', 'Verres', 'Objets légers'], ARRAY['Équipements de protection', 'Nettoyage'], true),
    ('Salle Carnage', 'Pour un défoulement intense', 75.00, 60, 6, ARRAY['Électroménager', 'Meubles', 'Gros objets'], ARRAY['Équipements de protection', 'Nettoyage', 'Marteau'], true),
    ('Salle Privatisée', 'Salle privatisée pour groupes', 120.00, 90, 10, ARRAY['Choix personnalisé'], ARRAY['Équipements de protection', 'Nettoyage', 'Animation'], true)
    ON CONFLICT DO NOTHING;
    "
else
    echo "   Salles déjà présentes: $room_count"
fi

echo ""
echo "4. Vérification finale des données..."
echo "   - homepage_sections:"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "SELECT id, section_type, title FROM homepage_sections ORDER BY order_index;"

echo "   - rooms:"
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "SELECT name, description, price FROM rooms WHERE is_active = true;"

echo ""
echo "5. Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

echo ""
echo "6. Attente du démarrage (15 secondes)..."
sleep 15

echo ""
echo "7. Test de l'API homepage-sections..."
curl -s "https://rageroom.usilenziu.com/api/homepage-sections" | head -c 200
echo ""

echo ""
echo "8. Test de l'API rooms..."
curl -s "https://rageroom.usilenziu.com/api/rooms" | head -c 200
echo ""

echo ""
echo "✅ CORRECTION TERMINÉE !"
echo "🌐 Vérifiez maintenant : https://rageroom.usilenziu.com"
echo "   Les salles devraient maintenant s'afficher dans la section 'Nos Salles'"
