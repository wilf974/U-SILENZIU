#!/bin/bash
# Script de diagnostic JavaScript en production
# U Silenziu - Septembre 2025

echo "🔍 DIAGNOSTIC JAVASCRIPT PRODUCTION"
echo "==================================="
echo ""

# 1. Vérifier les logs de l'application
echo "1. Logs récents de l'application..."
docker compose -f docker-compose.prod.yml logs --tail=20 u-silenziu

echo ""

# 2. Vérifier les erreurs dans les logs
echo "2. Recherche d'erreurs JavaScript..."
docker compose -f docker-compose.prod.yml logs u-silenziu | grep -i "error\|exception\|failed" | tail -10

echo ""

# 3. Vérifier la compilation Next.js
echo "3. Vérification de la compilation Next.js..."
docker exec u-silenziu-app ls -la /app/.next/static/chunks/ | head -10

echo ""

# 4. Tester l'API rooms directement
echo "4. Test API rooms depuis le conteneur..."
docker exec u-silenziu-app node -e "
const fetch = require('node-fetch');

async function testRoomsAPI() {
  try {
    console.log('🔄 Test API /api/rooms depuis le conteneur...');
    const response = await fetch('http://localhost:3000/api/rooms');
    console.log('📡 Status:', response.status, response.statusText);
    
    if (response.ok) {
      const data = await response.json();
      console.log('📦 Données reçues:', JSON.stringify(data, null, 2));
    } else {
      const errorText = await response.text();
      console.log('❌ Erreur:', errorText);
    }
  } catch (error) {
    console.log('❌ Erreur catch:', error.message);
  }
}

testRoomsAPI();
"

echo ""

# 5. Vérifier les variables d'environnement
echo "5. Variables d'environnement critiques..."
docker exec u-silenziu-app env | grep -E "(NODE_ENV|NEXT_PUBLIC|DATABASE_URL)" | sort

echo ""

# 6. Vérifier la structure des fichiers
echo "6. Vérification des composants..."
docker exec u-silenziu-app ls -la /app/components/ | grep -E "(Salles|Rooms|Test)"

echo ""

# 7. Test de rendu simple
echo "7. Test de rendu simple..."
docker exec u-silenziu-app node -e "
console.log('🔄 Test de rendu simple...');
try {
  const fs = require('fs');
  const sallesPath = '/app/components/Salles.tsx';
  if (fs.existsSync(sallesPath)) {
    console.log('✅ Fichier Salles.tsx existe');
    const content = fs.readFileSync(sallesPath, 'utf8');
    if (content.includes('TestSalles')) {
      console.log('✅ TestSalles trouvé dans Salles.tsx');
    } else {
      console.log('❌ TestSalles NON trouvé dans Salles.tsx');
    }
  } else {
    console.log('❌ Fichier Salles.tsx n\'existe pas');
  }
} catch (error) {
  console.log('❌ Erreur:', error.message);
}
"

echo ""

echo "✅ DIAGNOSTIC TERMINÉ !"
echo ""
echo "🔗 Vérifiez maintenant :"
echo "- Site: https://rageroom.usilenziu.com"
echo "- Console navigateur (F12) pour voir les erreurs JavaScript"
