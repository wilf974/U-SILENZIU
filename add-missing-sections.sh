#!/bin/bash
# Script pour ajouter les sections manquantes
# U Silenziu - Septembre 2025

echo "🔧 AJOUT DES SECTIONS MANQUANTES"
echo "==============================="
echo ""

# 1. Ajouter les sections manquantes
echo "1. Ajout des sections manquantes..."
echo "Ajout de la section 'Comment fonctionne une séance ?'..."

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
INSERT INTO homepage_sections (id, section_type, title, content, data, order_index, is_visible, is_active) 
VALUES (
    'comment-ca-marche', 
    'comment-ca-marche', 
    'Comment fonctionne une séance ?', 
    'Découvrez le déroulement type d\'une session chez U Silenziu. Chaque étape est pensée pour votre sécurité et votre plaisir.',
    '{}', 
    4, 
    true, 
    true
) ON CONFLICT (id) DO UPDATE SET 
    title = EXCLUDED.title,
    content = EXCLUDED.content,
    is_visible = EXCLUDED.is_visible,
    is_active = EXCLUDED.is_active;
"

echo "Ajout de la section 'FAQ'..."

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
INSERT INTO homepage_sections (id, section_type, title, content, data, order_index, is_visible, is_active) 
VALUES (
    'faq', 
    'faq', 
    'Foire aux Questions', 
    'Trouvez les réponses aux questions les plus fréquentes sur l\'expérience U Silenziu.',
    '{}', 
    5, 
    true, 
    true
) ON CONFLICT (id) DO UPDATE SET 
    title = EXCLUDED.title,
    content = EXCLUDED.content,
    is_visible = EXCLUDED.is_visible,
    is_active = EXCLUDED.is_active;
"

echo ""

# 2. Vérifier les sections ajoutées
echo "2. Vérification des sections ajoutées..."
echo "Sections homepage actuelles :"

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, section_type, title, order_index, is_active, is_visible
FROM homepage_sections 
ORDER BY order_index;
"

echo ""

# 3. Redémarrer l'application
echo "3. Redémarrage de l'application..."
echo "Redémarrage du conteneur application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

echo "Attente du démarrage (15 secondes)..."
sleep 15

echo ""

# 4. Test des APIs
echo "4. Test des APIs..."
echo "Test API /api/homepage-sections :"
curl -s "https://rageroom.usilenziu.com/api/homepage-sections" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 500

echo ""

echo "Test API /api/rooms :"
curl -s "https://rageroom.usilenziu.com/api/rooms" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 300

echo ""

# 5. Instructions de vérification
echo "5. INSTRUCTIONS DE VÉRIFICATION"
echo "==============================="
echo ""
echo "🔗 Vérifiez maintenant :"
echo "- Site public: https://rageroom.usilenziu.com"
echo "- Admin: https://rageroom.usilenziu.com/admin"
echo ""
echo "📱 Ouvrez la console du navigateur (F12) pour voir les logs de débogage des salles"
echo ""
echo "✅ SECTIONS AJOUTÉES !"
