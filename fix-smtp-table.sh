#!/bin/bash

# Script pour créer la table smtp_config manquante
# Corrige l'erreur "relation smtp_config does not exist"

echo "🔧 Création de la table smtp_config..."

# Obtenir l'ID du container PostgreSQL
PG_CONTAINER=$(docker compose -f docker-compose.prod.yml ps -q postgres)

if [ -z "$PG_CONTAINER" ]; then
    echo "❌ Erreur: Container PostgreSQL non trouvé"
    exit 1
fi

echo "✅ Container PostgreSQL trouvé: $PG_CONTAINER"

# Créer la table smtp_config
echo "📧 Création de la table smtp_config..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
CREATE TABLE IF NOT EXISTS smtp_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    host VARCHAR(255) NOT NULL,
    port INTEGER NOT NULL DEFAULT 587,
    secure BOOLEAN DEFAULT false,
    username VARCHAR(255) NOT NULL,
    password_encrypted VARCHAR(500) NOT NULL,
    from_email VARCHAR(255) NOT NULL,
    tls_reject_unauthorized BOOLEAN DEFAULT true,
    tls_min_version VARCHAR(20) DEFAULT 'TLSv1.2',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Créer un index pour les performances
CREATE INDEX IF NOT EXISTS idx_smtp_config_active ON smtp_config(is_active);
EOF

# Créer également la table legal_pages si elle n'existe pas
echo "📄 Création de la table legal_pages..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
CREATE TABLE IF NOT EXISTS legal_pages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(100) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insérer les pages légales par défaut
INSERT INTO legal_pages (slug, title, content, is_active) VALUES 
('mentions-legales', 'Mentions Légales', 'Contenu des mentions légales à définir.', true),
('politique-confidentialite', 'Politique de Confidentialité', 'Contenu de la politique de confidentialité à définir.', true),
('cgv', 'Conditions Générales de Vente', 'Contenu des CGV à définir.', true),
('cgu', 'Conditions Générales d''Utilisation', 'Contenu des CGU à définir.', true)
ON CONFLICT (slug) DO NOTHING;
EOF

# Vérifier que les tables ont été créées
echo "✅ Vérification des tables créées..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio << 'EOF'
-- Lister les tables
SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename IN ('smtp_config', 'legal_pages');

-- Vérifier la structure de smtp_config
\d smtp_config
EOF

echo ""
echo "✅ Tables SMTP et Legal Pages créées avec succès !"
echo ""
echo "📧 Tu peux maintenant configurer le SMTP dans l'admin."
echo "📄 Les pages légales par défaut ont été ajoutées."
