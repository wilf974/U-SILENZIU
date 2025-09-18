#!/bin/bash

# Script d'initialisation de la base de données pour le VPS
# À exécuter dans le répertoire du projet avec docker-compose.prod.yml

echo "🚀 Initialisation de la base de données PostgreSQL pour le VPS..."

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "docker-compose.prod.yml" ]; then
    echo "❌ Erreur: docker-compose.prod.yml non trouvé"
    echo "Veuillez exécuter ce script depuis le répertoire du projet"
    exit 1
fi

# Vérifier les containers
echo "📋 Vérification des containers..."
docker compose -f docker-compose.prod.yml ps

# Obtenir l'ID du container PostgreSQL
echo "🔍 Récupération de l'ID du container PostgreSQL..."
PG_CONTAINER=$(docker compose -f docker-compose.prod.yml ps -q postgres)

if [ -z "$PG_CONTAINER" ]; then
    echo "❌ Erreur: Container PostgreSQL non trouvé"
    echo "Vérifiez que les containers sont démarrés avec:"
    echo "docker compose -f docker-compose.prod.yml up -d"
    exit 1
fi

echo "✅ Container PostgreSQL trouvé: $PG_CONTAINER"

# Créer les extensions nécessaires
echo "🔧 Création des extensions PostgreSQL..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;" || echo "⚠️ Extension pgcrypto déjà présente"
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";" || echo "⚠️ Extension uuid-ossp déjà présente"

# Vérifier que les fichiers SQL existent
SQL_FILES=(
    "init-db.sql"
    "create-header-config-table.sql"
    "create-footer-config-table.sql"
    "create-homepage-sections-table.sql"
    "create-global-sections-table.sql"
    "create-homepage-config-table.sql"
    "create-admin-users-table.sql"
)

echo "📁 Vérification des fichiers SQL..."
for file in "${SQL_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Erreur: Fichier $file non trouvé"
        exit 1
    fi
    echo "✅ $file trouvé"
done

# Initialiser les tables dans l'ordre
echo "🗄️ Initialisation des tables..."

echo "  📋 Exécution de init-db.sql..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio < init-db.sql

echo "  🏠 Création de la table header_config..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio < create-header-config-table.sql

echo "  🦶 Création de la table footer_config..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio < create-footer-config-table.sql

echo "  📄 Création de la table homepage_sections..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio < create-homepage-sections-table.sql

echo "  🌐 Création de la table global_sections..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio < create-global-sections-table.sql

echo "  ⚙️ Création de la table homepage_config..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio < create-homepage-config-table.sql

echo "  👤 Création de la table admin_users..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio < create-admin-users-table.sql

# Vérifier que les tables ont été créées
echo "🔍 Vérification des tables créées..."
docker exec -i $PG_CONTAINER psql -U usilenzio_user -d usilenzio -c "\dt" | grep -E "(header_config|footer_config|homepage_sections|admin_users)"

# Redémarrer l'application
echo "🔄 Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

# Attendre quelques secondes pour le redémarrage
echo "⏳ Attente du redémarrage (5 secondes)..."
sleep 5

# Vérifier le statut des containers
echo "📊 Statut final des containers..."
docker compose -f docker-compose.prod.yml ps

echo ""
echo "✅ Initialisation terminée !"
echo ""
echo "🌐 Testez votre site: http://VOTRE_IP:3000"
echo "🔐 Admin: http://VOTRE_IP:3000/admin"
echo "   👤 Utilisateur: administrateur"
echo "   🔑 Mot de passe: MotDePasse123!"
echo ""
echo "📋 Si des erreurs persistent, consultez les logs:"
echo "   docker compose -f docker-compose.prod.yml logs --tail=50 u-silenziu"
