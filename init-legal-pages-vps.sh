#!/bin/bash

echo "📄 INITIALISATION DES PAGES LÉGALES DANS LA BASE DE DONNÉES"
echo "=========================================================="

# 1. Vérifier la connexion à la base de données
echo "1. Vérification de la connexion à la base de données..."
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "SELECT version();" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "❌ Erreur de connexion à la base de données"
    exit 1
fi

echo "✅ Connexion à la base de données réussie"

# 2. Exécuter le script SQL d'initialisation
echo "2. Exécution du script d'initialisation des pages légales..."
docker compose -f docker-compose.prod.yml exec -T postgres psql -U usilenzio_user -d usilenzio < init-legal-pages-database.sql

if [ $? -eq 0 ]; then
    echo "✅ Pages légales initialisées avec succès"
else
    echo "❌ Erreur lors de l'initialisation des pages légales"
    exit 1
fi

# 3. Vérifier les données insérées
echo "3. Vérification des pages légales créées..."
docker compose -f docker-compose.prod.yml exec postgres psql -U usilenzio_user -d usilenzio -c "
SELECT 
    page_type,
    title,
    is_published,
    last_updated_by,
    created_at
FROM legal_pages 
ORDER BY page_type;"

# 4. Redémarrer l'application pour prendre en compte les changements
echo "4. Redémarrage de l'application..."
docker compose -f docker-compose.prod.yml restart u-silenziu

# 5. Attendre le démarrage
echo "5. Attente du démarrage (30 secondes)..."
sleep 30

# 6. Test des pages légales
echo "6. Test des pages légales..."
echo ""

echo "🧪 Test de la page CGV..."
response_cgv=$(curl -s -o /dev/null -w "%{http_code}" "https://rageroom.usilenziu.com/legal/cgv")
if [ "$response_cgv" = "200" ]; then
    echo "✅ Page CGV accessible (HTTP $response_cgv)"
else
    echo "❌ Page CGV non accessible (HTTP $response_cgv)"
fi

echo "🧪 Test de la page Mentions Légales..."
response_legal=$(curl -s -o /dev/null -w "%{http_code}" "https://rageroom.usilenziu.com/legal/mentions-legales")
if [ "$response_legal" = "200" ]; then
    echo "✅ Page Mentions Légales accessible (HTTP $response_legal)"
else
    echo "❌ Page Mentions Légales non accessible (HTTP $response_legal)"
fi

echo "🧪 Test de la page Politique de Confidentialité..."
response_privacy=$(curl -s -o /dev/null -w "%{http_code}" "https://rageroom.usilenziu.com/legal/politique-confidentialite")
if [ "$response_privacy" = "200" ]; then
    echo "✅ Page Politique de Confidentialité accessible (HTTP $response_privacy)"
else
    echo "❌ Page Politique de Confidentialité non accessible (HTTP $response_privacy)"
fi

echo ""
echo "🎉 INITIALISATION TERMINÉE !"
echo ""
echo "📋 Pages légales disponibles :"
echo "   • CGV : https://rageroom.usilenziu.com/legal/cgv"
echo "   • Mentions Légales : https://rageroom.usilenziu.com/legal/mentions-legales"
echo "   • Politique de Confidentialité : https://rageroom.usilenziu.com/legal/politique-confidentialite"
echo ""
echo "🔧 Interface d'administration :"
echo "   • Gestion des pages légales : https://rageroom.usilenziu.com/admin/legal-pages"
echo ""
echo "✅ Les pages légales sont maintenant synchronisées avec l'interface d'administration !"
