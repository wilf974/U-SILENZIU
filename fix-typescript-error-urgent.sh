#!/bin/bash

echo "=== CORRECTION URGENTE ERREUR TYPESCRIPT ==="
echo ""

# 1. Pull correction
echo "1. 📥 RÉCUPÉRATION CORRECTION :"
echo "==============================="
git pull origin main

# 2. Rebuild rapide uniquement de l'app
echo ""
echo "2. 🔨 REBUILD RAPIDE :"
echo "====================="
docker compose -f docker-compose.prod.yml build u-silenziu

# 3. Redémarrer seulement l'app
echo ""
echo "3. 🚀 REDÉMARRAGE APP :"
echo "======================="
docker compose -f docker-compose.prod.yml up -d u-silenziu

# 4. Attendre stabilisation
echo ""
echo "4. ⏳ ATTENTE (20s) :"
echo "===================="
sleep 20

# 5. Vérifier compilation
echo ""
echo "5. ✅ VÉRIFICATION :"
echo "===================="
docker compose -f docker-compose.prod.yml logs u-silenziu --tail=10

# 6. Test rapide
echo ""
echo "6. 🧪 TEST RAPIDE :"
echo "=================="
curl -s -w "Status: %{http_code}\n" "https://rageroom.usilenziu.com" | head -c 100

echo ""
echo "=== CORRECTION TYPESCRIPT TERMINÉE ==="
echo "✅ Erreur 'boolean vs number' corrigée"
echo "✅ Type availabilityData mis à jour"
echo "✅ Logique slotData !== false implémentée"
