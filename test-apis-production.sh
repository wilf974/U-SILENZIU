#!/bin/bash
# Test des APIs en production
# U Silenziu - Septembre 2025

echo "🔍 TEST DES APIS EN PRODUCTION"
echo "=============================="
echo ""

# Test de chaque API individuellement
APIS=("header-config" "footer-config" "homepage-sections" "legal-pages" "global-sections")

for api in "${APIS[@]}"; do
    echo "Test API: $api"
    echo "URL: https://rageroom.usilenziu.com/api/$api"
    
    # Test avec curl et affichage de la réponse
    response=$(curl -s -w "\nHTTP_CODE:%{http_code}" "https://rageroom.usilenziu.com/api/$api")
    http_code=$(echo "$response" | grep "HTTP_CODE:" | cut -d: -f2)
    body=$(echo "$response" | grep -v "HTTP_CODE:")
    
    echo "Code HTTP: $http_code"
    echo "Réponse: $body"
    echo "---"
done

echo ""
echo "🔍 Test de connexion base de données depuis l'application..."
docker exec u-silenziu-app node -e "
const { Pool } = require('pg');
const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

async function testDB() {
  try {
    const client = await pool.connect();
    console.log('✅ Connexion DB réussie');
    
    // Test des tables
    const tables = ['header_config', 'footer_config', 'homepage_sections', 'legal_pages', 'global_sections'];
    for (const table of tables) {
      try {
        const result = await client.query(\`SELECT COUNT(*) FROM \${table}\`);
        console.log(\`✅ Table \${table}: \${result.rows[0].count} enregistrements\`);
      } catch (err) {
        console.log(\`❌ Table \${table}: \${err.message}\`);
      }
    }
    
    client.release();
  } catch (err) {
    console.log('❌ Erreur connexion DB:', err.message);
  }
  process.exit(0);
}

testDB();
"

echo ""
echo "🔍 Logs récents de l'application..."
docker compose -f docker-compose.prod.yml logs --tail=10 u-silenziu
