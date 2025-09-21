#!/bin/bash
set -euo pipefail

APP_CONTAINER="u-silenziu-app"
DB_CONTAINER="u-silenziu-postgres"
DB_USER="usilenzio_user"
DB_NAME="usilenzio"

echo "🔍 ANALYSE COMPLÈTE REACT ERROR #31 - U SILENZIU"
echo "================================================"

# 1. État général du système
echo ""
echo "📊 1. ÉTAT GÉNÉRAL DU SYSTÈME"
echo "=============================="
echo "Date et heure : $(date)"
echo "Uptime : $(uptime)"
echo "Mémoire disponible : $(free -h | awk '/^Mem/ {print $7}')"
echo "Espace disque (/) : $(df -h / | awk 'NR==2 {print $4}')"

# 2. Conteneurs Docker
echo ""
echo "📋 2. ÉTAT DES CONTENEURS DOCKER"
echo "================================"
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 3. Logs de l'application
echo ""
echo "📄 3. LOGS DE L'APPLICATION (DERNIÈRES 100 LIGNES)"
echo "=================================================="
docker logs "$APP_CONTAINER" --tail 100 || echo "Impossible de lire les logs"

# 4. Recherche d'erreurs ciblées
echo ""
echo "🔍 4. RECHERCHE D'ERREURS SPÉCIFIQUES"
echo "===================================="
echo "Erreurs React :"
docker logs "$APP_CONTAINER" 2>&1 | grep -iE "react|error|exception" | tail -20 || echo "Aucune erreur React trouvée"

echo ""
echo "Erreurs Next.js :"
docker logs "$APP_CONTAINER" 2>&1 | grep -iE "nextjs|next" | tail -10 || echo "Aucune erreur Next.js trouvée"

echo ""
echo "Erreurs de build :"
docker logs "$APP_CONTAINER" 2>&1 | grep -iE "build|compile" | tail -10 || echo "Aucune erreur de build trouvée"

# 5. Versions et dépendances
echo ""
echo "🔧 5. VÉRIFICATION DES VERSIONS ET DÉPENDANCES"
echo "============================================="
echo "Version Node.js :"
docker exec "$APP_CONTAINER" node -v || echo "Impossible de récupérer Node.js"

echo ""
echo "Version Next.js :"
docker exec "$APP_CONTAINER" npm ls next || echo "Impossible de récupérer Next.js"

echo ""
echo "Versions React :"
docker exec "$APP_CONTAINER" npm ls react react-dom || echo "Impossible de récupérer React/ReactDOM"

# 6. Vérification base de données
echo ""
echo "📊 6. VÉRIFICATION DE LA BASE DE DONNÉES"
echo "======================================="
docker exec "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1 AS connection_test;" || echo "Connexion PostgreSQL échouée"

echo ""
echo "Données homepage_sections :"
docker exec "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "
SELECT
    id,
    section_name,
    content,
    CASE
        WHEN jsonb_typeof(content->'title') = 'string' THEN 'Contient title'
        ELSE 'Anomalie'
    END AS content_type
FROM homepage_sections
ORDER BY created_at DESC;
" || echo "Lecture homepage_sections échouée"

# 7. Analyse JSON détaillée
echo ""
echo "🔍 7. ANALYSE DES DONNÉES JSON"
echo "=============================="
docker exec "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "
SELECT
    id,
    section_name,
    content->>'title' AS title_value,
    content->>'subtitle' AS subtitle_value,
    jsonb_typeof(content->'title') AS title_type,
    jsonb_typeof(content->'subtitle') AS subtitle_type
FROM homepage_sections
ORDER BY created_at DESC;
" || echo "Analyse JSON échouée"

# 8. Tests de connectivité
echo ""
echo "🌐 8. TEST DE CONNECTIVITÉ"
echo "========================="
echo "Test HTTPS :"
curl -skI https://rageroom.usilenziu.com | head -n 10 || echo "Test HTTPS échoué"

echo ""
echo "Test HTTP (redirection) :"
curl -sI http://rageroom.usilenziu.com | head -n 10 || echo "Test HTTP échoué"

echo ""
echo "Test API publique :"
curl -s https://rageroom.usilenziu.com/api/rooms || echo "Test API échoué"

# 9. Logs persistants pour support
echo ""
echo "🗃️ 9. ARCHIVAGE DES LOGS (optionnel)"
echo "===================================="
LOG_ARCHIVE="/tmp/u-silenziu-diagnostic-$(date +%Y%m%d%H%M%S).tar.gz"
docker logs "$APP_CONTAINER" > /tmp/u-silenziu-app.log 2>&1 || true
tar -czf "$LOG_ARCHIVE" /tmp/u-silenziu-app.log 2>/dev/null && echo "Logs archivés : $LOG_ARCHIVE" || echo "Archivage non réalisé"

echo ""
echo "✅ ANALYSE TERMINÉE"
echo "==================="
echo "Si l'erreur React #31 persiste, inspecte les logs ci-dessus et les composants Next.js incriminés."
