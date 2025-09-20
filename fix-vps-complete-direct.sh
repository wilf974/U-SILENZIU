#!/bin/bash
# Script de correction complète pour le VPS
# U Silenziu - Septembre 2025

echo "🔧 CORRECTION COMPLÈTE VPS"
echo "=========================="
echo ""

# 1. Récupérer les dernières corrections
echo "1. Récupération des dernières corrections..."
git pull origin main

echo ""

# 2. Créer la table homepage_config
echo "2. Création de la table homepage_config..."

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
CREATE TABLE IF NOT EXISTS homepage_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_title VARCHAR(255) NOT NULL DEFAULT 'U SILENZIU',
    site_description TEXT,
    site_name VARCHAR(255) NOT NULL DEFAULT 'U SILENZIU',
    contact_email VARCHAR(255),
    contact_phone VARCHAR(50),
    address TEXT,
    opening_hours TEXT,
    seo_keywords TEXT,
    seo_description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
"

echo ""

# 3. Insérer une configuration par défaut
echo "3. Insertion de la configuration par défaut..."

docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
INSERT INTO homepage_config (
    site_title, site_description, site_name,
    contact_email, contact_phone, address,
    opening_hours, seo_keywords, seo_description,
    is_active
) VALUES (
    'U SILENZIU',
    'Votre zone de défoulement à Buros. Libérez votre stress et vos tensions dans un environnement sécurisé et fun.',
    'U SILENZIU',
    'contact@usilenziu.com',
    '05 59 12 34 56',
    '123 Rue de la Libération, 64400 Buros',
    'Mardi au Jeudi: 14:00 - 21:00\nVendredi au Samedi: 14:00 - 00:00\nDimanche: Sur réservation uniquement',
    'défoulement, stress, rage room, Buros, relaxation',
    'U Silenziu - Zone de défoulement à Buros. Libérez votre stress dans nos salles sécurisées.',
    true
) ON CONFLICT DO NOTHING;
"

echo ""

# 4. Ajouter les sections manquantes avec SQL corrigé
echo "4. Ajout des sections manquantes..."

echo "Ajout de la section 'Comment fonctionne une séance ?'..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
INSERT INTO homepage_sections (id, section_type, title, content, data, order_index, is_visible, is_active) 
VALUES (
    'comment-ca-marche', 
    'comment-ca-marche', 
    'Comment fonctionne une séance ?', 
    'Découvrez le déroulement type d''une session chez U Silenziu. Chaque étape est pensée pour votre sécurité et votre plaisir.',
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
    'Trouvez les réponses aux questions les plus fréquentes sur l''expérience U Silenziu.',
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

# 5. Vérifier les sections
echo "5. Vérification des sections..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, section_type, title, order_index, is_active, is_visible
FROM homepage_sections 
ORDER BY order_index;
"

echo ""

# 6. Redémarrer l'application
echo "6. Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

echo "Attente du démarrage (20 secondes)..."
sleep 20

echo ""

# 7. Test des APIs critiques
echo "7. Test des APIs critiques..."

echo "Test API /api/admin/homepage-config :"
curl -s "https://rageroom.usilenziu.com/api/admin/homepage-config" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 300

echo ""

echo "Test API /api/homepage-sections :"
curl -s "https://rageroom.usilenziu.com/api/homepage-sections" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 300

echo ""

echo "Test API /api/rooms :"
curl -s "https://rageroom.usilenziu.com/api/rooms" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 300

echo ""

# 8. Vérification des logs
echo "8. Vérification des logs récents..."
docker compose -f docker-compose.prod.yml logs --tail=10 u-silenziu

echo ""

echo "✅ CORRECTION COMPLÈTE TERMINÉE !"
echo ""
echo "🔗 Vérifiez maintenant :"
echo "- Site public: https://rageroom.usilenziu.com"
echo "- Admin: https://rageroom.usilenziu.com/admin"
echo ""
echo "📱 Ouvrez la console du navigateur (F12) pour voir les logs de débogage"
