#!/bin/bash
# Script pour créer la table homepage_config
# U Silenziu - Septembre 2025

echo "🔧 CRÉATION TABLE HOMEPAGE_CONFIG"
echo "================================="
echo ""

# 1. Créer la table homepage_config
echo "1. Création de la table homepage_config..."

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

# 2. Insérer une configuration par défaut
echo "2. Insertion de la configuration par défaut..."

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

# 3. Vérifier la création
echo "3. Vérification de la table..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
SELECT id, site_title, site_name, is_active, created_at 
FROM homepage_config 
ORDER BY created_at DESC;
"

echo ""

# 4. Redémarrer l'application
echo "4. Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

echo "Attente du démarrage (15 secondes)..."
sleep 15

echo ""

# 5. Test de l'API
echo "5. Test de l'API homepage-config..."
echo "Test API /api/admin/homepage-config :"
curl -s "https://rageroom.usilenziu.com/api/admin/homepage-config" \
  -w "\nHTTP_CODE:%{http_code}\n" | head -c 500

echo ""

echo "✅ TABLE HOMEPAGE_CONFIG CRÉÉE AVEC SUCCÈS !"
