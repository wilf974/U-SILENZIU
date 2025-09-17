#!/bin/bash

# Script de déploiement simple pour VPS
set -e

echo "🚀 Déploiement de U Silenziu sur VPS..."

# Vérifier si on est dans le bon répertoire
if [ ! -f "package.json" ]; then
    echo "❌ Erreur: Ce script doit être exécuté dans le répertoire du projet"
    exit 1
fi

# Arrêter les conteneurs existants
echo "🛑 Arrêt des conteneurs existants..."
docker compose down || true

# Nettoyer les images inutilisées
echo "🧹 Nettoyage des images Docker..."
docker system prune -f

# Construire et démarrer les conteneurs
echo "🔨 Construction et démarrage des conteneurs..."
docker compose up -d --build

# Attendre que la base de données soit prête
echo "⏳ Attente de la base de données..."
sleep 30

# Vérifier le statut des conteneurs
echo "📊 Statut des conteneurs:"
docker compose ps

# Configuration de l'utilisateur admin
echo "👤 Configuration de l'utilisateur administrateur..."
docker exec u-silenziu-postgres psql -U usilenzio_user -d usilenzio -c "
INSERT INTO admin_users (username, password_hash, role) 
VALUES ('administrateur', '\$2a\$10\$I2QGTSQhxlwflsXseiUbH.E2wXgj2T20Y.LKqj0MDSDtuDJCUrO56', 'super-admin')
ON CONFLICT (username) DO UPDATE SET 
    password_hash = EXCLUDED.password_hash,
    role = EXCLUDED.role,
    updated_at = CURRENT_TIMESTAMP;
" || echo "⚠️  L'utilisateur admin existe peut-être déjà"

echo "✅ Déploiement terminé !"
echo "🌐 Application accessible sur: http://localhost:3000"
echo "🔐 Admin: http://localhost:3000/admin/login"
echo "   Utilisateur: administrateur"
echo "   Mot de passe: @dm1n1str@t3uR!)"
